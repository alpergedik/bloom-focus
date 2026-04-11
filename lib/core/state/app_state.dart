import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class BloomAppState extends ChangeNotifier {
  static const int focusMinutesDefault = 25;
  static const int shortBreakMinutesDefault = 5;
  static const int longBreakMinutesDefault = 15;

  int focusMinutes = focusMinutesDefault;
  int shortBreakMinutes = shortBreakMinutesDefault;
  int longBreakMinutes = longBreakMinutesDefault;

  bool notificationsEnabled = true;
  bool soundEffectsEnabled = true;
  bool darkModeEnabled = false;

  int availableWaterMl = 0;
  int totalWaterGivenMl = 0;

  int completedSessions = 0;
  int totalFocusMinutes = 0;
  int currentStreakDays = 0;

  double plantHeightMeters = 1.2;
  double plantGrowthPercent = 0.62;
  int plantLevel = 5;
  String plantName = 'Sage';
  String plantStageName = 'Grown Plant';

  int selectedFocusMode = 0;
  int remainingSeconds = focusMinutesDefault * 60;
  bool isTimerRunning = false;
  int? timerLastUpdatedMillis;

  final Set<String> unlockedAchievementIds = {};
  final Map<String, List<PlanTask>> tasksByDate = {};

  static const String _focusMinutesKey = 'focus_minutes';
  static const String _shortBreakMinutesKey = 'short_break_minutes';
  static const String _longBreakMinutesKey = 'long_break_minutes';

  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _soundEffectsEnabledKey = 'sound_effects_enabled';
  static const String _darkModeEnabledKey = 'dark_mode_enabled';

  static const String _availableWaterMlKey = 'available_water_ml';
  static const String _totalWaterGivenMlKey = 'total_water_given_ml';
  static const String _completedSessionsKey = 'completed_sessions';
  static const String _totalFocusMinutesKey = 'total_focus_minutes';
  static const String _currentStreakDaysKey = 'current_streak_days';

  static const String _plantHeightMetersKey = 'plant_height_meters';
  static const String _plantGrowthPercentKey = 'plant_growth_percent';
  static const String _plantLevelKey = 'plant_level';
  static const String _plantNameKey = 'plant_name';
  static const String _plantStageNameKey = 'plant_stage_name';

  static const String _selectedFocusModeKey = 'selected_focus_mode';
  static const String _remainingSecondsKey = 'remaining_seconds';
  static const String _isTimerRunningKey = 'is_timer_running';
  static const String _timerLastUpdatedMillisKey = 'timer_last_updated_millis';

  static const String _unlockedAchievementIdsKey = 'unlocked_achievement_ids';
  static const String _tasksByDateKey = 'tasks_by_date';

  int get minutesForSelectedMode {
    switch (selectedFocusMode) {
      case 1:
        return shortBreakMinutes;
      case 2:
        return longBreakMinutes;
      default:
        return focusMinutes;
    }
  }

  int minutesForMode(int mode) {
    switch (mode) {
      case 1:
        return shortBreakMinutes;
      case 2:
        return longBreakMinutes;
      default:
        return focusMinutes;
    }
  }

  int get totalSecondsForSelectedMode => minutesForSelectedMode * 60;
  int get totalWaterEarned => availableWaterMl + totalWaterGivenMl;
  double get totalFocusHours => totalFocusMinutes / 60.0;

  String dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  List<PlanTask> tasksForDate(DateTime date) {
    final key = dateKey(date);
    final tasks = List<PlanTask>.from(tasksByDate[key] ?? []);
    tasks.sort((a, b) {
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return tasks;
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    focusMinutes = prefs.getInt(_focusMinutesKey) ?? focusMinutesDefault;
    shortBreakMinutes =
        prefs.getInt(_shortBreakMinutesKey) ?? shortBreakMinutesDefault;
    longBreakMinutes =
        prefs.getInt(_longBreakMinutesKey) ?? longBreakMinutesDefault;

    notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    soundEffectsEnabled = prefs.getBool(_soundEffectsEnabledKey) ?? true;
    darkModeEnabled = prefs.getBool(_darkModeEnabledKey) ?? false;

    availableWaterMl = prefs.getInt(_availableWaterMlKey) ?? 0;
    totalWaterGivenMl = prefs.getInt(_totalWaterGivenMlKey) ?? 0;
    completedSessions = prefs.getInt(_completedSessionsKey) ?? 0;
    totalFocusMinutes = prefs.getInt(_totalFocusMinutesKey) ?? 0;
    currentStreakDays = prefs.getInt(_currentStreakDaysKey) ?? 0;

    plantHeightMeters = prefs.getDouble(_plantHeightMetersKey) ?? 1.2;
    plantGrowthPercent = prefs.getDouble(_plantGrowthPercentKey) ?? 0.62;
    plantLevel = prefs.getInt(_plantLevelKey) ?? 5;
    plantName = prefs.getString(_plantNameKey) ?? 'Sage';
    plantStageName = prefs.getString(_plantStageNameKey) ?? 'Grown Plant';

    selectedFocusMode = prefs.getInt(_selectedFocusModeKey) ?? 0;
    remainingSeconds = prefs.getInt(_remainingSecondsKey) ??
        (minutesForMode(selectedFocusMode) * 60);
    isTimerRunning = prefs.getBool(_isTimerRunningKey) ?? false;
    timerLastUpdatedMillis = prefs.getInt(_timerLastUpdatedMillisKey);

    final storedAchievements =
        prefs.getStringList(_unlockedAchievementIdsKey) ?? <String>[];
    unlockedAchievementIds
      ..clear()
      ..addAll(storedAchievements);

    final tasksJson = prefs.getString(_tasksByDateKey);
    tasksByDate.clear();
    if (tasksJson != null && tasksJson.isNotEmpty) {
      final decoded = jsonDecode(tasksJson) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        final list = (value as List<dynamic>)
            .map((e) => PlanTask.fromMap(Map<String, dynamic>.from(e)))
            .toList();
        tasksByDate[key] = list;
      });
    }

    _reconcileRunningTimer();
    notifyListeners();
  }

  void _reconcileRunningTimer() {
    if (!isTimerRunning || timerLastUpdatedMillis == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = ((now - timerLastUpdatedMillis!) / 1000).floor();

    if (elapsedSeconds <= 0) return;

    remainingSeconds -= elapsedSeconds;

    if (remainingSeconds <= 0) {
      remainingSeconds = 0;
      isTimerRunning = false;
      timerLastUpdatedMillis = null;
    } else {
      timerLastUpdatedMillis = now;
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_focusMinutesKey, focusMinutes);
    await prefs.setInt(_shortBreakMinutesKey, shortBreakMinutes);
    await prefs.setInt(_longBreakMinutesKey, longBreakMinutes);

    await prefs.setBool(_notificationsEnabledKey, notificationsEnabled);
    await prefs.setBool(_soundEffectsEnabledKey, soundEffectsEnabled);
    await prefs.setBool(_darkModeEnabledKey, darkModeEnabled);

    await prefs.setInt(_availableWaterMlKey, availableWaterMl);
    await prefs.setInt(_totalWaterGivenMlKey, totalWaterGivenMl);
    await prefs.setInt(_completedSessionsKey, completedSessions);
    await prefs.setInt(_totalFocusMinutesKey, totalFocusMinutes);
    await prefs.setInt(_currentStreakDaysKey, currentStreakDays);

    await prefs.setDouble(_plantHeightMetersKey, plantHeightMeters);
    await prefs.setDouble(_plantGrowthPercentKey, plantGrowthPercent);
    await prefs.setInt(_plantLevelKey, plantLevel);
    await prefs.setString(_plantNameKey, plantName);
    await prefs.setString(_plantStageNameKey, plantStageName);

    await prefs.setInt(_selectedFocusModeKey, selectedFocusMode);
    await prefs.setInt(_remainingSecondsKey, remainingSeconds);
    await prefs.setBool(_isTimerRunningKey, isTimerRunning);

    if (timerLastUpdatedMillis != null) {
      await prefs.setInt(_timerLastUpdatedMillisKey, timerLastUpdatedMillis!);
    } else {
      await prefs.remove(_timerLastUpdatedMillisKey);
    }

    await prefs.setStringList(
      _unlockedAchievementIdsKey,
      unlockedAchievementIds.toList(),
    );

    final tasksMap = tasksByDate.map(
      (key, value) => MapEntry(
        key,
        value.map((task) => task.toMap()).toList(),
      ),
    );
    await prefs.setString(_tasksByDateKey, jsonEncode(tasksMap));
  }

  Future<void> updateFocusMinutes({
    int? focus,
    int? shortBreak,
    int? longBreak,
  }) async {
    if (focus != null) focusMinutes = focus;
    if (shortBreak != null) shortBreakMinutes = shortBreak;
    if (longBreak != null) longBreakMinutes = longBreak;

    if (!isTimerRunning) {
      remainingSeconds = minutesForMode(selectedFocusMode) * 60;
    }

    notifyListeners();
    await _saveToStorage();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled = value;
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> setSoundEffectsEnabled(bool value) async {
    soundEffectsEnabled = value;
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> setDarkModeEnabled(bool value) async {
    darkModeEnabled = value;
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> setSelectedFocusMode(int mode) async {
    selectedFocusMode = mode;
    isTimerRunning = false;
    timerLastUpdatedMillis = null;
    remainingSeconds = minutesForMode(mode) * 60;

    notifyListeners();
    await _saveToStorage();
  }

  Future<void> startTimerState() async {
    isTimerRunning = true;
    timerLastUpdatedMillis = DateTime.now().millisecondsSinceEpoch;

    notifyListeners();
    await _saveToStorage();
  }

  Future<void> pauseTimerState(int currentRemainingSeconds) async {
    remainingSeconds = currentRemainingSeconds;
    isTimerRunning = false;
    timerLastUpdatedMillis = null;

    notifyListeners();
    await _saveToStorage();
  }

  Future<void> tickTimerState(int currentRemainingSeconds) async {
    remainingSeconds = currentRemainingSeconds;
    timerLastUpdatedMillis = DateTime.now().millisecondsSinceEpoch;

    await _saveToStorage();
  }

  Future<void> resetTimerState() async {
    isTimerRunning = false;
    timerLastUpdatedMillis = null;
    remainingSeconds = minutesForMode(selectedFocusMode) * 60;

    notifyListeners();
    await _saveToStorage();
  }

  Future<List<String>> completeFocusSession() async {
    completedSessions += 1;
    totalFocusMinutes += focusMinutes;
    availableWaterMl += 10;
    currentStreakDays = completedSessions;

    notifyListeners();
    await _saveToStorage();

    return _checkAndStoreNewAchievements();
  }

  Future<List<String>> completeCurrentModeAndAdvance() async {
    isTimerRunning = false;
    timerLastUpdatedMillis = null;

    final List<String> newlyUnlocked = [];

    if (selectedFocusMode == 0) {
      final earned = await completeFocusSession();
      newlyUnlocked.addAll(earned);
      selectedFocusMode = completedSessions % 4 == 0 ? 2 : 1;
    } else {
      selectedFocusMode = 0;
    }

    remainingSeconds = minutesForMode(selectedFocusMode) * 60;

    notifyListeners();
    await _saveToStorage();

    return newlyUnlocked;
  }

  Future<List<String>> giveLife({int waterAmountMl = 10}) async {
    if (availableWaterMl <= 0) return [];

    final usableWater =
        availableWaterMl >= waterAmountMl ? waterAmountMl : availableWaterMl;

    availableWaterMl -= usableWater;
    totalWaterGivenMl += usableWater;

    plantGrowthPercent += usableWater / 100.0;
    plantHeightMeters += usableWater / 50.0;

    while (plantGrowthPercent >= 1.0) {
      plantGrowthPercent -= 1.0;
      plantLevel += 1;
      _updatePlantStage();
    }

    notifyListeners();
    await _saveToStorage();

    return _checkAndStoreNewAchievements();
  }

  Future<void> addTask({
    required DateTime date,
    required String title,
    required TimeOfDay time,
    required TaskCategory category,
  }) async {
    final key = dateKey(date);
    tasksByDate.putIfAbsent(key, () => []);
    tasksByDate[key]!.add(
      PlanTask(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        time: time,
        category: category,
      ),
    );

    notifyListeners();
    await _saveToStorage();
  }

  Future<void> updateTask({
    required String oldTaskId,
    required PlanTask updatedTask,
    required DateTime newDate,
  }) async {
    String? oldKey;

    for (final entry in tasksByDate.entries) {
      final index = entry.value.indexWhere((task) => task.id == oldTaskId);
      if (index != -1) {
        oldKey = entry.key;
        entry.value.removeAt(index);
        break;
      }
    }

    final newKey = dateKey(newDate);
    tasksByDate.putIfAbsent(newKey, () => []);
    tasksByDate[newKey]!.add(updatedTask);

    if (oldKey != null && tasksByDate[oldKey]!.isEmpty) {
      tasksByDate.remove(oldKey);
    }

    notifyListeners();
    await _saveToStorage();
  }

  Future<void> toggleTask({
    required DateTime date,
    required String taskId,
  }) async {
    final key = dateKey(date);
    final tasks = tasksByDate[key] ?? [];
    final index = tasks.indexWhere((task) => task.id == taskId);

    if (index == -1) return;

    tasks[index] = tasks[index].copyWith(
      isCompleted: !tasks[index].isCompleted,
    );

    notifyListeners();
    await _saveToStorage();
  }

  Future<PlanTask?> deleteTask({
    required DateTime date,
    required String taskId,
  }) async {
    final key = dateKey(date);
    final tasks = tasksByDate[key] ?? [];
    final index = tasks.indexWhere((task) => task.id == taskId);

    if (index == -1) return null;

    final removed = tasks.removeAt(index);

    if (tasks.isEmpty) {
      tasksByDate.remove(key);
    }

    notifyListeners();
    await _saveToStorage();
    return removed;
  }

  Future<void> restoreTask({
    required DateTime date,
    required PlanTask task,
  }) async {
    final key = dateKey(date);
    tasksByDate.putIfAbsent(key, () => []);
    tasksByDate[key]!.add(task);

    notifyListeners();
    await _saveToStorage();
  }

  DateTime? findTaskDate(String taskId) {
    for (final entry in tasksByDate.entries) {
      for (final task in entry.value) {
        if (task.id == taskId) {
          final parts = entry.key.split('-');
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      }
    }
    return null;
  }

  List<String> _checkAndStoreNewAchievements() {
    final newlyUnlocked = <String>[];

    final rules = <String, bool>{
      'first_session': completedSessions >= 1,
      'week_warrior': currentStreakDays >= 7,
      'focus_builder': completedSessions >= 25,
      'century_club': completedSessions >= 100,
      'deep_focus': totalFocusHours >= 5,
      'zen_master': totalFocusHours >= 25,
      'first_pour': totalWaterGivenMl > 0,
      'green_thumb': plantLevel >= 5,
      'blooming_soul':
          plantStageName == 'Flowering' || plantStageName == 'Full Bloom',
      'full_bloom': plantStageName == 'Full Bloom',
      'water_master': totalWaterEarned >= 1000,
    };

    for (final entry in rules.entries) {
      if (entry.value && !unlockedAchievementIds.contains(entry.key)) {
        unlockedAchievementIds.add(entry.key);
        newlyUnlocked.add(entry.key);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      _saveToStorage();
      notifyListeners();
    }

    return newlyUnlocked;
  }

  bool isAchievementUnlocked(String id) {
    return unlockedAchievementIds.contains(id);
  }

  void _updatePlantStage() {
    if (plantLevel <= 1) {
      plantStageName = 'Seedling';
    } else if (plantLevel <= 3) {
      plantStageName = 'First Leaves';
    } else if (plantLevel <= 5) {
      plantStageName = 'Grown Plant';
    } else if (plantLevel <= 7) {
      plantStageName = 'Flowering';
    } else {
      plantStageName = 'Full Bloom';
    }
  }

  String get plantHeightLabel => '${plantHeightMeters.toStringAsFixed(1)}m';
  String get growthLabel => '${(plantGrowthPercent * 100).round()}%';
  int get remainingToNextPercent => 100 - (plantGrowthPercent * 100).round();
}

class PlanTask {
  final String id;
  final String title;
  final TimeOfDay time;
  final TaskCategory category;
  final bool isCompleted;

  const PlanTask({
    required this.id,
    required this.title,
    required this.time,
    required this.category,
    this.isCompleted = false,
  });

  PlanTask copyWith({
    String? id,
    String? title,
    TimeOfDay? time,
    TaskCategory? category,
    bool? isCompleted,
  }) {
    return PlanTask(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'hour': time.hour,
      'minute': time.minute,
      'category': category.name,
      'isCompleted': isCompleted,
    };
  }

  factory PlanTask.fromMap(Map<String, dynamic> map) {
    return PlanTask(
      id: map['id'] as String,
      title: map['title'] as String,
      time: TimeOfDay(
        hour: map['hour'] as int,
        minute: map['minute'] as int,
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.work,
      ),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}

enum TaskCategory {
  work,
  study,
  health,
  personal,
}

extension TaskCategoryX on TaskCategory {
  TaskCategoryStyle get style {
    switch (this) {
      case TaskCategory.work:
        return const TaskCategoryStyle(
          label: 'Work',
          icon: Icons.work_outline_rounded,
          color: Color(0xFF8AAE93),
        );
      case TaskCategory.study:
        return const TaskCategoryStyle(
          label: 'Study',
          icon: Icons.menu_book_rounded,
          color: Color(0xFF8BC3E8),
        );
      case TaskCategory.health:
        return const TaskCategoryStyle(
          label: 'Health',
          icon: Icons.favorite_border_rounded,
          color: Color(0xFFF19393),
        );
      case TaskCategory.personal:
        return const TaskCategoryStyle(
          label: 'Personal',
          icon: Icons.self_improvement_rounded,
          color: Color(0xFFB69ADF),
        );
    }
  }
}

class TaskCategoryStyle {
  final String label;
  final IconData icon;
  final Color color;

  const TaskCategoryStyle({
    required this.label,
    required this.icon,
    required this.color,
  });
}