import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: Stack(
        children: [
          // Background texture
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://images.unsplash.com/photo-1557683316-973673baf926',
                fit: BoxFit.cover,
                color: Colors.grey,
                colorBlendMode: BlendMode.modulate,
              ),
            ),
          ),

          // Gradient overlays
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF020408),
                    const Color(0xFF020408).withOpacity(0.9),
                    const Color(0xFF020408),
                  ],
                ),
              ),
            ),
          ),

          // Blur effects
          Positioned(
            bottom: -200,
            left: -100,
            child: Container(
              width: 600,
              height: 600,
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
            top: -200,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
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

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo section
                        _buildLogo(),
                        const SizedBox(height: 64),

                        // Main heading
                        _buildHeading(),
                        const SizedBox(height: 48),

                        // Action card
                        _buildActionCard(context),
                        const SizedBox(height: 48),

                        // Social proof
                        _buildSocialProof(),
                        const SizedBox(height: 32),

                        // Footer tags
                        _buildFooterTags(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1c212b),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.blur_on,
            color: Color(0xFF94a3b8),
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'LUMINAL',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 8,
            color: const Color(0xFFe2e8f0).withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildHeading() {
    return Column(
      children: [
        Column(
          children: [
            const Text(
              'Connect in',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -1,
                color: Color(0xFFe2e8f0),
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF94a3b8), Color(0xFFe2e8f0)],
              ).createShader(bounds),
              child: const Text(
                'Style',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Trải nghiệm nhắn tin đẳng cấp thượng lưu,\nnơi thẩm mỹ và bảo mật hội tụ.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: const Color(0xFF94a3b8).withOpacity(0.9),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF94a3b8).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main CTA button
          Material(
            color: const Color(0xFF1e3a8a),
            borderRadius: BorderRadius.circular(2),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
              borderRadius: BorderRadius.circular(2),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bắt đầu ngay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Đã có tài khoản?',
                style: TextStyle(
                  color: const Color(0xFF94a3b8).withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(
                    color: Color(0xFF94a3b8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF94a3b8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialProof() {
    return Column(
      children: [
        Text(
          'THAM GIA CÙNG 10K+ HỘI VIÊN',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: const Color(0xFF94a3b8).withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String imagePath) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: const Color(0xFF020408),
          width: 2,
        ),
        image: DecorationImage(
          image: imagePath.startsWith('http')
              ? NetworkImage(imagePath) as ImageProvider
              : AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildFooterTags() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTag('THANH LỊCH'),
        _buildDot(),
        _buildTag('BẢO MẬT'),
        _buildDot(),
        _buildTag('TỐC ĐỘ'),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9,
        letterSpacing: 2,
        color: const Color(0xFF94a3b8).withOpacity(0.5),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF94a3b8).withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}
