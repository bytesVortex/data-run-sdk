import 'dart:convert';

import 'package:d2_remote/core/annotations/column.annotation.dart';
import 'package:d2_remote/core/annotations/entity.annotation.dart';
import 'package:d2_remote/core/annotations/reflectable.annotation.dart';
import 'package:d2_remote/shared/entities/identifiable.entity.dart';

@AnnotationReflectable
@Entity(tableName: 'organisationunit', apiResourceName: 'organisationUnits')
class OrganisationUnit extends IdentifiableEntity {
  @Column(type: ColumnType.INTEGER)
  int? level;

  @Column()
  String path;

  @Column(nullable: true)
  bool? externalAccess;

  @Column()
  String openingDate;

  @Column(nullable: true)
  Object? geometry;

  @Column(name: 'parent', nullable: true)
  Object? parent;

  // NMC
  @Column(nullable: true)
  String? ancestors;

  @Column(nullable: true)
  String? closedDate;

  @Column(nullable: true)
  String? programs;
  //

  OrganisationUnit(
      {required String id,
      String? created,
      String? lastUpdated,
      required String name,
      required String? shortName,
      String? code,
      String? displayName,
      required this.level,
      required this.path,
      this.externalAccess,
      required this.openingDate,
      this.parent,
      this.geometry,
      this.ancestors,
      this.closedDate,
      this.programs,
      required dirty})
      : super(
            uid: id,
            name: name,
            shortName: shortName,
            displayName: displayName,
            code: code,
            createdDate: created,
            lastModifiedDate: lastUpdated,
            dirty: dirty);

  factory OrganisationUnit.fromJson(Map<String, dynamic> json) {
    final parent = json['parent'];

    final jsonEncoder = JsonEncoder();
    final ancestors = jsonEncoder.convert(json['ancestors'] ?? []);
    final progs = json['programs'];
    String? programs;
    if(progs is List) {
      programs = jsonEncoder.convert(progs.map((p) => p['id']).toList());
    }

    return OrganisationUnit(
        id: json['id'],
        name: json['name'],
        level: json['level'],
        created: json['created'],
        shortName: json['shortName'],
        code: json['code'],
        path: json['path'],
        displayName: json['displayName'],
        externalAccess: json['externalAccess'],
        openingDate: json['openingDate'],
        dirty: json['dirty'] ?? false,
        geometry: json['geometry']?.toString() ?? null,
        parent: parent != null
            ? parent is String
                ? parent
                : parent['id'] ?? parent
            : null,
        ancestors: ancestors,
        programs: programs,
        closedDate: json['closedDate']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lastModifiedDate'] = this.lastModifiedDate;
    data['id'] = this.id;
    data['uid'] = this.id;
    data['level'] = this.level;
    data['created'] = this.createdDate;
    data['name'] = this.name;
    data['shortName'] = this.shortName;
    data['code'] = this.code;
    data['path'] = this.path;
    data['displayName'] = this.displayName;
    data['externalAccess'] = this.externalAccess;
    data['openingDate'] = this.openingDate;
    data['dirty'] = this.dirty;
    data['geometry'] = this.geometry;
    data['ancestors'] = this.ancestors;
    data['closedDate'] = this.closedDate;
    data['programs'] = this.programs;
    if (this.parent != null) {
      data['parent'] = this.parent;
    }

    return data;
  }
}
