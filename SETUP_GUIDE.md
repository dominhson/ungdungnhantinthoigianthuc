# 🚀 Hướng dẫn Setup Hoàn chỉnh

## ✅ Đã hoàn thành

### 1. Message Reactions (Emoji) 👍❤️😂
- ✅ Models, Services, Widgets
- ✅ Database migration SQL
- ✅ Tích hợp sẵn trong Chat Screen
- ✅ Documentation đầy đủ

### 2. Forgot Password (Quên mật khẩu) 🔐
- ✅ Forgot Password Screen
- ✅ Reset Password Screen
- ✅ Routes đã cập nhật trong main.dart
- ✅ Link "Quên mật khẩu?" trong Login Screen
- ✅ Documentation đầy đủ

---

## 📦 Cài đặt

### Bước 1: Chạy Database Migration

#### Option A: Supabase CLI (Recommended)
```bash
cd supabase
supabase migration up
```

#### Option B: Manual (Supabase Dashboard)
1. Mở Supabase Dashboard
2. Vào **SQL Editor**
3. Copy nội dung từ `supabase/migrations/20240101000003_create_message_reactions.sql`
4. Paste và Run

### Bước 2: Cấu hình Email cho Forgot Password

#### 2.1. Cấu hình Email Template
1. Mở Supabase Dashboard
2. Vào **Authentication** > **Email Templates**
3. Chọn **Reset Password**
4. Tùy chỉnh template (xem guide)

#### 2.2. Cấu hình Redirect URL
1. Vào **Authentication** > **URL Configuration**
2. Thêm Redirect URLs:
   - Development: `http://localhost:3000/reset-password`
   - Production: `https://yourdomain.com/reset-password`

⚠️ **Lưu ý:** Nếu gặp lỗi 500 "Error sending recovery email", xem hướng dẫn chi tiết:
📖 [SUPABASE_EMAIL_SETUP.md](docs/SUPABASE_EMAIL_SETUP.md)

### Bước 3: Test Ứng dụng

```bash
# Run app
flutter run

# Hoặc build
flutter build apk --release
```

---

## 🎯 Tính năng đã tích hợp

### Message Reactions

**Đã tích hợp sẵn trong Chat Screen:**
- Long press message để hiện menu actions
- Chọn "Thả cảm xúc"
- Chọn emoji từ picker
- Reactions hiển thị dưới message
- Click reaction để toggle (thêm/xóa)

**Emoji mặc định:**
👍 ❤️ 😂 😮 😢 🙏

**Realtime:**
- Reactions tự động cập nhật khi có người khác react
- Không cần refresh

### Forgot Password

**Luồng hoạt động:**
1. User click "QUÊN MẬT KHẨU?" trên Login Screen
2. Nhập email
3. Nhận email với link reset
4. Click link → mở Reset Password Screen
5. Nhập mật khẩu mới
6. Đăng nhập với mật khẩu mới

---

## 📁 Cấu trúc Files

```
lib/
├── models/
│   └── message_reaction_model.dart       ✨ NEW
├── services/
│   └── reaction_service.dart             ✨ NEW
├── screens/
│   ├── forgot_password_screen.dart       ✨ NEW
│   ├── reset_password_screen.dart        ✨ NEW
│   ├── login_screen.dart                 📝 UPDATED
│   └── chat_screen.dart                  📝 UPDATED (reactions integrated)
├── widgets/
│   ├── reaction_picker.dart              ✨ NEW
│   └── message_bubble_with_reactions.dart ✨ NEW
└── main.dart                             📝 UPDATED (routes)

supabase/migrations/
└── 20240101000003_create_message_reactions.sql ✨ NEW

docs/
├── EMOJI_REACTIONS_GUIDE.md              ✨ NEW
├── FORGOT_PASSWORD_GUIDE.md              ✨ NEW
└── NEW_FEATURES_SUMMARY.md               ✨ NEW
```

---

## 🧪 Testing

### Test Message Reactions

1. **Mở chat với user khác**
2. **Long press vào message**
3. **Chọn "Thả cảm xúc"**
4. **Chọn emoji** (ví dụ: 👍)
5. **Verify:**
   - Emoji hiển thị dưới message
   - Số lượng reactions đúng
   - Có highlight nếu là reaction của bạn

6. **Click vào reaction để remove**
7. **Verify:** Reaction biến mất

8. **Test realtime:**
   - Mở 2 devices/browsers
   - React từ device 1
   - Verify device 2 nhận được realtime update

### Test Forgot Password

1. **Mở Login Screen**
2. **Click "QUÊN MẬT KHẨU?"**
3. **Nhập email hợp lệ**
4. **Click "GỬI LINK ĐẶT LẠI MẬT KHẨU"**
5. **Verify:**
   - Success message hiển thị
   - Email được gửi (check inbox + spam)

6. **Mở email**
7. **Click link reset password**
8. **Verify:** Mở Reset Password Screen

9. **Nhập mật khẩu mới (2 lần)**
10. **Click "ĐẶT LẠI MẬT KHẨU"**
11. **Verify:**
    - Success message
    - Redirect về Login Screen

12. **Đăng nhập với mật khẩu mới**
13. **Verify:** Đăng nhập thành công

---

## 🔧 Troubleshooting

### Reactions không hiển thị

**Nguyên nhân:** Migration chưa chạy

**Giải pháp:**
```bash
# Check migrations
supabase migration list

# Run migration
supabase migration up
```

### Email reset password không gửi

**Nguyên nhân:** SMTP chưa cấu hình

**Giải pháp:**
1. Check Supabase Dashboard > Settings > Auth
2. Verify SMTP settings
3. Check email template đã cấu hình

### Link reset password không hoạt động

**Nguyên nhân:** Redirect URL chưa được thêm

**Giải pháp:**
1. Vào Authentication > URL Configuration
2. Thêm redirect URL
3. Test lại

### Lỗi "permission denied for table message_reactions"

**Nguyên nhân:** RLS policies chưa được tạo

**Giải pháp:**
- Migration file đã bao gồm RLS policies
- Chạy lại migration
- Hoặc check trong Supabase Dashboard > Authentication > Policies

---

## 📊 Database Schema

### message_reactions table

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
- `idx_message_reactions_message_id`
- `idx_message_reactions_user_id`
- `idx_message_reactions_emoji`

**RLS Policies:**
- Users can view reactions on accessible messages
- Users can add reactions to their messages
- Users can only delete their own reactions

---

## 🎨 Customization

### Thay đổi emoji mặc định

Trong `chat_screen.dart`, tìm method `_showReactionPicker`:

```dart
void _showReactionPicker(Message message) {
  final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏']; // Thay đổi ở đây
  
  // ... rest of code
}
```

### Thay đổi email template

Vào Supabase Dashboard > Authentication > Email Templates > Reset Password

### Thay đổi thời gian hết hạn link

Mặc định: 1 giờ (cấu hình trong Supabase)

---

## 📚 Documentation

- [EMOJI_REACTIONS_GUIDE.md](docs/EMOJI_REACTIONS_GUIDE.md) - Chi tiết về reactions
- [FORGOT_PASSWORD_GUIDE.md](docs/FORGOT_PASSWORD_GUIDE.md) - Chi tiết về forgot password
- [NEW_FEATURES_SUMMARY.md](docs/NEW_FEATURES_SUMMARY.md) - Tổng hợp tính năng
- [FEATURES_README.md](FEATURES_README.md) - Quick start guide

---

## ✅ Checklist Triển khai

### Database
- [ ] Chạy migration `20240101000003_create_message_reactions.sql`
- [ ] Verify bảng `message_reactions` đã được tạo
- [ ] Verify RLS policies hoạt động

### Email Configuration
- [ ] Cấu hình email template
- [ ] Thêm redirect URLs
- [ ] Test gửi email

### Code
- [ ] Pull latest code
- [ ] Run `flutter pub get`
- [ ] Build app
- [ ] Test trên dev environment

### Testing
- [ ] Test message reactions
- [ ] Test forgot password flow
- [ ] Test realtime updates
- [ ] Test trên nhiều devices

### Production
- [ ] Deploy database migrations
- [ ] Update email templates
- [ ] Update redirect URLs
- [ ] Deploy app
- [ ] Monitor errors

---

## 🚀 Deploy to Production

### 1. Database
```bash
# Production migration
supabase db push --linked
```

### 2. Email
- Update email template với production branding
- Update redirect URLs với production domain

### 3. App
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### 4. Monitor
- Check Supabase logs
- Monitor email delivery
- Track user feedback

---

## 🎉 Kết luận

Đã hoàn thành 100% cả 2 tính năng:

✅ **Message Reactions** - Đã tích hợp sẵn trong Chat Screen  
✅ **Forgot Password** - Đầy đủ flow từ forgot → reset → login  

**Ready for production!** 🚀

---

**Questions?** Check documentation hoặc tạo issue.

**Happy coding!** 💻
