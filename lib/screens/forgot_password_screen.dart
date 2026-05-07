import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: Stack(
        children: [
          // Background effects
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1e3a8a).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF94a3b8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Header
                      _buildHeader(),
                      const SizedBox(height: 48),

                      // Content based on state
                      if (!_emailSent) ...[
                        _buildForm(),
                        const SizedBox(height: 32),
                        _buildResetButton(),
                      ] else ...[
                        _buildSuccessMessage(),
                        const SizedBox(height: 32),
                        _buildBackToLoginButton(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF1c212b),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.lock_reset,
            color: Color(0xFF94a3b8),
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _emailSent ? 'Kiểm tra email của bạn' : 'Quên mật khẩu?',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: Color(0xFFe1e2eb),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _emailSent
              ? 'Chúng tôi đã gửi link đặt lại mật khẩu đến email của bạn.'
              : 'Nhập email của bạn và chúng tôi sẽ gửi link để đặt lại mật khẩu.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF958ea0),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'ĐỊA CHỈ EMAIL',
            style: TextStyle(
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
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Color(0xFFe1e2eb),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'vidu@luminal.com',
              hintStyle: TextStyle(
                color: const Color(0xFF94a3b8).withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: const Color(0xFF0d1117),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(0xFF94a3b8),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      _showError('Vui lòng nhập địa chỉ email');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Địa chỉ email không hợp lệ');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(email);
      
      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Check if it's a 500 error (SMTP not configured)
        final errorMessage = e.toString();
        if (errorMessage.contains('500') || errorMessage.contains('Error sending')) {
          _showError(
            'Chức năng quên mật khẩu chưa được cấu hình.\n\n'
            'Vui lòng liên hệ admin để:\n'
            '1. Cấu hình SMTP trong Supabase\n'
            '2. Setup Email Templates\n'
            '3. Thêm Redirect URLs'
          );
        } else {
          _showError('Có lỗi xảy ra: ${e.toString()}');
        }
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF93000a),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF94a3b8), Color(0xFFe2e8f0)],
        ),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3b82f6).withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleResetPassword,
          borderRadius: BorderRadius.circular(2),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0d1117)),
                    ),
                  )
                : const Text(
                    'GỬI LINK ĐẶT LẠI MẬT KHẨU',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Color(0xFF0d1117),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1c212b),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3b82f6).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            size: 48,
            color: Color(0xFF3b82f6),
          ),
          const SizedBox(height: 16),
          const Text(
            'Email đã được gửi!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFFe1e2eb),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vui lòng kiểm tra hộp thư đến (và cả thư mục spam) để tìm email từ chúng tôi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF958ea0),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        'Quay lại đăng nhập',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3b82f6),
        ),
      ),
    );
  }
}
