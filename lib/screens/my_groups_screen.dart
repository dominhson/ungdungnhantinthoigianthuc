import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';

class MyGroupsScreen extends StatefulWidget {
  const MyGroupsScreen({super.key});

  @override
  State<MyGroupsScreen> createState() => _MyGroupsScreenState();
}

class _MyGroupsScreenState extends State<MyGroupsScreen> {
  final _profileService = ProfileService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _isLoading = true);
    try {
      final userId = _authService.currentUser?.id;
      if (userId != null) {
        final groups = await _profileService.getUserGroups(userId);
        setState(() {
          _groups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải nhóm: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d1117),
        title: const Text('Nhóm của tôi'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF94a3b8),
              ),
            )
          : _groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa tham gia nhóm nào',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _groups.length,
                  itemBuilder: (context, index) {
                    final groupData = _groups[index];
                    final conversation = groupData['conversations'] as Map<String, dynamic>;
                    final role = groupData['role'] as String;

                    return Card(
                      color: const Color(0xFF0d1117),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1e293b),
                          backgroundImage: conversation['avatar_url'] != null
                              ? NetworkImage(conversation['avatar_url'])
                              : null,
                          child: conversation['avatar_url'] == null
                              ? const Icon(Icons.group, color: Color(0xFF94a3b8))
                              : null,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                conversation['name'] ?? 'Nhóm',
                                style: const TextStyle(
                                  color: Color(0xFFe2e8f0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (role == 'admin')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF60a5fa),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Admin',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          conversation['description'] ?? 'Không có mô tả',
                          style: const TextStyle(
                            color: Color(0xFF94a3b8),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF94a3b8),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                userName: conversation['name'] ?? 'Nhóm',
                                userAvatar: conversation['avatar_url'] ?? '',
                                conversationId: conversation['id'],
                                otherUserId: null,
                                isGroup: true,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
