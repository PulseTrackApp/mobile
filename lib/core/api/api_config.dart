class ApiConfig {
  const ApiConfig({required this.baseUrl});

  static const defaultBaseUrl = 'https://api.gymflow.millogo-studio.com';

  static const gymFlowEnvironmentBaseUrl = String.fromEnvironment(
    'GYMFLOW_API_BASE_URL',
  );

  static const legacyEnvironmentBaseUrl = String.fromEnvironment(
    'PULSETRACK_API_BASE_URL',
  );

  factory ApiConfig.fromEnvironment() {
    final configuredBaseUrl = gymFlowEnvironmentBaseUrl.isNotEmpty
        ? gymFlowEnvironmentBaseUrl
        : legacyEnvironmentBaseUrl.isNotEmpty
        ? legacyEnvironmentBaseUrl
        : defaultBaseUrl;

    return ApiConfig(baseUrl: configuredBaseUrl);
  }

  final String baseUrl;

  String get dioBaseUrl {
    final normalized = _withApiVersion(baseUrl.trim());
    if (normalized.endsWith('/')) return normalized;
    return '$normalized/';
  }

  String _withApiVersion(String value) {
    final withoutTrailingSlash = value.replaceFirst(RegExp(r'/+$'), '');
    if (withoutTrailingSlash.endsWith('/api/v1')) {
      return withoutTrailingSlash;
    }
    return '$withoutTrailingSlash/api/v1';
  }
}
