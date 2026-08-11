import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_providers.dart';
import 'module_access_controller.dart';

final moduleAccessControllerProvider =
    ChangeNotifierProvider<ModuleAccessController>((ref) {
      return ModuleAccessController(
        api: ref.watch(pulseTrackApiProvider),
        tokenStore: ref.watch(authTokenStoreProvider),
      );
    });
