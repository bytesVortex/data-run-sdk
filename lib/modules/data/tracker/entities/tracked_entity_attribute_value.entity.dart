import 'package:d2_remote/core/annotations/index.dart';
import 'package:d2_remote/shared/entities/identifiable.entity.dart';

import 'tracked-entity.entity.dart';

@AnnotationReflectable
@Entity(tableName: 'trackedEntityAttributeValue', apiResourceName: 'attributes')
class TrackedEntityAttributeValue extends IdentifiableEntity {
  @Column()
  String attribute;
  @Column()
  String value;
  @Column()
  bool? synced;

  @ManyToOne(
      joinColumnName: 'trackedEntityInstance', table: TrackedEntityInstance)
  dynamic trackedEntityInstance;

  TrackedEntityAttributeValue(
      {String? id,
      String? name,
      String? created,
      String? lastUpdated,
      required bool dirty,
      required this.attribute,
      required this.trackedEntityInstance,
      required this.value,
      this.synced})
      : super(
            uid: id,
            name: name,
            createdDate: created,
            lastModifiedDate: lastUpdated,
            dirty: dirty) {
    this.uid = '${this.trackedEntityInstance}_${this.attribute}';
    this.name = this.uid;
  }

  factory TrackedEntityAttributeValue.fromJson(Map<String, dynamic> json) {
    return TrackedEntityAttributeValue(
        id: json['id'],
        name: json['id'],
        attribute: json['attribute'],
        created: json['created'],
        lastUpdated: json['lastModifiedDate'],
        trackedEntityInstance: json['trackedEntityInstance'],
        value: json['value'],
        dirty: json['dirty']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.id;
    data['name'] = this.name;
    data['attribute'] = this.attribute;
    data['value'] = this.value;
    data['trackedEntityInstance'] = this.trackedEntityInstance;
    data['dirty'] = this.dirty;
    data['created'] = this.createdDate;
    data['lastModifiedDate'] = this.lastModifiedDate;
    return data;
  }

  static toUpload(TrackedEntityAttributeValue attribute) {
    return {"attribute": attribute.attribute, "value": attribute.value};
  }
}
