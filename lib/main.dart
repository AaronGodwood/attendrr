import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gwprvalawbilnjtffxuh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3cHJ2YWxhd2JpbG5qdGZmeHVoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMDcyMTQsImV4cCI6MjA3OTY4MzIxNH0.dC6CcCUKXGZVfKvsYx6V1vPTSUtSVLfoEQayyYM9ZlU',

    authOptions: const FlutterAuthClientOptions(authFlowType:
    AuthFlowType.pkce, localStorage: EmptyLocalStorage()),
  );
  
  // Initialize shared preferences
  await SharedPreferences.getInstance();
  
  // Initialize dependency injection
  await di.InjectionContainer.init();
  
  runApp(const LectureTrackerApp());
}

// Empty local storage to handle auth persistence manually
class EmptyLocalStorage implements LocalStorage {
  const EmptyLocalStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async => null;

  @override
  Future<bool> hasAccessToken() async => false;

  @override
  Future<void> persistSession(String persistSessionString) async {}

  @override
  Future<void> removePersistedSession() async {}
}