class MyResponse {
  MyResponse({required this.data, this.fallo = false, this.error: ''});

  dynamic data;
  bool fallo;
  String error;

  factory MyResponse.fromJson(Map<String, dynamic> json) => MyResponse(
      data: json['data'],
      fallo: json['fallo'],
      error: json.containsKey('error') ? json['error'] : '');
}
