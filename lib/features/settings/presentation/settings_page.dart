import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _changeMinutes({
    required int currentValue,
    required void Function(int newValue) onChanged,
    required int min,
    required int max,
    required bool increase,
  }) {
    final newValue = increase ? currentValue + 1 : currentValue - 1;
    if (newValue < min || newValue > max) return;

    setState(() {
      onChanged(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3EA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    color: Colors.white.withValues(alpha: 0.68),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppTheme.primary.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                "CONFIGURATION",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.primary.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "Settings",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.darkGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("⚙️", style: TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 26),
              _sectionTitle("TIMER DURATIONS"),
              const SizedBox(height: 10),
              _SettingsCard(
                child: Column(
                  children: [
                    _DurationTile(
                      icon: Icons.timer_outlined,
                      iconColor: const Color(0xFF77B77A),
                      title: "Focus Session",
                      subtitle: "Deep work interval",
                      value: AppState.focusMinutes,
                      onMinus: () => _changeMinutes(
                        currentValue: AppState.focusMinutes,
                        onChanged: (value) => AppState.focusMinutes = value,
                        min: 5,
                        max: 120,
                        increase: false,
                      ),
                      onPlus: () => _changeMinutes(
                        currentValue: AppState.focusMinutes,
                        onChanged: (value) => AppState.focusMinutes = value,
                        min: 5,
                        max: 120,
                        increase: true,
                      ),
                    ),
                    const _TileDivider(),
                    _DurationTile(
                      icon: Icons.timer_outlined,
                      iconColor: const Color(0xFF77B77A),
                      title: "Short Break",
                      subtitle: "Quick rest period",
                      value: AppState.shortBreakMinutes,
                      onMinus: () => _changeMinutes(
                        currentValue: AppState.shortBreakMinutes,
                        onChanged: (value) =>
                            AppState.shortBreakMinutes = value,
                        min: 1,
                        max: 30,
                        increase: false,
                      ),
                      onPlus: () => _changeMinutes(
                        currentValue: AppState.shortBreakMinutes,
                        onChanged: (value) =>
                            AppState.shortBreakMinutes = value,
                        min: 1,
                        max: 30,
                        increase: true,
                      ),
                    ),
                    const _TileDivider(),
                    _DurationTile(
                      icon: Icons.timer_outlined,
                      iconColor: const Color(0xFF77B77A),
                      title: "Long Break",
                      subtitle: "After 4 sessions",
                      value: AppState.longBreakMinutes,
                      onMinus: () => _changeMinutes(
                        currentValue: AppState.longBreakMinutes,
                        onChanged: (value) => AppState.longBreakMinutes = value,
                        min: 5,
                        max: 60,
                        increase: false,
                      ),
                      onPlus: () => _changeMinutes(
                        currentValue: AppState.longBreakMinutes,
                        onChanged: (value) => AppState.longBreakMinutes = value,
                        min: 5,
                        max: 60,
                        increase: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _sectionTitle("PREFERENCES"),
              const SizedBox(height: 10),
              _SettingsCard(
                child: Column(
                  children: [
                    _PreferenceTile(
                      icon: Icons.notifications_none_rounded,
                      iconColor: const Color(0xFFF29B63),
                      title: "Notifications",
                      subtitle: "Session reminders",
                      value: AppState.notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          AppState.notificationsEnabled = value;
                        });
                      },
                    ),
                    const _TileDivider(),
                    _PreferenceTile(
                      icon: Icons.volume_up_outlined,
                      iconColor: const Color(0xFF61AFE8),
                      title: "Sound Effects",
                      subtitle: "UI feedback sounds",
                      value: AppState.soundEffectsEnabled,
                      onChanged: (value) {
                        setState(() {
                          AppState.soundEffectsEnabled = value;
                        });
                      },
                    ),
                    const _TileDivider(),
                    _PreferenceTile(
                      icon: Icons.dark_mode_outlined,
                      iconColor: const Color(0xFFB58ADF),
                      title: "Dark Mode",
                      subtitle: "Easy on the eyes",
                      value: AppState.darkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          AppState.darkModeEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _sectionTitle("ABOUT"),
              const SizedBox(height: 10),
              const _SettingsCard(
                child: Column(
                  children: [
                    _AboutTile(
                      icon: Icons.star_border_rounded,
                      iconColor: Color(0xFFF2B35B),
                      title: "Rate Bloom Focus",
                      subtitle: "♥ Support our growth",
                    ),
                    _TileDivider(),
                    _AboutTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: Color(0xFF61AFE8),
                      title: "Help & Support",
                      subtitle: "We're here for you",
                    ),
                    _TileDivider(),
                    _AboutTile(
                      icon: Icons.share_outlined,
                      iconColor: Color(0xFF79A987),
                      title: "Share the App",
                      subtitle: "Spread the focus",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.darkGreen,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.darkGreen.withValues(alpha: 0.22),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.energy_savings_leaf_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Bloom Focus",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Version 1.0.0 • Made with 💚",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primary.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Focus deeply. Grow beautifully.",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primary.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppTheme.primary.withValues(alpha: 0.78),
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        fontSize: 14,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DurationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _DurationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _CircleIcon(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGreen,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _RoundActionButton(icon: Icons.remove, onTap: onMinus),
          const SizedBox(width: 10),
          SizedBox(
            width: 52,
            child: Text(
              "${value}m",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkGreen,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _RoundActionButton(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _CircleIcon(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGreen,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.darkGreen,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFDDE6DD),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _AboutTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          _CircleIcon(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGreen,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.primary.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _CircleIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE6EFE6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, size: 18, color: AppTheme.primary),
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.black.withValues(alpha: 0.05),
    );
  }
}