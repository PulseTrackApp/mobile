import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_formatters.dart';
import '../api/api_providers.dart';

class CurrentUserInfo {
  const CurrentUserInfo({this.displayName, this.email});

  final String? displayName;
  final String? email;

  String? get primaryLabel {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final fallbackEmail = email?.trim();
    if (fallbackEmail != null && fallbackEmail.isNotEmpty) {
      return fallbackEmail;
    }

    return null;
  }
}

final currentUserProvider = FutureProvider.autoDispose<CurrentUserInfo>((ref) {
  final tokenStore = ref.watch(authTokenStoreProvider);
  final email = tokenStore.email?.trim();
  final localDisplayName = tokenStore.displayName?.trim();

  if (!tokenStore.isAuthenticated) {
    return Future.value(
      CurrentUserInfo(displayName: localDisplayName, email: email),
    );
  }

  return ref
      .watch(pulseTrackApiProvider)
      .getProfile()
      .then(
        (profile) => CurrentUserInfo(
          displayName:
              jsonString(profile, 'displayName')?.trim() ?? localDisplayName,
          email: email,
        ),
      )
      .catchError(
        (_) => CurrentUserInfo(displayName: localDisplayName, email: email),
      );
});
