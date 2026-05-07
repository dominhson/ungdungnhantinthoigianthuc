# Sơ đồ hoạt động 4: Quản lý trạng thái Online/Offline

```mermaid
flowchart TD
    Start([Người dùng đăng nhập]) --> InitStatus[Khởi tạo trạng thái]
    InitStatus --> UpdateOnline[Update users.is_online = true]
    UpdateOnline --> RecordLoginTime[Ghi nhận thời gian đăng nhập]
    
    RecordLoginTime --> StartHeartbeat[Bắt đầu Heartbeat Timer]
    StartHeartbeat --> HeartbeatLoop{Timer 30 giây}
    
    %% Heartbeat Loop
    HeartbeatLoop --> CheckConnection{Kết nối<br/>còn hoạt động?}
    CheckConnection -->|Có| SendHeartbeat[Gửi heartbeat signal]
    SendHeartbeat --> UpdateLastSeen[Update users.last_seen = NOW]
    UpdateLastSeen --> KeepOnline[Giữ is_online = true]
    KeepOnline --> BroadcastStatus[Broadcast trạng thái online]
    BroadcastStatus --> NotifyFriends[Thông báo cho bạn bè]
    NotifyFriends --> HeartbeatLoop
    
    CheckConnection -->|Không| DetectDisconnect[Phát hiện mất kết nối]
    DetectDisconnect --> UpdateOffline[Update is_online = false]
    UpdateOffline --> RecordLastSeen[Ghi nhận last_seen]
    RecordLastSeen --> BroadcastOffline[Broadcast trạng thái offline]
    BroadcastOffline --> NotifyFriendsOffline[Thông báo cho bạn bè]
    NotifyFriendsOffline --> TryReconnect{Thử kết nối lại?}
    
    TryReconnect -->|Có| ReconnectAttempt[Thử kết nối lại]
    ReconnectAttempt --> ReconnectSuccess{Thành công?}
    ReconnectSuccess -->|Có| UpdateOnline
    ReconnectSuccess -->|Không| WaitRetry[Chờ 5 giây]
    WaitRetry --> TryReconnect
    
    TryReconnect -->|Không| End
    
    %% Friend Status Subscription
    StartHeartbeat --> SubscribeFriends[Subscribe trạng thái bạn bè]
    SubscribeFriends --> ListenChanges[Lắng nghe Postgres Changes<br/>trên bảng users]
    ListenChanges --> ReceiveUpdate{Nhận update?}
    
    ReceiveUpdate -->|Có| CheckFriend{Là bạn bè?}
    CheckFriend -->|Có| UpdateFriendUI[Cập nhật UI trạng thái bạn bè]
    UpdateFriendUI --> ShowOnlineIndicator[Hiển thị chấm xanh/xám]
    ShowOnlineIndicator --> UpdateLastSeenText[Cập nhật "Hoạt động X phút trước"]
    UpdateLastSeenText --> ReceiveUpdate
    
    CheckFriend -->|Không| ReceiveUpdate
    
    %% Manual Logout
    HeartbeatLoop -->|Người dùng đăng xuất| ManualLogout[Đăng xuất thủ công]
    ManualLogout --> StopHeartbeat[Dừng Heartbeat Timer]
    StopHeartbeat --> UpdateOfflineManual[Update is_online = false]
    UpdateOfflineManual --> UnsubscribeChannels[Unsubscribe tất cả channels]
    UnsubscribeChannels --> ClearSession[Xóa session]
    ClearSession --> End([Kết thúc])
    
    style Start fill:#4ade80
    style End fill:#f87171
    style SendHeartbeat fill:#fbbf24
    style BroadcastStatus fill:#a78bfa
    style UpdateOnline fill:#60a5fa
    style UpdateOffline fill:#94a3b8
    style DetectDisconnect fill:#f87171
```

## Mô tả luồng hoạt động

### 1. Khởi tạo trạng thái Online
Khi người dùng đăng nhập thành công:
- Update `users.is_online = true`
- Ghi nhận thời gian đăng nhập
- Broadcast trạng thái online cho tất cả bạn bè

### 2. Heartbeat Mechanism (Cơ chế nhịp tim)
**Mục đích:** Duy trì và cập nhật trạng thái online liên tục

**Quy trình:**
- Timer chạy mỗi 30 giây
- Gửi heartbeat signal đến server
- Update `users.last_seen = NOW()`
- Giữ `is_online = true`
- Broadcast trạng thái cho bạn bè

**Lợi ích:**
- Phát hiện nhanh khi người dùng mất kết nối
- Cập nhật thời gian "hoạt động lần cuối" chính xác
- Giảm tải cho database (chỉ update 30s/lần thay vì realtime)

### 3. Phát hiện mất kết nối
**Khi nào xảy ra:**
- Người dùng đóng app
- Mất kết nối internet
- App bị crash
- Heartbeat timeout (không nhận được response sau 30s)

**Xử lý:**
1. Phát hiện mất kết nối qua heartbeat timeout
2. Update `is_online = false`
3. Ghi nhận `last_seen` = thời điểm mất kết nối
4. Broadcast trạng thái offline
5. Thông báo cho tất cả bạn bè

### 4. Tự động kết nối lại
**Khi kết nối internet trở lại:**
- Tự động thử kết nối lại đến Supabase
- Nếu thành công, update lại `is_online = true`
- Khôi phục Heartbeat Timer
- Nếu thất bại, chờ 5 giây và thử lại

### 5. Subscribe trạng thái bạn bè
**Realtime Subscription:**
```dart
supabase
  .channel('friend_status_changes')
  .onPostgresChanges(
    event: PostgresChangeEvent.update,
    schema: 'public',
    table: 'users',
    callback: (payload) {
      // Cập nhật UI khi bạn bè thay đổi trạng thái
    }
  )
  .subscribe();
```

**Khi nhận update:**
1. Kiểm tra xem user có phải bạn bè không
2. Nếu có, cập nhật UI:
   - Hiển thị chấm xanh (online) hoặc xám (offline)
   - Cập nhật text "Hoạt động X phút trước"
   - Sắp xếp lại danh sách (bạn online lên đầu)

### 6. Đăng xuất thủ công
Khi người dùng nhấn nút đăng xuất:
1. Dừng Heartbeat Timer
2. Update `is_online = false`
3. Unsubscribe tất cả Realtime channels
4. Xóa session và auth token
5. Chuyển về màn hình đăng nhập

## Hiển thị trạng thái trong UI

### Chấm trạng thái (Status Indicator)
- 🟢 **Chấm xanh**: Online (is_online = true)
- ⚫ **Chấm xám**: Offline (is_online = false)

### Text trạng thái
- **"Đang hoạt động"**: is_online = true
- **"Hoạt động 5 phút trước"**: is_online = false, tính từ last_seen
- **"Hoạt động 2 giờ trước"**: is_online = false, last_seen > 1 giờ
- **"Hoạt động hôm qua"**: is_online = false, last_seen > 24 giờ

## Tối ưu hóa

### 1. Giảm tải Database
- Sử dụng Heartbeat 30s thay vì update realtime
- Chỉ update khi có thay đổi thực sự
- Batch updates nếu có nhiều thay đổi cùng lúc

### 2. Giảm băng thông
- Chỉ broadcast cho bạn bè, không broadcast toàn bộ users
- Sử dụng payload nhỏ gọn (chỉ user_id và is_online)

### 3. Xử lý Edge Cases
- **App ở background**: Giảm tần suất heartbeat xuống 60s
- **Low battery mode**: Tạm dừng heartbeat, chỉ update khi có tương tác
- **Airplane mode**: Dừng heartbeat, tự động reconnect khi có mạng

## Services liên quan
- `UserService`: Quản lý trạng thái online/offline
- `FriendService`: Subscribe trạng thái bạn bè
- Heartbeat được implement trong `main.dart` hoặc `UserService`
