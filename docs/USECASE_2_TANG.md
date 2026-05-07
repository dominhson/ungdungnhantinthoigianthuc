# Use Case Diagram 2 Tầng - Lumine Chat

## Cấu trúc

### Tầng 1: Use Case Tổng Quát (Overview)
File: `Lumine_Chat_UseCase_Overview.drawio`

### Tầng 2: Use Case Chi Tiết (Details) 
File: `Lumine_Chat_UseCase.drawio` (đã tạo trước đó)

---

## TẦNG 1: USE CASE TỔNG QUÁT

### Actors (3)
- 👤 **Guest User** - Người dùng chưa đăng ký
- 👤 **Registered User** - Người dùng đã đăng ký (kế thừa Guest)
- 🤖 **Supabase System** - Hệ thống backend

### Use Cases Chính (6 UC lớn)

#### 1. 🔵 **Quản lý Xác thực**
- **Actor**: Guest User, Registered User
- **Mô tả**: Xử lý đăng ký, đăng nhập, đăng xuất, quản lý profile
- **Phân rã thành**: 4 UC con (xem tầng 2)

#### 2. 🟢 **Quản lý Bạn bè**
- **Actor**: Registered User
- **Mô tả**: Tìm kiếm, kết bạn, quản lý danh sách bạn bè
- **Include**: Quản lý Xác thực
- **Phân rã thành**: 6 UC con (xem tầng 2)

#### 3. 🟡 **Nhắn tin 1-1**
- **Actor**: Registered User
- **Mô tả**: Chat trực tiếp với bạn bè
- **Include**: Quản lý Xác thực
- **Phân rã thành**: 8 UC con (xem tầng 2)

#### 4. 🔴 **Quản lý Nhóm Chat**
- **Actor**: Registered User
- **Mô tả**: Tạo nhóm, chat nhóm, quản lý thành viên
- **Include**: Quản lý Xác thực
- **Phân rã thành**: 5 UC con (xem tầng 2)

#### 5. 🟣 **Xử lý Realtime**
- **Actor**: Supabase System
- **Mô tả**: Cập nhật trạng thái, push tin nhắn, thông báo
- **Phân rã thành**: 3 UC con (xem tầng 2)

#### 6. 🟠 **Cài đặt Ứng dụng**
- **Actor**: Registered User
- **Mô tả**: Cấu hình app
- **Include**: Quản lý Xác thực
- **Phân rã thành**: 1 UC con (xem tầng 2)

---

## TẦNG 2: USE CASE CHI TIẾT (PHÂN RÃ)

### 1. 🔵 Quản lý Xác thực → 4 UC con

#### UC01: Đăng ký tài khoản
- **Actor**: Guest User
- **Flow**:
  1. Nhập email, password, full name
  2. Hệ thống validate
  3. Tạo account trong Supabase Auth
  4. Tạo profile trong bảng users

#### UC02: Đăng nhập ⭐
- **Actor**: Registered User
- **Flow**:
  1. Nhập email, password
  2. Xác thực với Supabase
  3. Cập nhật trạng thái online (include UC24)
  4. Chuyển đến màn hình chính

#### UC03: Đăng xuất
- **Actor**: Registered User
- **Flow**:
  1. User click đăng xuất
  2. Cập nhật trạng thái offline (include UC24)
  3. Clear session
  4. Về màn hình login

#### UC04: Quản lý Profile
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Xem profile (avatar, name, email, bio)
  2. Chỉnh sửa thông tin
  3. Upload avatar mới
  4. Lưu thay đổi

---

### 2. 🟢 Quản lý Bạn bè → 6 UC con

#### UC05: Tìm kiếm người dùng
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Nhập từ khóa (tên, email)
  2. Hệ thống tìm kiếm trong bảng users
  3. Hiển thị kết quả
  4. Xem profile người dùng

#### UC06: Gửi lời mời kết bạn
- **Actor**: Registered User
- **Include**: UC02, UC05 (Tìm kiếm)
- **Flow**:
  1. Chọn người dùng từ kết quả tìm kiếm
  2. Click "Thêm bạn bè"
  3. Tạo bản ghi trong friend_requests (status: pending)
  4. Hệ thống gửi thông báo realtime (UC26)

#### UC07: Quản lý lời mời kết bạn
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Xem danh sách lời mời đang chờ
  2. **Chấp nhận**: 
     - Update status = 'accepted'
     - Trigger tự động tạo 2 bản ghi trong friends
  3. **Từ chối**: Update status = 'rejected'

#### UC08: Xem danh sách bạn bè
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Query bảng friends WHERE user_id = current_user
  2. Hiển thị danh sách với:
     - Avatar, tên
     - Trạng thái online/offline
     - Last seen
  3. Click vào bạn bè → Xem profile hoặc Chat

#### UC09: Xóa bạn bè
- **Actor**: Registered User
- **Include**: UC02, UC08
- **Flow**:
  1. Chọn bạn bè từ danh sách
  2. Click "Xóa bạn bè"
  3. Xác nhận
  4. Xóa 2 bản ghi trong friends (2 chiều)

#### UC10: Xem gợi ý kết bạn
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Gọi function get_friend_suggestions()
  2. Hệ thống tính toán dựa trên bạn chung
  3. Hiển thị danh sách gợi ý
  4. Hiển thị số lượng bạn chung

---

### 3. 🟡 Nhắn tin 1-1 → 8 UC con

#### UC11: Xem danh sách cuộc trò chuyện
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Query bảng conversations
  2. Hiển thị danh sách với:
     - Avatar người chat
     - Tin nhắn cuối
     - Thời gian
     - Số tin nhắn chưa đọc

#### UC12: Bắt đầu cuộc trò chuyện mới
- **Actor**: Registered User
- **Include**: UC02, UC08 (Xem bạn bè)
- **Flow**:
  1. Chọn bạn bè từ danh sách
  2. Kiểm tra conversation đã tồn tại chưa
  3. Nếu chưa: Tạo mới trong conversations
  4. Chuyển đến màn hình chat

#### UC13: Gửi tin nhắn văn bản
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Nhập nội dung tin nhắn
  2. Click gửi
  3. Insert vào bảng messages
  4. Hệ thống push realtime (UC25)

#### UC14: Gửi tin nhắn hình ảnh
- **Actor**: Registered User
- **Extend**: UC13 (Gửi text)
- **Flow**:
  1. Chọn ảnh từ thư viện hoặc chụp ảnh
  2. Upload lên Supabase Storage
  3. Lấy URL
  4. Insert vào messages với message_type = 'image'
  5. Push realtime

#### UC15: Gửi tin nhắn file
- **Actor**: Registered User
- **Extend**: UC13 (Gửi text)
- **Flow**:
  1. Chọn file (PDF, DOC, XLS, etc.)
  2. Upload lên Supabase Storage
  3. Lấy URL và metadata (tên, size)
  4. Insert vào messages với message_type = 'file'
  5. Push realtime

#### UC16: Xem tin nhắn
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Query messages WHERE conversation_id
  2. Subscribe realtime updates
  3. Hiển thị tin nhắn (text, ảnh, file)
  4. Update is_read = true

#### UC17: Xóa tin nhắn
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Long press tin nhắn
  2. Chọn "Xóa"
  3. Chọn: Xóa ở phía mình / Xóa cho cả 2
  4. Update hoặc delete trong messages

#### UC18: Tìm kiếm tin nhắn
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Nhập từ khóa
  2. Search trong messages WHERE content LIKE '%keyword%'
  3. Hiển thị kết quả
  4. Click vào kết quả → Jump đến tin nhắn đó

---

### 4. 🔴 Quản lý Nhóm Chat → 5 UC con

#### UC19: Tạo nhóm chat
- **Actor**: Registered User
- **Include**: UC02, UC08 (Xem bạn bè)
- **Flow**:
  1. Nhập tên nhóm
  2. Chọn avatar nhóm (optional)
  3. Chọn thành viên từ danh sách bạn bè
  4. Tạo bản ghi trong groups
  5. Tạo group_members cho tất cả thành viên

#### UC20: Xem danh sách nhóm
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Query groups JOIN group_members WHERE user_id
  2. Hiển thị danh sách nhóm
  3. Hiển thị tin nhắn cuối, số thành viên

#### UC21: Gửi tin nhắn trong nhóm
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Nhập tin nhắn
  2. Insert vào messages với group_id
  3. Push realtime cho tất cả thành viên (UC25)

#### UC22: Quản lý thành viên nhóm
- **Actor**: Registered User (Admin)
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Xem danh sách thành viên
  2. **Thêm thành viên**: Insert vào group_members
  3. **Xóa thành viên**: Delete từ group_members
  4. **Chuyển admin**: Update role trong group_members
  5. **Rời nhóm**: Delete bản ghi của mình

#### UC23: Xem thông tin nhóm
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Xem tên nhóm, avatar
  2. Xem danh sách thành viên
  3. Xem ngày tạo, admin
  4. Xem media đã chia sẻ

---

### 5. 🟣 Xử lý Realtime → 3 UC con

#### UC24: Cập nhật trạng thái online
- **Actor**: Supabase System (tự động)
- **Flow**:
  1. Khi user đăng nhập: Update is_online = true
  2. Mỗi 30 giây: Update last_seen = NOW()
  3. Khi user đăng xuất: Update is_online = false
  4. Push realtime cho bạn bè

#### UC25: Nhận tin nhắn realtime
- **Actor**: Supabase System (tự động)
- **Flow**:
  1. Khi có tin nhắn mới trong messages
  2. Supabase Realtime (WebSocket) push đến client
  3. Client nhận và hiển thị ngay lập tức
  4. Không cần refresh

#### UC26: Nhận thông báo lời mời kết bạn
- **Actor**: Supabase System (tự động)
- **Flow**:
  1. Khi có bản ghi mới trong friend_requests
  2. Push realtime đến receiver
  3. Hiển thị badge thông báo
  4. User click vào → UC07 (Quản lý lời mời)

---

### 6. 🟠 Cài đặt Ứng dụng → 1 UC con

#### UC27: Cài đặt ứng dụng
- **Actor**: Registered User
- **Include**: UC02 (Đăng nhập)
- **Flow**:
  1. Mở màn hình Settings
  2. Thay đổi theme (sáng/tối)
  3. Cài đặt thông báo (bật/tắt)
  4. Chọn ngôn ngữ
  5. Cài đặt quyền riêng tư
  6. Lưu preferences

---

## Tổng kết

### Tầng 1 (Overview):
- **6 Use Cases lớn**
- Dễ hiểu, tổng quan
- Phù hợp cho stakeholder, khách hàng

### Tầng 2 (Details):
- **27 Use Cases chi tiết**
- Phân rã từ 6 UC lớn
- Phù hợp cho developer, tester

### Lợi ích:
✅ Dễ quản lý (không quá phức tạp)
✅ Dễ trình bày (overview trước, details sau)
✅ Dễ maintain (thay đổi 1 UC không ảnh hưởng toàn bộ)
✅ Chuẩn UML (theo best practice)

---

## Files đã tạo:

1. **Lumine_Chat_UseCase_Overview.drawio** - Tầng 1 (6 UC lớn) ✅
2. **Lumine_Chat_UseCase.drawio** - Tầng 2 (27 UC chi tiết) ✅
3. **USECASE_2_TANG.md** - Tài liệu giải thích ✅

Mở file `.drawio` trong Draw.io để xem diagram!
