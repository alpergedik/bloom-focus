import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_state.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  static const int initialSeconds = 25 * 60;

  int remainingSeconds = initialSeconds;
  Timer? timer;
  bool isRunning = false;

  double get progress =>
      (initialSeconds - remainingSeconds) / initialSeconds;

  void startTimer() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer?.cancel();

        setState(() {
          isRunning = false;
          AppState.water += 10;
          AppState.plantHeight += 0.2;
          AppState.completedSessions += 1;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Session complete! +10 water, plant grew +0.2m 🌱",
            ),
          ),
        );
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      remainingSeconds = initialSeconds;
      isRunning = false;
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 40),

          Text(
            "Focus",
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 260,
                  height: 260,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: AppTheme.primary.withOpacity(0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.darkGreen,
                    ),
                  ),
                ),
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.15),
                      width: 6,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "FOCUS",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formatTime(remainingSeconds),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Session ${AppState.completedSessions + 1}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primary.withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Text(
            isRunning
                ? "You're doing great, keep going 💚"
                : "Ready to grow? Start your session 🌿",
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: resetTimer,
                icon: const Icon(Icons.refresh_rounded),
                color: AppTheme.primary,
                iconSize: 28,
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: isRunning ? pauseTimer : startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isRunning ? const Color(0xFFE06A6A) : AppTheme.darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isRunning ? "Pause" : "Start Focus",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}