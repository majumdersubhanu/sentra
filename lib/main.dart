import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra/core/sync/realtime_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentra/features/auth/domain/auth_repository.dart';
import 'app/app.dart';
import 'core/di/injection.dart';
import 'core/env/env.dart';
import 'core/network/connectivity_service.dart';
import 'core/storage/database.dart';
import 'core/sync/sync_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment configuration
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
  }

  // Initialize Supabase client (only when credentials are provided)
  final supabaseUrl = Env.supabaseUrl;
  final supabaseAnonKey = Env.supabaseAnonKey;
  final hasSupabaseConfig =
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  if (hasSupabaseConfig) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  // Initialize dependency injection graph
  configureDependencies();

  // Initialize connectivity monitoring
  await ConnectivityService.instance.init();

  // Start sync engine (drains offline mutations when online)
  final db = getIt<SentraDatabase>();
  final authRepo = getIt<AuthRepository>();
  final syncEngine = SyncEngine(db, ConnectivityService.instance, authRepo);
  syncEngine.start();

  // Realtime requires a configured Supabase client.
  if (hasSupabaseConfig) {
    final realtimeService = RealtimeService(db, Supabase.instance.client);
    realtimeService.start();
  }

  runApp(ProviderScope(child: SentraApp()));
}
