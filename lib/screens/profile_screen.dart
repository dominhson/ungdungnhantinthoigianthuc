import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _userService = UserService();
  int _selectedIndex = 3;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId != null) {
        final profile = await _userService.getUserProfile(userId);
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(color: Color(0xFFf8fafc)),
        ),
        content: const Text(
          'Bạn có chắc muốn đăng xuất?',
          style: TextStyle(color: Color(0xFF94a3b8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Color(0xFFef4444)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF020617),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF94a3b8),
          ),
        ),
      );
    }

    final userName = _userProfile?['full_name'] ?? 'User';
    final userEmail = _userProfile?['email'] ?? '';
    final userAvatar = _userProfile?['avatar_url'] ?? 'https://i.pravatar.cc/300?img=12';

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Top App Bar
              _buildTopAppBar(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
                  child: Column(
                    children: [
                      // Profile hero section
                      _buildProfileHero(userName, userEmail, userAvatar),
                      const SizedBox(height: 40),

                      // Stats grid
                      _buildStatsGrid(),
                      const SizedBox(height: 40),

                      // Moments gallery
                      _buildMomentsSection(),
                      const SizedBox(height: 40),

                      // Settings section
                      _buildSettingsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Navigation Bar
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF020617).withOpacity(0.8),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFffffff),
            width: 0.05,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://i.pravatar.cc/150?img=10',
                        ),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: const Color(0xFFffffff).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                'Midnight',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFf8fafc),
                  letterSpacing: -0.5,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Color(0xFF94a3b8),
                  size: 22,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHero(String userName, String userEmail, String userAvatar) {
    return Column(
      children: [
        // Avatar with gradient border
        Stack(
          children: [
            Container(
              width: 112,
              height: 112,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFffffff).withOpacity(0.1),
                    const Color(0xFFffffff).withOpacity(0.3),
                  ],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF020617),
                    width: 4,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(userAvatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFcbd5e1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF020617),
                    width: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Name
        Text(
          userName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFFf8fafc),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),

        // Email
        Text(
          userEmail,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF94a3b8).withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 32),

        // Action buttons
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFcbd5e1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: const Center(
                      child: Text(
                        'Theo dõi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0f172a),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFffffff).withOpacity(0.05),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: const Icon(
                    Icons.mail_outline,
                    color: Color(0xFF94a3b8),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFffffff).withOpacity(0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem('12.8k', 'FOLLOWERS'),
            ),
            Container(
              width: 1,
              height: 60,
              color: const Color(0xFFffffff).withOpacity(0.05),
            ),
            Expanded(
              child: _buildStatItem('342', 'MOMENTS'),
            ),
            Container(
              width: 1,
              height: 60,
              color: const Color(0xFFffffff).withOpacity(0.05),
            ),
            Expanded(
              child: _buildStatItem('89', 'MEDIA'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      color: const Color(0xFF1e293b),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFFf8fafc),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: const Color(0xFF94a3b8).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentsSection() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Moments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFf8fafc),
                  letterSpacing: -0.5,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94a3b8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Gallery grid
        SizedBox(
          height: 380,
          child: Row(
            children: [
              // Large image
              Expanded(
                flex: 4,
                child: _buildMomentCard(
                  'https://images.unsplash.com/photo-1682687220742-aba13b6e50ba',
                  likes: '2.4k',
                  isLarge: true,
                ),
              ),
              const SizedBox(width: 12),

              // Small images column
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildMomentCard(
                        'https://images.unsplash.com/photo-1682687221038-404cb8830901',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildMomentCard(
                        'https://images.unsplash.com/photo-1682687220063-4742bd7fd538',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMomentCard(String imageUrl, {String? likes, bool isLarge = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFffffff).withOpacity(0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: const Color(0xFF1e293b),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF94a3b8),
                    ),
                  ),
                );
              },
            ),
            if (isLarge && likes != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF020617).withOpacity(0.9),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFFcbd5e1),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        likes,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFffffff).withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'CÀI ĐẶT & BẢO MẬT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: const Color(0xFF94a3b8).withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingItem(
          icon: Icons.notifications_outlined,
          title: 'Thông báo',
          subtitle: 'Quản lý âm thanh & thông báo đẩy',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildSettingItem(
          icon: Icons.lock_outline,
          title: 'Quyền riêng tư',
          subtitle: 'Kiểm soát ai có thể xem hồ sơ của bạn',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildSettingItem(
          icon: Icons.logout,
          title: 'Đăng xuất',
          subtitle: 'Thoát khỏi tài khoản hiện tại',
          onTap: _handleLogout,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFffffff).withOpacity(0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? const Color(0xFFef4444).withOpacity(0.1)
                        : const Color(0xFFffffff).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive
                        ? const Color(0xFFef4444)
                        : const Color(0xFF94a3b8),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDestructive
                              ? const Color(0xFFef4444)
                              : const Color(0xFFf8fafc),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94a3b8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFF94a3b8).withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 448),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1e293b).withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFffffff).withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIconWithLabel(
                icon: Icons.chat_bubble_outline,
                label: 'Chats',
                isActive: _selectedIndex == 0,
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.pushReplacementNamed(context, '/chats');
                },
              ),
              _buildNavIconWithLabel(
                icon: Icons.auto_awesome_outlined,
                label: 'Moments',
                isActive: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _buildNavIconWithLabel(
                icon: Icons.explore_outlined,
                label: 'Discover',
                isActive: _selectedIndex == 2,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              _buildNavItemActive(
                icon: Icons.person,
                label: 'Profile',
                onTap: () => setState(() => _selectedIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIconWithLabel({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? const Color(0xFFcbd5e1)
                  : const Color(0xFF94a3b8).withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: isActive
                    ? const Color(0xFFcbd5e1)
                    : const Color(0xFF94a3b8).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemActive({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFcbd5e1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF0f172a),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: Color(0xFF0f172a),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
