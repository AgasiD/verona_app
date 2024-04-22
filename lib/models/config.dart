class Config {
  late bool send_ws_reports;
  late String schedule_send_report;
  late String schedule_backup;
  late String id;

  Config(
      {
       id = '',
      send_ws_reports = true,
      schedule_send_report = '',
      schedule_backup = ''}) {
        this.id = id;
    this.schedule_backup = schedule_backup;
    this.send_ws_reports = send_ws_reports;
    this.schedule_send_report = schedule_send_report;
  }

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        id: json["id"] ?? '',
        send_ws_reports: json["send_ws_reports"] ?? true,
        schedule_send_report: json["schedule_send_report"] ?? '',
        schedule_backup: json["schedule_backup"] ?? '',
      );

  toMap() => {
    "id": id,
        "send_ws_reports": send_ws_reports,
        "schedule_send_report": schedule_send_report,
        "schedule_backup": schedule_backup
      };
}
