# Tài Khoản Test - Đã Tạo Xong ✅

## Thông Tin Đăng Nhập

Tất cả tài khoản đều dùng password: **123456**

| Email | Tên | Số Bạn Bè | Trạng Thái |
|-------|-----|-----------|------------|
| test1@gmail.com | Nguyen Duc Trong | 1 | ✅ Sẵn sàng |
| test2@gmail.com | Trần Thị B | 2 | ✅ Sẵn sàng |
| test3@gmail.com | Lê Văn C | 2 | ✅ Sẵn sàng |
| test4@gmail.com | Phạm Thị D | 1 | ✅ Sẵn sàng |
| test5@gmail.com | Hoàng Văn E | 0 | ✅ Sẵn sàng |

## Mối Quan Hệ Bạn Bè

```
test1 ←→ test2 ←→ test3 ←→ test4
                            
test5 (không có bạn)
```

## Cách Test

### 1. Test Đăng Nhập
```
Email: test1@gmail.com
Password: 123456
```

### 2. Test Danh Sách Bạn Bè
- Đăng nhập test1 → Xem 1 bạn (test2)
- Đăng nhập test2 → Xem 2 bạn (test1, test3)
- Đăng nhập test3 → Xem 2 bạn (test2, test4)

### 3. Test Gợi Ý Kết Bạn
- Đăng nhập test1 → Gợi ý: test3 (bạn chung: test2)
- Đăng nhập test4 → Gợi ý: test2 (bạn chung: test3)

### 4. Test Gửi Lời Mời Kết Bạn
- Đăng nhập test1
- Gửi lời mời cho test5
- Đăng nhập test5 → Xem lời mời từ test1
- Chấp nhận → test1 và test5 trở thành bạn

### 5. Test Online Status
- Đăng nhập test1 → Status: Online
- Đăng nhập test2 (thiết bị khác) → Thấy test1 online
- Đóng app test1 (sau 30s) → test2 thấy test1 offline

### 6. Test Realtime Updates
- Mở app test1 và test2 cùng lúc
- test1 gửi lời mời cho test5
- test5 chấp nhận
- test1 tự động cập nhật danh sách bạn (không cần refresh)

## Kịch Bản Test Đầy Đủ

### Scenario 1: Kết Bạn Mới
1. Đăng nhập test5@gmail.com
2. Vào tab "Gợi ý" → Không có gợi ý (chưa có bạn chung)
3. Tìm kiếm test1 (nếu có chức năng search)
4. Gửi lời mời kết bạn
5. Đăng nhập test1@gmail.com (thiết bị khác)
6. Vào tab "Lời mời" → Thấy lời mời từ test5
7. Chấp nhận
8. Kiểm tra tab "Bạn bè" → Thấy test5 trong danh sách

### Scenario 2: Xóa Bạn
1. Đăng nhập test1@gmail.com
2. Vào tab "Bạn bè"
3. Nhấn nút xóa bạn test2
4. Xác nhận
5. test2 biến mất khỏi danh sách

### Scenario 3: Từ Chối Lời Mời
1. Đăng nhập test4@gmail.com
2. Gửi lời mời cho test5
3. Đăng nhập test5@gmail.com
4. Vào tab "Lời mời"
5. Từ chối lời mời từ test4
6. Lời mời biến mất

## Lưu Ý Khi Test

✅ **Đã hoàn thành:**
- Tạo 5 tài khoản auth với password 123456
- Sync ID giữa auth.users và users table
- Tạo mối quan hệ bạn bè test
- Tất cả tài khoản đều có thể login ngay

⚠️ **Cần chú ý:**
- Online status chỉ update khi app đang chạy
- Heartbeat gửi mỗi 30 giây
- Realtime subscriptions cần internet connection
- RLS policies đã được enable

## Troubleshooting

### Không login được?
- Kiểm tra email đã đúng chưa (test1@gmail.com, không phải test1)
- Password phải là: 123456
- Kiểm tra internet connection

### Không thấy bạn bè?
- Kiểm tra tab "Bạn bè" (không phải "Lời mời")
- Pull to refresh
- Kiểm tra RLS policies

### Không thấy online status?
- Đợi 30 giây (heartbeat interval)
- Kiểm tra Realtime subscription
- Xem logs trong Supabase Dashboard

## Xóa Tài Khoản Test (Nếu Cần)

Nếu muốn xóa và tạo lại từ đầu:

```sql
-- Xóa tất cả data test
DELETE FROM conversation_participants WHERE user_id IN (
  SELECT id FROM users WHERE email LIKE 'test%@gmail.com'
);
DELETE FROM messages WHERE sender_id IN (
  SELECT id FROM users WHERE email LIKE 'test%@gmail.com'
);
DELETE FROM friend_requests WHERE sender_id IN (
  SELECT id FROM users WHERE email LIKE 'test%@gmail.com'
) OR receiver_id IN (
  SELECT id FROM users WHERE email LIKE 'test%@gmail.com'
);
DELETE FROM friends WHERE user_id IN (
  SELECT id FROM users WHERE email LIKE 'test%@gmail.com'
) OR friend_id IN (
  SELECT id FROM users WHERE email LIKE 'test%@gmail.com'
);
DELETE FROM users WHERE email LIKE 'test%@gmail.com';
```

Sau đó xóa auth users trong Supabase Dashboard.

---

**Tạo bởi:** Kiro AI  
**Ngày:** 2026-04-23  
**Status:** ✅ Hoàn thành - Sẵn sàng test
