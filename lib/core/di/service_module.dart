import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentra/core/network/connectivity_service.dart';

@module
abstract class ServiceModule {
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @lazySingleton
  ConnectivityService get connectivityService => ConnectivityService.instance;
}
