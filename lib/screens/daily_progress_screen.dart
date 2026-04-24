import 'package:flutter/material.dart';

import '../services/daily_progress_service.dart';

class DailyProgressScreen extends StatefulWidget {
  const DailyProgressScreen({super.key});

  @override
  State<DailyProgressScreen> createState() => _DailyProgressScreenState();
}

class _DailyProgressScreenState extends State<DailyProgressScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  void _goPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });
  }

  void _goNextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Progress')),
      body: FutureBuilder<List<DailyProgressEntry>>(
        future: DailyProgressService.instance.loadEntriesForMonth(
          year: _selectedMonth.year,
          month: _selectedMonth.month,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data!;
          final completed = entries.where((entry) => entry.completed).length;
          final missed = entries.length - completed;
          final monthLabel = _monthLabel(_selectedMonth);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SummaryCard(
                monthLabel: monthLabel,
                completed: completed,
                missed: missed,
                totalDays: entries.length,
              ),
              const SizedBox(height: 16),
              _MonthNavigator(
                label: monthLabel,
                onPrevious: _goPreviousMonth,
                onNext: _goNextMonth,
              ),
              const SizedBox(height: 16),
              const _CalendarLegend(),
              const SizedBox(height: 16),
              _CalendarGrid(entries: entries, monthStart: _selectedMonth),
            ],
          );
        },
      ),
    );
  }

  String _monthLabel(DateTime date) {
    const months = <String>[
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
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        _LegendChip(color: Color(0xFF1B8F3A), label: 'Completed'),
        _LegendChip(color: Color(0xFFE53935), label: 'Missed'),
        _LegendChip(color: Color(0xFFE8D8FF), label: 'No data'),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.entries,
    required this.monthStart,
  });

  final List<DailyProgressEntry> entries;
  final DateTime monthStart;

  @override
  Widget build(BuildContext context) {
    final leadingEmptyCells = monthStart.weekday % 7;
    final trailingEmptyCells = (7 - ((leadingEmptyCells + entries.length) % 7)) % 7;
    final tiles = <Widget>[
      for (final day in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
        _WeekdayTile(label: day),
      for (var i = 0; i < leadingEmptyCells; i++) const SizedBox.shrink(),
      for (final entry in entries) _DayTile(entry: entry),
      for (var i = 0; i < trailingEmptyCells; i++) const SizedBox.shrink(),
    ];

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: tiles,
    );
  }
}

class _WeekdayTile extends StatelessWidget {
  const _WeekdayTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Color(0xFF67537C),
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.entry});

  final DailyProgressEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = entry.completed ? const Color(0xFF1B8F3A) : const Color(0xFFE53935);

    return Container(
      decoration: BoxDecoration(
        color: entry.completed ? color.withValues(alpha: 0.15) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.completed ? color : const Color(0xFFE3D5F1),
          width: 1.4,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${entry.date.day}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E2240),
            ),
          ),
          const SizedBox(height: 2),
          Icon(
            entry.completed ? Icons.check_rounded : Icons.close_rounded,
            size: 22,
            color: entry.completed ? color : const Color(0xFFB8A6C9),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.monthLabel,
    required this.completed,
    required this.missed,
    required this.totalDays,
  });

  final String monthLabel;
  final int completed;
  final int missed;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(monthLabel, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Completed: $completed'),
            Text('Missed: $missed'),
            Text('Days in month: $totalDays'),
          ],
        ),
      ),
    );
  }
}
