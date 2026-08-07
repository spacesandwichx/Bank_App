import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import 'home_providers.dart';

final userBootstrapProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
    final user = next.value;
    if (user == null) return;
    if (previous?.value?.uid == user.uid) return;

    ref.read(accountRepositoryProvider).bootstrap(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
        );
  }, fireImmediately: true);
});
