import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';
import 'auth_token_store.dart';
import 'pulse_track_api.dart';

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ApiConfig.fromEnvironment();
});

final authTokenStoreProvider = ChangeNotifierProvider<AuthTokenStore>((ref) {
  return AuthTokenStore();
});

final pulseTrackApiProvider = Provider<PulseTrackApi>((ref) {
  return PulseTrackApi(
    config: ref.watch(apiConfigProvider),
    tokenStore: ref.watch(authTokenStoreProvider),
  );
});
