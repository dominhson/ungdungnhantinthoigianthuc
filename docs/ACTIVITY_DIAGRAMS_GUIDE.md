# Activity Diagrams - Lumine Chat

## Hướng dẫn vẽ Activity Diagram trong Draw.io

### Các Activity Diagram cần vẽ:

---

## 1. Activity Diagram - Đăng ký & Đăng nhập

### Luồng Đăng ký:
```
[Start] 
  ↓
[Mở app]
  ↓
[Click "Đăng ký"]
  ↓
[Nhập email, password, full name]
  ↓
<Validate dữ liệu?>
  ├─ Không hợp lệ → [Hiển thị lỗi] → (quay lại nhập)
  └─ Hợp lệ
      ↓
[Gọi Supabase Auth.signUp()]
  ↓
<Đăng ký thành công?>
  ├─ Thất bại → [Hiển thị lỗi] → [End]
  └─ Thành công
      ↓
[Tạo profile trong bảng users]
      ↓
[Chuyển đến màn hình Login]
      ↓
[End]
```

### Luồng Đăng nhập:
```
[Start]
  ↓
[Nhập email, password]
  ↓
<Validate?>
  ├─ Không → [Hiển thị lỗi]
  └─ Có
      ↓
[Gọi Supabase Auth.signIn()]
  ↓
<Đăng nhập thành công?>
  ├─ Thất bại → [Hiển thị lỗi] → [End]
  └─ Thành công
      ↓
[Update is_online = true]
      ↓
[Start heartbeat (30s)]
      ↓
[Chuyển đến Home]
      ↓
[End]
```

---

## 2. Activity Diagram - Gửi lời mời kết bạn

```
[Start]
  ↓
[Mở màn hình Friends]
  ↓
[Click "Tìm kiếm"]
  ↓
[Nhập từ khóa (tên/email)]
  ↓
[Query bảng users]
  ↓
<Tìm thấy?>
  ├─ Không → [Hiển thị "Không tìm thấy"] → [End]
  └─ Có
      ↓
[Hiển thị danh sách kết quả]
      ↓
[User chọn 1 người]
      ↓
<Đã là bạn bè?>
  ├─ Có → [Hiển thị "Đã là bạn bè"] → [End]
  └─ Chưa
      ↓
<Đã gửi lời mời?>
  ├─ Có → [Hiển thị "Đã gửi lời mời"] → [End]
  └─ Chưa
      ↓
[Click "Thêm bạn bè"]
      ↓
[Insert vào friend_requests (status: pending)]
      ↓
[Supabase Realtime push thông báo]
      ↓
[Hiển thị "Đã gửi lời mời"]
      ↓
[End]
```

---

## 3. Activity Diagram - Chấp nhận lời mời kết bạn

```
[Start]
  ↓
[Nhận thông báo realtime]
  ↓
[Mở màn hình Friend Requests]
  ↓
[Hiển thị danh sách lời mời pending]
  ↓
[User chọn 1 lời mời]
  ↓
<Chấp nhận hay Từ chối?>
  ├─ Từ chối
  │   ↓
  │ [Update status = 'rejected']
  │   ↓
  │ [Xóa khỏi danh sách]
  │   ↓
  │ [End]
  │
  └─ Chấp nhận
      ↓
[Update status = 'accepted']
      ↓
[Trigger: on_friend_request_accepted]
      ↓
[Insert vào friends (user_id, friend_id)]
      ↓
[Insert vào friends (friend_id, user_id)]
      ↓
[Supabase Realtime push thông báo]
      ↓
[Hiển thị "Đã là bạn bè"]
      ↓
[End]
```

---

## 4. Activity Diagram - Gửi tin nhắn

```
[Start]
  ↓
[Mở cuộc trò chuyện]
  ↓
[Subscribe Realtime messages]
  ↓
[Nhập tin nhắn]
  ↓
<Loại tin nhắn?>
  ├─ Text
  │   ↓
  │ [Insert vào messages (type: text)]
  │
  ├─ Hình ảnh
  │   ↓
  │ [Chọn ảnh từ thư viện]
  │   ↓
  │ [Upload lên Supabase Storage]
  │   ↓
  │ <Upload thành công?>
  │   ├─ Không → [Hiển thị lỗi] → [End]
  │   └─ Có
  │       ↓
  │   [Lấy URL]
  │       ↓
  │   [Insert vào messages (type: image, media_url)]
  │
  └─ File
      ↓
  [Chọn file]
      ↓
  [Upload lên Supabase Storage]
      ↓
  <Upload thành công?>
    ├─ Không → [Hiển thị lỗi] → [End]
    └─ Có
        ↓
    [Lấy URL + metadata]
        ↓
    [Insert vào messages (type: file, media_url)]
        ↓
[Supabase Realtime push tin nhắn]
        ↓
[Người nhận nhận được tin nhắn ngay lập tức]
        ↓
<Người nhận online?>
  ├─ Có → [Update status: delivered]
  └─ Không → [Giữ status: sent]
      ↓
[End]
```

---

## 5. Activity Diagram - Tạo nhóm chat

```
[Start]
  ↓
[Click "Tạo nhóm"]
  ↓
[Nhập tên nhóm]
  ↓
<Upload avatar nhóm?>
  ├─ Có
  │   ↓
  │ [Chọn ảnh]
  │   ↓
  │ [Upload lên Storage]
  │   ↓
  │ [Lấy URL]
  │
  └─ Không → [Dùng avatar mặc định]
      ↓
[Hiển thị danh sách bạn bè]
      ↓
[Chọn thành viên (nhiều người)]
      ↓
<Đã chọn ít nhất 1 người?>
  ├─ Không → [Hiển thị "Chọn ít nhất 1 thành viên"]
  └─ Có
      ↓
[Click "Tạo"]
      ↓
[Insert vào groups (created_by = current_user)]
      ↓
[Lấy group_id]
      ↓
[Loop: Với mỗi thành viên được chọn]
  ↓
[Insert vào group_members (group_id, user_id, role)]
      ↓
[Insert creator vào group_members (role: admin)]
      ↓
[Supabase Realtime push thông báo cho tất cả thành viên]
      ↓
[Chuyển đến màn hình Group Chat]
      ↓
[End]
```

---

## 6. Activity Diagram - Xem gợi ý kết bạn

```
[Start]
  ↓
[Mở tab "Gợi ý"]
  ↓
[Gọi function get_friend_suggestions(current_user_id)]
  ↓
[Function thực thi:]
  ├─ [Query users chưa là bạn bè]
  ├─ [Query users chưa gửi/nhận lời mời]
  ├─ [LEFT JOIN với friends để tìm bạn chung]
  ├─ [COUNT số lượng bạn chung]
  └─ [ORDER BY mutual_friends_count DESC]
      ↓
[Trả về danh sách top 10]
      ↓
<Có kết quả?>
  ├─ Không → [Hiển thị "Chưa có gợi ý"] → [End]
  └─ Có
      ↓
[Hiển thị danh sách với:]
  - Avatar
  - Tên
  - Số bạn chung
      ↓
[User có thể click "Thêm bạn bè"]
      ↓
[End]
```

---

## 7. Activity Diagram - Cập nhật trạng thái online

```
[Start: User đăng nhập]
  ↓
[Update is_online = true]
  ↓
[Update last_seen = NOW()]
  ↓
[Start Timer: 30 giây]
  ↓
[Loop: Mỗi 30 giây]
  ↓
<User vẫn đang dùng app?>
  ├─ Không (app bị kill/đóng)
  │   ↓
  │ [Stop Timer]
  │   ↓
  │ [Update is_online = false]
  │   ↓
  │ [Update last_seen = NOW()]
  │   ↓
  │ [End]
  │
  └─ Có
      ↓
  <Có hoạt động trong 5 phút qua?>
    ├─ Không
    │   ↓
    │ [Update status = 'away']
    │   ↓
    │ [Tiếp tục loop]
    │
    └─ Có
        ↓
    [Update last_seen = NOW()]
        ↓
    [Update status = 'online']
        ↓
    [Supabase Realtime push status cho bạn bè]
        ↓
    [Tiếp tục loop]
```

---

## Ký hiệu trong Activity Diagram:

- **[Start]** - Hình tròn đen (Initial node)
- **[End]** - Hình tròn đen viền trắng (Final node)
- **[Activity]** - Hình chữ nhật bo góc
- **<Decision?>** - Hình th菱 (Diamond)
- **[Fork/Join]** - Thanh ngang đen (cho parallel activities)
- **→** - Mũi tên chuyển tiếp
- **[Note]** - Ghi chú (hình chữ nhật góc gấp)

---

## Swimlanes (Phân làn):

Nếu muốn vẽ với swimlanes, chia thành:
- **User** (Người dùng)
- **Client App** (Ứng dụng Flutter)
- **Supabase Backend** (Server)
- **Database** (PostgreSQL)

---

## Lưu ý khi vẽ:

1. **Không dùng màu fill** cho các activity
2. **Có decision nodes** (diamond) cho các điều kiện
3. **Có notes** giải thích các bước quan trọng
4. **Có parallel activities** nếu có xử lý đồng thời
5. **Rõ ràng về luồng lỗi** (error handling)

---

**Tạo file Draw.io với 7 tabs tương ứng 7 activity diagrams trên!**
