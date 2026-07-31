import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/activity_provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';

class ActivityLogsScreen extends ConsumerWidget {
  const ActivityLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(activityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Gradient header
          Container(
            decoration: primaryGradientDecoration(radius: 0),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Logs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Your recent actions',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: activityState.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return Center(
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
                            Icons.history_rounded,
                            size: 40,
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No activity yet',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Your actions will appear here',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(activityProvider.notifier).fetchActivityLogs(),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final dateStr = DateFormat('MMM d, y · h:mm a')
                          .format(log.createdAt.toLocal());

                      return Container(
                        decoration: cardDecoration(),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            log.action.replaceAll('_', ' ').toLowerCase().split(' ').map((w) =>
                              w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w
                            ).join(' '),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textHint),
                                const SizedBox(width: 4),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: log.metadata.isNotEmpty
                              ? Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textSecondary,
                                )
                              : null,
                          onTap: () {
                            if (log.metadata.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  title: Row(
                                    children: [
                                      const Icon(Icons.info_outline_rounded,
                                          color: AppColors.primary, size: 22),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Activity Details',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      log.metadata.toString(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
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
        ],
      ),
    );
  }
}
