import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const HourglassDoApp());
}

// ============================================================
// HOURGLASSDO
// Modern Antique / Historic Minimalist Productivity App
// Complete single-file Flutter application.
// No third-party packages required.
// ============================================================

// COLOUR PALETTE
const Color bg = Color(0xFF171A1D);
const Color panel = Color(0xFF242729);
const Color brass = Color(0xFFB38A49);
const Color parchment = Color(0xFFE6D2A7);
const Color muted = Color(0xFFA7A39A);
const Color borderGold = Color(0xFF514633);

// ============================================================
// APP ENTRY POINT AND THEME
// ============================================================

class HourglassDoApp extends StatelessWidget {
  const HourglassDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HourglassDo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brass,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: parchment,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// ============================================================
// HABIT MODEL
// ============================================================

class Habit {
  final String title;
  final IconData icon;
  bool completed;

  Habit({
    required this.title,
    required this.icon,
    this.completed = false,
  });
}

// ============================================================
// MAIN DASHBOARD SCREEN
// ============================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ---------------- POMODORO TIMER ----------------

  static const int focusDuration = 25 * 60;

  int remainingSeconds = focusDuration;
  int completedSessions = 0;
  bool isRunning = false;
  Timer? countdown;

  // ---------------- HABITS ----------------

  final List<Habit> habits = [
    Habit(title: 'Read for 20 minutes', icon: Icons.menu_book),
    Habit(title: 'Study mathematics', icon: Icons.calculate),
    Habit(title: 'Review science notes', icon: Icons.science),
    Habit(title: 'Write daily log', icon: Icons.edit_note),
  ];

  // ---------------- MOCK STREAK HISTORY ----------------
  // These values are examples, not calculated real history.

  int currentStreak = 7;
  int longestStreak = 12;

  // Example weekly history: completed activity for each day.
  final List<bool> weekHistory = [
    true,
    true,
    false,
    true,
    true,
    true,
    true,
  ];

  final List<String> weekdays = [
    'M', 'T', 'W', 'T', 'F', 'S', 'S'
  ];

  // ---------------- JOURNAL ----------------

  final TextEditingController journalController =
      TextEditingController();

  String savedJournal = '';

  // ---------------- CALCULATED VALUES ----------------

  int get completedHabits =>
      habits.where((habit) => habit.completed).length;

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  double get timerProgress =>
      remainingSeconds / focusDuration;

  // ============================================================
  // TIMER CONTROLS
  // ============================================================

  void startTimer() {
    if (isRunning) return;

    if (remainingSeconds <= 0) {
      remainingSeconds = focusDuration;
    }

    setState(() {
      isRunning = true;
    });

    countdown = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (remainingSeconds > 1) {
          setState(() {
            remainingSeconds--;
          });
        } else {
          timer.cancel();
          countdown = null;

          setState(() {
            remainingSeconds = 0;
            isRunning = false;
            completedSessions++;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Focus session completed. Well done!'),
              backgroundColor: Color(0xFF514633),
            ),
          );
        }
      },
    );
  }

  void pauseTimer() {
    countdown?.cancel();
    countdown = null;

    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    countdown?.cancel();
    countdown = null;

    setState(() {
      isRunning = false;
      remainingSeconds = focusDuration;
    });
  }

  // ============================================================
  // HABIT CONTROLS
  // ============================================================

  void toggleHabit(int index, bool value) {
    setState(() {
      habits[index].completed = value;
    });
  }

  // ============================================================
  // JOURNAL SAVE
  // Saves to memory during this app session only.
  // ============================================================

  void saveJournal() {
    setState(() {
      savedJournal = journalController.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Journal entry saved for this session.'),
        backgroundColor: Color(0xFF514633),
      ),
    );
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  @override
  void dispose() {
    countdown?.cancel();
    journalController.dispose();
    super.dispose();
  }

  // ============================================================
  // MAIN PAGE LAYOUT
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  22, 20, 22, 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: brass,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.hourglass_bottom,
                        color: bg,
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HourglassDo',
                            style: TextStyle(
                              color: parchment,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.8,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'YOUR DAILY CHRONICLE',
                            style: TextStyle(
                              color: muted,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.explore_outlined,
                      color: brass,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),

            // WELCOME TEXT
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  22, 25, 22, 18,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR TIME IS NOW',
                      style: TextStyle(
                        color: brass,
                        fontSize: 10,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Make every moment count.',
                      style: TextStyle(
                        color: parchment,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'A little progress, faithfully repeated.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TIMER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: buildTimerCard(),
              ),
            ),

            // HABIT SECTION HEADING
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  22, 29, 22, 12,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Today's Duties",
                        style: TextStyle(
                          color: parchment,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '$completedHabits/${habits.length} DONE',
                      style: const TextStyle(
                        color: brass,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // HABITS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: buildHabitCard(),
              ),
            ),

            // HABIT PROGRESS BAR
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  22, 12, 22, 0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completedHabits / habits.length,
                    minHeight: 5,
                    backgroundColor: panel,
                    color: brass,
                  ),
                ),
              ),
            ),

            // HISTORY HEADING
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  22, 29, 22, 12,
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'The Chronicle',
                        style: TextStyle(
                          color: parchment,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.history,
                      color: brass,
                    ),
                  ],
                ),
              ),
            ),

            // STREAK CARDS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: buildHistoryCards(),
              ),
            ),

            // WEEKLY HISTORY
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  18, 12, 18, 0,
                ),
                child: buildWeeklyHistory(),
              ),
            ),

            // JOURNAL HEADING
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  22, 29, 22, 12,
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: brass,
                      size: 27,
                    ),
                    SizedBox(width: 9),
                    Text(
                      "Captain's Log",
                      style: TextStyle(
                        color: parchment,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // JOURNAL
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  18, 0, 18, 30,
                ),
                child: buildJournalCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TIMER CARD
  // ============================================================

  Widget buildTimerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderGold),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.hourglass_empty,
                color: brass,
                size: 19,
              ),
              SizedBox(width: 9),
              Text(
                'FOCUS SESSION',
                style: TextStyle(
                  color: brass,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                '25 MINUTES',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Animated custom-painted antique hourglass.
          SizedBox(
            height: 155,
            width: 140,
            child: CustomPaint(
              painter: HourglassPainter(
                progress: timerProgress,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            formattedTime,
            style: const TextStyle(
              color: parchment,
              fontSize: 46,
              fontWeight: FontWeight.w300,
              letterSpacing: 3,
              fontFeatures: [
                FontFeature.tabularFigures(),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Text(
            isRunning
                ? 'Stay present. One task at a time.'
                : remainingSeconds == 0
                    ? 'Session complete. Well done.'
                    : 'A quiet hour begins with one minute.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed:
                      isRunning ? pauseTimer : startTimer,
                  icon: Icon(
                    isRunning
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  label: Text(
                    isRunning ? 'Pause' : 'Begin focus',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brass,
                    foregroundColor: bg,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: resetTimer,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: parchment,
                    side: const BorderSide(
                      color: borderGold,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: brass,
                size: 15,
              ),
              const SizedBox(width: 7),
              Text(
                'Sessions completed: $completedSessions',
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HABIT CHECKLIST CARD
  // ============================================================

  Widget buildHabitCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGold),
      ),
      child: Column(
        children: List.generate(habits.length, (index) {
          final habit = habits[index];

          return Column(
            children: [
              CheckboxListTile(
                value: habit.completed,
                onChanged: (value) {
                  toggleHabit(index, value ?? false);
                },
                activeColor: brass,
                c
