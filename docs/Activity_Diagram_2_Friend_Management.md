# Sơ đồ hoạt động 2: Quản lý bạn bè (Friend Management Flow)

```mermaid
flowchart TD
    Start([Người dùng vào màn hình Friends]) --> LoadFriends[Tải danh sách bạn bè]
    LoadFriends --> QueryFriends[Query bảng friends với user_id]
    QueryFriends --> JoinUsers[Join với bảng users để lấy thông tin]
    JoinUsers --> DisplayFriends[Hiển thị danh sách bạn bè]
    
    DisplayFriends --> UserAction{Người dùng chọn}
    
    %% Add Friend Flow
    UserAction -->|Thêm bạn| SearchUsers[Tìm kiếm người dùng]
    SearchUsers --> ShowSuggestions[Hiển thị gợi ý kết bạn]
    ShowSuggestions --> CallRPC[Gọi RPC get_friend_suggestions]
    CallRPC --> FilterUsers[Lọc người dùng<br/>- Không phải bạn bè<br/>- Không có request pending<br/>- Sắp xếp theo mutual friends]
    FilterUsers --> DisplaySuggestions[Hiển thị danh sách gợi ý]
    
    DisplaySuggestions --> SelectUser[Chọn người dùng]
    SelectUser --> SendRequest[Gửi lời mời kết bạn]
    SendRequest --> InsertRequest[Insert vào friend_requests<br/>status = 'pending']
    InsertRequest --> NotifyReceiver[Thông báo cho người nhận]
    NotifyReceiver --> ShowSuccess1[Hiển thị thành công]
    ShowSuccess1 --> DisplayFriends
    
    %% View Requests Flow
    UserAction -->|Xem lời mời| LoadRequests[Tải lời mời kết bạn]
    LoadRequests --> QueryRequests[Query friend_requests<br/>receiver_id = current_user<br/>status = 'pending']
    QueryRequests --> DisplayRequests[Hiển thị danh sách lời mời]
    
    DisplayRequests --> RequestAction{Người dùng chọn}
    
    %% Accept Request
    RequestAction -->|Chấp nhận| AcceptRequest[Chấp nhận lời mời]
    AcceptRequest --> UpdateStatus[Update status = 'accepted']
    UpdateStatus --> TriggerFunction[Trigger: create_bidirectional_friendship]
    TriggerFunction --> InsertFriend1[Insert friends<br/>user_id = sender<br/>friend_id = receiver]
    InsertFriend1 --> InsertFriend2[Insert friends<br/>user_id = receiver<br/>friend_id = sender]
    InsertFriend2 --> NotifySender1[Thông báo cho người gửi]
    NotifySender1 --> ShowSuccess2[Hiển thị thành công]
    ShowSuccess2 --> DisplayFriends
    
    %% Reject Request
    RequestAction -->|Từ chối| RejectRequest[Từ chối lời mời]
    RejectRequest --> UpdateReject[Update status = 'rejected']
    UpdateReject --> ShowSuccess3[Hiển thị thành công]
    ShowSuccess3 --> DisplayFriends
    
    %% Remove Friend Flow
    UserAction -->|Xóa bạn| ConfirmRemove{Xác nhận xóa?}
    ConfirmRemove -->|Không| DisplayFriends
    ConfirmRemove -->|Có| RemoveFriend[Xóa bạn bè]
    RemoveFriend --> DeleteBoth[Xóa cả 2 chiều trong bảng friends]
    DeleteBoth --> NotifyFriend[Thông báo cho bạn bè]
    NotifyFriend --> ShowSuccess4[Hiển thị thành công]
    ShowSuccess4 --> DisplayFriends
    
    %% View Online Friends
    UserAction -->|Xem bạn online| FilterOnline[Lọc bạn bè online]
    FilterOnline --> CheckStatus[Kiểm tra is_online = true]
    CheckStatus --> DisplayOnline[Hiển thị danh sách bạn online]
    DisplayOnline --> DisplayFriends
    
    DisplayFriends --> End([Kết thúc])
    
    style Start fill:#4ade80
    style End fill:#f87171
    style TriggerFunction fill:#a78bfa
    style CallRPC fill:#fbbf24
    style NotifyReceiver fill:#60a5fa
    style NotifySender1 fill:#60a5fa
```

## Mô tả luồng hoạt động

### 1. Tải danh sách bạn bè
- Query bảng `friends` với `user_id = current_user`
- Join với bảng `users` để lấy thông tin chi tiết (tên, avatar, trạng thái online)
- Hiển thị danh sách với trạng thái online/offline

### 2. Gửi lời mời kết bạn
- Tìm kiếm người dùng hoặc xem gợi ý
- Gọi RPC function `get_friend_suggestions()` để lấy danh sách gợi ý dựa trên:
  - Số lượng bạn chung (mutual friends)
  - Người dùng chưa là bạn bè
  - Chưa có lời mời pending
- Insert vào bảng `friend_requests` với status = 'pending'

### 3. Chấp nhận lời mời kết bạn
- Update status = 'accepted' trong bảng `friend_requests`
- Trigger `on_friend_request_accepted` tự động chạy
- Function `create_bidirectional_friendship()` tạo 2 bản ghi trong bảng `friends`:
  - user_id = sender, friend_id = receiver
  - user_id = receiver, friend_id = sender

### 4. Từ chối lời mời
- Update status = 'rejected' trong bảng `friend_requests`
- Không tạo bản ghi trong bảng `friends`

### 5. Xóa bạn bè
- Xóa cả 2 chiều trong bảng `friends`
- Đảm bảo cả 2 người dùng đều không còn là bạn bè

### 6. Xem bạn bè online
- Lọc danh sách bạn bè với `is_online = true`
- Sử dụng Realtime để cập nhật trạng thái online/offline tự động

## Services liên quan
- `FriendService`: Quản lý tất cả logic liên quan đến bạn bè
- Database Functions:
  - `get_friend_suggestions()`: Gợi ý kết bạn dựa trên mutual friends
  - `create_bidirectional_friendship()`: Tạo quan hệ bạn bè 2 chiều

## Row Level Security (RLS)
- Users chỉ có thể xem bạn bè của chính họ
- Users chỉ có thể gửi lời mời với sender_id = auth.uid()
- Users chỉ có thể chấp nhận/từ chối lời mời nhận được
