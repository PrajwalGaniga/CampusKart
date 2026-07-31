import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_provider.dart';
import '../../core/app_theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsState = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: primaryGradientDecoration(radius: 0),
                padding: const EdgeInsets.fromLTRB(20, 48, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                      tooltip: 'Mark all as read',
                      onPressed: () =>
                          ref.read(notificationsProvider.notifier).markAllAsRead(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: notifsState.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const _EmptyNotifications();
            }
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(notificationsProvider.notifier).fetchNotifications(),
              color: AppColors.primary,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, i) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: notif.is_read
                          ? null
                          : Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Row(
                        children: [
                          // Unread accent strip
                          if (!notif.is_read)
                            Container(
                              width: 4,
                              height: 70,
                              color: AppColors.primary,
                            ),
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.only(
                                left: notif.is_read ? 16 : 12,
                                right: 8,
                                top: 4,
                                bottom: 4,
                              ),
                              leading: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: notif.is_read
                                      ? Colors.grey.withValues(alpha: 0.1)
                                      : AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.notifications_rounded,
                                  color: notif.is_read
                                      ? AppColors.textHint
                                      : AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                notif.title,
                                style: TextStyle(
                                  fontWeight: notif.is_read
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  notif.message,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              trailing: notif.is_read
                                  ? null
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                                      onPressed: () => ref
                                          .read(notificationsProvider.notifier)
                                          .markAsRead(notif.id),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 40,
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'All caught up!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No new notifications',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
