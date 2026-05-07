# Tổng hợp Sơ đồ hoạt động - Realtime Chat App

Tài liệu này tổng hợp tất cả các sơ đồ hoạt động (Activity Diagrams) cho hệ thống chat realtime được xây dựng với Flutter và Supabase.

## 📋 Danh sách Sơ đồ

### 1. [Xác thực người dùng (Authentication Flow)](./Activity_Diagram_1_Authentication.md)
**Mô tả:** Quy trình đăng nhập, đăng ký và quản lý phiên làm việc của người dùng.

**Các tính năng chính:**
- ✅ Kiểm tra trạng thái đăng nhập
- ✅ Đăng nhập với email/password
- ✅ Đăng ký tài khoản mới
- ✅ Khởi tạo kết nối Realtime
- ✅ Cập nhật trạng thái online

**Services:** `AuthService`, `UserService`

---

### 2. [Quản lý bạn bè (Friend Management Flow)](./Activity_Diagram_2_Friend_Management.md)
**Mô tả:** Quy trình quản lý quan hệ bạn bè, gửi/nhận lời mời kết bạn, và gợi ý kết bạn.

**Các tính năng chính:**
- ✅ Tải danh sách bạn bè
- ✅ Gửi lời mời kết bạn
- ✅ Chấp nhận/Từ chối lời mời
- ✅ Gợi ý kết bạn dựa trên mutual friends
- ✅ Xóa bạn bè
- ✅ Xem bạn bè online

**Services:** `FriendService`

**Database Functions:**
- `get_friend_suggestions()`: Gợi ý kết bạn
- `create_bidirectional_friendship()`: Tạo quan hệ bạn bè 2 chiều

---

### 3. [Chat thời gian thực (Realtime Chat Flow)](./Activity_Diagram_3_Realtime_Chat.md)
**Mô tả:** Quy trình gửi/nhận tin nhắn realtime, typing indicators, và quản lý cuộc trò chuyện.

**Các tính năng chính:**
- ✅ Tạo cuộc trò chuyện mới
- ✅ Gửi/Nhận tin nhắn realtime
- ✅ Typing indicator ("đang gõ...")
- ✅ Gửi media (ảnh, video, file)
- ✅ Trả lời tin nhắn (Reply)
- ✅ Đánh dấu đã đọc
- ✅ Broadcast với Supabase Realtime

**Services:** `ChatService`, `MediaService`, `StorageService`

**Tối ưu hóa:**
- Sử dụng Broadcast thay vì Postgres Changes
- Channel caching để tái sử dụng
- Short topic names để giảm bandwidth

---

### 4. [Quản lý trạng thái Online/Offline](./Activity_Diagram_4_Online_Status.md)
**Mô tả:** Quy trình theo dõi và cập nhật trạng thái online/offline của người dùng.

**Các tính năng chính:**
- ✅ Heartbeat mechanism (30 giây/lần)
- ✅ Phát hiện mất kết nối
- ✅ Tự động kết nối lại
- ✅ Subscribe trạng thái bạn bè
- ✅ Hiển thị "Hoạt động X phút trước"
- ✅ Cập nhật last_seen

**Services:** `UserService`, `FriendService`

**Hiển thị UI:**
- 🟢 Chấm xanh: Online
- ⚫ Chấm xám: Offline
- Text: "Đang hoạt động" / "Hoạt động X phút trước"

---

### 5. [Quản lý nhóm chat (Group Chat Management)](./Activity_Diagram_5_Group_Chat.md)
**Mô tả:** Quy trình tạo, quản lý và tương tác với nhóm chat.

**Các tính năng chính:**
- ✅ Tạo nhóm mới
- ✅ Xem thông tin nhóm
- ✅ Chỉnh sửa thông tin nhóm (admin)
- ✅ Thêm/Xóa thành viên (admin)
- ✅ Rời nhóm
- ✅ Xóa nhóm (creator)
- ✅ Chat trong nhóm với mention

**Services:** `GroupService`, `ChatService`

**Phân quyền:**
- **Admin**: Chỉnh sửa, thêm/xóa thành viên
- **Member**: Gửi tin nhắn, rời nhóm
- **Creator**: Tất cả quyền + xóa nhóm

---

### 6. [Xử lý Media (Media Handling Flow)](./Activity_Diagram_6_Media_Handling.md)
**Mô tả:** Quy trình upload, download và quản lý media (ảnh, video, audio, file).

**Các tính năng chính:**
- ✅ Gửi ảnh (camera/thư viện)
- ✅ Gửi video (quay/chọn)
- ✅ Ghi âm và gửi audio
- ✅ Gửi file documents
- ✅ Compression và thumbnail generation
- ✅ Progress bar khi upload
- ✅ Download và share media
- ✅ Xóa media

**Services:** `MediaService`, `StorageService`

**Giới hạn:**
- Ảnh: 10MB, JPG/PNG/GIF/WEBP
- Video: 100MB, 5 phút, MP4/MOV/AVI
- Audio: 20MB, 10 phút, MP3/AAC/WAV
- File: 50MB, không cho phép .exe/.bat/.sh

---

## 🏗️ Kiến trúc hệ thống

### Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase
  - PostgreSQL Database
  - Realtime (WebSocket)
  - Storage (S3-compatible)
  - Authentication (JWT)
  - Row Level Security (RLS)

### Database Schema

#### Bảng chính:
1. **users** - Thông tin người dùng
   - id, email, full_name, avatar_url, bio
   - is_online, last_seen
   - created_at, updated_at

2. **conversations** - Cuộc trò chuyện
   - id, is_group, name, description, avatar_url
   - created_by, created_at, updated_at

3. **messages** - Tin nhắn
   - id, conversation_id, sender_id
   - text, type, media_url, duration
   - reply_to_message_id
   - created_at

4. **friends** - Quan hệ bạn bè
   - id, user_id, friend_id
   - created_at

5. **friend_requests** - Lời mời kết bạn
   - id, sender_id, receiver_id
   - status (pending/accepted/rejected)
   - created_at, updated_at

6. **conversation_participants** - Thành viên cuộc trò chuyện
   - id, conversation_id, user_id
   - role (admin/member)
   - joined_at, unread_count

7. **media_metadata** - Metadata của media
   - id, message_id, media_type
   - media_url, thumbnail_url
   - size, width, height, duration

### Services Architecture

```
lib/
├── services/
│   ├── auth_service.dart          # Xác thực
│   ├── user_service.dart          # Quản lý user & online status
│   ├── friend_service.dart        # Quản lý bạn bè
│   ├── chat_service.dart          # Chat & Realtime
│   ├── group_service.dart         # Quản lý nhóm
│   ├── media_service.dart         # Xử lý media
│   ├── storage_service.dart       # Supabase Storage
│   └── search_service.dart        # Tìm kiếm
├── models/
│   ├── user_model.dart
│   ├── conversation_model.dart
│   ├── message_model.dart
│   ├── friend_model.dart
│   └── media_models.dart
└── screens/
    ├── welcome_screen.dart
    ├── login_screen.dart
    ├── register_screen.dart
    ├── chat_list_screen.dart
    ├── chat_screen.dart
    ├── friends_screen.dart
    ├── my_groups_screen.dart
    └── profile_screen.dart
```

## 🔄 Realtime Flow

### Broadcast Channels
```dart
// Chat messages
channel('c:12345678')
  .onBroadcast(event: 'msg', callback: ...)
  .subscribe()

// Typing indicators
channel('t:12345678')
  .onBroadcast(event: 'typing', callback: ...)
  .subscribe()

// Friend status changes
channel('friend_status_changes')
  .onPostgresChanges(table: 'users', callback: ...)
  .subscribe()
```

### Message Flow
1. User gửi tin nhắn → Insert vào DB
2. Broadcast `{id: message_id}` qua channel
3. Tất cả clients nhận broadcast
4. Clients fetch tin nhắn từ DB bằng message_id
5. Cập nhật UI

**Lợi ích:**
- Độ trễ thấp (broadcast nhanh hơn Postgres Changes)
- Đảm bảo data consistency (fetch từ DB)
- Giảm payload size (chỉ gửi ID)

## 🔒 Security

### Row Level Security (RLS)
Tất cả bảng đều enable RLS với policies:
- Users chỉ xem được data liên quan đến mình
- Chỉ có thể insert/update với auth.uid()
- Không thể xóa data của người khác

### Storage Security
- Users chỉ upload vào folder của mình
- Chỉ xem được media trong conversations mình tham gia
- Validate file type và size trên server

### Authentication
- JWT-based authentication với Supabase Auth
- Session management tự động
- Refresh token khi hết hạn

## 📊 Performance Optimization

### 1. Database
- Indexes trên các foreign keys
- Composite indexes cho queries phức tạp
- Pagination cho danh sách dài

### 2. Realtime
- Channel caching để tái sử dụng
- Short topic names để giảm bandwidth
- Unsubscribe khi không cần

### 3. Media
- Compression trước khi upload
- Thumbnail generation
- Lazy loading
- CDN caching

### 4. UI
- Infinite scroll cho chat history
- Virtual scrolling cho danh sách dài
- Image caching
- Debounce cho typing indicators

## 🧪 Testing

### Unit Tests
- Test các service methods
- Test models và data parsing
- Test validation logic

### Integration Tests
- Test authentication flow
- Test chat flow end-to-end
- Test friend management

### Widget Tests
- Test UI components
- Test user interactions
- Test state management

## 📱 Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🚀 Deployment

### Supabase Setup
1. Tạo project trên Supabase
2. Run migration scripts
3. Enable Realtime
4. Configure Storage buckets
5. Setup RLS policies

### Flutter Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ipa --release

# Web
flutter build web --release
```

## 📚 Tài liệu tham khảo
- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)
- [Supabase Storage](https://supabase.com/docs/guides/storage)

## 🤝 Contributing
Contributions are welcome! Please read the contributing guidelines first.

## 📄 License
MIT License

---

**Tạo bởi:** Kiro AI Assistant  
**Ngày tạo:** May 7, 2026  
**Phiên bản:** 1.0.0
