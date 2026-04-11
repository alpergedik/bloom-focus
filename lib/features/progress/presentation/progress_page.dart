import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_background.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<BloomAppState>();

    final achievements = _buildAchievements(appState);
    final unlockedCount = achievements.where((e) => e.unlocked).length;

    const weeklyData = <WeeklyBarData>[
      WeeklyBarData(label: 'M', value: 0.46),
      WeeklyBarData(label: 'T', value: 0.62),
      WeeklyBarData(label: 'W', value: 0.38),
      WeeklyBarData(label: 'T', value: 0.76),
      WeeklyBarData(label: 'F', value: 0.64),
      WeeklyBarData(label: 'S', value: 0.28, highlighted: true),
      WeeklyBarData(label: 'S', value: 0.66),
    ];

    return AppBackground(
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProgressHeader(),
              const SizedBox(height: 18),
              _HeroProgressCard(appState: appState),
              const SizedBox(height: 20),
              _StatsGrid(appState: appState),
              const SizedBox(height: 22),
              _WeeklyActivityCard(
                data: weeklyData,
                totalMinutes: appState.totalFocusMinutes,
              ),
              const SizedBox(height: 22),
              _AchievementsSection(
                unlockedCount: unlockedCount,
                totalCount: achievements.length,
                achievements: achievements,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<AchievementItem> _buildAchievements(BloomAppState appState) {
    final totalWaterEarned = appState.availableWaterMl + appState.totalWaterGivenMl;
    final totalFocusHours = appState.totalFocusMinutes / 60.0;

    return [
      AchievementItem(
        title: 'First Session',
        subtitle: 'Complete 1\nfocus session',
        icon: Icons.play_circle_outline,
        unlocked: appState.completedSessions >= 1,
        accent: const Color(0xFF6FAF7A),
      ),
      AchievementItem(
        title: 'Week Warrior',
        subtitle: '7 day streak',
        icon: Icons.shield_outlined,
        unlocked: appState.currentStreakDays >= 7,
        accent: const Color(0xFF8E72C7),
      ),
      AchievementItem(
        title: 'Focus Builder',
        subtitle: '25 sessions\ndone',
        icon: Icons.bolt_outlined,
        unlocked: appState.completedSessions >= 25,
        accent: const Color(0xFF9A71C6),
      ),
      AchievementItem(
        title: 'Century Club',
        subtitle: '100 sessions\ndone',
        icon: Icons.workspace_premium,
        unlocked: appState.completedSessions >= 100,
        accent: const Color(0xFFE14B6D),
      ),
      AchievementItem(
        title: 'Deep Focus',
        subtitle: '5 hours\nfocused',
        icon: Icons.timelapse_rounded,
        unlocked: totalFocusHours >= 5,
        accent: const Color(0xFF6A9D79),
      ),
      AchievementItem(
        title: 'Zen Master',
        subtitle: '25 hours\nfocused',
        icon: Icons.self_improvement,
        unlocked: totalFocusHours >= 25,
        accent: const Color(0xFF9BA3A0),
      ),
      AchievementItem(
        title: 'First Pour',
        subtitle: 'Give water\nto your plant',
        icon: Icons.water_drop_outlined,
        unlocked: appState.totalWaterGivenMl > 0,
        accent: const Color(0xFF4AA1D4),
      ),
      AchievementItem(
        title: 'Green Thumb',
        subtitle: 'Reach plant level\n5',
        icon: Icons.spa,
        unlocked: appState.plantLevel >= 5,
        accent: const Color(0xFF83B86F),
      ),
      AchievementItem(
        title: 'Blooming Soul',
        subtitle: 'Reach\nFlowering',
        icon: Icons.local_florist_outlined,
        unlocked: appState.plantStageName == 'Flowering' ||
            appState.plantStageName == 'Full Bloom',
        accent: const Color(0xFFF2A640),
      ),
      AchievementItem(
        title: 'Full Bloom',
        subtitle: 'Reach final\nplant stage',
        icon: Icons.emoji_events_outlined,
        unlocked: appState.plantStageName == 'Full Bloom',
        accent: const Color(0xFFE9763A),
      ),
      AchievementItem(
        title: 'Water Master',
        subtitle: '1000ml earned',
        icon: Icons.water_drop,
        unlocked: totalWaterEarned >= 1000,
        accent: const Color(0xFF7DAED6),
      ),
    ];
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR JOURNEY',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppTheme.mutedText,
              ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Progress ',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkGreen,
                    ),
              ),
              const TextSpan(
                text: '🏆',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroProgressCard extends StatelessWidget {
  final BloomAppState appState;

  const _HeroProgressCard({
    required this.appState,
  });

  String _emojiForStage() {
    switch (appState.plantStageName) {
      case 'Seedling':
        return '🌱';
      case 'First Leaves':
        return '🌿';
      case 'Flowering':
        return '🌸';
      case 'Full Bloom':
        return '🌺';
      default:
        return '🪴';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3E7A57),
            Color(0xFF2F6747),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.military_tech_outlined,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  'Level ${appState.plantLevel}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    _emojiForStage(),
                    style: TextStyle(
                      fontSize: 54,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.plantName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appState.plantStageName} • ${appState.plantHeightLabel} tall',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You helped your plant grow today 💚',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Level Progress',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                appState.growthLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: appState.plantGrowthPercent,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFA7D0AA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final BloomAppState appState;

  const _StatsGrid({
    required this.appState,
  });

  String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final totalWaterEarned = appState.availableWaterMl + appState.totalWaterGivenMl;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.timelapse_rounded,
                iconColor: const Color(0xFF6A9D79),
                background: const Color(0xFFD3E6D2),
                title: 'Focus Time',
                value: _formatMinutes(appState.totalFocusMinutes),
                subtitle: 'Total focused',
                valueColor: const Color(0xFF4D7A5A),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatCard(
                icon: Icons.water_drop_outlined,
                iconColor: const Color(0xFF4AA1D4),
                background: const Color(0xFFBFE5FA),
                title: 'Water Earned',
                value: '${totalWaterEarned}ml',
                subtitle: 'Lifetime total',
                valueColor: const Color(0xFF2F8CC4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_outlined,
                iconColor: const Color(0xFFF28C48),
                background: const Color(0xFFF6DFC0),
                title: 'Current Streak',
                value: '${appState.currentStreakDays} days',
                subtitle: 'Keep it going! 🔥',
                valueColor: const Color(0xFFE9763A),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatCard(
                icon: Icons.bolt_outlined,
                iconColor: const Color(0xFF9A71C6),
                background: const Color(0xFFE7D5F0),
                title: 'Sessions',
                value: '${appState.completedSessions}',
                subtitle: 'Completed',
                valueColor: const Color(0xFF9367C1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color background;
  final String title;
  final String value;
  final String subtitle;
  final Color valueColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.55),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: iconColor.withValues(alpha: 0.72),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyActivityCard extends StatelessWidget {
  final List<WeeklyBarData> data;
  final int totalMinutes;

  const _WeeklyActivityCard({
    required this.data,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Activity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkGreen,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Focus minutes per day',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.mutedText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE8DC),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${totalMinutes}m total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.darkGreen,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: data
                  .map(
                    (item) => _WeeklyBar(
                      label: item.label,
                      value: item.value,
                      highlighted: item.highlighted,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBar extends StatelessWidget {
  final String label;
  final double value;
  final bool highlighted;

  const _WeeklyBar({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = highlighted
        ? AppTheme.primary
        : AppTheme.primary.withValues(alpha: 0.28);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 22,
            height: 72 * value.clamp(0.18, 1.0),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  final int unlockedCount;
  final int totalCount;
  final List<AchievementItem> achievements;

  const _AchievementsSection({
    required this.unlockedCount,
    required this.totalCount,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Achievements',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkGreen,
                    ),
              ),
            ),
            Text(
              '$unlockedCount/$totalCount unlocked',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          itemCount: achievements.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.60,
          ),
          itemBuilder: (context, index) {
            final item = achievements[index];
            return _AchievementCard(item: item);
          },
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementItem item;

  const _AchievementCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = item.unlocked ? AppTheme.darkGreen : AppTheme.mutedText;
    final subtitleColor = item.unlocked
        ? AppTheme.mutedText.withValues(alpha: 0.9)
        : AppTheme.mutedText.withValues(alpha: 0.65);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: item.unlocked
            ? Colors.white.withValues(alpha: 0.78)
            : Colors.white.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: item.unlocked ? 0.85 : 0.5),
        ),
        boxShadow: item.unlocked
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.unlocked
                  ? item.accent.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            child: Icon(
              item.icon,
              size: 22,
              color: item.unlocked
                  ? item.accent
                  : AppTheme.mutedText.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            item.subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtitleColor,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
          ),
          const SizedBox(height: 8),
          if (item.unlocked)
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary,
              ),
              child: const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              ),
            )
          else
            const SizedBox(height: 22),
        ],
      ),
    );
  }
}

class WeeklyBarData {
  final String label;
  final double value;
  final bool highlighted;

  const WeeklyBarData({
    required this.label,
    required this.value,
    this.highlighted = false,
  });
}

class AchievementItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool unlocked;
  final Color accent;

  const AchievementItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.unlocked,
    required this.accent,
  });
}