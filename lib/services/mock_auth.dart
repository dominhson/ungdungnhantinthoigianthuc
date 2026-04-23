class MockAuthService {
  static bool _isLoggedIn = false;
  static String? _currentUser;

  static bool get isLoggedIn => _isLoggedIn;
  static String? get currentUser => _currentUser;

  static Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful login
    _isLoggedIn = true;
    _currentUser = email;
    return true;
  }

  static Future<bool> register(String email, String password, String name) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful registration
    _isLoggedIn = true;
    _currentUser = email;
    return true;
  }

  static void logout() {
    _isLoggedIn = false;
    _currentUser = null;
  }
}