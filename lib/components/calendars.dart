import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/core.dart';
import 'habbit_entry_tile.dart';

enum StatsIntervals { oneWeek, oneMonth, threeMonths, oneYear, all }

class CalendarsSubPage extends StatefulWidget {
  const CalendarsSubPage({
    super.key,
    required this.entries,
    required this.habbit,
  });

  final List<HabbitEntry>? entries;
  final Habbit? habbit;

  @override
  State<CalendarsSubPage> createState() => _CalendarsSubPageState();
}

class _CalendarsSubPageState extends State<CalendarsSubPage> {
  late DateTime _focusedDay = _lastDay;
  CalendarFormat _calendarformat = CalendarFormat.month;

  List<DateTime> _firstAndLast() {
    final entries = (widget.entries ?? [])
      ..sort((a, b) {
        return a.creationTime.difference(b.creationTime).inSeconds;
      });
    return [
      entries.firstOrNull?.creationTime ??
          (DateTime.now().subtract(const Duration(days: 1))),
      entries.lastOrNull?.creationTime ??
          (DateTime.now().add(const Duration(days: 1))),
    ];
  }

  DateTime get _firstDay {
    return _firstAndLast()[0];
  }

  DateTime get _lastDay {
    return _firstAndLast()[1];
  }

  List<HabbitEntry> _getEventsForDay(DateTime day) {
    return widget.entries!
        .where((element) => isSameDay(day, element.creationTime.toLocal()))
        .toList();
  }

  Widget _buildTable() {
    return TableCalendar(
      calendarFormat: _calendarformat,
      onFormatChanged: (calendarFormat) {
        setState(() {
          _calendarformat = calendarFormat;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      eventLoader: (day) {
        return _getEventsForDay(day);
      },
      selectedDayPredicate: (day) {
        return isSameDay(_focusedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      currentDay: DateTime.now(),
      focusedDay: _focusedDay,
      firstDay: _firstDay,
      lastDay: _lastDay,
    );
  }

  Widget _buildEvents(List<HabbitEntry> entries) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
      itemCount: entries.isNotEmpty ? entries.length : 1,
      itemBuilder: (BuildContext context, int index) {
        if (entries.isEmpty) {
          return const Text("No Entry");
        }
        final entry = entries[index];
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: HabbitEntryTile(
                habbit: widget.habbit!.id,
                entry: entry,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTable(),
        const SizedBox(height: 8.0),
        _buildEvents(_getEventsForDay(_focusedDay)),
      ],
    );
  }
}
