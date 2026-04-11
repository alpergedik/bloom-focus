import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with TickerProviderStateMixin {
  late DateTime _today;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDate = DateTime(_today.year, _today.month, _today.day);
  }

  List<DateTime> get _weekDays {
    final weekday = _today.weekday;
    final monday = _today.subtract(Duration(days: weekday - 1));
    return List.generate(
      7,
      (index) => DateTime(monday.year, monday.month, monday.day + index),
    );
  }

  List<PlanTask> _selectedTasks(BloomAppState appState) {
    return appState.tasksForDate(_selectedDate);
  }

  int _completedCount(BloomAppState appState) =>
      _selectedTasks(appState).where((task) => task.isCompleted).length;

  int _completionPercent(BloomAppState appState) {
    final tasks = _selectedTasks(appState);
    if (tasks.isEmpty) return 0;
    return ((_completedCount(appState) / tasks.length) * 100).round();
  }

  Future<void> _openAddTaskSheet() async {
    String title = '';
    TimeOfDay selectedTime = TimeOfDay.now();
    TaskCategory selectedCategory = TaskCategory.work;
    DateTime selectedDate = _selectedDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FAF5),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 52,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Add New Task',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.darkGreen,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Plan your day in a calm and focused way 🌿',
                        style: TextStyle(
                          color: AppTheme.primary.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Task title',
                        style: TextStyle(
                          color: AppTheme.primary.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        autofocus: true,
                        cursorColor: AppTheme.darkGreen,
                        onChanged: (value) => title = value,
                        decoration: InputDecoration(
                          hintText: 'e.g. Finish assignment',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _SheetInfoButton(
                              icon: Icons.schedule_rounded,
                              label: _formatTime(selectedTime),
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    selectedTime = picked;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SheetInfoButton(
                              icon: Icons.calendar_today_rounded,
                              label:
                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(_today.year - 1),
                                  lastDate: DateTime(_today.year + 2),
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    selectedDate = DateTime(
                                      picked.year,
                                      picked.month,
                                      picked.day,
                                    );
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Category',
                        style: TextStyle(
                          color: AppTheme.primary.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: TaskCategory.values.map((category) {
                          final selected = category == selectedCategory;
                          final style = category.style;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedCategory = category;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? style.color.withValues(alpha: 0.20)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? style.color.withValues(alpha: 0.55)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    style.icon,
                                    size: 18,
                                    color: style.color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    style.label,
                                    style: TextStyle(
                                      color: selected
                                          ? AppTheme.darkGreen
                                          : AppTheme.primary.withValues(alpha: 0.85),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final trimmed = title.trim();
                            if (trimmed.isEmpty) return;

                            await context.read<BloomAppState>().addTask(
                                  date: selectedDate,
                                  title: trimmed,
                                  time: selectedTime,
                                  category: selectedCategory,
                                );

                            if (!mounted) return;

                            setState(() {
                              _selectedDate = selectedDate;
                            });

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppTheme.darkGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text(
                            'Add Task',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openEditTaskSheet(PlanTask task) async {
    final controller = TextEditingController(text: task.title);
    TimeOfDay selectedTime = task.time;
    TaskCategory selectedCategory = task.category;
    DateTime selectedDate =
        context.read<BloomAppState>().findTaskDate(task.id) ?? _selectedDate;
    bool isCompleted = task.isCompleted;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FAF5),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 52,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Edit Task',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.darkGreen,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adjust your plan gently and keep moving 🌱',
                        style: TextStyle(
                          color: AppTheme.primary.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Task title',
                        style: TextStyle(
                          color: AppTheme.primary.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller,
                        cursorColor: AppTheme.darkGreen,
                        decoration: InputDecoration(
                          hintText: 'Task title',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _SheetInfoButton(
                              icon: Icons.schedule_rounded,
                              label: _formatTime(selectedTime),
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    selectedTime = picked;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SheetInfoButton(
                              icon: Icons.calendar_today_rounded,
                              label:
                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(_today.year - 1),
                                  lastDate: DateTime(_today.year + 2),
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    selectedDate = DateTime(
                                      picked.year,
                                      picked.month,
                                      picked.day,
                                    );
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Category',
                        style: TextStyle(
                          color: AppTheme.primary.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: TaskCategory.values.map((category) {
                          final selected = category == selectedCategory;
                          final style = category.style;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedCategory = category;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? style.color.withValues(alpha: 0.20)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? style.color.withValues(alpha: 0.55)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(style.icon, size: 18, color: style.color),
                                  const SizedBox(width: 8),
                                  Text(
                                    style.label,
                                    style: TextStyle(
                                      color: selected
                                          ? AppTheme.darkGreen
                                          : AppTheme.primary.withValues(alpha: 0.85),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.darkGreen,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: isCompleted,
                              activeThumbColor: Colors.white,
                              activeTrackColor: AppTheme.darkGreen,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: const Color(0xFFDDE6DD),
                              onChanged: (value) {
                                setModalState(() {
                                  isCompleted = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: AppTheme.primary.withValues(alpha: 0.20),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppTheme.primary.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final trimmed = controller.text.trim();
                                if (trimmed.isEmpty) return;

                                await context.read<BloomAppState>().updateTask(
                                      oldTaskId: task.id,
                                      updatedTask: task.copyWith(
                                        title: trimmed,
                                        time: selectedTime,
                                        category: selectedCategory,
                                        isCompleted: isCompleted,
                                      ),
                                      newDate: selectedDate,
                                    );

                                if (!mounted) return;

                                setState(() {
                                  _selectedDate = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                  );
                                });

                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AppTheme.darkGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleTask(String id) async {
    await context.read<BloomAppState>().toggleTask(
          date: _selectedDate,
          taskId: id,
        );
  }

  Future<void> _deleteTask(String id) async {
    final removedTask = await context.read<BloomAppState>().deleteTask(
          date: _selectedDate,
          taskId: id,
        );

    if (removedTask != null && mounted) {
      final restoreDate = _selectedDate;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.darkGreen,
          content: const Text(
            'Task deleted',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () {
              context.read<BloomAppState>().restoreTask(
                    date: restoreDate,
                    task: removedTask,
                  );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<BloomAppState>();
    final selectedTasks = _selectedTasks(appState);
    final completedCount = _completedCount(appState);
    final completionPercent = _completionPercent(appState);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3EA),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY PLANNER',
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
                        'Your Plan',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppTheme.darkGreen,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('🗓️', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _buildWeekSelector(),
                  const SizedBox(height: 22),
                  _buildDaySummary(
                    selectedTasks: selectedTasks,
                    completedCount: completedCount,
                    completionPercent: completionPercent,
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: selectedTasks.isEmpty
                        ? _EmptyTasksCard(
                            key: ValueKey(context.read<BloomAppState>().dateKey(_selectedDate)),
                            onAddTask: _openAddTaskSheet,
                          )
                        : Column(
                            key: ValueKey(context.read<BloomAppState>().dateKey(_selectedDate)),
                            children: selectedTasks
                                .map(
                                  (task) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _TaskCard(
                                      task: task,
                                      onToggle: () => _toggleTask(task.id),
                                      onDelete: () => _deleteTask(task.id),
                                      onEdit: () => _openEditTaskSheet(task),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 18,
              child: FloatingActionButton(
                elevation: 0,
                backgroundColor: AppTheme.darkGreen,
                onPressed: _openAddTaskSheet,
                child: const Icon(Icons.add_rounded, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    final days = _weekDays;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: days.map((day) {
          final selected = _isSameDay(day, _selectedDate);
          final isToday = _isSameDay(day, _today);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = DateTime(day.year, day.month, day.day);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.darkGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppTheme.darkGreen.withValues(alpha: 0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 7),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Text(
                      _weekdayShort(day.weekday),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white.withValues(alpha: 0.92)
                            : AppTheme.primary.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: isToday && !selected ? 1 : 0,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDaySummary({
    required List<PlanTask> selectedTasks,
    required int completedCount,
    required int completionPercent,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_weekdayFull(_selectedDate.weekday)}, ${_monthName(_selectedDate.month)} ${_selectedDate.day}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completedCount/${selectedTasks.length} tasks completed',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primary.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$completionPercent% done',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkGreen,
            ),
          ),
        ),
      ],
    );
  }

  String _weekdayShort(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  String _weekdayFull(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return names[weekday - 1];
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[month - 1];
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _TaskCard extends StatelessWidget {
  final PlanTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final style = task.category.style;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4B8B8),
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: task.isCompleted ? 0.72 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onEdit,
            child: Row(
              children: [
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? const Color(0xFF7FB48B)
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? const Color(0xFF7FB48B)
                            : AppTheme.primary.withValues(alpha: 0.45),
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkGreen,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor:
                              AppTheme.primary.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            _formatTime(task.time),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.primary.withValues(alpha: 0.72),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          _CategoryChip(style: style),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7F3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: AppTheme.primary.withValues(alpha: 0.72),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class _CategoryChip extends StatelessWidget {
  final TaskCategoryStyle style;

  const _CategoryChip({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.color),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: style.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetInfoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetInfoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.darkGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTasksCard extends StatelessWidget {
  final VoidCallback onAddTask;

  const _EmptyTasksCard({
    super.key,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_note_rounded,
            size: 34,
            color: AppTheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          const Text(
            'No tasks for this day yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add your first task and make the day feel intentional 🌿',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primary.withValues(alpha: 0.78),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAddTask,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppTheme.darkGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Add Task',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}