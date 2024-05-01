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
    final entries = List<HabbitEntry>.from(widget.entries ?? [])
      ..sort((a, b) {
        return a.creationTime.difference(b.creationTime).inSeconds;
      });
    return [
      entries.firstOrNull?.creationTime.toLocal() ??
          (DateTime.now().subtract(const Duration(days: 1))),
      entries.lastOrNull?.creationTime.toLocal() ??
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
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
        weekendStyle: TextStyle(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      calendarStyle: CalendarStyle(
        markerDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.inverseSurface,
          fontSize: 16.0,
        ),
      ),
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
          return const ListTile(title: Text("No Entry"));
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
