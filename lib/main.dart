import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/profile_screen_new.dart';
import 'screens/friends_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with Realtime enabled
  await Supabase.initialize(
    url: 'https://ybwdoryryjaiblpntbhj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlid2RvcnlyeWphaWJscG50YmhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2OTc3OTAsImV4cCI6MjA5MjI3Mzc5MH0.LNJy5AzTOuQKOYIYuNz2tIfia0kWiGkzHitXYyVg6xE',
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF020408),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

// Global Supabase client
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luminal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020408),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1e3a8a),
          secondary: Color(0xFF94a3b8),
          surface: Color(0xFF05070a),
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/chats': (context) => const ChatListScreen(),
        '/friends': (context) => const FriendsScreen(),
        '/profile': (context) => const ProfileScreenNew(),
      },
    );
  }
}

// Auth gate to check if user is logged in
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF020408),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF94a3b8),
              ),
            ),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return const ChatListScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
