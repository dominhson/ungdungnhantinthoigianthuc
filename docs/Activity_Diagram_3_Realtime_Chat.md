# Sơ đồ hoạt động 3: Chat thời gian thực (Realtime Chat Flow)

```mermaid
flowchart TD
    Start([Người dùng mở cuộc trò chuyện]) --> CheckConversation{Cuộc trò chuyện<br/>đã tồn tại?}
    
    %% Create Conversation
    CheckConversation -->|Không| CreateConv[Tạo cuộc trò chuyện mới]
    CreateConv --> InsertConv[Insert vào bảng conversations]
    InsertConv --> AddParticipants[Thêm participants vào<br/>conversation_participants]
    AddParticipants --> LoadConversation
    
    %% Load Conversation
    CheckConversation -->|Có| LoadConversation[Tải cuộc trò chuyện]
    LoadConversation --> QueryMessages[Query bảng messages<br/>conversation_id = current]
    QueryMessages --> JoinSender[Join với users để lấy thông tin sender]
    JoinSender --> DisplayMessages[Hiển thị tin nhắn]
    
    DisplayMessages --> SetupRealtime[Thiết lập Realtime]
    SetupRealtime --> CreateChannel[Tạo Broadcast Channel<br/>topic = 'c:shortId']
    CreateChannel --> SubscribeBroadcast[Subscribe event 'msg']
    SubscribeBroadcast --> CacheChannel[Cache channel để tái sử dụng]
    
    CacheChannel --> UserAction{Người dùng thực hiện}
    
    %% Send Message Flow
    UserAction -->|Gửi tin nhắn| ComposeMessage[Soạn tin nhắn]
    ComposeMessage --> ValidateMessage{Kiểm tra nội dung}
    ValidateMessage -->|Rỗng| UserAction
    ValidateMessage -->|Hợp lệ| PrepareMessage[Chuẩn bị dữ liệu tin nhắn]
    
    PrepareMessage --> InsertMessage[Insert vào bảng messages]
    InsertMessage --> UpdateConvTime[Update conversations.updated_at]
    UpdateConvTime --> BroadcastMessage[Broadcast qua channel]
    BroadcastMessage --> SendPayload[Gửi payload với message_id]
    
    SendPayload --> AllClientsReceive[Tất cả clients nhận broadcast]
    AllClientsReceive --> FetchNewMessage[Fetch tin nhắn mới từ DB]
    FetchNewMessage --> UpdateUI[Cập nhật UI]
    UpdateUI --> PlaySound[Phát âm thanh thông báo]
    PlaySound --> UserAction
    
    %% Typing Indicator Flow
    UserAction -->|Đang gõ| StartTyping[Bắt đầu gõ]
    StartTyping --> UpsertTyping[Upsert vào typing_indicators<br/>is_typing = true]
    UpsertTyping --> BroadcastTyping[Broadcast typing status]
    BroadcastTyping --> ShowTypingIndicator[Hiển thị "đang gõ..." cho người khác]
    ShowTypingIndicator --> StopTyping{Dừng gõ?}
    StopTyping -->|Tiếp tục| ShowTypingIndicator
    StopTyping -->|Dừng| UpdateTypingFalse[Update is_typing = false]
    UpdateTypingFalse --> HideTypingIndicator[Ẩn "đang gõ..."]
    HideTypingIndicator --> UserAction
    
    %% Send Media Flow
    UserAction -->|Gửi media| SelectMedia[Chọn ảnh/video/file]
    SelectMedia --> UploadStorage[Upload lên Supabase Storage]
    UploadStorage --> GetPublicURL[Lấy public URL]
    GetPublicURL --> InsertMediaMessage[Insert message với media_url]
    InsertMediaMessage --> BroadcastMessage
    
    %% Reply Message Flow
    UserAction -->|Trả lời tin nhắn| SelectReplyMessage[Chọn tin nhắn để trả lời]
    SelectReplyMessage --> ShowReplyPreview[Hiển thị preview tin nhắn gốc]
    ShowReplyPreview --> ComposeReply[Soạn tin nhắn trả lời]
    ComposeReply --> InsertReplyMessage[Insert với reply_to_message_id]
    InsertReplyMessage --> BroadcastMessage
    
    %% Mark as Read Flow
    UserAction -->|Đọc tin nhắn| MarkAsRead[Đánh dấu đã đọc]
    MarkAsRead --> InsertRead[Insert vào message_reads]
    InsertRead --> UpdateUnreadCount[Cập nhật unread_count]
    UpdateUnreadCount --> UserAction
    
    %% Leave Conversation
    UserAction -->|Rời khỏi| UnsubscribeChannel[Unsubscribe channel]
    UnsubscribeChannel --> RemoveFromCache[Xóa khỏi cache]
    RemoveFromCache --> UpdateLastSeen[Cập nhật last_seen]
    UpdateLastSeen --> End([Kết thúc])
    
    style Start fill:#4ade80
    style End fill:#f87171
    style BroadcastMessage fill:#a78bfa
    style AllClientsReceive fill:#fbbf24
    style SetupRealtime fill:#60a5fa
    style UploadStorage fill:#f472b6
```

## Mô tả luồng hoạt động

### 1. Khởi tạo cuộc trò chuyện
- Kiểm tra xem cuộc trò chuyện đã tồn tại chưa
- Nếu chưa, tạo mới trong bảng `conversations` và thêm participants
- Load tất cả tin nhắn từ database

### 2. Thiết lập Realtime Broadcast
- Tạo channel với topic ngắn: `c:<8_chars_of_conversation_id>`
- Subscribe event `msg` để nhận tin nhắn mới
- Cache channel để tái sử dụng và tránh tạo nhiều kết nối

### 3. Gửi tin nhắn
**Quy trình:**
1. Validate nội dung tin nhắn
2. Insert vào bảng `messages` với thông tin:
   - conversation_id
   - sender_id
   - text/media_url
   - type (text/image/video/audio/file)
   - reply_to_message_id (nếu là reply)
3. Update `conversations.updated_at` để sắp xếp cuộc trò chuyện
4. Broadcast qua channel với payload `{id: message_id}`

**Nhận tin nhắn:**
1. Tất cả clients trong channel nhận broadcast
2. Fetch tin nhắn mới từ database bằng message_id
3. Cập nhật UI với tin nhắn mới
4. Phát âm thanh thông báo (nếu không phải sender)

### 4. Typing Indicator (Đang gõ)
- Khi người dùng bắt đầu gõ, upsert vào `typing_indicators` với `is_typing = true`
- Broadcast typing status qua channel riêng `t:<shortId>`
- Hiển thị "đang gõ..." cho người khác trong cuộc trò chuyện
- Khi dừng gõ (timeout 3s), update `is_typing = false`

### 5. Gửi Media (Ảnh/Video/File)
1. Người dùng chọn file từ thiết bị
2. Upload lên Supabase Storage bucket
3. Lấy public URL của file
4. Insert message với `type = image/video/file` và `media_url`
5. Broadcast như tin nhắn thông thường

### 6. Trả lời tin nhắn (Reply)
- Chọn tin nhắn muốn trả lời
- Hiển thị preview tin nhắn gốc
- Insert message với `reply_to_message_id` trỏ đến tin nhắn gốc
- UI hiển thị tin nhắn gốc kèm theo tin nhắn trả lời

### 7. Đánh dấu đã đọc
- Insert vào bảng `message_reads` với `message_id` và `user_id`
- Cập nhật `unread_count` trong `conversation_participants`
- Hiển thị checkmark xanh cho sender

### 8. Rời khỏi cuộc trò chuyện
- Unsubscribe channel để ngừng nhận tin nhắn mới
- Xóa channel khỏi cache
- Cập nhật `last_seen` của người dùng

## Tối ưu hóa Realtime

### Broadcast vs Postgres Changes
- **Sử dụng Broadcast** thay vì Postgres Changes để giảm độ trễ
- Broadcast gửi ngay lập tức, không cần chờ database trigger
- Clients tự fetch tin nhắn từ DB sau khi nhận broadcast

### Channel Caching
- Cache channels để tái sử dụng
- Tránh tạo nhiều kết nối WebSocket không cần thiết
- Giảm overhead khi chuyển đổi giữa các cuộc trò chuyện

### Short Topic Names
- Sử dụng topic ngắn `c:12345678` thay vì UUID đầy đủ
- Giảm kích thước payload và băng thông

## Services liên quan
- `ChatService`: Quản lý tin nhắn và Realtime
- `MediaService`: Xử lý upload/download media
- `StorageService`: Tương tác với Supabase Storage
