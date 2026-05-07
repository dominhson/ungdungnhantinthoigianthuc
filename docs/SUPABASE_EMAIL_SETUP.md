# 📧 Hướng dẫn cấu hình Email cho Supabase

## ⚠️ Lỗi: "Error sending recovery email" (Status 500)

Nếu bạn gặp lỗi này khi sử dụng tính năng "Quên mật khẩu", có nghĩa là **SMTP chưa được cấu hình** trong Supabase.

---

## 🔧 Cách khắc phục

### Option 1: Sử dụng SMTP mặc định của Supabase (Recommended)

Supabase Free tier có SMTP mặc định, nhưng có giới hạn:
- **60 emails/hour** cho Free tier
- Chỉ gửi đến email đã verified

#### Bước 1: Enable Auth Email
1. Mở **Supabase Dashboard**
2. Vào project của bạn
3. Vào **Authentication** > **Providers**
4. Tìm **Email** provider
5. Đảm bảo **Enable Email provider** được bật

#### Bước 2: Cấu hình Email Templates
1. Vào **Authentication** > **Email Templates**
2. Chọn **Reset Password**
3. Customize template (hoặc dùng mặc định)
4. Click **Save**

#### Bước 3: Thêm Redirect URL
1. Vào **Authentication** > **URL Configuration**
2. Thêm **Redirect URLs**:
   ```
   http://localhost:3000/reset-password
   https://yourdomain.com/reset-password
   ```
3. Click **Save**

#### Bước 4: Test
1. Mở app
2. Click "Quên mật khẩu?"
3. Nhập email (phải là email đã đăng ký)
4. Check inbox (và spam folder)

---

### Option 2: Sử dụng Custom SMTP (Production)

Để production, nên dùng SMTP riêng (Gmail, SendGrid, AWS SES, etc.)

#### A. Sử dụng Gmail SMTP

**Bước 1: Tạo App Password**
1. Vào Google Account: https://myaccount.google.com/
2. Security > 2-Step Verification (bật nếu chưa có)
3. Security > App passwords
4. Tạo app password mới
5. Copy password (16 ký tự)

**Bước 2: Cấu hình trong Supabase**
1. Vào **Project Settings** > **Auth**
2. Scroll xuống **SMTP Settings**
3. Điền thông tin:
   ```
   Host: smtp.gmail.com
   Port: 587
   Username: your-email@gmail.com
   Password: [app password 16 ký tự]
   Sender email: your-email@gmail.com
   Sender name: Luminal Chat
   ```
4. Click **Save**

**Giới hạn Gmail:**
- 500 emails/day cho free Gmail
- 2000 emails/day cho Google Workspace

---

#### B. Sử dụng SendGrid (Recommended for Production)

**Bước 1: Tạo SendGrid Account**
1. Đăng ký tại: https://sendgrid.com/
2. Free tier: 100 emails/day
3. Verify email của bạn

**Bước 2: Tạo API Key**
1. Vào SendGrid Dashboard
2. Settings > API Keys
3. Create API Key
4. Copy API key

**Bước 3: Cấu hình trong Supabase**
1. Vào **Project Settings** > **Auth**
2. SMTP Settings:
   ```
   Host: smtp.sendgrid.net
   Port: 587
   Username: apikey
   Password: [SendGrid API Key]
   Sender email: noreply@yourdomain.com
   Sender name: Luminal Chat
   ```
3. Click **Save**

**Ưu điểm SendGrid:**
- 100 emails/day miễn phí
- Deliverability tốt
- Analytics & tracking
- Không bị giới hạn như Gmail

---

#### C. Sử dụng AWS SES (Cheapest for High Volume)

**Bước 1: Setup AWS SES**
1. Tạo AWS account
2. Vào SES console
3. Verify domain hoặc email
4. Request production access (nếu cần > 200 emails/day)

**Bước 2: Tạo SMTP Credentials**
1. SES > SMTP Settings
2. Create SMTP Credentials
3. Download credentials

**Bước 3: Cấu hình trong Supabase**
1. Vào **Project Settings** > **Auth**
2. SMTP Settings:
   ```
   Host: email-smtp.[region].amazonaws.com
   Port: 587
   Username: [SMTP username]
   Password: [SMTP password]
   Sender email: noreply@yourdomain.com
   Sender name: Luminal Chat
   ```
3. Click **Save**

**Giá AWS SES:**
- $0.10 per 1,000 emails
- Rất rẻ cho high volume

---

### Option 3: Tạm thời disable Forgot Password

Nếu chưa muốn setup email ngay:

1. Comment out link "Quên mật khẩu?" trong `login_screen.dart`:
```dart
// GestureDetector(
//   onTap: () {
//     Navigator.pushNamed(context, '/forgot-password');
//   },
//   child: const Text('QUÊN MẬT KHẨU?'),
// ),
```

2. Hoặc hiển thị thông báo:
```dart
GestureDetector(
  onTap: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vui lòng liên hệ admin để reset mật khẩu'),
      ),
    );
  },
  child: const Text('QUÊN MẬT KHẨU?'),
),
```

---

## 📧 Email Template Customization

### Reset Password Template

```html
<h2>Đặt lại mật khẩu Luminal</h2>

<p>Xin chào,</p>

<p>Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản <strong>{{ .Email }}</strong>.</p>

<p>Click vào nút bên dưới để đặt lại mật khẩu:</p>

<p style="text-align: center; margin: 30px 0;">
  <a href="{{ .ConfirmationURL }}" 
     style="background-color: #3b82f6; 
            color: white; 
            padding: 12px 24px; 
            text-decoration: none; 
            border-radius: 4px;
            display: inline-block;">
    Đặt lại mật khẩu
  </a>
</p>

<p>Hoặc copy link này vào trình duyệt:</p>
<p style="word-break: break-all; color: #666;">{{ .ConfirmationURL }}</p>

<p><strong>Link này sẽ hết hạn sau 1 giờ.</strong></p>

<p>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</p>

<hr style="margin: 30px 0; border: none; border-top: 1px solid #eee;">

<p style="color: #666; font-size: 12px;">
  Email này được gửi từ Luminal Chat.<br>
  Vui lòng không reply email này.
</p>
```

---

## 🧪 Testing

### Test với email thật:

1. **Đăng ký tài khoản** với email thật của bạn
2. **Đăng xuất**
3. **Click "Quên mật khẩu?"**
4. **Nhập email** đã đăng ký
5. **Check inbox** (và spam folder)
6. **Click link** trong email
7. **Nhập mật khẩu mới**
8. **Đăng nhập** với mật khẩu mới

### Test với Mailtrap (Development):

Mailtrap là fake SMTP server để test email trong development:

1. Đăng ký tại: https://mailtrap.io/
2. Tạo inbox
3. Copy SMTP credentials
4. Cấu hình trong Supabase
5. Test - emails sẽ xuất hiện trong Mailtrap inbox

---

## 🔍 Troubleshooting

### Email không được gửi

**Check:**
1. SMTP credentials đúng chưa?
2. Port đúng chưa? (587 cho TLS, 465 cho SSL)
3. Sender email đã verify chưa?
4. Rate limit đã vượt chưa?

**Debug:**
1. Vào Supabase Dashboard > Logs
2. Filter by "auth"
3. Tìm error messages

### Email vào spam

**Giải pháp:**
1. Verify domain với SPF, DKIM, DMARC
2. Sử dụng professional SMTP (SendGrid, AWS SES)
3. Không dùng Gmail cho production
4. Customize email template (không spam-like)

### Link reset không hoạt động

**Check:**
1. Redirect URL đã được thêm vào Supabase chưa?
2. Link đã hết hạn chưa? (1 giờ)
3. Deep linking đã cấu hình chưa? (mobile)

---

## 📊 So sánh SMTP Providers

| Provider | Free Tier | Giá | Deliverability | Dễ setup |
|----------|-----------|-----|----------------|----------|
| **Supabase Default** | 60/hour | Free | Tốt | ⭐⭐⭐⭐⭐ |
| **Gmail** | 500/day | Free | Trung bình | ⭐⭐⭐⭐ |
| **SendGrid** | 100/day | $0.10/1k | Rất tốt | ⭐⭐⭐⭐ |
| **AWS SES** | 62k/month | $0.10/1k | Rất tốt | ⭐⭐⭐ |
| **Mailgun** | 5k/month | $0.80/1k | Tốt | ⭐⭐⭐⭐ |
| **Postmark** | 100/month | $1.25/1k | Rất tốt | ⭐⭐⭐⭐ |

**Recommendation:**
- **Development:** Supabase Default hoặc Mailtrap
- **Small Production:** SendGrid Free
- **Large Production:** AWS SES

---

## 🎯 Best Practices

1. **Verify domain** để tăng deliverability
2. **Customize email template** với branding
3. **Monitor email metrics** (open rate, bounce rate)
4. **Implement rate limiting** để tránh abuse
5. **Log email events** để debug
6. **Test thoroughly** trước khi deploy
7. **Have backup SMTP** provider

---

## 📚 Tài liệu tham khảo

- [Supabase Auth Email](https://supabase.com/docs/guides/auth/auth-email)
- [SendGrid Documentation](https://docs.sendgrid.com/)
- [AWS SES Documentation](https://docs.aws.amazon.com/ses/)
- [Gmail SMTP Settings](https://support.google.com/mail/answer/7126229)

---

**Cần help?** Tạo issue hoặc liên hệ admin.
