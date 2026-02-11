import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import '../utils/location_lookup.dart';

class ICalService {
  static final ICalService instance = ICalService._();
  ICalService._();

  Future<bool> validateUrl(String url) async {
    try {
      final content = await _fetchICalContent(url);
      return _looksLikeICal(content);
    } catch (_) {
      return false;
    }
  }

  Future<List<ICalEvent>> fetchAndParse(String url) async {
    final content = await _fetchICalContent(url);
    if (!_looksLikeICal(content)) {
      throw Exception('Failed to parse iCal data from the provided URL.');
    }
    return _parseICalString(content);
  }

  Future<String> _fetchICalContent(String url) async {
    final directUri = Uri.parse(url);

    // Native platforms can request the feed directly.
    if (!kIsWeb) {
      final response = await http
          .get(directUri)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch iCal: HTTP ${response.statusCode}');
      }
      return response.body;
    }

    // Web often needs a CORS-friendly relay for remote iCal feeds.
    final candidates = <Uri>[directUri, ..._buildWebProxyCandidates(url)];
    final errors = <String>[];

    for (final uri in candidates) {
      try {
        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 200 && _looksLikeICal(response.body)) {
          return response.body;
        }
        errors.add('${uri.host} -> HTTP ${response.statusCode}');
      } catch (e) {
        errors.add('${uri.host} -> $e');
      }
    }

    throw Exception(
      'Unable to fetch iCal feed on web (likely CORS blocked): ${errors.join(' | ')}',
    );
  }

  List<Uri> _buildWebProxyCandidates(String targetUrl) {
    final encoded = Uri.encodeComponent(targetUrl);
    final uris = <Uri>[];

    final configuredProxy = dotenv.env['ICAL_CORS_PROXY']?.trim();
    if (configuredProxy != null && configuredProxy.isNotEmpty) {
      final proxyUri = _buildConfiguredProxyUri(configuredProxy, targetUrl);
      if (proxyUri != null) uris.add(proxyUri);
    }

    final fallbackRaw = 'https://api.allorigins.win/raw?url=$encoded';
    final fallbackCorsProxy = 'https://corsproxy.io/?$encoded';

    uris.add(Uri.parse(fallbackRaw));
    uris.add(Uri.parse(fallbackCorsProxy));
    return uris;
  }

  Uri? _buildConfiguredProxyUri(String configuredProxy, String targetUrl) {
    try {
      if (configuredProxy.contains('{url}')) {
        return Uri.parse(
          configuredProxy.replaceAll('{url}', Uri.encodeComponent(targetUrl)),
        );
      }
      final separator = configuredProxy.contains('?') ? '&' : '?';
      return Uri.parse(
        '$configuredProxy${separator}url=${Uri.encodeComponent(targetUrl)}',
      );
    } catch (_) {
      return null;
    }
  }

  bool _looksLikeICal(String body) {
    final normalized = body.toUpperCase();
    return normalized.contains('BEGIN:VCALENDAR') &&
        (normalized.contains('BEGIN:VEVENT') ||
            normalized.contains('END:VCALENDAR'));
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
