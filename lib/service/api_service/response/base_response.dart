class BaseResponse<T> {
  BaseResponse({this.code, this.data, this.status, this.message, this.error});

  final int? code;
  final List<T>? data; // data là một danh sách các đối tượng T
  final String? status;
  final String? message;
  final String? error;

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    final rawData = json['data'];
    final responseData = <T>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          responseData.add(fromJsonT(Map<String, dynamic>.from(item)));
        }
      }
    } else if (rawData is Map && rawData.isNotEmpty) {
      responseData.add(fromJsonT(Map<String, dynamic>.from(rawData)));
    }

    return BaseResponse<T>(
      code: _asInt(json['code']),
      data: responseData,
      status: _asString(json['status']),
      message: _asString(json['message']),
      error: _asString(
        json['error'] ?? json['detail'] ?? json['title'] ?? json['message'],
      ),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _asString(dynamic value) =>
      value == null ? null : value.toString();

  Map<String, dynamic> toJson() => {
    "code": code,
    "data": data != null ? data!.map((e) => e).toList() : [],
    "status": status,
    "message": message,
    "error": error,
  };
}
