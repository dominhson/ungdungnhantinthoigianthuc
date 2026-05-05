import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/profile_service.dart';
import 'edit_profile_screen.dart';
import 'my_friends_screen.dart';
import 'my_groups_screen.dart';
import 'settings_screen.dart';

class ProfileScreenNew extends StatefulWidget {
  const ProfileScreenNew({super.key});

  @override
  State<ProfileScreenNew> createState() => _ProfileScreenNewState();
}

class _ProfileScreenNewState extends State<ProfileScreenNew> {
  final _authService = AuthService();
  final _userService = UserService();
  final _profileService = ProfileService();
  
  Map<String, dynamic>? _userProfile;
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = _authService.currentUser?.id;
      if (userId != null) {
        final profile = await _userService.getUserProfile(userId);
        final stats = await _profileService.getUserStats(userId);
        setState(() {
          _userProfile = profile;
          _stats = stats;
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
    final userBio = _userProfile?['bio'] ?? 'Chưa có giới thiệu';
    final userAvatar = _userProfile?['avatar_url'];

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d1117),
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Profile header
              _buildProfileHeader(userName, userEmail, userBio, userAvatar),
              const SizedBox(height: 32),

              // Real stats
              _buildRealStats(),
              const SizedBox(height: 24),

              // Quick actions
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Settings section
              _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    String name,
    String email,
    String bio,
    String? avatarUrl,
  ) {
    return Column(
      children: [
        // Avatar
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 40),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF60a5fa),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF020617),
                    width: 3,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: Colors.white,
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          currentProfile: _userProfile!,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadProfile();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Name
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFf8fafc),
          ),
        ),
        const SizedBox(height: 4),

        // Email
        Text(
          email,
          style: const TextStyle(
            color: Color(0xFF94a3b8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),

        // Bio
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0d1117),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            bio,
            style: const TextStyle(
              color: Color(0xFFe2e8f0),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildRealStats() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '${_stats['friends'] ?? 0}',
              'Bạn bè',
              Icons.people,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: const Color(0xFF1e293b),
          ),
          Expanded(
            child: _buildStatItem(
              '${_stats['groups'] ?? 0}',
              'Nhóm',
              Icons.group,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: const Color(0xFF1e293b),
          ),
          Expanded(
            child: _buildStatItem(
              '${_stats['messages'] ?? 0}',
              'Tin nhắn',
              Icons.chat_bubble,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF60a5fa), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFf8fafc),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94a3b8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRUY CẬP NHANH',
          style: TextStyle(
            color: Color(0xFF94a3b8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Bạn bè',
                Icons.people,
                const Color(0xFF60a5fa),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyFriendsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Nhóm',
                Icons.group,
                const Color(0xFF10b981),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyGroupsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      color: const Color(0xFF0d1117),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFe2e8f0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CÀI ĐẶT',
          style: TextStyle(
            color: Color(0xFF94a3b8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.edit,
          title: 'Chỉnh sửa profile',
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  currentProfile: _userProfile!,
                ),
              ),
            );
            if (result == true) {
              _loadProfile();
            }
          },
        ),
        const SizedBox(height: 8),
        _buildSettingItem(
          icon: Icons.settings,
          title: 'Cài đặt & Thông báo',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildSettingItem(
          icon: Icons.logout,
          title: 'Đăng xuất',
          onTap: _handleLogout,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      color: const Color(0xFF0d1117),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive
              ? const Color(0xFFef4444)
              : const Color(0xFF94a3b8),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive
                ? const Color(0xFFef4444)
                : const Color(0xFFe2e8f0),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF94a3b8),
        ),
        onTap: onTap,
      ),
    );
  }
}
