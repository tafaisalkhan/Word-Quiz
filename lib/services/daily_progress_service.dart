import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DailyProgressEntry {
  const DailyProgressEntry({
    required this.date,
    required this.completed,
  });

  final DateTime date;
  final bool completed;
}

class DailyProgressService {
  DailyProgressService._();

  static final DailyProgressService instance = DailyProgressService._();

  static const String _completedDaysKey = 'completed_daily_quiz_days';
  static const String _timezoneName = 'Asia/Karachi';
  static const int _reminderId = 1001;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_timezoneName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(settings: initializationSettings);

    const androidDetails = AndroidNotificationDetails(
      'daily_quiz_reminder',
      'Daily Quiz Reminder',
      channelDescription: 'Reminder to complete the daily quiz',
      importance: Importance.max,
      priority: Priority.high,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'daily_quiz_reminder',
        'Daily Quiz Reminder',
        description: 'Reminder to complete the daily quiz',
        importance: Importance.max,
      ),
    );

    try {
      await _notifications.zonedSchedule(
        id: _reminderId,
        title: 'Daily quiz is ready',
        body: 'Complete today\'s quiz to keep your streak going.',
        scheduledDate: _nextReminderInstance(),
        notificationDetails: const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException catch (error) {
      if (error.code != 'exact_alarms_not_permitted') {
        rethrow;
      }

      await _notifications.zonedSchedule(
        id: _reminderId,
        title: 'Daily quiz is ready',
        body: 'Complete today\'s quiz to keep your streak going.',
        scheduledDate: _nextReminderInstance(),
        notificationDetails: const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<Set<String>> _loadCompletedDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_completedDaysKey)?.toSet() ?? <String>{};
  }

  Future<void> markCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final days = prefs.getStringList(_completedDaysKey) ?? <String>[];
    final today = _dayKey(DateTime.now());
    if (!days.contains(today)) {
      days.add(today);
      await prefs.setStringList(_completedDaysKey, days);
    }
  }

  Future<List<DailyProgressEntry>> loadRecentEntries({int days = 14}) async {
    final completed = await _loadCompletedDays();
    final today = DateTime.now();
    return List.generate(days, (index) {
      final date = today.subtract(Duration(days: days - index - 1));
      return DailyProgressEntry(
        date: date,
        completed: completed.contains(_dayKey(date)),
      );
    });
  }

  Future<List<DailyProgressEntry>> loadEntriesForMonth({
    required int year,
    required int month,
  }) async {
    final completed = await _loadCompletedDays();
    final firstDay = DateTime(year, month, 1);
    final nextMonth = month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    final daysInMonth = nextMonth.difference(firstDay).inDays;

    return List.generate(daysInMonth, (index) {
      final date = DateTime(year, month, index + 1);
      return DailyProgressEntry(
        date: date,
        completed: completed.contains(_dayKey(date)),
      );
    });
  }

  Future<int> completedCount({int days = 14}) async {
    final entries = await loadRecentEntries(days: days);
    return entries.where((entry) => entry.completed).length;
  }

  Future<int> missedCount({int days = 14}) async {
    final entries = await loadRecentEntries(days: days);
    return entries.where((entry) => !entry.completed).length;
  }

  String _dayKey(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  tz.TZDateTime _nextReminderInstance() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
