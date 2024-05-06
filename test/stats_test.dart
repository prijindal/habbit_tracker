import 'package:habbit_tracker/helpers/stats.dart';
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
  });
}
