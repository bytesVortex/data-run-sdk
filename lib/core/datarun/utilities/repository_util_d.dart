import 'package:d2_remote/core/annotations/index.dart';
import 'package:reflectable/reflectable.dart';

class RepositoryUtilD {
  static getEntityData(
      {required List<Column> columns,
      required Map<String, dynamic> objectMap,
      required ClassMirror classMirror}) {
    Map<String, dynamic> resultMap = {};

    columns.forEach((column) {
      var value = objectMap[column.name];

      if (value.runtimeType == int && column.type == ColumnType.BOOLEAN) {
        resultMap[column.name as String] = value == 1 ? true : false;
      } else if (column.relation != null) {
        resultMap[column.name as String] =
            column.relation?.relationType == RelationType.OneToMany
                ? RepositoryUtilD.getRelationObject(
                    relation: column.relation as ColumnRelation, value: value)
                : value;
      } else {
        resultMap[column.name as String] = value;
      }
    });

    return classMirror.newInstance('fromJson', [resultMap]);
  }

  static getRelationObject({required ColumnRelation relation, dynamic value}) {
    if (value == null) {
      return null;
    }
    switch (relation.relationType) {
      case RelationType.ManyToOne:
        Map<String, dynamic> relationMap = {};

        relation.referencedEntityColumns?.forEach((column) {
          var relationValue = value[column!.name];
          if (relationValue.runtimeType == int &&
              column.type == ColumnType.BOOLEAN) {
            relationMap[column.name as String] =
                relationValue == 1 ? true : false;
          } else {
            relationMap[column.name as String] = relationValue;
          }
        });

        return relation.referencedEntity?.classMirror!
            .newInstance('fromJson', [relationMap]);

      case RelationType.OneToMany:
        return value.toList().map((valueItem) {
          Map<String, dynamic> relationMap = {};

          relation.referencedEntityColumns?.forEach((column) {
            var relationValue = valueItem[column!.name];
            if (relationValue.runtimeType == int &&
                column.type == ColumnType.BOOLEAN) {
              relationMap[column.name as String] =
                  relationValue == 1 ? true : false;
            } else {
              relationMap[column.name as String] = relationValue;
            }
          });

          return relationMap;
        }).toList();

      default:
        return null;
    }
  }
}
