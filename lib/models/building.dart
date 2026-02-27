import 'package:equatable/equatable.dart';

class Building extends Equatable {
  final String name;
  final double latitude;
  final double longitude;
  final List<String> aliases;

  const Building({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.aliases = const [],
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      aliases:
          (json['aliases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'aliases': aliases,
  };

  @override
  List<Object?> get props => [name, latitude, longitude, aliases];
}
