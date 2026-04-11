import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_background.dart';

class PlantPage extends StatelessWidget {
  const PlantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<BloomAppState>();

    final plant = PlantCompanionData(
      name: appState.plantName,
      level: appState.plantLevel,
      stageName: appState.plantStageName,
      heightLabel: appState.plantHeightLabel,
      growthPercent: appState.plantGrowthPercent,
      remainingToNextPercent: appState.remainingToNextPercent,
      availableWaterMl: appState.availableWaterMl,
      sessionsCompleted: appState.completedSessions,
      growthLabel: appState.growthLabel,
      emoji: _plantEmojiForStage(appState.plantStageName),
    );

    final milestones = _buildMilestones(appState);

    return AppBackground(
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PlantHeader(
                title: plant.name,
                level: plant.level,
              ),
              const SizedBox(height: 18),
              _MainPlantCard(plant: plant),
              const SizedBox(height: 18),
              _PlantStatsRow(
                availableWaterMl: appState.availableWaterMl,
                totalWaterGivenMl: appState.totalWaterGivenMl,
                sessionsCompleted: appState.completedSessions,
                growthLabel: appState.growthLabel,
              ),
              const SizedBox(height: 18),
              _MilestonesCard(
                milestones: milestones,
                completedCount: milestones.where((m) => m.completed).length,
              ),
              const SizedBox(height: 22),
              _GiveLifeButton(
                availableWaterMl: appState.availableWaterMl,
                onTap: () async {
                  final newlyUnlocked =
                      await context.read<BloomAppState>().giveLife();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.darkGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      content: const Text(
                        'Your plant absorbed water and grew 🌱',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );

                  for (final id in newlyUnlocked) {
                    final title = _achievementTitle(id);
                    if (title == null) continue;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF3E7A57),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        content: Text(
                          '🏆 Achievement unlocked: $title',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _achievementTitle(String id) {
    switch (id) {
      case 'first_session':
        return 'First Session';
      case 'week_warrior':
        return 'Week Warrior';
      case 'focus_builder':
        return 'Focus Builder';
      case 'century_club':
        return 'Century Club';
      case 'deep_focus':
        return 'Deep Focus';
      case 'zen_master':
        return 'Zen Master';
      case 'first_pour':
        return 'First Pour';
      case 'green_thumb':
        return 'Green Thumb';
      case 'blooming_soul':
        return 'Blooming Soul';
      case 'full_bloom':
        return 'Full Bloom';
      case 'water_master':
        return 'Water Master';
      default:
        return null;
    }
  }

  static String _plantEmojiForStage(String stageName) {
    switch (stageName) {
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

  static List<PlantMilestone> _buildMilestones(BloomAppState appState) {
    return [
      PlantMilestone(
        title: 'Seedling',
        heightLabel: 'Lv. 1',
        completed: appState.plantLevel >= 1,
      ),
      PlantMilestone(
        title: 'First Leaves',
        heightLabel: 'Lv. 3',
        completed: appState.plantLevel >= 3,
      ),
      PlantMilestone(
        title: 'Grown Plant',
        heightLabel: 'Lv. 5',
        completed: appState.plantLevel >= 5,
      ),
      PlantMilestone(
        title: 'Flowering',
        heightLabel: 'Lv. 7',
        completed: appState.plantLevel >= 7,
      ),
      PlantMilestone(
        title: 'Full Bloom',
        heightLabel: 'Lv. 8+',
        completed: appState.plantLevel >= 8,
      ),
    ];
  }
}

class _PlantHeader extends StatelessWidget {
  final String title;
  final int level;

  const _PlantHeader({
    required this.title,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR COMPANION',
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
                      text: '$title ',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkGreen,
                          ),
                    ),
                    const TextSpan(
                      text: '🌿',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.26),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 17,
                color: AppTheme.darkGreen.withValues(alpha: 0.82),
              ),
              const SizedBox(width: 6),
              Text(
                'Lv. $level',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkGreen,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MainPlantCard extends StatelessWidget {
  final PlantCompanionData plant;

  const _MainPlantCard({
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.78),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TopMetric(
                        label: 'Stage',
                        value: plant.stageName,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    ),
                    Expanded(
                      child: _TopMetric(
                        label: 'Height',
                        value: plant.heightLabel,
                        crossAxisAlignment: CrossAxisAlignment.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Growth progress',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mutedText,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Text(
                      '${(plant.growthPercent * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: plant.growthPercent,
                    minHeight: 8,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _PlantVisual(emoji: plant.emoji),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.primary.withValues(alpha: 0.10),
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '✨',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.primary.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${plant.remainingToNextPercent}% more to next stage • Keep focusing!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mutedText,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopMetric extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;

  const _TopMetric({
    required this.label,
    required this.value,
    required this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    final textAlign = crossAxisAlignment == CrossAxisAlignment.end
        ? TextAlign.end
        : TextAlign.start;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mutedText,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: textAlign,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.darkGreen,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
        ),
      ],
    );
  }
}

class _PlantVisual extends StatelessWidget {
  final String emoji;

  const _PlantVisual({
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.14),
                    AppTheme.primary.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 88),
                ),
                Container(
                  width: 52,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantStatsRow extends StatelessWidget {
  final int availableWaterMl;
  final int totalWaterGivenMl;
  final int sessionsCompleted;
  final String growthLabel;

  const _PlantStatsRow({
    required this.availableWaterMl,
    required this.totalWaterGivenMl,
    required this.sessionsCompleted,
    required this.growthLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PlantStatCard(
            icon: Icons.water_drop,
            iconColor: const Color(0xFF57A8EA),
            title: 'Available Water',
            value: '${availableWaterMl}ml',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PlantStatCard(
            icon: Icons.timer_outlined,
            iconColor: const Color(0xFF5B5B5B),
            title: 'Sessions',
            value: '$sessionsCompleted',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PlantStatCard(
            icon: Icons.show_chart_rounded,
            iconColor: const Color(0xFF7D8DDE),
            title: 'Growth',
            value: growthLabel,
          ),
        ),
      ],
    );
  }
}

class _PlantStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _PlantStatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.82),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedText,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.darkGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
          ),
        ],
      ),
    );
  }
}

class _MilestonesCard extends StatelessWidget {
  final List<PlantMilestone> milestones;
  final int completedCount;

  const _MilestonesCard({
    required this.milestones,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.78),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Growth Milestones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.darkGreen,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.mutedText.withValues(alpha: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$completedCount/${milestones.length} completed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          ...milestones.map(
            (milestone) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _MilestoneRow(milestone: milestone),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  final PlantMilestone milestone;

  const _MilestoneRow({
    required this.milestone,
  });

  @override
  Widget build(BuildContext context) {
    final bool completed = milestone.completed;

    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed
                ? AppTheme.primary
                : AppTheme.primary.withValues(alpha: 0.10),
            boxShadow: completed
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: completed
              ? const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            milestone.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: completed
                      ? AppTheme.darkGreen
                      : AppTheme.mutedText.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          milestone.heightLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: completed
                    ? AppTheme.mutedText
                    : AppTheme.mutedText.withValues(alpha: 0.72),
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _GiveLifeButton extends StatelessWidget {
  final int availableWaterMl;
  final VoidCallback onTap;

  const _GiveLifeButton({
    required this.availableWaterMl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = availableWaterMl > 0;

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.45),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          '💧 Give Life 💧',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
        ),
      ),
    );
  }
}

class PlantCompanionData {
  final String name;
  final int level;
  final String stageName;
  final String heightLabel;
  final double growthPercent;
  final int remainingToNextPercent;
  final int availableWaterMl;
  final int sessionsCompleted;
  final String growthLabel;
  final String emoji;

  const PlantCompanionData({
    required this.name,
    required this.level,
    required this.stageName,
    required this.heightLabel,
    required this.growthPercent,
    required this.remainingToNextPercent,
    required this.availableWaterMl,
    required this.sessionsCompleted,
    required this.growthLabel,
    required this.emoji,
  });
}

class PlantMilestone {
  final String title;
  final String heightLabel;
  final bool completed;

  const PlantMilestone({
    required this.title,
    required this.heightLabel,
    required this.completed,
  });
}