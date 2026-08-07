import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../domain/entities/notification_entity.dart';

final _currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});

final notificationsStreamProvider =
    StreamProvider<List<NotificationEntity>>((ref) {
  final uid = ref.watch(_currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(accountRemoteDataSourceProvider).watchNotifications(uid);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsStreamProvider).maybeWhen(
        data: (list) => list.where((n) => !n.read).length,
        orElse: () => 0,
      );
});

class NotificationActions {
  NotificationActions(this._ref);
  final Ref _ref;

  Future<void> markRead(String id) async {
    final uid = _ref.read(_currentUidProvider);
    if (uid == null) return;
    await _ref
        .read(accountRemoteDataSourceProvider)
        .markNotificationRead(uid, id);
  }

  Future<void> markAllRead() async {
    final uid = _ref.read(_currentUidProvider);
    if (uid == null) return;
    await _ref
        .read(accountRemoteDataSourceProvider)
        .markAllNotificationsRead(uid);
  }
}

final notificationActionsProvider = Provider<NotificationActions>((ref) {
  return NotificationActions(ref);
});
