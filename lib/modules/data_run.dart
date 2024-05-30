library d2_remote;

import 'package:d2_remote/core/database/database_manager.dart';
import 'package:d2_remote/modules/activity/d_activity.module.dart';
import 'package:d2_remote/modules/assignment/d_assignment.module.dart';
import 'package:d2_remote/modules/auth/user/d_user.module.dart';
import 'package:d2_remote/modules/auth/user/entities/d_user.entity.dart';
import 'package:d2_remote/modules/auth/user/models/auth-token.model.dart';
import 'package:d2_remote/modules/auth/user/models/login-response.model.dart';
import 'package:d2_remote/modules/auth/user/queries/d_user.query.dart';
import 'package:d2_remote/modules/iccm/iccm.module.dart';
import 'package:d2_remote/modules/itns/itns.module.dart';
import 'package:d2_remote/modules/project/d_project.module.dart';
import 'package:d2_remote/modules/teams/d_team.module.dart';
import 'package:d2_remote/modules/village_location/d_organisation_unit.module.dart';
import 'package:d2_remote/modules/warehouse/warehouse.module.dart';
import 'package:d2_remote/shared/utilities/http_client.util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DRun {
  static Future<void> initialize(
      {String? databaseName,
      bool? inMemory,
      DatabaseFactory? databaseFactory}) async {
    final newDatabaseName = databaseName ?? await DRun.getDatabaseName();
    if (newDatabaseName != null) {
      DatabaseManager(
          databaseName: newDatabaseName,
          inMemory: inMemory,
          databaseFactory: databaseFactory);

      await DatabaseManager.instance.database;
      await DUserModule.createTables();
      await WarehouseModule.createTables();
      await DOrganisationUnitModule.createTables();
      await DProjectModule.createTables();
      await DActivityModule.createTables();
      await DTeamModule.createTables();
      await DAssignmentModule.createTables();
      await ItnsVillageModule.createTables();
      await IccmModule.createTables();
    }
  }

  static Future<bool> isAuthenticated(
      {Future<SharedPreferences>? sharedPreferenceInstance,
      bool? inMemory,
      DatabaseFactory? databaseFactory}) async {
    WidgetsFlutterBinding.ensureInitialized();
    final databaseName = await DRun.getDatabaseName(
        sharedPreferenceInstance: sharedPreferenceInstance);

    if (databaseName == null) {
      return false;
    }

    await DRun.initialize(
        databaseName: databaseName,
        inMemory: inMemory,
        databaseFactory: databaseFactory);

    DUser? user = await DRun.userModule.user.getOne();

    return user?.isLoggedIn ?? false;
  }

  static Future<String?> getDatabaseName(
      {Future<SharedPreferences>? sharedPreferenceInstance}) async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs =
        await (sharedPreferenceInstance ?? SharedPreferences.getInstance());
    return prefs.getString('databaseName');
  }

  static Future<bool> setDatabaseName(
      {required String databaseName,
      Future<SharedPreferences>? sharedPreferenceInstance}) async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs =
        await (sharedPreferenceInstance ?? SharedPreferences.getInstance());
    return prefs.setString('databaseName', databaseName);
  }

  static Future<LoginResponseStatus> logIn(
      {required String username,
      required String password,
      required String url,
      Future<SharedPreferences>? sharedPreferenceInstance,
      bool? inMemory,
      DatabaseFactory? databaseFactory,
      Dio? dioTestClient}) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Data-Run
    HttpResponse tokenResponse = await HttpClient.get('authenticate',
        baseUrl: url,
        username: username,
        password: password,
        dioTestClient: dioTestClient);

    if (tokenResponse.statusCode == 401) {
      return LoginResponseStatus.WRONG_CREDENTIALS;
    }

    if (tokenResponse.statusCode == 500) {
      return LoginResponseStatus.SERVER_ERROR;
    }

    HttpResponse userResponse = await HttpClient.get('account',
        baseUrl: url,
        username: username,
        password: password,
        dioTestClient: dioTestClient);

    final uri = Uri.parse(url).host;
    final String databaseName = '${username}_$uri';

    await DRun.initialize(
        databaseName: databaseName,
        inMemory: inMemory,
        databaseFactory: databaseFactory);

    await DRun.setDatabaseName(
        databaseName: databaseName,
        sharedPreferenceInstance:
            sharedPreferenceInstance ?? SharedPreferences.getInstance());

    DUserQuery userQuery = DUserQuery();

    Map<String, dynamic> userData = userResponse.body;
    userData['password'] = password;
    userData['isLoggedIn'] = true;
    userData['username'] = username;
    userData['baseUrl'] = url;
    userData['authTye'] = 'basic';
    userData['dirty'] = true;
    // Data-Run
    userData['token'] = tokenResponse.body['id_token'];

    final user = DUser.fromApi(userData);
    await userQuery.setData(user).save();

    // await DUserOrganisationUnitQuery().setData(user.organisationUnits).save();

    // await DUserTeamQuery().setData(user.teams).save();

    return LoginResponseStatus.ONLINE_LOGIN_SUCCESS;
  }

  static Future<bool> logOut() async {
    WidgetsFlutterBinding.ensureInitialized();
    bool logOutSuccess = false;
    try {
      DUser? currentUser = await DRun.userModule.user.getOne();

      currentUser?.isLoggedIn = false;
      currentUser?.dirty = true;

      await DRun.userModule.user.setData(currentUser).save();

      logOutSuccess = true;
    } catch (e) {}
    return logOutSuccess;
  }

  static Future<LoginResponseStatus> setToken(
      {required String instanceUrl,
      required Map<String, dynamic> userObject,
      required Map<String, dynamic> tokenObject,
      Future<SharedPreferences>? sharedPreferenceInstance,
      bool? inMemory,
      DatabaseFactory? databaseFactory,
      Dio? dioTestClient}) async {
    final uri = Uri.parse(instanceUrl).host;
    final String databaseName = '$uri';
    await DRun.initialize(
        databaseName: databaseName,
        inMemory: inMemory,
        databaseFactory: databaseFactory);

    await DRun.setDatabaseName(
        databaseName: databaseName,
        sharedPreferenceInstance:
            sharedPreferenceInstance ?? SharedPreferences.getInstance());

    AuthToken token = AuthToken.fromJson(tokenObject);

    List<dynamic> authorities = [];

    // userObject['userRoles'].forEach((role) {
    //   List<dynamic> authoritiesToAdd = role["authorities"].map((auth) {
    //     return auth as String;
    //   }).toList();
    //
    //   authorities.addAll(authoritiesToAdd);
    // });

    userObject['token'] = token.accessToken;
    userObject['tokenType'] = token.tokenType;
    userObject['tokenExpiry'] = token.expiresIn;
    userObject['refreshToken'] = token.refreshToken;
    userObject['isLoggedIn'] = true;
    userObject['dirty'] = true;
    userObject['baseUrl'] = instanceUrl;
    userObject['authType'] = "token";
    userObject['authorities'] = authorities;

    final user = DUser.fromApi(userObject);
    await DUserQuery().setData(user).save();

    return LoginResponseStatus.ONLINE_LOGIN_SUCCESS;
  }

  static Future<List<Map>> rawQuery(
      {required String query, required List args}) async {
    final Database db = await DatabaseManager.instance.database;

    final List<Map> queryResult = await db.rawQuery(query.toString(), args);

    return queryResult;
  }

  static DUserModule userModule = DUserModule();

  static WarehouseModule warehouseModule = WarehouseModule();

  static DOrganisationUnitModule organisationUnitModule =
      DOrganisationUnitModule();

  static DProjectModule projectModule = DProjectModule();

  static DActivityModule activityModule = DActivityModule();

  static DAssignmentModule assignmentModule = DAssignmentModule();

  static DTeamModule teamModule = DTeamModule();

  static ItnsVillageModule itnsVillageModule = ItnsVillageModule();

  static IccmModule iccmModule = IccmModule();
}