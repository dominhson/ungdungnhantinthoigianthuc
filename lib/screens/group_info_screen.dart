import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/group_service.dart';
import '../services/user_service.dart';
import '../models/group_model.dart';
import '../constants/app_constants.dart';

class GroupInfoScreen extends StatefulWidget {
  final String conversationId;
  final String groupName;
  final String? groupAvatar;
  final String? groupDescription;

  const GroupInfoScreen({
    super.key,
    required this.conversationId,
    required this.groupName,
    this.groupAvatar,
    this.groupDescription,
  });

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final _groupService = GroupService();
  final _userService = UserService();
  List<GroupMember> _members = [];
  GroupSettings? _settings;
  bool _isLoading = false;
  GroupMember? _currentUserMember;

  @override
  void initState() {
    super.initState();
    _loadGroupInfo();
  }

  Future<void> _loadGroupInfo() async {
    setState(() => _isLoading = true);
    try {
      final members = await _groupService.getGroupMembers(widget.conversationId);
      final settings = await _groupService.getGroupSettings(widget.conversationId);
      
      // Get current user ID from Supabase
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      
      setState(() {
        _members = members;
        _settings = settings;
        _currentUserMember = members.firstWhere(
          (m) => m.userId == currentUserId,
          orElse: () => members.first,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải thông tin nhóm: $e'),
            backgroundColor: const Color(0xFFef4444),
          ),
        );
      }
    }
  }

  Future<void> _leaveGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0d1117),
        title: const Text('Rời nhóm', style: TextStyle(color: Color(0xFFe2e8f0))),
        content: const Text(
          'Bạn có chắc muốn rời khỏi nhóm này?',
          style: TextStyle(color: Color(0xFF94a3b8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF94a3b8))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rời nhóm', style: TextStyle(color: Color(0xFFef4444))),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _groupService.leaveGroup(widget.conversationId);
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate left group
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã rời nhóm'),
            backgroundColor: Color(0xFF10b981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: const Color(0xFFef4444),
          ),
        );
      }
    }
  }

  Future<void> _removeMember(GroupMember member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0d1117),
        title: const Text('Xóa thành viên', style: TextStyle(color: Color(0xFFe2e8f0))),
        content: Text(
          'Xóa ${member.fullName} khỏi nhóm?',
          style: const TextStyle(color: Color(0xFF94a3b8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF94a3b8))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Color(0xFFef4444))),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Show loading
      if (mounted) {
        setState(() => _isLoading = true);
      }
      
      await _groupService.removeMember(
        conversationId: widget.conversationId,
        memberId: member.userId,
      );
      
      // Force reload
      await _loadGroupInfo();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa thành viên'),
            backgroundColor: Color(0xFF10b981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: const Color(0xFFef4444),
          ),
        );
      }
    }
  }

  Future<void> _changeRole(GroupMember member) async {
    String? selectedRole = member.role;
    
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0d1117),
          title: Text(
            'Thay đổi vai trò: ${member.fullName}',
            style: const TextStyle(color: Color(0xFFe2e8f0)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRoleOption('Admin', 'admin', selectedRole, (value) {
                setDialogState(() => selectedRole = value);
              }),
              _buildRoleOption('Moderator', 'moderator', selectedRole, (value) {
                setDialogState(() => selectedRole = value);
              }),
              _buildRoleOption('Member', 'member', selectedRole, (value) {
                setDialogState(() => selectedRole = value);
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Color(0xFF94a3b8))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, selectedRole),
              child: const Text('Lưu', style: TextStyle(color: Color(0xFF1e3a8a))),
            ),
          ],
        ),
      ),
    );

    if (newRole == null || newRole == member.role) return;

    try {
      await _groupService.updateMemberRole(
        conversationId: widget.conversationId,
        memberId: member.userId,
        newRole: newRole,
      );
      await _loadGroupInfo(); // Add await
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật vai trò'),
            backgroundColor: Color(0xFF10b981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: const Color(0xFFef4444),
          ),
        );
      }
    }
  }

  Widget _buildRoleOption(String label, String value, String? selectedValue, Function(String?) onChanged) {
    final isSelected = selectedValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1e3a8a).withOpacity(0.2) : const Color(0xFF11141a),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1e3a8a) : const Color(0xFF94a3b8).withOpacity(0.15),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF1e3a8a) : const Color(0xFF94a3b8),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFe2e8f0) : const Color(0xFF94a3b8),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddMembersDialog() async {
    final searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    final currentMemberIds = _members.map((m) => m.userId).toSet();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0d1117),
          title: const Text(
            'Thêm thành viên',
            style: TextStyle(color: Color(0xFFe2e8f0)),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  style: const TextStyle(color: Color(0xFFe2e8f0)),
                  decoration: InputDecoration(
                    hintText: 'Tìm người dùng...',
                    hintStyle: const TextStyle(color: Color(0xFF94a3b8)),
                    filled: true,
                    fillColor: const Color(0xFF11141a),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94a3b8)),
                  ),
                  onChanged: (query) async {
                    if (query.trim().isNotEmpty) {
                      final results = await _userService.searchUsers(query);
                      // Filter out existing members
                      final filtered = results.where((user) => 
                        !currentMemberIds.contains(user['id'])
                      ).toList();
                      setDialogState(() {
                        searchResults = filtered;
                      });
                    } else {
                      setDialogState(() {
                        searchResults = [];
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (searchResults.isNotEmpty)
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final user = searchResults[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['avatar_url'] != null && user['avatar_url'].startsWith('http')
                                ? NetworkImage(user['avatar_url']) as ImageProvider
                                : const AssetImage(AppConstants.defaultAvatar),
                          ),
                          title: Text(
                            user['full_name'] ?? 'Unknown',
                            style: const TextStyle(color: Color(0xFFe2e8f0)),
                          ),
                          subtitle: Text(
                            user['email'] ?? '',
                            style: const TextStyle(color: Color(0xFF94a3b8)),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add, color: Color(0xFF1e3a8a)),
                            onPressed: () async {
                              try {
                                await _groupService.addMembers(
                                  conversationId: widget.conversationId,
                                  memberIds: [user['id']],
                                );
                                Navigator.pop(context);
                                _loadGroupInfo();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã thêm thành viên'),
                                      backgroundColor: Color(0xFF10b981),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi: $e'),
                                      backgroundColor: const Color(0xFFef4444),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Tìm kiếm người dùng để thêm vào nhóm',
                      style: TextStyle(color: Color(0xFF94a3b8)),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Color(0xFF94a3b8))),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editGroupInfo() async {
    final nameController = TextEditingController(text: widget.groupName);
    final descController = TextEditingController(text: widget.groupDescription);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0d1117),
        title: const Text(
          'Chỉnh sửa thông tin nhóm',
          style: TextStyle(color: Color(0xFFe2e8f0)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Color(0xFFe2e8f0)),
              decoration: InputDecoration(
                labelText: 'Tên nhóm',
                labelStyle: const TextStyle(color: Color(0xFF94a3b8)),
                filled: true,
                fillColor: const Color(0xFF11141a),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              style: const TextStyle(color: Color(0xFFe2e8f0)),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Mô tả',
                labelStyle: const TextStyle(color: Color(0xFF94a3b8)),
                filled: true,
                fillColor: const Color(0xFF11141a),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF94a3b8))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu', style: TextStyle(color: Color(0xFF1e3a8a))),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      await _groupService.updateGroupInfo(
        conversationId: widget.conversationId,
        name: nameController.text.trim(),
        description: descController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật thông tin nhóm'),
            backgroundColor: Color(0xFF10b981),
          ),
        );
        // Reload to show updated info
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: const Color(0xFFef4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _currentUserMember?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFf8fafc)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông tin nhóm',
          style: TextStyle(
            color: Color(0xFFf8fafc),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFf8fafc)),
              onPressed: _editGroupInfo,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF94a3b8),
              ),
            )
          : ListView(
              children: [
                // Group header
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0d1117),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFffffff).withOpacity(0.05),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Group avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1e293b),
                          border: Border.all(
                            color: const Color(0xFFffffff).withOpacity(0.1),
                            width: 2,
                          ),
                        ),
                        child: widget.groupAvatar != null && widget.groupAvatar!.startsWith('http')
                            ? ClipOval(
                                child: Image.network(
                                  widget.groupAvatar!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.group,
                                size: 50,
                                color: Color(0xFF94a3b8),
                              ),
                      ),
                      const SizedBox(height: 16),
                      // Group name
                      Text(
                        widget.groupName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFf8fafc),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Group description
                      if (widget.groupDescription != null && widget.groupDescription!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.groupDescription!,
                          style: const TextStyle(
                            color: Color(0xFF94a3b8),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Member count
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1e3a8a).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF1e3a8a).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${_members.length} thành viên',
                          style: const TextStyle(
                            color: Color(0xFF60a5fa),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Members section header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'THÀNH VIÊN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Color(0xFF94a3b8),
                        ),
                      ),
                      if (isAdmin)
                        InkWell(
                          onTap: _showAddMembersDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1e3a8a),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_add, size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Thêm',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Members list
                ..._members.map((member) {
                  final isCurrentUser = member.userId == _currentUserMember?.userId;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0d1117),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFffffff).withOpacity(0.05),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF1e293b),
                            backgroundImage: member.avatarUrl != null && member.avatarUrl!.startsWith('http')
                                ? NetworkImage(member.avatarUrl!) as ImageProvider
                                : const AssetImage(AppConstants.defaultAvatar),
                            child: member.avatarUrl == null || !member.avatarUrl!.startsWith('http')
                                ? Text(
                                    member.fullName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF94a3b8),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          if (member.isOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10b981),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF0d1117),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.fullName,
                              style: const TextStyle(
                                color: Color(0xFFf8fafc),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 6),
                            const Text(
                              '(Bạn)',
                              style: TextStyle(
                                color: Color(0xFF94a3b8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        member.email,
                        style: const TextStyle(
                          color: Color(0xFF64748b),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Role badge
                          if (member.isAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1e3a8a).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF1e3a8a),
                                ),
                              ),
                              child: const Text(
                                'Admin',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF60a5fa),
                                ),
                              ),
                            )
                          else if (member.isModerator)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF059669),
                                ),
                              ),
                              child: const Text(
                                'Mod',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10b981),
                                ),
                              ),
                            ),
                          // Admin menu
                          if (isAdmin && !isCurrentUser)
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Color(0xFF94a3b8),
                                size: 20,
                              ),
                              color: const Color(0xFF0d1117),
                              onSelected: (value) {
                                if (value == 'remove') {
                                  _removeMember(member);
                                } else if (value == 'change_role') {
                                  _changeRole(member);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'change_role',
                                  child: Row(
                                    children: [
                                      Icon(Icons.admin_panel_settings, size: 18, color: Color(0xFF94a3b8)),
                                      SizedBox(width: 12),
                                      Text(
                                        'Thay đổi vai trò',
                                        style: TextStyle(color: Color(0xFFe2e8f0)),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_remove, size: 18, color: Color(0xFFef4444)),
                                      SizedBox(width: 12),
                                      Text(
                                        'Xóa khỏi nhóm',
                                        style: TextStyle(color: Color(0xFFef4444)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                
                const SizedBox(height: 24),
                
                // Leave group button
                if (_settings?.allowMemberToLeave ?? true)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFef4444).withOpacity(0.3),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _leaveGroup,
                          borderRadius: BorderRadius.circular(8),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.exit_to_app,
                                  color: Color(0xFFef4444),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Rời nhóm',
                                  style: TextStyle(
                                    color: Color(0xFFef4444),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}
