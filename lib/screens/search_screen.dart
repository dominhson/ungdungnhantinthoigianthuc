import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../models/user_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchService = SearchService();
  final _searchController = TextEditingController();
  late TabController _tabController;

  List<UserModel> _userResults = [];
  List<Map<String, dynamic>> _conversationResults = [];
  List<Map<String, dynamic>> _friendResults = [];
  bool _isLoading = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _userResults = [];
        _conversationResults = [];
        _friendResults = [];
        _currentQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _currentQuery = query;
    });

    try {
      final users = await _searchService.searchUsers(query);
      final conversations = await _searchService.searchConversations(query);
      final friends = await _searchService.searchFriends(query);

      setState(() {
        _userResults = users;
        _conversationResults = conversations;
        _friendResults = friends;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tìm kiếm: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            // Debounce search
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text == value) {
                _performSearch(value);
              }
            });
          },
          onSubmitted: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Người dùng (${_userResults.length})'),
            Tab(text: 'Nhóm (${_conversationResults.length})'),
            Tab(text: 'Bạn bè (${_friendResults.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentQuery.isEmpty
              ? _buildEmptyState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserResults(),
                    _buildConversationResults(),
                    _buildFriendResults(),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'Tìm kiếm người dùng, nhóm, bạn bè',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserResults() {
    if (_userResults.isEmpty) {
      return const Center(child: Text('Không tìm thấy người dùng nào'));
    }

    return ListView.builder(
      itemCount: _userResults.length,
      itemBuilder: (context, index) {
        final user = _userResults[index];
        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(user.fullName[0].toUpperCase())
                    : null,
              ),
              if (user.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(user.fullName),
          subtitle: Text(user.email),
          onTap: () {
            // TODO: Navigate to user profile or start chat
            Navigator.pop(context, user);
          },
        );
      },
    );
  }

  Widget _buildConversationResults() {
    if (_conversationResults.isEmpty) {
      return const Center(child: Text('Không tìm thấy nhóm nào'));
    }

    return ListView.builder(
      itemCount: _conversationResults.length,
      itemBuilder: (context, index) {
        final conversation = _conversationResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: conversation['avatar_url'] != null
                ? NetworkImage(conversation['avatar_url'])
                : null,
            child: conversation['avatar_url'] == null
                ? const Icon(Icons.group)
                : null,
          ),
          title: Text(conversation['name'] ?? 'Nhóm'),
          subtitle: conversation['description'] != null
              ? Text(conversation['description'])
              : null,
          onTap: () {
            // TODO: Navigate to group chat
            Navigator.pop(context, conversation);
          },
        );
      },
    );
  }

  Widget _buildFriendResults() {
    if (_friendResults.isEmpty) {
      return const Center(child: Text('Không tìm thấy bạn bè nào'));
    }

    return ListView.builder(
      itemCount: _friendResults.length,
      itemBuilder: (context, index) {
        final friendData = _friendResults[index];
        final friend = friendData['friend'] as Map<String, dynamic>;
        
        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundImage: friend['avatar_url'] != null
                    ? NetworkImage(friend['avatar_url'])
                    : null,
                child: friend['avatar_url'] == null
                    ? Text((friend['full_name'] ?? 'U')[0].toUpperCase())
                    : null,
              ),
              if (friend['is_online'] == true)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(friend['full_name'] ?? 'Unknown'),
          subtitle: Text(friend['email'] ?? ''),
          onTap: () {
            // TODO: Navigate to chat with friend
            Navigator.pop(context, friend);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
