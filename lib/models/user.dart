import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? universityId;
  final String? avatarUrl;
  final String? icalUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.universityId,
    this.avatarUrl,
    this.icalUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      universityId: json['university_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      icalUrl: json['ical_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'university_id': universityId,
    'avatar_url': avatarUrl,
    'ical_url': icalUrl,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? universityId,
    String? avatarUrl,
    String? icalUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      universityId: universityId ?? this.universityId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      icalUrl: icalUrl ?? this.icalUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get initials {
    if (username.isEmpty) return '?';
    return username[0].toUpperCase();
  }

  bool get hasIcalConnected => icalUrl != null && icalUrl!.isNotEmpty;

  @override
  List<Object?> get props => [id, email, username, universityId, avatarUrl, icalUrl, createdAt, updatedAt];
}