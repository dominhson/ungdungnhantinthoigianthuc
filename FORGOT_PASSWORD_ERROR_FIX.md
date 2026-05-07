# 🔧 Fix Lỗi "Error sending recovery email" (Status 500)

## ❌ Lỗi

```
Failed to load resource: the server responded with a status of 500
Error sending recovery email
```

## ✅ Nguyên nhân

**SMTP chưa được cấu hình** trong Supabase project.

---

## 🚀 Giải pháp nhanh (5 phút)

### Option 1: Sử dụng SMTP mặc định của Supabase

1. **Mở Supabase Dashboard**
   - Vào project: https://supabase.com/dashboard/project/ybwdoryryjaiblpntbhj

2. **Enable Email Provider**
   - Vào **Authentication** > **Providers**
   - Tìm **Email**
   - Đảm bảo toggle **Enable Email provider** đang BẬT (màu xanh)

3. **Cấu hình Email Template**
   - Vào **Authentication** > **Email Templates**
   - Chọn **Reset Password**
   - Click **Save** (dùng template mặc định)

4. **Thêm Redirect URL**
   - Vào **Authentication** > **URL Configuration**
   - Trong **Redirect URLs**, thêm:
     ```
     http://localhost:3000/reset-password
     ```
   - Click **Save**

5. **Test lại**
   - Mở app
   - Click "Quên mật khẩu?"
   - Nhập email đã đăng ký
   - Check inbox (và spam folder)

---

### Option 2: Sử dụng Gmail SMTP (Nếu option 1 không work)

1. **Tạo App Password**
   - Vào: https://myaccount.google.com/apppasswords
   - Tạo app password mới
   - Copy password (16 ký tự, không có dấu cách)

2. **Cấu hình SMTP trong Supabase**
   - Vào **Project Settings** > **Auth**
   - Scroll xuống **SMTP Settings**
   - Click **Enable Custom SMTP**
   - Điền:
     ```
     Host: smtp.gmail.com
     Port: 587
     Username: your-email@gmail.com
     Password: [16-digit app password]
     Sender email: your-email@gmail.com
     Sender name: Luminal Chat
     ```
   - Click **Save**

3. **Test lại**

---

### Option 3: Tạm thời disable (Nếu không cần ngay)

Nếu chưa muốn setup email, có thể tạm thời disable:

**Cách 1: Comment out link**

Trong `lib/screens/login_screen.dart`, tìm và comment:

```dart
// GestureDetector(
//   onTap: () {
//     Navigator.pushNamed(context, '/forgot-password');
//   },
//   child: const Text(
//     'QUÊN MẬT KHẨU?',
//     style: TextStyle(...),
//   ),
// ),
```

**Cách 2: Hiển thị thông báo**

```dart
GestureDetector(
  onTap: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vui lòng liên hệ admin để reset mật khẩu'),
        backgroundColor: Color(0xFF93000a),
      ),
    );
  },
  child: const Text('QUÊN MẬT KHẨU?', ...),
),
```

---

## 📖 Hướng dẫn chi tiết

Xem hướng dẫn đầy đủ về cấu hình email:
- [SUPABASE_EMAIL_SETUP.md](docs/SUPABASE_EMAIL_SETUP.md)

Bao gồm:
- Setup Gmail SMTP
- Setup SendGrid (recommended for production)
- Setup AWS SES (cheapest for high volume)
- Email template customization
- Troubleshooting

---

## ✅ Checklist

- [ ] Enable Email Provider trong Supabase
- [ ] Cấu hình Email Template
- [ ] Thêm Redirect URL
- [ ] Test với email thật
- [ ] Check spam folder
- [ ] Verify link hoạt động

---

## 🆘 Vẫn không work?

1. **Check Supabase Logs:**
   - Dashboard > Logs
   - Filter by "auth"
   - Tìm error messages

2. **Verify email đã đăng ký:**
   - Chỉ gửi được đến email đã có trong database
   - Check trong Authentication > Users

3. **Check rate limit:**
   - Free tier: 60 emails/hour
   - Đợi 1 giờ nếu đã vượt limit

4. **Tạo issue:**
   - Nếu vẫn lỗi, tạo issue với:
     - Screenshot error
     - Supabase logs
     - Steps to reproduce

---

**Good luck!** 🚀
