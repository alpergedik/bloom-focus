import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_state.dart';
import '../../settings/presentation/settings_page.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage>
    with TickerProviderStateMixin {
  Timer? timer;
  bool isRunning = false;
  int selectedMode = 0; // 0 Focus, 1 Short Break, 2 Long Break

  late int remainingSeconds;

  late final AnimationController _pulseController;
  late final AnimationController _entryController;

  late final Animation<double> _pulseAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  int get currentModeMinutes {
    switch (selectedMode) {
      case 1:
        return AppState.shortBreakMinutes;
      case 2:
        return AppState.longBreakMinutes;
      default:
        return AppState.focusMinutes;
    }
  }

  int get totalSeconds => currentModeMinutes * 60;

  double get progress {
    if (totalSeconds == 0) return 0;
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }

  @override
  void initState() {
    super.initState();

    remainingSeconds = AppState.focusMinutes * 60;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.025,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entryController.forward();
  }

  void applySelectedMode() {
    timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    setState(() {
      isRunning = false;
      remainingSeconds = currentModeMinutes * 60;
    });
  }

  void startTimer() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
    });

    _pulseController.repeat(reverse: true);

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer?.cancel();

        setState(() {
          isRunning = false;

          if (selectedMode == 0) {
            AppState.water += 10;
            AppState.plantHeight += 0.2;
            AppState.completedSessions += 1;
          }
        });

        _pulseController.stop();
        _pulseController.reset();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.darkGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            content: Text(
              selectedMode == 0
                  ? "Focus session complete! +10 water, plant grew +0.2m 🌱"
                  : "Break complete! Ready for your next focus session 💚",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

        if (selectedMode == 0) {
          setState(() {
            selectedMode =
                AppState.completedSessions % 4 == 0 ? 2 : 1; // long or short
            remainingSeconds = currentModeMinutes * 60;
          });
        } else {
          setState(() {
            selectedMode = 0;
            remainingSeconds = currentModeMinutes * 60;
          });
        }
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
    _pulseController.stop();
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      remainingSeconds = currentModeMinutes * 60;
      isRunning = false;
    });
    _pulseController.stop();
    _pulseController.reset();
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning 👋";
    if (hour < 18) return "Good Afternoon ☀️";
    return "Good Evening 🌙";
  }

  String get modeLabel {
    switch (selectedMode) {
      case 1:
        return "SHORT BREAK";
      case 2:
        return "LONG BREAK";
      default:
        return "FOCUS";
    }
  }

  String get motivationText {
    if (isRunning) {
      switch (selectedMode) {
        case 1:
          return "Take a gentle pause, you earned it 🌿";
        case 2:
          return "Relax deeply and reset your energy 💚";
        default:
          return "You're doing great, keep going 💚";
      }
    } else {
      switch (selectedMode) {
        case 1:
          return "Time for a short break ✨";
        case 2:
          return "Enjoy your long break 🌙";
        default:
          return "Ready to grow? Start your session 🌿";
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _pulseController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 22),
                _buildStatsRow(),
                const SizedBox(height: 26),
                _buildModeSelector(),
                const SizedBox(height: 34),
                Center(child: _buildTimer(theme)),
                const SizedBox(height: 26),
                _buildMotivationText(theme),
                const SizedBox(height: 28),
                _buildControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primary.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Bloom Focus",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkGreen,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SettingsPage(),
              ),
            ).then((_) {
              applySelectedMode();
            });
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.settings_rounded,
              color: AppTheme.primary.withValues(alpha: 0.85),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.bolt_rounded,
            title: "Focus",
            value: "${AppState.focusMinutes}m",
            iconColor: const Color(0xFF7FA88E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.water_drop_rounded,
            title: "Water",
            value: "${AppState.water}ml",
            iconColor: const Color(0xFF63A9D8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            title: "Streak",
            value: "${AppState.completedSessions}d 🔥",
            iconColor: const Color(0xFFF09A5A),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    final items = ["Focus", "Short Break", "Long Break"];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = selectedMode == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedMode = index;
                });
                applySelectedMode();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.darkGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppTheme.darkGreen.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  items[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : AppTheme.primary.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimer(ThemeData theme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isRunning ? _pulseAnimation.value : 1,
          child: SizedBox(
            width: 290,
            height: 290,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (context, value, _) {
                    return SizedBox(
                      width: 290,
                      height: 290,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 9,
                        backgroundColor: Colors.white.withValues(alpha: 0.42),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          selectedMode == 0
                              ? AppTheme.darkGreen
                              : AppTheme.primary,
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.44),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.55),
                      width: 7,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        modeLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.primary.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.98,
                                end: 1,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          formatTime(remainingSeconds),
                          key: ValueKey("${selectedMode}_$remainingSeconds"),
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkGreen,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        selectedMode == 0
                            ? "Session ${AppState.completedSessions + 1}"
                            : selectedMode == 1
                                ? "Quick reset"
                                : "Deep reset",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primary.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMotivationText(ThemeData theme) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Text(
          motivationText,
          key: ValueKey("${selectedMode}_$isRunning"),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.primary.withValues(alpha: 0.88),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.68),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: IconButton(
            onPressed: resetTimer,
            icon: const Icon(Icons.refresh_rounded),
            color: AppTheme.primary.withValues(alpha: 0.85),
            iconSize: 26,
          ),
        ),
        const SizedBox(width: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: (isRunning
                        ? const Color(0xFFE06A6A)
                        : AppTheme.darkGreen)
                    .withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isRunning ? pauseTimer : startTimer,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor:
                  isRunning ? const Color(0xFFE06A6A) : AppTheme.darkGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 34,
                vertical: 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Row(
                key: ValueKey("${selectedMode}_$isRunning"),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRunning
                        ? "Pause"
                        : selectedMode == 0
                            ? "Start Focus"
                            : "Start Break",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primary.withValues(alpha: 0.72),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.darkGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}