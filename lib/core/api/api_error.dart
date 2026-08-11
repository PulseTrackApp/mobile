import 'package:dio/dio.dart';

class ApiProblem implements Exception {
  const ApiProblem({
    this.type,
    required this.title,
    this.status,
    required this.detail,
    this.instance,
    this.module,
    this.fieldErrors = const {},
  });

  factory ApiProblem.fromDioException(DioException exception) {
    final response = exception.response;
    final data = response?.data;

    if (data is Map<String, dynamic>) {
      return ApiProblem.fromJson(data, fallbackStatus: response?.statusCode);
    }

    if (data is Map) {
      return ApiProblem.fromJson(
        Map<String, dynamic>.from(data),
        fallbackStatus: response?.statusCode,
      );
    }

    return ApiProblem(
      title: 'Erreur reseau',
      status: response?.statusCode,
      detail: exception.message ?? 'Impossible de joindre le serveur.',
    );
  }

  factory ApiProblem.fromJson(
    Map<String, dynamic> json, {
    int? fallbackStatus,
  }) {
    final rawErrors = json['errors'];
    final fieldErrors = <String, String>{};

    if (rawErrors is Map) {
      rawErrors.forEach((key, value) {
        if (key != null && value != null) {
          fieldErrors[key.toString()] = value.toString();
        }
      });
    }

    return ApiProblem(
      type: _uriOrNull(json['type']),
      title: json['title']?.toString() ?? 'Erreur API',
      status: _intOrNull(json['status']) ?? fallbackStatus,
      detail: json['detail']?.toString() ?? '',
      instance: _uriOrNull(json['instance']),
      module: json['module']?.toString(),
      fieldErrors: fieldErrors,
    );
  }

  final Uri? type;
  final String title;
  final int? status;
  final String detail;
  final Uri? instance;
  final String? module;
  final Map<String, String> fieldErrors;

  bool get isUnauthorized => status == 401;

  bool get isModuleLocked =>
      status == 403 && type?.path.endsWith('/module-locked') == true;

  String get message => detail.isNotEmpty ? detail : title;

  @override
  String toString() {
    final code = status == null ? '' : ' ($status)';
    return 'ApiProblem$code: $message';
  }
}

Uri? _uriOrNull(Object? value) {
  if (value == null) return null;
  return Uri.tryParse(value.toString());
}

int? _intOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
