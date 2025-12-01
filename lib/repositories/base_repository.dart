import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BaseRepository {
  SupabaseClient get client => Supabase.instance.client;
  String? get currentUserId => client.auth.currentUser?.id;

  void requireAuth() {
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }
  }
}