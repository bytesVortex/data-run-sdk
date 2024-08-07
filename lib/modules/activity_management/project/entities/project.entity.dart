import 'package:d2_remote/core/annotations/index.dart';
import 'package:d2_remote/modules/activity_management/activity/entities/activity.entity.dart';
import 'package:d2_remote/shared/entities/identifiable.entity.dart';

@AnnotationReflectable
@Entity(tableName: 'project', apiResourceName: 'old-projects')
class Project extends IdentifiableEntity {
  @OneToMany(table: Activity)
  List<Activity>? activities;

  Project(
      {required String id,
      String? uid,
      String? createdDate,
      String? lastModifiedDate,
      required String name,
      required String shortName,
      String? code,
      String? displayName,
      this.activities,
      required dirty})
      : super(
            id: id,
            uid: uid,
            name: name,
            shortName: shortName,
            displayName: displayName,
            code: code,
            createdDate: createdDate,
            lastModifiedDate: lastModifiedDate,
            dirty: dirty);

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
        id: json['id'],
        uid: json['uid'],
        name: json['name'],
        createdDate: json['createdDate'],
        shortName: json['shortName'],
        code: json['code'],
        displayName: json['displayName'],
        activities: List<dynamic>.from(json['activities'] ?? [])
            .map((activity) => Activity.fromJson(
                {...activity, 'project': json['uid'], 'dirty': false}))
            .toList(),
        dirty: json['dirty']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lastModifiedDate'] = this.lastModifiedDate;
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['createdDate'] = this.createdDate;
    data['name'] = this.name;
    data['shortName'] = this.shortName;
    data['code'] = this.code;
    data['displayName'] = this.displayName;
    data['activities'] = this.activities;
    data['dirty'] = this.dirty;
    return data;
  }
}
