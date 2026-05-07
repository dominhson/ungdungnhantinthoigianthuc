# Sequence Diagrams - Realtime Chat App

Thư mục này chứa các **Sequence Diagrams** (Sơ đồ tuần tự) mô tả chi tiết các tương tác giữa các thành phần trong hệ thống chat realtime.

## 📋 Danh sách Sơ đồ

### 1. [Authentication Sequence](./01_authentication_sequence.puml)
**Mô tả:** Quy trình xác thực người dùng (đăng nhập/đăng ký)

**Actors & Components:**
- 👤 Người dùng
- 🖥️ WelcomeScreen, LoginScreen, RegisterScreen, ChatListScreen
- ⚙️ AuthService, UserService
- 🗄️ Supabase Auth, users table

**Luồng chính:**
1. Kiểm tra trạng thái đăng nhập
2. Đăng nhập với email/password
3. Đăng ký tài khoản mới
4. Cập nhật trạng thái online
5. Chuyển sang màn hình chat

---

### 2. [Friend Management Sequence](./02_friend_management_sequence.puml)
**Mô tả:** Quản lý bạn bè và lời mời kết bạn

**Actors & Components:**
- 👤 Người dùng
- 🖥️ FriendsScreen, FriendRequestsScreen
- ⚙️ FriendService
- 🗄️ friends, friend_requests, users tables

**Luồng chính:**
1. Tải danh sách bạn bè
2. Gửi lời mời kết bạn
3. Xem gợi ý kết bạn (mutual friends)
4. Chấp nhận/Từ chối lời mời
5. Xóa bạn bè

---

### 3. [Realtime Chat Sequence](./03_realtime_chat_sequence.puml)
**Mô tả:** Gửi/Nhận tin nhắn realtime

**Actors & Components:**
- 👤 Người gửi, Người nhận
- 🖥️ ChatScreen
- ⚙️ ChatService, RealtimeChannel
- 🗄️ conversations, messages, typing_indicators tables

**Luồng chính:**
1. Mở cuộc trò chuyện
2. Thiết lập Realtime channel
3. Typing indicator ("đang gõ...")
4. Gửi tin nhắn
5. Broadcast qua Realtime
6. Nhận tin nhắn (realtime)
7. Đánh dấu đã đọc

---

### 4. [Online Status Sequence](./04_online_status_sequence.puml)
**Mô tả:** Quản lý trạng thái online/offline

**Actors & Components:**
- 👤 Người dùng A, Bạn bè (User B)
- 🖥️ MainScreen
- ⚙️ UserService, HeartbeatTimer, RealtimeChannel
- 🗄️ users table

**Luồng chính:**
1. Khởi tạo trạng thái online
2. Bắt đầu Heartbeat Timer (30s)
3. Subscribe trạng thái bạn bè
4. Heartbeat loop (cập nhật last_seen)
5. Phát hiện mất kết nối
6. Tự động kết nối lại
7. Đăng xuất thủ công

---

### 5. [Group Chat Sequence](./05_group_chat_sequence.puml)
**Mô tả:** Tạo và quản lý nhóm chat

**Actors & Components:**
- 👤 Admin, Thành viên
- 🖥️ MyGroupsScreen, CreateGroupScreen, GroupInfoScreen
- ⚙️ GroupService, StorageService
- 🗄️ conversations, conversation_participants, messages tables

**Luồng chính:**
1. Tải danh sách nhóm
2. Tạo nhóm mới (với avatar)
3. Xem thông tin nhóm
4. Thêm thành viên (admin)
5. Rời nhóm (member)
6. Xóa nhóm (creator)

---

### 6. [Media Handling Sequence](./06_media_handling_sequence.puml)
**Mô tả:** Upload và xử lý media (ảnh, video, audio, file)

**Actors & Components:**
- 👤 Người dùng
- 🖥️ ChatScreen, MediaPicker
- ⚙️ MediaService, StorageService, ChatService
- 🗄️ Supabase Storage, messages, media_metadata tables

**Luồng chính:**
1. Chọn loại media
2. Validate file
3. Compress & generate thumbnail
4. Upload lên Supabase Storage
5. Lấy public URL
6. Insert message với media_url
7. Lưu metadata
8. Broadcast tin nhắn

---

## 🎨 Đặc điểm Sequence Diagram

### Màu sắc
- **🔵 DeepSkyBlue**: Request/Action từ user hoặc component
- **🔴 Red**: Response/Return từ system

### Ký hiệu
- **actor**: Người dùng (User, Admin, Member)
- **boundary**: UI Components (Screens)
- **control**: Business Logic (Services)
- **entity**: Database Tables

### Cấu trúc
```plantuml
actor "Người dùng" as User
boundary ": Screen" as UI
control ": Service" as Ctrl
entity ": Table" as DB

User -> UI: 1. Action
UI -> Ctrl: 2. Method call
Ctrl -> DB: 3. Query
DB --> Ctrl: 4. Result
Ctrl --> UI: 5. Data
UI --> User: 6. Display
```

---

## 🚀 Cách xem sơ đồ

### 1. VS Code (Khuyến nghị)
```bash
# Cài extension PlantUML
# Mở file .puml
# Nhấn Alt+D để preview
```

### 2. Online
Truy cập: https://www.plantuml.com/plantuml/uml/
- Copy nội dung file `.puml`
- Paste vào editor
- Xem kết quả realtime

### 3. Export PNG/SVG
```bash
cd docs/plantuml/sequence

# Export tất cả
plantuml -tpng *.puml
plantuml -tsvg *.puml

# Export một file
plantuml -tpng 01_authentication_sequence.puml
```

---

## 📊 So sánh với Activity Diagram

| Tiêu chí | Activity Diagram | Sequence Diagram |
|----------|------------------|------------------|
| **Mục đích** | Mô tả luồng hoạt động | Mô tả tương tác giữa các thành phần |
| **Focus** | Quy trình nghiệp vụ | Giao tiếp giữa objects |
| **Thời gian** | Không quan trọng | Theo thứ tự thời gian |
| **Phù hợp** | Business logic | Technical design |
| **Actors** | Ít | Nhiều (User, UI, Service, DB) |

**Khi nào dùng:**
- **Activity Diagram**: Khi muốn hiểu luồng nghiệp vụ tổng thể
- **Sequence Diagram**: Khi muốn hiểu chi tiết cách các component tương tác

---

## 🎯 Best Practices

### 1. Đặt tên rõ ràng
```plantuml
✅ Good:
actor "Người dùng" as User
boundary ": LoginScreen" as Login
control ": AuthService" as AuthCtrl

❌ Bad:
actor User
boundary UI
control Service
```

### 2. Sử dụng màu sắc nhất quán
```plantuml
skinparam ArrowColor DeepSkyBlue  // Request
skinparam ArrowColor Red          // Response
```

### 3. Group các luồng liên quan
```plantuml
group Trường hợp thành công
  ' ... success flow
end

group Trường hợp lỗi
  ' ... error flow
end
```

### 4. Thêm notes giải thích
```plantuml
note right of Component
  Giải thích logic phức tạp
  hoặc business rule
end note
```

### 5. Sử dụng alt/loop/opt
```plantuml
alt Điều kiện A
  ' Flow A
else Điều kiện B
  ' Flow B
end

loop Lặp lại
  ' Repeated flow
end
```

---

## 📚 Tài liệu tham khảo

- [PlantUML Sequence Diagram](https://plantuml.com/sequence-diagram)
- [UML Sequence Diagram Tutorial](https://www.visual-paradigm.com/guide/uml-unified-modeling-language/what-is-sequence-diagram/)
- [Sequence Diagram Best Practices](https://www.lucidchart.com/pages/uml-sequence-diagram)

---

## 🤝 Contributing

Khi thêm sơ đồ mới:
1. Đặt tên file: `XX_feature_name_sequence.puml`
2. Sử dụng cùng style và màu sắc
3. Thêm title và hide footbox
4. Định nghĩa rõ actors và components
5. Sử dụng group cho các luồng phức tạp
6. Thêm notes giải thích khi cần
7. Cập nhật README này

---

**Tạo bởi:** Kiro AI Assistant  
**Ngày tạo:** May 7, 2026  
**Phiên bản:** 1.0.0
