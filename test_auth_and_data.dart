import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  final supabase = SupabaseClient(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_ANON_KEY']!,
  );

  print('Attempting login...');
  try {
    final response = await supabase.auth.signInWithPassword(
      email: 'user_1_1@sentra-test.com',
      password: 'password123',
    );
    print('Login success! User ID: ${response.user?.id}');

    final profile = await supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();
    print('Profile: \$profile');

    final workOrders = await supabase.from('work_orders').select().limit(5);
    print('Work Orders fetched: \${workOrders.length}');

    final assets = await supabase.from('assets').select().limit(5);
    print('Assets fetched: \${assets.length}');
  } catch (e) {
    print('Error: \$e');
  }
}
