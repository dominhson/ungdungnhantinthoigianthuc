# KẾ HOẠCH XÂY DỰNG CHAT REALTIME - LUMINAL

## TUẦN 1: MÔ TẢ CHỨC NĂNG VÀ PHÁC THẢO GIAO DIỆN

### 1.1. Bản mô tả các chức năng của ứng dụng

#### Chức năng chính:
1. **Xác thực người dùng (Authentication)**
   - Đăng ký tài khoản (email/password)
   - Đăng nhập (email/password)
   - Đăng nhập bằng Google
   - Đăng nhập bằng Apple
   - Quên mật khẩu
   - Đăng xuất

2. **Quản lý Profile**
   - Xem profile cá nhân
   - Chỉnh sửa thông tin (tên, bio, avatar)
   - Xem thống kê (followers, moments, media)
   - Cài đặt thông báo
   - Cài đặt quyền riêng tư

3. **Chat Realtime**
   - Gửi tin nhắn văn bản realtime
   - Gửi hình ảnh
   - Gửi tin nhắn thoại (voice message)
   - Hiển thị trạng thái "đang gõ" (typing indicator)
   - Hiển thị trạng thái online/offline
   - Hiển thị trạng thái đã đọc/chưa đọc
   - Timestamp cho mỗi tin nhắn
   - Tìm kiếm tin nhắn trong cuộc hội thoại

4. **Danh sách cuộc trò chuyện**
   - Hiển thị danh sách các cuộc trò chuyện
   - Sắp xếp theo thời gian tin nhắn mới nhất
   - Hiển thị preview tin nhắn cuối cùng
   - Badge số tin nhắn chưa đọc
   - Tìm kiếm cuộc trò chuyện
   - Ghim cuộc trò chuyện quan trọng

5. **Moments (Tính năng mở rộng)**
   - Đăng moments (ảnh/video)
   - Xem moments của người khác
   - Like/comment moments
   - Gallery moments cá nhân

6. **Discover (Tính năng mở rộng)**
   - Tìm kiếm người dùng
   - Gợi ý kết bạn
   - Theo dõi người dùng

### 1.2. Bản thiết kế UI cho các giao diện chính

#### Các màn hình đã thiết kế:
✅ **Welcome Screen** - Màn hình chào mừng với gradient, animation
✅ **Login Screen** - Form đăng nhập với social login
✅ **Register Screen** - Form đăng ký tài khoản
✅ **Chat List Screen** - Danh sách cuộc trò chuyện
✅ **Chat Screen** - Màn hình chat conversation
✅ **Profile Screen** - Màn hình profile người dùng

#### Thiết kế UI đã hoàn thành:
- Color scheme: Navy Blue (#1e3a8a) + Silver (#94a3b8)
- Typography: Manrope (headline), Inter (body)
- Border radius: Sharp minimal (2-8px)
- Dark theme với gradient effects
- Backdrop blur cho depth
- Status indicators (online/offline/typing)
- Bottom navigation bar với active state

---

## TUẦN 2: XÂY DỰNG FRONTEND (Flutter)

### 2.1. Code các giao diện UI chính theo thiết kế

#### Đã hoàn thành:
✅ `lib/screens/welcome_screen.dart` - Màn hình welcome
✅ `lib/screens/login_screen.dart` - Màn hình đăng nhập
✅ `lib/screens/register_screen.dart` - Màn hình đăng ký
✅ `lib/screens/chat_list_screen.dart` - Danh sách chat
✅ `lib/screens/chat_screen.dart` - Màn hình chat
✅ `lib/screens/profile_screen.dart` - Màn hình profile
✅ `lib/models/message.dart` - Model tin nhắn

#### Cần hoàn thiện:
- [ ] Thêm đầy đủ UI cho Chat List Screen (hiện đang placeholder)
- [ ] Tích hợp navigation giữa các màn hình
- [ ] Thêm loading states
- [ ] Thêm error handling UI
- [ ] Thêm empty states

### 2.2. Code giả lập việc điều hướng giữa các giao diện

#### Đã hoàn thành:
✅ Navigation routes trong `main.dart`:
  - `/` → Welcome Screen
  - `/login` → Login Screen
  - `/register` → Register Screen
  - `/chats` → Chat List Screen
  - `/profile` → Profile Screen

✅ Navigation flow:
  - Welcome → Login/Register
  - Login/Register → Chat List
  - Chat List → Chat Screen
  - Bottom Nav → Profile

#### Cần bổ sung:
- [ ] Deep linking
- [ ] Navigation guards (check authentication)
- [ ] Back button handling
- [ ] Transition animations

---

## TUẦN 3: THIẾT KẾ BACKEND (API/Function)

### 3.1. Bản mô tả danh sách các API/Function chính

#### Authentication APIs:
```
POST /api/auth/register
- Input: { email, password, fullName }
- Output: { userId, token, user }

POST /api/auth/login
- Input: { email, password }
- Output: { userId, token, user }

POST /api/auth/google
- Input: { googleToken }
- Output: { userId, token, user }

POST /api/auth/logout
- Input: { token }
- Output: { success }

POST /api/auth/forgot-password
- Input: { email }
- Output: { success, message }
```

#### User APIs:
```
GET /api/users/:userId
- Output: { user }

PUT /api/users/:userId
- Input: { fullName, bio, avatar }
- Output: { user }

GET /api/users/:userId/profile
- Output: { user, stats, moments }

GET /api/users/search?q=query
- Output: { users[] }
```

#### Chat APIs (REST):
```
GET /api/conversations
- Output: { conversations[] }

GET /api/conversations/:conversationId
- Output: { conversation, messages[] }

POST /api/conversations
- Input: { participantIds[] }
- Output: { conversation }

POST /api/messages
- Input: { conversationId, text, type, mediaUrl }
- Output: { message }

PUT /api/messages/:messageId/read
- Output: { success }

GET /api/messages/:conversationId?limit=50&before=timestamp
- Output: { messages[] }
```

#### Realtime Events (WebSocket/Firebase):
```
SUBSCRIBE /conversations/:conversationId
- Events:
  - message.new
  - message.read
  - user.typing
  - user.online
  - user.offline

EMIT typing
- Data: { conversationId, userId, isTyping }

EMIT message
- Data: { conversationId, message }
```

#### Media Upload APIs:
```
POST /api/upload/image
- Input: FormData (image file)
- Output: { url }

POST /api/upload/voice
- Input: FormData (audio file)
- Output: { url, duration }
```

### 3.2. Bản thiết kế chi tiết từng API/Function

#### Database Schema (Firestore):

**Users Collection:**
```javascript
users/{userId}
{
  userId: string,
  email: string,
  fullName: string,
  bio: string,
  avatar: string,
  isOnline: boolean,
  lastSeen: timestamp,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Conversations Collection:**
```javascript
conversations/{conversationId}
{
  conversationId: string,
  participantIds: string[],
  lastMessage: {
    text: string,
    senderId: string,
    timestamp: timestamp,
    type: 'text' | 'image' | 'voice'
  },
  unreadCount: {
    [userId]: number
  },
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Messages Collection:**
```javascript
conversations/{conversationId}/messages/{messageId}
{
  messageId: string,
  conversationId: string,
  senderId: string,
  text: string,
  type: 'text' | 'image' | 'voice',
  mediaUrl: string?,
  duration: number?, // for voice messages
  readBy: string[],
  timestamp: timestamp,
  createdAt: timestamp
}
```

**Typing Indicators (Realtime Database):**
```javascript
typing/{conversationId}/{userId}
{
  isTyping: boolean,
  timestamp: timestamp
}
```

**Online Status (Realtime Database):**
```javascript
status/{userId}
{
  isOnline: boolean,
  lastSeen: timestamp
}
```

---

## TUẦN 4: XÂY DỰNG BACKEND

### 4.1. Code các API/Function (có thể tuỳ ý sử dụng các công nghệ Backend)

#### Công nghệ đề xuất:
- **Firebase** (Recommended cho MVP):
  - Firebase Authentication
  - Cloud Firestore (Database)
  - Firebase Realtime Database (Online status, typing)
  - Firebase Storage (Media files)
  - Firebase Cloud Functions (Server-side logic)
  - Firebase Cloud Messaging (Push notifications)

- **Alternative Stack**:
  - Node.js + Express
  - Socket.io (Realtime)
  - MongoDB/PostgreSQL
  - AWS S3 (Media storage)
  - Redis (Caching, presence)

#### Firebase Implementation Plan:

**1. Firebase Authentication:**
```dart
// lib/services/auth_service.dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<UserCredential> signUp(String email, String password, String fullName);
  Future<UserCredential> signIn(String email, String password);
  Future<UserCredential> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<User?> get authStateChanges;
}
```

**2. Firestore Service:**
```dart
// lib/services/firestore_service.dart
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Users
  Future<void> createUser(UserModel user);
  Future<UserModel> getUser(String userId);
  Future<void> updateUser(String userId, Map<String, dynamic> data);
  
  // Conversations
  Stream<List<Conversation>> getConversations(String userId);
  Future<Conversation> createConversation(List<String> participantIds);
  
  // Messages
  Stream<List<Message>> getMessages(String conversationId);
  Future<void> sendMessage(Message message);
  Future<void> markAsRead(String messageId, String userId);
}
```

**3. Realtime Service:**
```dart
// lib/services/realtime_service.dart
class RealtimeService {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  
  // Online status
  Future<void> setOnlineStatus(String userId, bool isOnline);
  Stream<bool> getUserOnlineStatus(String userId);
  
  // Typing indicator
  Future<void> setTypingStatus(String conversationId, String userId, bool isTyping);
  Stream<Map<String, bool>> getTypingStatus(String conversationId);
}
```

**4. Storage Service:**
```dart
// lib/services/storage_service.dart
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<String> uploadImage(File image, String path);
  Future<String> uploadVoice(File audio, String path);
  Future<void> deleteFile(String url);
}
```

### 4.2. Kiểm thử API/Function (Unit Test)

#### Test Cases:

**Authentication Tests:**
```dart
// test/services/auth_service_test.dart
void main() {
  group('AuthService', () {
    test('should sign up user successfully', () async {});
    test('should sign in user successfully', () async {});
    test('should sign in with Google', () async {});
    test('should sign out user', () async {});
    test('should reset password', () async {});
    test('should throw error on invalid credentials', () async {});
  });
}
```

**Firestore Tests:**
```dart
// test/services/firestore_service_test.dart
void main() {
  group('FirestoreService', () {
    test('should create user', () async {});
    test('should get user by id', () async {});
    test('should update user', () async {});
    test('should create conversation', () async {});
    test('should send message', () async {});
    test('should mark message as read', () async {});
  });
}
```

**Integration Tests:**
```dart
// test/integration/chat_flow_test.dart
void main() {
  testWidgets('should complete chat flow', (tester) async {
    // 1. Login
    // 2. Navigate to chat list
    // 3. Open conversation
    // 4. Send message
    // 5. Verify message appears
  });
}
```

---

## TUẦN 5: TÍCH HỢP FRONTEND VÀ BACKEND

### 5.1. Code tích hợp các giao diện Frontend chính với phần Backend đã xây dựng

#### State Management:
```dart
// lib/providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;
  
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password, String fullName);
  Future<void> signOut();
}

// lib/providers/chat_provider.dart
class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final RealtimeService _realtimeService;
  
  List<Conversation> _conversations = [];
  List<Message> _messages = [];
  Map<String, bool> _typingStatus = {};
  
  Stream<List<Conversation>> getConversations();
  Stream<List<Message>> getMessages(String conversationId);
  Future<void> sendMessage(String conversationId, String text);
  Future<void> setTyping(String conversationId, bool isTyping);
}
```

#### Integration Steps:

**1. Setup Firebase:**
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_database: ^10.3.0
  firebase_storage: ^11.5.0
  firebase_messaging: ^14.7.0
```

**2. Update Login Screen:**
```dart
// lib/screens/login_screen.dart
onPressed: () async {
  try {
    await context.read<AuthProvider>().signIn(email, password);
    Navigator.pushReplacementNamed(context, '/chats');
  } catch (e) {
    // Show error
  }
}
```

**3. Update Chat List Screen:**
```dart
// lib/screens/chat_list_screen.dart
StreamBuilder<List<Conversation>>(
  stream: context.read<ChatProvider>().getConversations(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(...);
    }
    return CircularProgressIndicator();
  },
)
```

**4. Update Chat Screen:**
```dart
// lib/screens/chat_screen.dart
StreamBuilder<List<Message>>(
  stream: context.read<ChatProvider>().getMessages(conversationId),
  builder: (context, snapshot) {
    return ListView.builder(...);
  },
)
```

### 5.2. Kiểm thử tích hợp/chức năng (Integration Test, Function Test)

#### Integration Test Plan:

**Test 1: Authentication Flow**
```dart
testWidgets('User can sign up and login', (tester) async {
  // 1. Open app
  // 2. Navigate to register
  // 3. Fill form and submit
  // 4. Verify redirect to chat list
  // 5. Logout
  // 6. Login again
  // 7. Verify redirect to chat list
});
```

**Test 2: Chat Flow**
```dart
testWidgets('User can send and receive messages', (tester) async {
  // 1. Login as User A
  // 2. Open conversation with User B
  // 3. Send message
  // 4. Verify message appears
  // 5. Login as User B (different device/emulator)
  // 6. Verify message received
  // 7. Send reply
  // 8. Verify User A receives reply
});
```

**Test 3: Realtime Features**
```dart
testWidgets('Typing indicator works', (tester) async {
  // 1. User A opens chat
  // 2. User B starts typing
  // 3. Verify User A sees typing indicator
  // 4. User B stops typing
  // 5. Verify indicator disappears
});

testWidgets('Online status updates', (tester) async {
  // 1. User A online
  // 2. Verify User B sees online status
  // 3. User A goes offline
  // 4. Verify User B sees offline status
});
```

---

## CÁC TUẦN CÒN LẠI: HOÀN THIỆN VÀ LÀM BÁO CÁO

### Checklist hoàn thiện:

#### Chức năng bắt buộc:
- [ ] Authentication (đăng ký, đăng nhập, đăng xuất)
- [ ] Chat realtime (gửi/nhận tin nhắn)
- [ ] Danh sách cuộc trò chuyện
- [ ] Hiển thị trạng thái online/offline
- [ ] Hiển thị trạng thái đã đọc/chưa đọc
- [ ] Gửi hình ảnh
- [ ] Profile management

#### Chức năng nâng cao:
- [ ] Typing indicator
- [ ] Voice messages
- [ ] Push notifications
- [ ] Search messages
- [ ] Pin conversations
- [ ] Moments feature
- [ ] Discover feature

#### Testing:
- [ ] Unit tests (>80% coverage)
- [ ] Integration tests
- [ ] Manual testing trên nhiều devices
- [ ] Performance testing

#### Documentation:
- [ ] README.md với hướng dẫn cài đặt
- [ ] API documentation
- [ ] User guide
- [ ] Technical documentation

#### Deployment:
- [ ] Setup Firebase project
- [ ] Configure Firebase trong app
- [ ] Build APK/IPA
- [ ] Test trên thiết bị thật
- [ ] Deploy backend functions

---

## TIMELINE CHI TIẾT

### Tuần 1 (Đã hoàn thành 90%):
- ✅ Mô tả chức năng
- ✅ Thiết kế UI mockup
- ⚠️ Cần hoàn thiện: Chat List UI

### Tuần 2 (Đã hoàn thành 70%):
- ✅ Code UI screens
- ✅ Navigation setup
- ⚠️ Cần bổ sung: Loading states, error handling

### Tuần 3 (Chưa bắt đầu):
- [ ] Thiết kế API schema
- [ ] Thiết kế database structure
- [ ] Document API endpoints

### Tuần 4 (Chưa bắt đầu):
- [ ] Setup Firebase project
- [ ] Implement authentication
- [ ] Implement Firestore services
- [ ] Implement realtime features
- [ ] Write unit tests

### Tuần 5 (Chưa bắt đầu):
- [ ] Integrate Firebase với Flutter
- [ ] Implement state management
- [ ] Connect UI với backend
- [ ] Write integration tests
- [ ] Bug fixes

### Tuần 6-7 (Chưa bắt đầu):
- [ ] Testing toàn diện
- [ ] Performance optimization
- [ ] UI/UX refinement
- [ ] Documentation
- [ ] Deployment

---

## CÔNG NGHỆ SỬ DỤNG

### Frontend:
- **Flutter** 3.5.0+
- **Dart** 3.0+
- **State Management**: Provider / Riverpod
- **Navigation**: Go Router
- **Local Storage**: Shared Preferences
- **Image Picker**: image_picker
- **Audio Recorder**: flutter_sound

### Backend:
- **Firebase Authentication**
- **Cloud Firestore**
- **Firebase Realtime Database**
- **Firebase Storage**
- **Firebase Cloud Functions** (Node.js)
- **Firebase Cloud Messaging**

### Testing:
- **flutter_test** (Unit tests)
- **integration_test** (Integration tests)
- **mockito** (Mocking)

### DevOps:
- **Git** (Version control)
- **GitHub Actions** (CI/CD)
- **Firebase Hosting** (Web deployment)

---

## NEXT STEPS (Ưu tiên cao)

1. **Hoàn thiện Chat List UI** (1-2 giờ)
   - Thêm đầy đủ UI components
   - Thêm animations
   - Test navigation

2. **Setup Firebase Project** (2-3 giờ)
   - Tạo Firebase project
   - Configure Android/iOS
   - Add Firebase dependencies
   - Initialize Firebase trong app

3. **Implement Authentication** (3-4 giờ)
   - Create AuthService
   - Integrate với Login/Register screens
   - Add loading states
   - Handle errors

4. **Implement Chat Service** (4-6 giờ)
   - Create FirestoreService
   - Create RealtimeService
   - Implement message sending
   - Implement message receiving

5. **Testing** (2-3 giờ)
   - Write unit tests
   - Write integration tests
   - Manual testing

---

## KẾT LUẬN

Dự án đã hoàn thành **70% phần Frontend** với UI design cao cấp và navigation flow. 

**Công việc còn lại:**
- Hoàn thiện Chat List UI
- Implement toàn bộ Backend với Firebase
- Tích hợp Frontend-Backend
- Testing và deployment

**Thời gian ước tính:** 3-4 tuần nữa để hoàn thành đầy đủ tất cả chức năng.

**Ưu tiên tiếp theo:** Setup Firebase và implement Authentication để có thể test end-to-end flow.
