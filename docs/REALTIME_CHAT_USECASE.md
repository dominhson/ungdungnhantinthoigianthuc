# Use Case Diagram - Realtime Chat Application

## Tổng quan dự án
**Realtime Chat with Flutter** - Ứng dụng nhắn tin thời gian thực được xây dựng với Flutter và Supabase.

---

## Actors (Tác nhân)

### 1. **Người dùng chưa đăng ký** (Guest User)
- Người dùng mới, chưa có tài khoản
- Chỉ có thể xem màn hình welcome và đăng ký

### 2. **Người dùng đã đăng ký** (Registered User)
- Đã có tài khoản trong hệ thống
- Có thể sử dụng đầy đủ các chức năng chat

### 3. **Hệ thống Supabase** (Supabase System)
- Backend tự động xử lý realtime
- Quản lý authentication, database, storage

---

## Use Cases (Chức năng)

### A. Quản lý Tài khoản & Xác thực

#### UC01: Đăng ký tài khoản
- **Actor**: Người dùng chưa đăng ký
- **Mô tả**: Tạo tài khoản mới với email và mật khẩu
- **Màn hình**: `register_screen.dart`
- **Service**: `auth_service.dart`
- **Flow**:
  1. Nhập email, password, full name
  2. Hệ thống xác thực thông tin
  3. Tạo user trong Supabase Auth
  4. Tạo profile trong bảng `users`

#### UC02: Đăng nhập
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Đăng nhập vào hệ thống
- **Màn hình**: `login_screen.dart`
- **Service**: `auth_service.dart`
- **Include**: Cập nhật trạng thái online

#### UC03: Đăng xuất
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Thoát khỏi hệ thống
- **Include**: Cập nhật trạng thái offline

#### UC04: Quản lý Profile
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Xem và chỉnh sửa thông tin cá nhân
- **Màn hình**: `profile_screen.dart`, `edit_profile_screen.dart`
- **Service**: `profile_service.dart`
- **Chức năng**:
  - Xem profile (avatar, full name, email, bio)
  - Chỉnh sửa thông tin
  - Upload/thay đổi avatar
  - Xem trạng thái online/offline

---

### B. Quản lý Bạn bè

#### UC05: Tìm kiếm người dùng
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Tìm kiếm người dùng khác trong hệ thống
- **Màn hình**: `search_screen.dart`, `friends_screen.dart`
- **Service**: `search_service.dart`, `friend_service.dart`
- **Chức năng**:
  - Tìm kiếm theo tên, email
  - Xem danh sách gợi ý kết bạn (dựa trên bạn chung)
  - Xem profile người dùng khác

#### UC06: Gửi lời mời kết bạn
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Gửi yêu cầu kết bạn đến người dùng khác
- **Service**: `friend_service.dart`
- **Database**: Bảng `friend_requests`
- **Include**: Tìm kiếm người dùng

#### UC07: Quản lý lời mời kết bạn
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Xem và xử lý lời mời kết bạn nhận được
- **Màn hình**: `friends_screen.dart`
- **Service**: `friend_service.dart`
- **Chức năng**:
  - Xem danh sách lời mời đang chờ
  - Chấp nhận lời mời (tạo quan hệ bạn bè 2 chiều)
  - Từ chối lời mời
- **Trigger**: `on_friend_request_accepted` tự động tạo friendship

#### UC08: Xem danh sách bạn bè
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Xem tất cả bạn bè hiện tại
- **Màn hình**: `my_friends_screen.dart`
- **Service**: `friend_service.dart`
- **Database**: Bảng `friends`
- **Hiển thị**:
  - Avatar, tên, trạng thái online/offline
  - Last seen (nếu offline)
  - Số lượng bạn chung

#### UC09: Xóa bạn bè
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Hủy quan hệ bạn bè
- **Service**: `friend_service.dart`
- **Database**: Xóa 2 bản ghi trong bảng `friends`

#### UC10: Xem gợi ý kết bạn
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Xem danh sách người dùng được gợi ý dựa trên bạn chung
- **Service**: `friend_service.dart`
- **Function**: `get_friend_suggestions()`
- **Thuật toán**: Sắp xếp theo số lượng bạn chung giảm dần

---

### C. Nhắn tin 1-1 (Direct Messages)

#### UC11: Xem danh sách cuộc trò chuyện
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Xem tất cả cuộc trò chuyện đang có
- **Màn hình**: `chat_list_screen.dart`
- **Service**: `chat_service.dart`
- **Database**: Bảng `conversations`
- **Hiển thị**:
  - Avatar người chat
  - Tin nhắn cuối cùng
  - Thời gian
  - Trạng thái online/offline
  - Số tin nhắn chưa đọc (nếu có)

#### UC12: Bắt đầu cuộc trò chuyện mới
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Tạo cuộc trò chuyện mới với bạn bè
- **Service**: `chat_service.dart`
- **Include**: Xem danh sách bạn bè
- **Flow**:
  1. Chọn bạn bè từ danh sách
  2. Tạo conversation (nếu chưa có)
  3. Chuyển đến màn hình chat

#### UC13: Gửi tin nhắn văn bản
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Gửi tin nhắn text trong cuộc trò chuyện
- **Màn hình**: `chat_screen.dart`
- **Service**: `chat_service.dart`
- **Database**: Bảng `messages`
- **Realtime**: Tin nhắn hiển thị ngay lập tức cho cả 2 người

#### UC14: Gửi tin nhắn hình ảnh
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Gửi ảnh trong cuộc trò chuyện
- **Service**: `chat_service.dart`, `media_service.dart`, `storage_service.dart`
- **Flow**:
  1. Chọn ảnh từ thư viện hoặc chụp ảnh
  2. Upload lên Supabase Storage
  3. Lưu URL vào bảng `messages`
  4. Hiển thị ảnh trong chat

#### UC15: Gửi tin nhắn file
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Gửi file đính kèm
- **Service**: `chat_service.dart`, `media_service.dart`, `storage_service.dart`
- **Hỗ trợ**: PDF, DOC, XLS, v.v.

#### UC16: Xem tin nhắn
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Xem lịch sử tin nhắn trong cuộc trò chuyện
- **Màn hình**: `chat_screen.dart`
- **Service**: `chat_service.dart`
- **Realtime**: Tự động cập nhật khi có tin nhắn mới
- **Hiển thị**:
  - Tin nhắn text
  - Hình ảnh (preview)
  - File (icon + tên file)
  - Thời gian gửi
  - Trạng thái đã đọc/chưa đọc

#### UC17: Xóa tin nhắn
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Xóa tin nhắn đã gửi
- **Service**: `message_actions_service.dart`
- **Chức năng**:
  - Xóa chỉ ở phía mình
  - Xóa cho cả 2 người (nếu trong thời gian cho phép)

#### UC18: Tìm kiếm tin nhắn
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Tìm kiếm tin nhắn trong cuộc trò chuyện
- **Service**: `search_service.dart`

---

### D. Nhóm Chat (Group Chat)

#### UC19: Tạo nhóm chat
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Tạo nhóm chat mới với nhiều thành viên
- **Màn hình**: `create_group_screen.dart`
- **Service**: `group_service.dart`
- **Database**: Bảng `groups`, `group_members`
- **Flow**:
  1. Nhập tên nhóm
  2. Chọn avatar nhóm (optional)
  3. Chọn thành viên từ danh sách bạn bè
  4. Tạo nhóm

#### UC20: Xem danh sách nhóm
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Xem tất cả nhóm mà mình là thành viên
- **Màn hình**: `my_groups_screen.dart`
- **Service**: `group_service.dart`

#### UC21: Gửi tin nhắn trong nhóm
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Gửi tin nhắn trong nhóm chat
- **Service**: `group_service.dart`, `chat_service.dart`
- **Realtime**: Tất cả thành viên nhận tin nhắn ngay lập tức

#### UC22: Quản lý thành viên nhóm
- **Actor**: Người dùng đã đăng ký (Admin nhóm)
- **Mô tả**: Thêm/xóa thành viên, phân quyền
- **Màn hình**: `group_info_screen.dart`
- **Service**: `group_service.dart`
- **Chức năng**:
  - Thêm thành viên mới
  - Xóa thành viên
  - Chuyển quyền admin
  - Rời nhóm

#### UC23: Xem thông tin nhóm
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Xem chi tiết thông tin nhóm
- **Màn hình**: `group_info_screen.dart`
- **Hiển thị**:
  - Tên nhóm, avatar
  - Danh sách thành viên
  - Ngày tạo
  - Admin

---

### E. Trạng thái & Realtime

#### UC24: Cập nhật trạng thái online
- **Actor**: Hệ thống Supabase
- **Mô tả**: Tự động cập nhật trạng thái online của user
- **Service**: `user_service.dart`
- **Database**: Cột `is_online`, `last_seen` trong bảng `users`
- **Cơ chế**: Cập nhật mỗi 30 giây khi app đang mở

#### UC25: Nhận tin nhắn realtime
- **Actor**: Hệ thống Supabase
- **Mô tả**: Push tin nhắn mới đến client ngay lập tức
- **Service**: `chat_service.dart`
- **Technology**: Supabase Realtime (WebSocket)

#### UC26: Nhận thông báo lời mời kết bạn
- **Actor**: Hệ thống Supabase
- **Mô tả**: Thông báo realtime khi có lời mời kết bạn mới
- **Service**: `friend_service.dart`

---

### F. Cài đặt

#### UC27: Cài đặt ứng dụng
- **Actor**: Người dùng đã đăng ký
- **Mô tả**: Thay đổi cài đặt app
- **Màn hình**: `settings_screen.dart`
- **Chức năng**:
  - Thay đổi theme (sáng/tối)
  - Cài đặt thông báo
  - Ngôn ngữ
  - Quyền riêng tư

---

## Mối quan hệ Use Case

### Generalization (Kế thừa)
- **Người dùng đã đăng ký** kế thừa từ **Người dùng chưa đăng ký**

### Include (Bao gồm)
Các use case sau **bắt buộc** phải thực hiện use case **Đăng nhập**:
- UC04: Quản lý Profile
- UC05: Tìm kiếm người dùng
- UC06: Gửi lời mời kết bạn
- UC07: Quản lý lời mời kết bạn
- UC08: Xem danh sách bạn bè
- UC09: Xóa bạn bè
- UC10: Xem gợi ý kết bạn
- UC11: Xem danh sách cuộc trò chuyện
- UC12: Bắt đầu cuộc trò chuyện mới
- UC13-18: Tất cả chức năng nhắn tin
- UC19-23: Tất cả chức năng nhóm
- UC27: Cài đặt ứng dụng

### Extend (Mở rộng)
- **UC14: Gửi tin nhắn hình ảnh** extends **UC13: Gửi tin nhắn văn bản**
- **UC15: Gửi tin nhắn file** extends **UC13: Gửi tin nhắn văn bản**

---

## Database Schema

### Bảng chính:
1. **users** - Thông tin người dùng
   - id, email, full_name, avatar_url, bio
   - is_online, last_seen
   - created_at, updated_at

2. **friends** - Quan hệ bạn bè (2 chiều)
   - id, user_id, friend_id
   - created_at

3. **friend_requests** - Lời mời kết bạn
   - id, sender_id, receiver_id
   - status (pending/accepted/rejected)
   - created_at, updated_at

4. **conversations** - Cuộc trò chuyện 1-1
   - id, user1_id, user2_id
   - created_at, updated_at

5. **messages** - Tin nhắn
   - id, conversation_id, sender_id
   - content, message_type (text/image/file)
   - media_url, file_name, file_size
   - is_read, created_at

6. **groups** - Nhóm chat
   - id, name, avatar_url, created_by
   - created_at, updated_at

7. **group_members** - Thành viên nhóm
   - id, group_id, user_id
   - role (admin/member)
   - joined_at

---

## Tech Stack

### Frontend
- **Framework**: Flutter 3.5.0
- **State Management**: Provider / Riverpod (tùy implementation)
- **UI**: Material Design với custom theme

### Backend
- **BaaS**: Supabase
- **Database**: PostgreSQL
- **Realtime**: Supabase Realtime (WebSocket)
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage (cho ảnh, file)

### Packages chính
- `supabase_flutter: ^2.12.4` - Supabase client
- `image_picker: ^1.0.7` - Chọn ảnh
- `file_picker: ^8.0.0+1` - Chọn file

---

## Tính năng nổi bật

### 1. Realtime Updates
- Tin nhắn hiển thị ngay lập tức
- Trạng thái online/offline cập nhật realtime
- Lời mời kết bạn thông báo ngay

### 2. Gợi ý kết bạn thông minh
- Dựa trên số lượng bạn chung
- Function `get_friend_suggestions()` tối ưu

### 3. Quan hệ bạn bè 2 chiều
- Trigger tự động tạo friendship khi chấp nhận lời mời
- Đảm bảo tính nhất quán dữ liệu

### 4. Row Level Security (RLS)
- Bảo mật dữ liệu ở cấp database
- User chỉ xem được dữ liệu của mình

### 5. Media Support
- Upload/download ảnh, file
- Preview ảnh trong chat
- Quản lý storage hiệu quả

---

## Sơ đồ quan hệ Actor

```
Người dùng chưa đăng ký
    └── Người dùng đã đăng ký

Hệ thống Supabase (Backend)
```

---

## Tổng kết

- **Actors**: 3 (Guest, Registered User, Supabase System)
- **Use Cases**: 27 chức năng
- **Screens**: 15 màn hình
- **Services**: 11 services
- **Database Tables**: 7 bảng chính

---

**Dự án**: Realtime Chat with Flutter  
**Tech**: Flutter + Supabase  
**Tác giả**: nguyenducteong  
**Repository**: https://github.com/nguyenducteong/Realtime-Chat-With-Flutter
