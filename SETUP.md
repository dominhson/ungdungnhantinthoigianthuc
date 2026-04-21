# Luminal Chat App - Setup Guide

## 🚀 Tính năng

- ✅ Authentication (Đăng ký, Đăng nhập, Đăng xuất)
- ✅ Realtime messaging với Supabase
- ✅ Typing indicators
- ✅ Online status
- ✅ Search users
- ✅ Create conversations
- ✅ Upload avatar & media (ready)
- ✅ Dark theme với Navy/Silver color scheme

## 📋 Yêu cầu

- Flutter SDK (3.0+)
- Supabase account
- Dart SDK

## 🔧 Setup

### 1. Clone và cài đặt dependencies

```bash
flutter pub get
```

### 2. Cấu hình Supabase

#### a. Tạo project trên Supabase
- Truy cập https://supabase.com
- Tạo project mới (đã có: `luminal-chat`)

#### b. Chạy migration để tạo database schema
- Vào Supabase Dashboard > SQL Editor
- Copy nội dung file `supabase_rls_policies.sql`
- Paste và Execute

#### c. Cập nhật credentials
File `.env` đã có sẵn credentials:
```
NEXT_PUBLIC_SUPABASE_URL=https://ybwdoryryjaiblpntbhj.supabase.co
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=sb_publishable_PX27sT2BS5YGtRFBGYUe0w_HR3n4GAm
```

### 3. Chạy app

```bash
flutter run
```

## 📱 Cấu trúc project

```
lib/
├── main.dart                 # Entry point, AuthGate
├── models/                   # Data models
│   ├── user_model.dart
│   ├── conversation_model.dart
│   ├── message_model.dart
│   └── message.dart
├── screens/                  # UI screens
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── chat_list_screen.dart
│   ├── chat_screen.dart
│   └── profile_screen.dart
└── services/                 # Business logic
    ├── auth_service.dart     # Authentication
    ├── user_service.dart     # User management
    ├── chat_service.dart     # Messaging & realtime
    └── storage_service.dart  # File uploads
```

## 🗄️ Database Schema

### Tables
- `users` - User profiles
- `conversations` - Chat conversations
- `conversation_participants` - Many-to-many relationship
- `messages` - Chat messages
- `message_reads` - Read receipts
- `typing_indicators` - Typing status

### Storage Buckets
- `avatars` - User profile pictures
- `message-media` - Images, videos, files

## 🔐 Security

- Row Level Security (RLS) enabled trên tất cả tables
- Users chỉ có thể:
  - Xem conversations của họ
  - Gửi messages trong conversations của họ
  - Upload files vào folder của họ
  - Update profile của họ

## 🎨 Theme

- Primary: Navy Blue (#1e3a8a)
- Secondary: Silver (#94a3b8)
- Background: Dark (#020408)
- Surface: Dark Navy (#05070a)

## 📝 Sử dụng

### Đăng ký tài khoản mới
1. Mở app
2. Tap "Bắt đầu ngay"
3. Nhập thông tin: Họ tên, Email, Mật khẩu
4. Tap "ĐĂNG KÝ NGAY"

### Tạo conversation mới
1. Từ Chat List, tap nút "+" (floating button)
2. Search user bằng tên hoặc email
3. Tap vào user để tạo conversation

### Gửi tin nhắn
1. Vào conversation
2. Nhập tin nhắn
3. Tap nút gửi hoặc Enter

### Realtime features
- Tin nhắn mới tự động hiển thị
- Typing indicator khi người khác đang gõ
- Online status realtime

## 🐛 Troubleshooting

### Lỗi kết nối Supabase
- Kiểm tra internet connection
- Verify Supabase URL và anon key trong `lib/main.dart`

### Lỗi RLS policies
- Chạy lại file `supabase_rls_policies.sql` trong SQL Editor
- Kiểm tra RLS đã enable trên tất cả tables

### Lỗi realtime
- Kiểm tra Realtime đã enable trong Supabase Dashboard
- Verify database policies cho SELECT/INSERT

## 🚧 Tính năng sắp tới

- [ ] Image/video messages
- [ ] Voice messages
- [ ] Group chats
- [ ] Push notifications
- [ ] Message reactions
- [ ] Message search
- [ ] User blocking
- [ ] Message encryption

## 📞 Support

Nếu gặp vấn đề, check:
1. Flutter doctor
2. Supabase dashboard logs
3. App console logs
