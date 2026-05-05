import 'package:flutter/material.dart';
import '../services/group_service.dart';
import '../services/friend_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _groupService = GroupService();
  final _friendService = FriendService();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<Map<String, dynamic>> _friends = [];
  Set<String> _selectedMembers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    try {
      final friends = await _friendService.getFriends();
      setState(() {
        _friends = friends;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách bạn bè: $e')),
        );
      }
    }
  }

  Future<void> _createGroup() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên nhóm')),
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 thành viên')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final conversationId = await _groupService.createGroup(
        name: _nameController.text.trim(),
        memberIds: _selectedMembers.toList(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, conversationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo nhóm thành công!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tạo nhóm: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo nhóm mới'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createGroup,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Tạo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Group info section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Column(
              children: [
                // Group avatar placeholder
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[800],
                  child: Icon(Icons.group, size: 40, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                // Group name
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Tên nhóm',
                    border: OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Group description
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Mô tả nhóm (tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          // Members section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Thành viên: ${_selectedMembers.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Friends list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _friends.isEmpty
                    ? const Center(
                        child: Text('Không có bạn bè nào'),
                      )
                    : ListView.builder(
                        itemCount: _friends.length,
                        itemBuilder: (context, index) {
                          final friend = _friends[index]['friend'] as Map<String, dynamic>;
                          final friendId = friend['id'] as String;
                          final isSelected = _selectedMembers.contains(friendId);

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedMembers.add(friendId);
                                } else {
                                  _selectedMembers.remove(friendId);
                                }
                              });
                            },
                            title: Text(friend['full_name'] ?? 'Unknown'),
                            subtitle: Text(friend['email'] ?? ''),
                            secondary: CircleAvatar(
                              backgroundImage: friend['avatar_url'] != null
                                  ? NetworkImage(friend['avatar_url'])
                                  : null,
                              child: friend['avatar_url'] == null
                                  ? Text(
                                      (friend['full_name'] ?? 'U')[0].toUpperCase(),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
