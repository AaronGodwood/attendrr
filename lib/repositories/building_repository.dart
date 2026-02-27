import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/building.dart';

class BuildingRepository {
  static final BuildingRepository instance = BuildingRepository._();
  BuildingRepository._();

  final SupabaseClient _client = Supabase.instance.client;

  List<Building>? _cache;

  /// Returns all buildings from Supabase, using an in-memory cache so
  /// repeated calls within the same session don't hit the network.
  Future<List<Building>> getBuildings({bool forceRefresh = false}) async {
    if (_cache != null && !forceRefresh) return _cache!;

    final response = await _client.from('campus_buildings').select();
    _cache = (response as List).map((json) => Building.fromJson(json)).toList();
    return _cache!;
  }

  /// Clears the in-memory cache (e.g. call after admin updates the table).
  void clearCache() => _cache = null;
}
