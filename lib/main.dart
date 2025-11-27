import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gwprvalawbilnjtffxuh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3cHJ2YWxhd2JpbG5qdGZmeHVoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMDcyMTQsImV4cCI6MjA3OTY4MzIxNH0.dC6CcCUKXGZVfKvsYx6V1vPTSUtSVLfoEQayyYM9ZlU',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Initialize shared preferences
  await SharedPreferences.getInstance();

  runApp(const LectureTrackerApp());
}