class ApiResponse<T> {
  final bool success;
  final int code;
  final String message;
  final T data;

  ApiResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      code: json['code'] as int,
      message: json['message'] as String,
      data: fromJsonT(json['data']),
    );
  }
}
