/// Body for DELETE /delete-account
/// { "password": "Password123#" }
class DeleteAccountRequest {
  final String password;

  const DeleteAccountRequest({required this.password});

  Map<String, dynamic> toJson() => {
    'password': password,
  };
}

/// Response for DELETE /delete-account
/// { "status": "1", "status_code": "200", "data": {}, "message": "..." }
class DeleteAccountResponse {
  final String status;
  final String statusCode;
  final String message;

  const DeleteAccountResponse({
    required this.status,
    required this.statusCode,
    required this.message,
  });

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAccountResponse(
      status: json['status']?.toString() ?? '',
      statusCode: json['status_code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  bool get isSuccess => status == '1';
}