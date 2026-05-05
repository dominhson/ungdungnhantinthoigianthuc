import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _profileService = ProfileService();
  Map<String, bool> _notificationSettings = {};
  String _theme = 'dark';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _profileService.getNotificationSettings();
      final theme = await _profileService.getThemePreference();
      setState(() {
        _notificationSettings = notifications;
        _theme = theme;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateNotificationSetting(String key, bool value) async {
    setState(() {
      _notificationSettings[key] = value;
    });
    await _profileService.updateNotificationSettings(_notificationSettings);
  }

  Future<void> _updateTheme(String theme) async {
    setState(() {
      _theme = theme;
    });
    await _profileService.updateThemePreference(theme);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Theme đã được đổi sang: $theme'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d1117),
        title: const Text('Cài đặt'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF94a3b8),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Notifications section
                const Text(
                  'THÔNG BÁO',
                  style: TextStyle(
                    color: Color(0xFF94a3b8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNotificationTile(
                  'Tin nhắn mới',
                  'Nhận thông báo khi có tin nhắn mới',
                  'messages',
                ),
                _buildNotificationTile(
                  'Lời mời kết bạn',
                  'Nhận thông báo khi có lời mời kết bạn',
                  'friend_requests',
                ),
                _buildNotificationTile(
                  'Lời mời nhóm',
                  'Nhận thông báo khi được mời vào nhóm',
                  'group_invites',
                ),
                _buildNotificationTile(
                  'Nhắc đến',
                  'Nhận thông báo khi được nhắc đến',
                  'mentions',
                ),
                const SizedBox(height: 24),

                // Theme section
                const Text(
                  'GIAO DIỆN',
                  style: TextStyle(
                    color: Color(0xFF94a3b8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _buildThemeTile('Tối', 'dark', Icons.dark_mode),
                _buildThemeTile('Sáng', 'light', Icons.light_mode),
                _buildThemeTile('Theo hệ thống', 'system', Icons.brightness_auto),
                const SizedBox(height: 24),

                // About section
                const Text(
                  'THÔNG TIN',
                  style: TextStyle(
                    color: Color(0xFF94a3b8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  'Phiên bản',
                  '1.0.0',
                  Icons.info_outline,
                ),
                _buildInfoTile(
                  'Điều khoản dịch vụ',
                  'Xem điều khoản',
                  Icons.description_outlined,
                  onTap: () {},
                ),
                _buildInfoTile(
                  'Chính sách bảo mật',
                  'Xem chính sách',
                  Icons.privacy_tip_outlined,
                  onTap: () {},
                ),
              ],
            ),
    );
  }

  Widget _buildNotificationTile(String title, String subtitle, String key) {
    return Card(
      color: const Color(0xFF0d1117),
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFe2e8f0),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF94a3b8),
            fontSize: 13,
          ),
        ),
        value: _notificationSettings[key] ?? true,
        onChanged: (value) => _updateNotificationSetting(key, value),
        activeColor: const Color(0xFF60a5fa),
      ),
    );
  }

  Widget _buildThemeTile(String title, String value, IconData icon) {
    final isSelected = _theme == value;
    return Card(
      color: isSelected ? const Color(0xFF1e293b) : const Color(0xFF0d1117),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF60a5fa) : const Color(0xFF94a3b8),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF60a5fa) : const Color(0xFFe2e8f0),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle,
                color: Color(0xFF60a5fa),
              )
            : null,
        onTap: () => _updateTheme(value),
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Card(
      color: const Color(0xFF0d1117),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF94a3b8),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFe2e8f0),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF94a3b8),
            fontSize: 13,
          ),
        ),
        trailing: onTap != null
            ? const Icon(
                Icons.chevron_right,
                color: Color(0xFF94a3b8),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
