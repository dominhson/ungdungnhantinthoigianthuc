# Draw.io Diagrams - Realtime Chat App

Thư mục này chứa các biểu đồ UML được tạo bằng draw.io (diagrams.net).

## 📋 Danh sách Biểu đồ

### 1. [Deployment Diagram](./deployment_diagram.drawio)
**Biểu đồ triển khai**

**Mô tả:** Mô tả kiến trúc triển khai hệ thống trên các node vật lý/ảo

**Bao gồm:**
- 📱 **Client Device** - Thiết bị người dùng (Mobile/Web)
  - Flutter App (APK/IPA/Web)
- ☁️ **Internet** - Mạng kết nối
- 🌐 **Supabase Cloud** - Backend as a Service
  - PostgreSQL Database
  - Realtime Server (WebSocket)
  - Storage Server (S3-compatible)
  - Auth Server (JWT-based)
  - CDN (Content Delivery Network)

**Kết nối:**
- HTTPS: Kết nối bảo mật
- WebSocket: Realtime connection
- SQL: Database queries
- REST API: HTTP requests
- JWT: Authentication tokens

---

### 2. [Component Diagram](./component_diagram.drawio)
**Biểu đồ thành phần**

**Mô tả:** Mô tả cấu trúc và mối quan hệ giữa các thành phần phần mềm

**Bao gồm 3 layers:**

#### 📱 Presentation Layer (UI Components)
- WelcomeScreen
- LoginScreen
- RegisterScreen
- ChatListScreen
- ChatScreen
- FriendsScreen
- GroupsScreen
- ProfileScreen

#### ⚙️ Business Logic Layer (Services)
- **AuthService** - Xác thực
  - signIn(), signUp(), signOut()
- **UserService** - Quản lý user
  - updateOnlineStatus(), getProfile(), updateProfile()
- **ChatService** - Chat
  - sendMessage(), getMessages(), subscribeToMessages()
- **FriendService** - Bạn bè
  - sendFriendRequest(), acceptRequest(), getFriends()
- **GroupService** - Nhóm
  - createGroup(), addMember(), removeGroup()
- **MediaService** - Media
  - uploadImage(), uploadVideo(), compressMedia()

#### 🗄️ Data Access Layer
- **SupabaseClient** - Database access
- **RealtimeChannel** - WebSocket connection
- **StorageService** - File storage
- **Models** - Data models
  - UserModel
  - MessageModel
  - ConversationModel
  - FriendModel

---

## 🚀 Cách mở và chỉnh sửa

### 1. Mở bằng draw.io Desktop
```bash
# Download draw.io Desktop
https://github.com/jgraph/drawio-desktop/releases

# Mở file .drawio
File → Open → Chọn file .drawio
```

### 2. Mở bằng draw.io Online
```
1. Truy cập: https://app.diagrams.net/
2. File → Open from → Device
3. Chọn file .drawio
```

### 3. Mở trong VS Code
```bash
# Cài extension Draw.io Integration
ext install hediet.vscode-drawio

# Click vào file .drawio để mở
```

---

## 📤 Export

### Export PNG/SVG/PDF

**Trong draw.io:**
```
File → Export as → PNG/SVG/PDF
- Chọn format
- Chọn quality
- Export
```

**Trong VS Code:**
```
Right click trên file .drawio
→ Export to PNG/SVG/PDF
```

---

## 🎨 Style Guide

### Màu sắc

| Thành phần | Màu | Hex Code |
|------------|-----|----------|
| UI Components | Vàng nhạt | #fff2cc |
| Services | Cam nhạt | #ffe6cc |
| Data Access | Hồng nhạt | #f8cecc |
| Models | Xám nhạt | #f5f5f5 |
| External | Xanh lá nhạt | #d5e8d4 |
| Layers | Xanh dương nhạt | #dae8fc |

### Kết nối

| Loại | Style | Màu |
|------|-------|-----|
| Dependency | Dashed line | #666666 |
| HTTPS | Solid line | #0066CC |
| WebSocket | Solid line | #CC0000 |
| REST API | Solid line | #FF9900 |
| SQL | Dashed line | #009900 |

---

## 🔧 Chỉnh sửa

### Thêm Component mới

1. Kéo shape "Rectangle" từ sidebar
2. Double click để đổi tên
3. Format → Fill color → Chọn màu
4. Thêm stereotype: `<<component>>`
5. Thêm methods nếu cần

### Thêm Connection

1. Click vào component nguồn
2. Kéo arrow đến component đích
3. Double click arrow để thêm label
4. Format → Line → Chọn style (solid/dashed)
5. Format → Line color → Chọn màu

### Thêm Layer

1. Kéo shape "Rectangle" lớn
2. Format → Fill color → Chọn màu layer
3. Thêm text: `<<layer>>`
4. Right click → To Back (đưa ra sau)
5. Đặt components vào trong layer

---

## 📚 Tài liệu tham khảo

### UML Diagrams
- [UML Deployment Diagram](https://www.visual-paradigm.com/guide/uml-unified-modeling-language/what-is-deployment-diagram/)
- [UML Component Diagram](https://www.visual-paradigm.com/guide/uml-unified-modeling-language/what-is-component-diagram/)

### Draw.io
- [Draw.io Documentation](https://www.diagrams.net/doc/)
- [Draw.io Shortcuts](https://www.diagrams.net/shortcuts)
- [Draw.io Examples](https://www.diagrams.net/example-diagrams)

---

## 🤝 Contributing

Khi thêm biểu đồ mới:
1. Đặt tên file: `feature_name_diagram.drawio`
2. Sử dụng style guide thống nhất
3. Thêm legend giải thích
4. Thêm notes nếu cần
5. Export PNG để preview
6. Cập nhật README này

---

## 💡 Tips

### 1. Sử dụng Layers
- Tổ chức components theo layers
- Dễ quản lý và chỉnh sửa

### 2. Sử dụng Containers
- Group các components liên quan
- Dễ di chuyển cùng lúc

### 3. Align & Distribute
- Sử dụng Arrange → Align
- Sử dụng Arrange → Distribute

### 4. Copy Style
- Format Painter (Ctrl+Shift+C)
- Paste Style (Ctrl+Shift+V)

### 5. Keyboard Shortcuts
- Ctrl+D: Duplicate
- Ctrl+G: Group
- Ctrl+Shift+G: Ungroup
- Ctrl+Shift+F: To Front
- Ctrl+Shift+B: To Back

---

**Tạo bởi:** Kiro AI Assistant  
**Ngày tạo:** May 7, 2026  
**Phiên bản:** 1.0.0
