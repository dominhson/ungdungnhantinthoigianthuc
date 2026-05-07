# Realtime-Chat-With-Flutter

Ứng dụng chat realtime được xây dựng với Flutter và Supabase.

## ✨ Tính năng mới (v1.1.0)

### 🎉 Message Reactions (Emoji)
Thả emoji reaction vào tin nhắn như Facebook Messenger.
- Long press message để react
- 6 emoji mặc định: 👍 ❤️ 😂 😮 😢 🙏
- Realtime updates
- Toggle reactions (thêm/xóa)

### 🔐 Forgot Password
Đặt lại mật khẩu qua email.
- Gửi link reset qua email
- Đặt lại mật khẩu mới
- Secure với link hết hạn

⚠️ **Lỗi 500?** Xem: [FORGOT_PASSWORD_ERROR_FIX.md](FORGOT_PASSWORD_ERROR_FIX.md)

📖 **Chi tiết:** [IMPLEMENTATION_COMPLETE.md](IMPLEMENTATION_COMPLETE.md)

---

## Tính năng

- 💬 Nhắn tin realtime
- 👤 Xác thực người dùng
- 👥 Quản lý bạn bè (thêm, xóa, gợi ý kết bạn)
- 🟢 Kiểm tra trạng thái online/offline
- 📱 Lời mời kết bạn
- 🎨 Giao diện đẹp mắt với theme tối
- 🔒 Bảo mật với Supabase
- 👍 **Message Reactions (NEW)**
- 🔐 **Forgot Password (NEW)**

## 🚀 Quick Start cho Tính năng mới

### 1. Setup Database
```bash
cd supabase
supabase migration up
```

### 2. Cấu hình Email (Supabase Dashboard)
- Authentication > Email Templates > Reset Password
- Authentication > URL Configuration > Add redirect URLs

### 3. Run App
```bash
flutter pub get
flutter run
```

📖 **Hướng dẫn đầy đủ:** [SETUP_GUIDE.md](SETUP_GUIDE.md)

## 📚 Documentation Tính năng mới

- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Hướng dẫn setup đầy đủ
- [FEATURES_README.md](FEATURES_README.md) - Quick start
- [IMPLEMENTATION_COMPLETE.md](IMPLEMENTATION_COMPLETE.md) - Tổng kết triển khai
- [docs/EMOJI_REACTIONS_GUIDE.md](docs/EMOJI_REACTIONS_GUIDE.md) - Chi tiết reactions
- [docs/FORGOT_PASSWORD_GUIDE.md](docs/FORGOT_PASSWORD_GUIDE.md) - Chi tiết forgot password

---

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Supabase (PostgreSQL + Realtime)
- **Authentication**: Supabase Auth

## Cài đặt

```bash
# Clone repository
git clone https://github.com/nguyenducteong/Realtime-Chat-With-Flutter.git

# Di chuyển vào thư mục project
cd Realtime-Chat-With-Flutter

# Cài đặt dependencies
flutter pub get

# Chạy app
flutter run
```

## Cấu hình

✅ **Database đã được setup qua Supabase MCP!**

Không cần chạy SQL scripts thủ công. Database đã sẵn sàng với:
- ✅ Tables: friends, friend_requests
- ✅ RLS policies enabled
- ✅ Functions: get_friend_suggestions, create_bidirectional_friendship
- ✅ Triggers: on_friend_request_accepted

**Xem chi tiết:** [SUPABASE_MCP_GUIDE.md](SUPABASE_MCP_GUIDE.md)

### Chạy app:
```bash
flutter pub get
flutter run
```

**Xem hướng dẫn đầy đủ:** [SETUP_COMPLETE.md](SETUP_COMPLETE.md)

## Cấu trúc Database

### Bảng chính:
- `users` - Thông tin người dùng (bao gồm is_online, last_seen)
- `conversations` - Cuộc trò chuyện
- `messages` - Tin nhắn
- `friends` - Quan hệ bạn bè
- `friend_requests` - Lời mời kết bạn

### Tính năng nổi bật:
- **Trạng thái online**: Tự động cập nhật mỗi 30 giây
- **Gợi ý kết bạn**: Dựa trên số lượng bạn chung
- **Realtime updates**: Cập nhật tin nhắn và trạng thái ngay lập tức

## License

MIT
