import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ybwdoryryjaiblpntbhj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlid2RvcnlyeWphaWJscG50YmhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2OTc3OTAsImV4cCI6MjA5MjI3Mzc5MH0.LNJy5AzTOuQKOYIYuNz2tIfia0kWiGkzHitXYyVg6xE',
  );

  final supabase = Supabase.instance.client;

  // Test accounts
  final accounts = [
    {'email': 'test1@gmail.com', 'name': 'Nguyen Duc Trong'},
    {'email': 'test2@gmail.com', 'name': 'Trần Thị B'},
    {'email': 'test3@gmail.com', 'name': 'Lê Văn C'},
    {'email': 'test4@gmail.com', 'name': 'Phạm Thị D'},
    {'email': 'test5@gmail.com', 'name': 'Hoàng Văn E'},
  ];

  print('🚀 Creating test accounts...\n');

  for (var account in accounts) {
    try {
      print('Creating ${account['email']}...');
      
      // Sign up user
      final response = await supabase.auth.signUp(
        email: account['email']!,
        password: '123456',
        data: {
          'full_name': account['name'],
        },
      );

      if (response.user != null) {
        print('✅ Created ${account['email']} - ID: ${response.user!.id}');
        
        // Update users table
        await supabase.from('users').upsert({
          'id': response.user!.id,
          'email': account['email'],
          'full_name': account['name'],
          'is_online': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        print('✅ Updated users table for ${account['email']}\n');
      }
    } catch (e) {
      print('❌ Error creating ${account['email']}: $e\n');
    }
  }

  print('✅ Done! All accounts created with password: 123456');
  print('\nYou can now login with:');
  for (var account in accounts) {
    print('- ${account['email']} / 123456');
  }
}
