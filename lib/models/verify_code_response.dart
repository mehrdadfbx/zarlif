class VerifyCodeResponse {
  final int statusCode;
  final String status;
  final String message;
  final dynamic data;
  final String? token;

  VerifyCodeResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
    this.token,
  });

  factory VerifyCodeResponse.fromJson(
    Map<String, dynamic> json, {
    String? token,
  }) {
    return VerifyCodeResponse(
      statusCode: json['statusCode'] ?? 0,
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'],
      token: token,
    );
  }

  bool get isSuccess => statusCode == 200;
}
