import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }
          return CustomScrollView(
            slivers: [
              // Hero header
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 200,
                      decoration: primaryGradientDecoration(radius: 0),
                      child: SafeArea(
                        bottom: false,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: IconButton(
                              icon: const Icon(Icons.logout_rounded, color: Colors.white),
                              tooltip: 'Logout',
                              onPressed: () async {
                                await ref.read(authProvider.notifier).logout();
                                if (context.mounted) context.go('/login');
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -48,
                      child: Column(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primaryLight, AppColors.primary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: user.profile_picture != null && user.profile_picture!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      user.profile_picture!.startsWith('http')
                                          ? user.profile_picture!
                                          : 'http://127.0.0.1:8000${user.profile_picture!}',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => _avatarIcon(user.display_name),
                                    ),
                                  )
                                : _avatarIcon(user.display_name),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 64, 20, 8),
                  child: Column(
                    children: [
                      Text(
                        user.display_name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats row
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: cardDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              label: 'Department',
                              value: user.department ?? 'N/A',
                              icon: Icons.school_rounded,
                            ),
                            _VerticalDivider(),
                            _StatItem(
                              label: 'Year',
                              value: user.year?.toString() ?? 'N/A',
                              icon: Icons.calendar_today_rounded,
                            ),
                            _VerticalDivider(),
                            _StatItem(
                              label: 'Section',
                              value: user.section ?? 'N/A',
                              icon: Icons.groups_rounded,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Info cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    const _SectionTitle(text: 'Account Info'),
                    const SizedBox(height: 10),
                    _InfoCard(
                      items: [
                        _InfoItem(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: user.email,
                        ),
                        _InfoItem(
                          icon: Icons.badge_outlined,
                          label: 'Role',
                          value: user.role,
                        ),
                        _InfoItem(
                          icon: Icons.circle_outlined,
                          label: 'Status',
                          value: user.status,
                          valueColor: user.status.toLowerCase() == 'active'
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _SectionTitle(text: 'Activity'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: cardDecoration(),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.history_rounded, color: AppColors.primary, size: 22),
                        ),
                        title: const Text(
                          'Activity Logs',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: const Text(
                          'View your recent actions',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () => context.push('/activity-logs'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _avatarIcon(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: const Color(0xFFEEEEF5));
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(items[i].icon, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[i].label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: items[i].valueColor ?? AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1)
              const Divider(height: 1, indent: 70, endIndent: 0),
          ],
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}
