# Hướng dẫn sử dụng Message Reactions (Emoji)

## Tổng quan

Tính năng Message Reactions cho phép người dùng thả emoji reaction vào tin nhắn, tương tự như Facebook Messenger, Telegram, hoặc Slack.

## Các thành phần

### 1. Models

#### `MessageReactionModel`
Model đại diện cho một reaction:
```dart
class MessageReactionModel {
  final String id;
  final String messageId;
  final String userId;
  final String emoji;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;
}
```

#### `ReactionSummary`
Model tổng hợp reactions theo emoji:
```dart
class ReactionSummary {
  final String emoji;
  final int count;
  final List<String> userIds;
  final bool hasCurrentUser;
}
```

### 2. Service

#### `ReactionService`
Service xử lý logic reactions:

**Các phương thức chính:**
- `addReaction()` - Thêm reaction mới
- `removeReaction()` - Xóa reaction
- `toggleReaction()` - Toggle reaction (thêm nếu chưa có, xóa nếu đã có)
- `getReactions()` - Lấy tất cả reactions của một message
- `getReactionSummaries()` - Lấy reactions đã được tổng hợp
- `subscribeToReactions()` - Subscribe realtime reactions

**Ví dụ sử dụng:**
```dart
final reactionService = ReactionService();

// Thêm reaction
await reactionService.addReaction(
  messageId: 'message-id',
  userId: 'user-id',
  emoji: '👍',
);

// Toggle reaction
final added = await reactionService.toggleReaction(
  messageId: 'message-id',
  userId: 'user-id',
  emoji: '❤️',
);

// Lấy reactions
final reactions = await reactionService.getReactionSummaries(
  'message-id',
  'current-user-id',
);
```

### 3. Widgets

#### `ReactionPicker`
Widget hiển thị bảng chọn emoji:
```dart
ReactionPicker(
  onEmojiSelected: (emoji) {
    // Handle emoji selection
  },
  quickReactions: ['👍', '❤️', '😂', '😮', '😢', '😡', '🔥', '👏'],
)
```

#### `ReactionButton`
Nút để mở reaction picker:
```dart
ReactionButton(
  onPressed: () {
    // Show reaction picker
  },
  isActive: false,
)
```

#### `ReactionDisplay`
Hiển thị một reaction với số lượng:
```dart
ReactionDisplay(
  emoji: '👍',
  count: 5,
  hasCurrentUser: true,
  onTap: () {
    // Toggle this reaction
  },
)
```

#### `MessageBubbleWithReactions`
Widget hoàn chỉnh cho message bubble có reactions:
```dart
MessageBubbleWithReactions(
  message: messageModel,
  currentUserId: 'user-id',
  isSentByMe: true,
)
```

## Cài đặt Database

### 1. Chạy migration

```bash
# Apply migration
supabase migration up
```

Hoặc chạy SQL trực tiếp trong Supabase Dashboard:

```sql
-- Xem file: supabase/migrations/20240101000003_create_message_reactions.sql
```

### 2. Cấu trúc bảng

```sql
CREATE TABLE message_reactions (
  id UUID PRIMARY KEY,
  message_id UUID REFERENCES messages(id),
  user_id UUID REFERENCES users(id),
  emoji TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(message_id, user_id, emoji)
);
```

**Indexes:**
- `idx_message_reactions_message_id` - Tìm reactions theo message
- `idx_message_reactions_user_id` - Tìm reactions theo user
- `idx_message_reactions_emoji` - Tìm reactions theo emoji

### 3. Row Level Security (RLS)

**Policies:**
1. Users có thể xem reactions trên messages mà họ có quyền truy cập
2. Users có thể thêm reactions vào messages trong conversations của họ
3. Users chỉ có thể xóa reactions của chính họ

## Tích hợp vào Chat Screen

### Cách 1: Sử dụng MessageBubbleWithReactions

```dart
// Trong chat_screen.dart
import '../widgets/message_bubble_with_reactions.dart';

ListView.builder(
  itemCount: messages.length,
  itemBuilder: (context, index) {
    final message = messages[index];
    return MessageBubbleWithReactions(
      message: message,
      currentUserId: currentUser.id,
      isSentByMe: message.senderId == currentUser.id,
    );
  },
)
```

### Cách 2: Tùy chỉnh

```dart
class ChatScreen extends StatefulWidget {
  // ...
}

class _ChatScreenState extends State<ChatScreen> {
  final _reactionService = ReactionService();
  Map<String, List<ReactionSummary>> _messageReactions = {};

  @override
  void initState() {
    super.initState();
    _loadReactions();
  }

  Future<void> _loadReactions() async {
    for (final message in messages) {
      final reactions = await _reactionService.getReactionSummaries(
        message.id,
        currentUserId,
      );
      setState(() {
        _messageReactions[message.id] = reactions;
      });
    }
  }

  Future<void> _handleReaction(String messageId, String emoji) async {
    await _reactionService.toggleReaction(
      messageId: messageId,
      userId: currentUserId,
      emoji: emoji,
    );
    await _loadReactions();
  }

  @override
  Widget build(BuildContext context) {
    // Build UI with reactions
  }
}
```

## Realtime Subscriptions

Để nhận reactions realtime:

```dart
RealtimeChannel? _reactionChannel;

void _subscribeToReactions(String messageId) {
  _reactionChannel = _reactionService.subscribeToReactions(
    messageId,
    (reaction) {
      // Reaction added
      setState(() {
        // Update UI
      });
    },
    (reactionId) {
      // Reaction removed
      setState(() {
        // Update UI
      });
    },
  );
}

@override
void dispose() {
  if (_reactionChannel != null) {
    _reactionService.unsubscribe(_reactionChannel!);
  }
  super.dispose();
}
```

## Tùy chỉnh Emoji

Thay đổi danh sách emoji mặc định:

```dart
ReactionPicker(
  onEmojiSelected: (emoji) {
    // Handle
  },
  quickReactions: [
    '👍', '👎', '❤️', '🔥', '😂', '😮', '😢', '😡',
    '🎉', '💯', '✅', '❌', '👀', '🙏', '💪', '🚀',
  ],
)
```

## Best Practices

### 1. Performance
- Load reactions khi cần thiết (lazy loading)
- Cache reactions để giảm số lần query
- Sử dụng pagination cho messages có nhiều reactions

### 2. UX
- Hiển thị animation khi thêm/xóa reaction
- Hiển thị tooltip với danh sách users đã react
- Giới hạn số lượng reactions hiển thị (ví dụ: top 3)

### 3. Error Handling
```dart
try {
  await _reactionService.toggleReaction(
    messageId: messageId,
    userId: userId,
    emoji: emoji,
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Không thể thêm reaction: $e')),
  );
}
```

## Troubleshooting

### Lỗi: "duplicate key value violates unique constraint"
**Nguyên nhân:** User đã react với emoji này rồi  
**Giải pháp:** Sử dụng `toggleReaction()` thay vì `addReaction()`

### Lỗi: "permission denied for table message_reactions"
**Nguyên nhân:** RLS policies chưa được cấu hình đúng  
**Giải pháp:** Kiểm tra lại RLS policies trong Supabase Dashboard

### Reactions không hiển thị realtime
**Nguyên nhân:** Chưa subscribe hoặc channel bị disconnect  
**Giải pháp:** Kiểm tra subscription và reconnect nếu cần

## Testing

### Unit Tests
```dart
test('should add reaction successfully', () async {
  final reaction = await reactionService.addReaction(
    messageId: 'test-message',
    userId: 'test-user',
    emoji: '👍',
  );
  
  expect(reaction.emoji, '👍');
  expect(reaction.userId, 'test-user');
});
```

### Integration Tests
```dart
testWidgets('should display reactions on message', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MessageBubbleWithReactions(
        message: testMessage,
        currentUserId: 'user-1',
        isSentByMe: true,
      ),
    ),
  );
  
  expect(find.text('👍'), findsOneWidget);
  expect(find.text('5'), findsOneWidget);
});
```

## Roadmap

- [ ] Reaction animations
- [ ] Custom emoji picker với search
- [ ] Reaction notifications
- [ ] Reaction analytics
- [ ] Bulk reaction operations
- [ ] Reaction permissions (admin only, etc.)

## Tài liệu tham khảo

- [Supabase Realtime Documentation](https://supabase.com/docs/guides/realtime)
- [Flutter Emoji Package](https://pub.dev/packages/emoji_picker_flutter)
- [Material Design - Reactions](https://m3.material.io/)
