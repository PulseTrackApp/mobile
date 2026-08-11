import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_providers.dart';
import '../modules/app_module.dart';
import '../modules/module_providers.dart';
import 'push_registrar.dart';
import 'push_service.dart';

final pushServiceProvider = Provider<PushService>((ref) {
  return FirebasePushService();
});

/// Instance unique pour toute l'application : deux registraires enverraient
/// deux fois le meme jeton, et le second ecraserait la memoire du premier.
final pushRegistrarProvider = Provider<PushRegistrar>((ref) {
  final moduleAccess = ref.watch(moduleAccessControllerProvider);
  final registrar = PushRegistrar(
    pushService: ref.watch(pushServiceProvider),
    api: ref.watch(pulseTrackApiProvider),
    tokenStore: ref.watch(authTokenStoreProvider),
    accessListenable: moduleAccess,
    canRegister: () => moduleAccess.isEnabled(AppModule.push),
  );
  ref.onDispose(registrar.dispose);
  return registrar;
});
