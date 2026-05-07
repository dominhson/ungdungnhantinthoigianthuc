# Hướng dẫn sử dụng Forgot Password (Quên mật khẩu)

## Tổng quan

Tính năng Forgot Password cho phép người dùng đặt lại mật khẩu khi quên thông qua email.

## Luồng hoạt động

```
1. User click "Quên mật khẩu?" trên Login Screen
2. Chuyển đến Forgot Password Screen
3. User nhập email
4. Hệ thống gửi email chứa link reset password
5. User click link trong email
6. Chuyển đến Reset Password Screen (web)
7. User nhập mật khẩu mới
8. Mật khẩu được cập nhật
9. User có thể đăng nhập với mật khẩu mới
```

## Các thành phần

### 1. AuthService

Service đã có sẵn các phương thức cần thiết:

```dart
class AuthService {
  // Gửi email reset password
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Cập nhật mật khẩu mới
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
```

### 2. ForgotPasswordScreen

Screen để user nhập email:

```dart
import '../screens/forgot_password_screen.dart';

// Sử dụng trong navigation
Navigator.pushNamed(context, '/forgot-password');
```

**Features:**
- Validate email format
- Loading state
- Success message
- Error handling
- Beautiful UI matching app theme

## Cài đặt

### 1. Cấu hình Supabase Email Templates

Truy cập Supabase Dashboard:
1. Vào **Authentication** > **Email Templates**
2. Chọn **Reset Password**
3. Tùy chỉnh template:

```html
<h2>Đặt lại mật khẩu</h2>
<p>Xin chào,</p>
<p>Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản Luminal của mình.</p>
<p>Click vào link bên dưới để đặt lại mật khẩu:</p>
<p><a href="{{ .ConfirmationURL }}">Đặt lại mật khẩu</a></p>
<p>Link này sẽ hết hạn sau 1 giờ.</p>
<p>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</p>
<p>Trân trọng,<br>Luminal Team</p>
```

### 2. Cấu hình Redirect URL

Trong Supabase Dashboard:
1. Vào **Authentication** > **URL Configuration**
2. Thêm redirect URL:
   - Development: `http://localhost:3000/reset-password`
   - Production: `https://yourdomain.com/reset-password`

### 3. Thêm route trong app

```dart
// main.dart hoặc routes.dart
MaterialApp(
  routes: {
    '/login': (context) => const LoginScreen(),
    '/forgot-password': (context) => const ForgotPasswordScreen(),
    '/reset-password': (context) => const ResetPasswordScreen(),
  },
)
```

Hoặc với GoRouter:

```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
  ],
)
```

## Tạo Reset Password Screen

```dart
// lib/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _authService = AuthService();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation
    if (password.isEmpty || confirmPassword.isEmpty) {
      _showError('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    if (password.length < 6) {
      _showError('Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    if (password != confirmPassword) {
      _showError('Mật khẩu xác nhận không khớp');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.updatePassword(password);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt lại mật khẩu thành công!'),
            backgroundColor: Color(0xFF10b981),
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        _showError('Có lỗi xảy ra: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF93000a),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  const Text(
                    'Đặt lại mật khẩu',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFe1e2eb),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nhập mật khẩu mới của bạn',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF958ea0),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Password field
                  _buildPasswordField(
                    controller: _passwordController,
                    label: 'MẬT KHẨU MỚI',
                    isVisible: _isPasswordVisible,
                    onToggleVisibility: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Confirm password field
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'XÁC NHẬN MẬT KHẨU',
                    isVisible: _isConfirmPasswordVisible,
                    onToggleVisibility: () {
                      setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Reset button
                  _buildResetButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Color(0xFF94a3b8),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF494454).withValues(alpha: 0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: !isVisible,
            style: const TextStyle(
              color: Color(0xFFe1e2eb),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(
                color: const Color(0xFF958ea0).withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: const Color(0xFF191c22),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF94a3b8),
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF94a3b8), Color(0xFFe2e8f0)],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleResetPassword,
          borderRadius: BorderRadius.circular(2),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0d1117)),
                  )
                : const Text(
                    'ĐẶT LẠI MẬT KHẨU',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                      color: Color(0xFF0d1117),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
```

## Deep Linking (Mobile)

Để xử lý link reset password trên mobile:

### Android

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
    android:scheme="https"
    android:host="yourdomain.com"
    android:pathPrefix="/reset-password" />
</intent-filter>
```

### iOS

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>luminal</string>
    </array>
  </dict>
</array>
```

### Flutter Deep Link Handler

```dart
// main.dart
import 'package:uni_links/uni_links.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.path == '/reset-password') {
        // Navigate to reset password screen
        Navigator.pushNamed(context, '/reset-password');
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ...
    );
  }
}
```

## Testing

### Manual Testing

1. **Test gửi email:**
   - Nhập email hợp lệ
   - Kiểm tra email đã nhận được
   - Verify link trong email

2. **Test reset password:**
   - Click link trong email
   - Nhập mật khẩu mới
   - Verify có thể đăng nhập với mật khẩu mới

3. **Test edge cases:**
   - Email không tồn tại
   - Link đã hết hạn
   - Mật khẩu quá ngắn
   - Mật khẩu không khớp

### Unit Tests

```dart
test('should send reset password email', () async {
  await authService.resetPassword('test@example.com');
  // Verify email sent
});

test('should update password successfully', () async {
  final response = await authService.updatePassword('newpassword123');
  expect(response.user, isNotNull);
});
```

## Security Best Practices

1. **Link expiration:** Link reset password nên hết hạn sau 1 giờ
2. **Rate limiting:** Giới hạn số lần request reset password
3. **Email verification:** Chỉ gửi email đến địa chỉ đã verified
4. **Password strength:** Yêu cầu mật khẩu mạnh (min 8 chars, uppercase, lowercase, number)
5. **Audit log:** Log tất cả password reset attempts

## Troubleshooting

### Email không được gửi
- Kiểm tra SMTP settings trong Supabase
- Verify email template đã được cấu hình
- Kiểm tra spam folder

### Link không hoạt động
- Verify redirect URL đã được thêm vào whitelist
- Kiểm tra deep linking configuration
- Test trên browser trước

### Lỗi "Invalid token"
- Link đã hết hạn (> 1 giờ)
- Link đã được sử dụng rồi
- User request reset password mới

## Roadmap

- [ ] SMS reset password option
- [ ] Security questions
- [ ] Two-factor authentication
- [ ] Password history (prevent reuse)
- [ ] Account recovery options

## Tài liệu tham khảo

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)
- [Email Best Practices](https://sendgrid.com/blog/email-best-practices/)
