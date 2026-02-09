import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import '../utils/location_lookup.dart';

class ICalService {
  static final ICalService instance = ICalService._();
  ICalService._();

  Future<bool> validateUrl(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return false;
      return response.body.contains('BEGIN:VCALENDAR') &&
          response.body.contains('BEGIN:VEVENT');
    } catch (e) {
      return false;
    }
  }

  Future<List<ICalEvent>> fetchAndParse(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch iCal: ${response.statusCode}');
    }
    return _parseICalString(response.body);
  }

  List<ICalEvent> _parseICalString(String content) {
    final calendar = ICalendar.fromString(content);
    final events = <ICalEvent>[];

    for (final data in calendar.data) {
      if (data['type'] == 'VEVENT') {
        try {
          events.add(ICalEvent.fromICalData(data));
        } catch (e) {
          // Skip malformed events
        }
      }
    }
    return events;
  }

  List<ICalEvent> filterLectures(List<ICalEvent> events) {
    final now = DateTime.now();
    final future = now.add(const Duration(days: 90));

    return events.where((event) {
      if (event.dtEnd.isBefore(now)) return false;
      if (event.dtStart.isAfter(future)) return false;
      final duration = event.dtEnd.difference(event.dtStart);
      if (duration.inHours >= 24) return false;
      if (duration.inMinutes < 30) return false;
      return true;
    }).toList();
  }
}

class ICalEvent {
  final String uid;
  final String summary;
  final String? description;
  final String? location;
  final DateTime dtStart;
  final DateTime dtEnd;
  final String? rrule;

  ICalEvent({
    required this.uid,
    required this.summary,
    this.description,
    this.location,
    required this.dtStart,
    required this.dtEnd,
    this.rrule,
  });

  factory ICalEvent.fromICalData(Map<String, dynamic> data) {
    DateTime parseDateTime(dynamic dt) {
      if (dt is IcsDateTime) return dt.toDateTime() ?? DateTime.now();
      if (dt is DateTime) return dt;
      if (dt is String) return DateTime.parse(dt);
      return DateTime.now();
    }

    return ICalEvent(
      uid:
          data['uid']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      summary: data['summary']?.toString() ?? 'Untitled',
      description: data['description']?.toString(),
      location: data['location']?.toString(),
      dtStart: parseDateTime(data['dtstart']),
      dtEnd: parseDateTime(data['dtend']),
      rrule: data['rrule']?.toString(),
    );
  }

  String get moduleCode {
    final match = RegExp(r'^([A-Z]{2,4}\d{4,5})').firstMatch(summary);
    return match?.group(1) ?? 'MISC';
  }

  String get title {
    return summary
        .replaceFirst(RegExp(r'^[A-Z]{2,4}\d{4,5}\s*[-:]\s*'), '')
        .trim();
  }

  Map<String, dynamic> toLectureJson(String timetableId) {
    final building = LocationLookup.resolve(location);

    return {
      'timetable_id': timetableId,
      'external_id': uid,
      'title': title.isEmpty ? summary : title,
      'module_code': moduleCode,
      'location': location ?? 'TBC',
      'latitude': building?.latitude ?? 0.0,
      'longitude': building?.longitude ?? 0.0,
      'start_time': dtStart.toIso8601String(),
      'end_time': dtEnd.toIso8601String(),
      'recurrence_rule': rrule,
    };
  }
}
