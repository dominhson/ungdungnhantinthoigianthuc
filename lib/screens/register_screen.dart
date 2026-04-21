import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            right: -50,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1e3a8a).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF94a3b8).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Decorative grid background
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: _buildDecorativeGrid(),
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
                    children: [
                      // Brand header
                      _buildHeader(),
                      const SizedBox(height: 48),

                      // Form card
                      _buildFormCard(),
                      const SizedBox(height: 32),

                      // Footer
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Decorative corner element
          Positioned(
            bottom: 40,
            right: 40,
            child: Opacity(
              opacity: 0.2,
              child: Row(
                children: [
                  Container(
                    width: 1,
                    height: 96,
                    color: const Color(0xFF94a3b8),
                  ),
                  const SizedBox(width: 16),
                  Transform.rotate(
                    angle: -1.5708,
                    child: const Text(
                      'EDITION 01 // MIDNIGHT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,
                        color: Color(0xFF94a3b8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      padding: const EdgeInsets.all(16),
      itemCount: 16,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF494454).withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF94a3b8), Color(0xFFe2e8f0)],
          ).createShader(bounds),
          child: const Text(
            'LUMINAL',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Tạo tài khoản mới',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFFe2e8f0),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Trải nghiệm không gian nhắn tin cao cấp',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF94a3b8),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117).withOpacity(0.6),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: const Color(0xFF94a3b8).withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          // Full name
          _buildInputField(
            label: 'HỌ VÀ TÊN',
            controller: _fullNameController,
            placeholder: 'Nguyễn Văn A',
          ),
          const SizedBox(height: 24),

          // Email
          _buildInputField(
            label: 'ĐỊA CHỈ EMAIL',
            controller: _emailController,
            placeholder: 'example@luminal.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),

          // Password fields in row
          Row(
            children: [
              Expanded(
                child: _buildPasswordField(
                  label: 'MẬT KHẨU',
                  controller: _passwordController,
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPasswordField(
                  label: 'XÁC NHẬN',
                  controller: _confirmPasswordController,
                  isVisible: _isConfirmPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Submit button
          _buildSubmitButton(),
          const SizedBox(height: 24),

          // Terms
          _buildTerms(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: Color(0xFF94a3b8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Color(0xFFe2e8f0),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: const Color(0xFF94a3b8).withOpacity(0.4),
            ),
            filled: true,
            fillColor: const Color(0xFF11141a),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: Color(0xFF94a3b8),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          style: const TextStyle(
            color: Color(0xFFe2e8f0),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(
              color: const Color(0xFF94a3b8).withOpacity(0.4),
            ),
            filled: true,
            fillColor: const Color(0xFF11141a),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF958ea0),
                size: 18,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
    // Validation
    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Mật khẩu xác nhận không khớp');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError('Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/chats');
      }
    } catch (e) {
      if (mounted) {
        _showError('Đăng ký thất bại: ${e.toString()}');
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFe1e2eb), Color(0xFF958ea0)],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleRegister,
          borderRadius: BorderRadius.circular(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0b0e14)),
                  ),
                )
              else ...[
                const Text(
                  'ĐĂNG KÝ NGAY',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: Color(0xFF0b0e14),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF0b0e14),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerms() {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 10,
          color: const Color(0xFF958ea0).withOpacity(0.6),
          height: 1.6,
        ),
        children: const [
          TextSpan(text: 'Bằng việc đăng ký, bạn đồng ý với '),
          TextSpan(
            text: 'Điều khoản dịch vụ',
            style: TextStyle(
              color: Color(0xFF958ea0),
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: ' và '),
          TextSpan(
            text: 'Chính sách bảo mật',
            style: TextStyle(
              color: Color(0xFF958ea0),
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: ' của Luminal.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Đã có tài khoản?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF958ea0),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.only(bottom: 2),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFd0bcff),
                    width: 1,
                  ),
                ),
              ),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFe1e2eb),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
