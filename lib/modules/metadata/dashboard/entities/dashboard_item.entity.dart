import 'package:d2_remote/core/annotations/index.dart';
import 'package:d2_remote/modules/metadata/dashboard/entities/dashboard.entity.dart';
import 'package:d2_remote/shared/entities/identifiable.entity.dart';

@AnnotationReflectable
@Entity(tableName: 'dashboarditem', apiResourceName: 'dashboardItems')
class DashboardItem extends IdentifiableEntity {
  @Column(type: ColumnType.TEXT, nullable: true)
  String? type;

  @Column(type: ColumnType.INTEGER, nullable: true)
  int? contentCount;

  @Column(type: ColumnType.INTEGER, nullable: true)
  int? interpretationCount;

  @Column(type: ColumnType.INTEGER, nullable: true)
  int? interpretationLikeCount;

  @Column(type: ColumnType.TEXT, nullable: true)
  String? chart;

  @Column(type: ColumnType.TEXT, nullable: true)
  String? report;

  @ManyToOne(joinColumnName: 'dashboard', table: Dashboard)
  Dashboard? dashboard;

  DashboardItem(
      {required String id,
      required String name,
      String? createdDate,
      String? lastModifiedDate,
      required this.dashboard,
      this.type,
      this.contentCount,
      this.interpretationCount,
      this.interpretationLikeCount,
      this.chart,
      this.report,
      required dirty})
      : super(uid: id, name: name, dirty: dirty);

  factory DashboardItem.fromJson(Map<String, dynamic> json) {
    return DashboardItem(
        id: json['id'],
        name: json['name'],
        type: json['type'],
        dashboard: json['dashboard'],
        contentCount: json['contentCount'],
        interpretationCount: json['interpretationCount'],
        interpretationLikeCount: json['interpretationLikeCount'],
        chart: json['chart'],
        report: json['report'],
        createdDate: json['createdDate'],
        dirty: json['dirty']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lastModifiedDate'] = this.lastModifiedDate;
    data['id'] = this.id;
    data['type'] = this.type;
    data['dashboard'] = this.dashboard!.toJson();
    data['contentcount'] = this.contentCount;
    data['interpretationCount'] = this.interpretationCount;
    data['interpretationLikeCount'] = this.interpretationLikeCount;
    data['chart'] = this.chart;
    data['report'] = this.report;
    data['createdDate'] = this.createdDate;
    data['dirty'] = this.dirty;

    return data;
  }
}
