import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/utils/location_lookup.dart';

void main() {
  group('UT-INV-03 Location lookup invalid and border inputs', () {
    test('returns null for null input', () {
      expect(LocationLookup.resolve(null), isNull);
    });

    test('returns null for empty and whitespace input', () {
      expect(LocationLookup.resolve(''), isNull);
      expect(LocationLookup.resolve('   '), isNull);
      expect(LocationLookup.resolve('\n\t'), isNull);
    });

    test('returns null for symbol-only input', () {
      expect(LocationLookup.resolve('@@@ ### !!!'), isNull);
    });

    test('returns null for unknown location text', () {
      expect(LocationLookup.resolve('Building That Does Not Exist'), isNull);
    });
  });
}
