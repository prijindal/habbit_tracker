import 'package:habbit_tracker/helpers/stats.dart';
import 'package:habbit_tracker/models/core.dart';
import 'package:test/test.dart';

void main() {
  group('Test stats helpers', () {
    test('Formatted date', () {
      final date = DateTime(2000, 1, 1, 0, 0, 0, 0, 0);
      expect(formatDate(date, HabbitDateFormat.shortTime), "Sat 12:00 AM");
      expect(formatDate(date, HabbitDateFormat.shortDate), "Sat, Jan 1");
      expect(
          formatDate(date, HabbitDateFormat.long), "Sat, Jan 1, 2000 12:00 AM");
    });
    test('Convert entries into durations', () {
      final entries = [
        HabbitEntryData(
          id: "1",
          creationTime: DateTime(2000, 1, 1, 0, 0, 0, 0, 0),
          habbit: "habbit-1",
        ),
        HabbitEntryData(
          id: "1",
          creationTime: DateTime(2000, 1, 1, 2, 0, 0, 0, 0),
          habbit: "habbit-1",
        )
      ];
      final durations = allDurationsData(entries);
      expect(durations.length, 1);
      expect(
        durations[0] ==
            DurationData(
              duration: Duration(hours: 2),
              start: DateTime(2000, 1, 1, 0, 0, 0, 0, 0),
              end: DateTime(2000, 1, 1, 2, 0, 0, 0, 0),
            ),
        true,
      );
    });

    test('Convert entries into Counts per days', () {
      final entries = [
        HabbitEntryData(
          id: "1",
          creationTime: DateTime(2000, 1, 1, 0, 0, 0, 0, 0),
          habbit: "habbit-1",
        ),
        HabbitEntryData(
          id: "1",
          creationTime: DateTime(2000, 1, 1, 2, 0, 0, 0, 0),
          habbit: "habbit-1",
        ),
        HabbitEntryData(
          id: "1",
          creationTime: DateTime(2000, 1, 2, 0, 0, 0, 0, 0),
          habbit: "habbit-1",
        )
      ];
      final counts = countPerDaysData(entries);
      expect(counts.length, 2);
      expect(
        counts[0] ==
            CountsDayData(date: DateTime(2000, 1, 1, 0, 0, 0, 0, 0), count: 2),
        true,
      );
      expect(
        counts[1] ==
            CountsDayData(date: DateTime(2000, 1, 2, 0, 0, 0, 0, 0), count: 1),
        true,
      );
    });
  });
}
