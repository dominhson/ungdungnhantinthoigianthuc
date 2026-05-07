# Sơ đồ hoạt động 1: Xác thực người dùng (Authentication Flow)

```mermaid
flowchart TD
    Start([Người dùng mở ứng dụng]) --> CheckAuth{Đã đăng nhập?}
    
    CheckAuth -->|Có| ShowChatList[Hiển thị danh sách chat]
    CheckAuth -->|Không| ShowWelcome[Hiển thị màn hình Welcome]
    
    ShowWelcome --> UserChoice{Người dùng chọn}
    UserChoice -->|Đăng nhập| LoginScreen[Màn hình đăng nhập]
    UserChoice -->|Đăng ký| RegisterScreen[Màn hình đăng ký]
    
    %% Login Flow
    LoginScreen --> EnterLoginInfo[Nhập email và password]
    EnterLoginInfo --> ValidateLogin{Kiểm tra thông tin}
    ValidateLogin -->|Không hợp lệ| ShowLoginError[Hiển thị lỗi]
    ShowLoginError --> EnterLoginInfo
    ValidateLogin -->|Hợp lệ| CallLoginAPI[Gọi Supabase Auth API]
    
    CallLoginAPI --> LoginSuccess{Đăng nhập thành công?}
    LoginSuccess -->|Không| ShowLoginError
    LoginSuccess -->|Có| UpdateOnlineStatus[Cập nhật trạng thái online]
    
    %% Register Flow
    RegisterScreen --> EnterRegisterInfo[Nhập email, password, tên]
    EnterRegisterInfo --> ValidateRegister{Kiểm tra thông tin}
    ValidateRegister -->|Không hợp lệ| ShowRegisterError[Hiển thị lỗi]
    ShowRegisterError --> EnterRegisterInfo
    ValidateRegister -->|Hợp lệ| CallRegisterAPI[Gọi Supabase Auth API]
    
    CallRegisterAPI --> CreateUserProfile[Tạo profile trong bảng users]
    CreateUserProfile --> RegisterSuccess{Đăng ký thành công?}
    RegisterSuccess -->|Không| ShowRegisterError
    RegisterSuccess -->|Có| UpdateOnlineStatus
    
    UpdateOnlineStatus --> InitRealtimeConnection[Khởi tạo kết nối Realtime]
    InitRealtimeConnection --> ShowChatList
    
    ShowChatList --> End([Kết thúc])
    
    style Start fill:#4ade80
    style End fill:#f87171
    style ShowChatList fill:#60a5fa
    style UpdateOnlineStatus fill:#fbbf24
    style InitRealtimeConnection fill:#a78bfa
```

## Mô tả luồng hoạt động

### 1. Kiểm tra trạng thái đăng nhập
- Ứng dụng sử dụng `StreamBuilder` để lắng nghe `auth.onAuthStateChange`
- Nếu có session, chuyển đến màn hình chat
- Nếu không, hiển thị màn hình Welcome

### 2. Đăng nhập (Login)
- Người dùng nhập email và password
- Validate dữ liệu đầu vào
- Gọi `AuthService.signIn()` → `supabase.auth.signInWithPassword()`
- Nếu thành công, cập nhật trạng thái online và khởi tạo Realtime

### 3. Đăng ký (Register)
- Người dùng nhập email, password và tên đầy đủ
- Validate dữ liệu đầu vào
- Gọi `AuthService.signUp()` → `supabase.auth.signUp()`
- Tạo bản ghi trong bảng `users` với thông tin profile
- Nếu thành công, tự động đăng nhập và chuyển đến màn hình chat

### 4. Khởi tạo Realtime
- Thiết lập kết nối WebSocket với Supabase Realtime
- Subscribe các channel cần thiết (messages, typing indicators, online status)

## Services liên quan
- `AuthService`: Xử lý authentication
- `UserService`: Quản lý thông tin người dùng và trạng thái online
