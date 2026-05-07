# Activity Diagrams với Swimlane

Thư mục này chứa các **Activity Diagrams** (Sơ đồ hoạt động) với **Swimlane** (làn bơi) để phân chia rõ ràng giữa các actors.

## 📋 Danh sách Sơ đồ

### 1. [Authentication Activity](./01_authentication_activity.puml)
**Mô tả:** Quy trình xác thực (đăng nhập & đăng ký)

**Swimlanes:**
- 👤 Người dùng
- 🖥️ Hệ thống

**Luồng chính:**
1. Kiểm tra trạng thái đăng nhập
2. Đăng nhập hoặc Đăng ký
3. Xác thực thông tin
4. Tạo session
5. Chuyển đến trang chủ

---

### 2. [Friend Management Activity](./02_friend_management_activity.puml)
**Mô tả:** Quản lý bạn bè

**Swimlanes:**
- 👤 Người dùng
- 🖥️ Hệ thống

**Luồng chính:**
1. Tải danh sách bạn bè
2. Thêm bạn / Xem lời mời / Xóa bạn
3. Xử lý lời mời kết bạn
4. Cập nhật danh sách

---

### 3. [Realtime Chat Activity](./03_realtime_chat_activity.puml)
**Mô tả:** Chat thời gian thực

**Swimlanes:**
- 👤 Người dùng
- 🖥️ Hệ thống
- 👥 Người nhận

**Luồng chính:**
1. Mở cuộc trò chuyện
2. Thiết lập Realtime
3. Gửi tin nhắn / media
4. Broadcast qua WebSocket
5. Nhận và hiển thị tin nhắn

---

### 4. [Online Status Activity](./04_online_status_activity.puml)
**Mô tả:** Quản lý trạng thái online/offline

**Swimlanes:**
- 👤 Người dùng
- 🖥️ Hệ thống
- 👥 Bạn bè

**Luồng chính:**
1. Cập nhật online khi đăng nhập
2. Heartbeat loop (30s)
3. Phát hiện mất kết nối
4. Tự động reconnect
5. Broadcast trạng thái cho bạn bè

---

### 5. [Group Chat Activity](./05_group_chat_activity.puml)
**Mô tả:** Quản lý nhóm chat

**Swimlanes:**
- 👤 Người dùng
- 🖥️ Hệ thống

**Luồng chính:**
1. Tạo nhóm mới
2. Xem thông tin nhóm
3. Thêm/Xóa thành viên (admin)
4. Rời nhóm / Xóa nhóm
5. Chat trong nhóm

---

### 6. [Media Handling Activity](./06_media_handling_activity.puml)
**Mô tả:** Xử lý media (ảnh, video, audio, file)

**Swimlanes:**
- 👤 Người dùng
- 🖥️ Hệ thống

**Luồng chính:**
1. Chọn loại media
2. Validate file
3. Compress & thumbnail
4. Upload lên Storage
5. Lưu message với media_url
6. Hiển thị trong chat

---

## 🎨 Đặc điểm Activity Diagram với Swimlane

### Swimlane (Làn bơi)
```plantuml
|Người dùng|
:Hành động của người dùng;

|Hệ thống|
:Hành động của hệ thống;
```

**Lợi ích:**
- Phân chia rõ ràng trách nhiệm
- Dễ hiểu luồng tương tác
- Thấy được ai làm gì

### Decision (Quyết định)
```plantuml
if (Điều kiện?) then (Có)
  :Hành động A;
else (Không)
  :Hành động B;
endif
```

### Loop (Vòng lặp)
```plantuml
repeat
  :Hành động lặp lại;
repeat while (Tiếp tục?) is (Có)
```

### Notes (Ghi chú)
```plantuml
:Hành động;
note right
  Giải thích chi tiết
end note
```

---

## 🚀 Cách xem sơ đồ

### 1. VS Code
```bash
# Cài extension PlantUML
# Mở file .puml
# Nhấn Alt+D
```

### 2. Online
https://www.plantuml.com/plantuml/uml/

### 3. Export
```bash
cd docs/plantuml/activity_swimlane

# Export PNG
plantuml -tpng *.puml

# Export SVG
plantuml -tsvg *.puml
```

---

## 📊 So sánh với các loại sơ đồ khác

| Loại sơ đồ | Mục đích | Khi nào dùng |
|------------|----------|--------------|
| **Activity Diagram** | Mô tả luồng hoạt động | Business logic, quy trình |
| **Sequence Diagram** | Mô tả tương tác giữa objects | Technical design, API calls |
| **Activity + Swimlane** | Mô tả luồng với phân chia trách nhiệm | Quy trình có nhiều actors |

---

## 🎯 Best Practices

### 1. Đặt tên Swimlane rõ ràng
```plantuml
✅ Good:
|Người dùng|
|Hệ thống|
|Bạn bè|

❌ Bad:
|User|
|System|
```

### 2. Sử dụng if-else cho quyết định
```plantuml
if (Điều kiện?) then (Có)
  :Hành động khi đúng;
else (Không)
  :Hành động khi sai;
endif
```

### 3. Thêm notes giải thích
```plantuml
:Hành động phức tạp;
note right
  Giải thích chi tiết
  về logic này
end note
```

### 4. Sử dụng repeat cho vòng lặp
```plantuml
repeat
  :Hành động lặp lại;
repeat while (Tiếp tục?) is (Có)
```

---

## 📚 Tài liệu tham khảo

- [PlantUML Activity Diagram](https://plantuml.com/activity-diagram-beta)
- [UML Activity Diagram Tutorial](https://www.visual-paradigm.com/guide/uml-unified-modeling-language/what-is-activity-diagram/)
- [Swimlane Diagram Guide](https://www.lucidchart.com/pages/tutorial/swimlane-diagram)

---

**Tạo bởi:** Kiro AI Assistant  
**Ngày tạo:** May 7, 2026  
**Phiên bản:** 1.0.0
