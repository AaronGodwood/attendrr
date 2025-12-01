import 'package:equatable/equatable.dart';

enum TimetableSource { manual, ical, universityApi }

class Timetable extends Equatable {
  final String id;
  final String userId;
  final String name;
  final TimetableSource source;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Timetable({
    required this.id,
    required this.userId,
    required this.name,
    required this.source,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      source: _parseSource(json['source'] as String?),
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static TimetableSource _parseSource(String? source) {
    switch (source) {
      case 'ical': return TimetableSource.ical;
      case 'university_api': return TimetableSource.universityApi;
      default: return TimetableSource.manual;
    }
  }

  String get sourceString {
    switch (source) {
      case TimetableSource.ical: return 'ical';
      case TimetableSource.universityApi: return 'university_api';
      default: return 'manual';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'source': sourceString,
    'last_synced_at': lastSyncedAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Timetable copyWith({
    String? id,
    String? userId,
    String? name,
    TimetableSource? source,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Timetable(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      source: source ?? this.source,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get needsSync {
    if (source == TimetableSource.manual) return false;
    if (lastSyncedAt == null) return true;
    return DateTime.now().difference(lastSyncedAt!).inHours >= 12;
  }

  @override
  List<Object?> get props => [id, userId, name, source, lastSyncedAt, createdAt, updatedAt];
}