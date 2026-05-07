# Sơ đồ hoạt động 5: Quản lý nhóm chat (Group Chat Management)

```mermaid
flowchart TD
    Start([Người dùng vào màn hình Groups]) --> LoadGroups[Tải danh sách nhóm]
    LoadGroups --> QueryGroups[Query conversations<br/>where is_group = true]
    QueryGroups --> JoinParticipants[Join với conversation_participants]
    JoinParticipants --> DisplayGroups[Hiển thị danh sách nhóm]
    
    DisplayGroups --> UserAction{Người dùng chọn}
    
    %% Create Group Flow
    UserAction -->|Tạo nhóm mới| CreateGroupScreen[Màn hình tạo nhóm]
    CreateGroupScreen --> EnterGroupInfo[Nhập thông tin nhóm]
    EnterGroupInfo --> InputName[Tên nhóm]
    InputName --> InputDescription[Mô tả nhóm]
    InputDescription --> SelectAvatar[Chọn avatar nhóm]
    SelectAvatar --> SelectMembers[Chọn thành viên từ danh sách bạn bè]
    
    SelectMembers --> ValidateGroup{Kiểm tra thông tin}
    ValidateGroup -->|Thiếu tên| ShowError1[Hiển thị lỗi: Cần có tên nhóm]
    ShowError1 --> EnterGroupInfo
    ValidateGroup -->|Ít hơn 2 thành viên| ShowError2[Hiển thị lỗi: Cần ít nhất 2 thành viên]
    ShowError2 --> SelectMembers
    
    ValidateGroup -->|Hợp lệ| UploadAvatar{Có avatar?}
    UploadAvatar -->|Có| UploadToStorage[Upload lên Supabase Storage]
    UploadToStorage --> GetAvatarURL[Lấy public URL]
    GetAvatarURL --> CreateGroupRecord
    UploadAvatar -->|Không| CreateGroupRecord[Tạo bản ghi nhóm]
    
    CreateGroupRecord --> InsertConversation[Insert vào conversations<br/>is_group = true<br/>name, description, avatar_url<br/>created_by = current_user]
    InsertConversation --> AddCreator[Thêm creator vào participants<br/>role = 'admin']
    AddCreator --> AddMembers[Thêm các thành viên<br/>role = 'member']
    AddMembers --> SendNotifications[Gửi thông báo cho thành viên]
    SendNotifications --> CreateSystemMessage[Tạo tin nhắn hệ thống<br/>"X đã tạo nhóm"]
    CreateSystemMessage --> ShowSuccess1[Hiển thị thành công]
    ShowSuccess1 --> DisplayGroups
    
    %% View Group Info Flow
    UserAction -->|Xem thông tin nhóm| LoadGroupInfo[Tải thông tin nhóm]
    LoadGroupInfo --> QueryGroupDetails[Query conversation details]
    QueryGroupDetails --> LoadMembers[Tải danh sách thành viên]
    LoadMembers --> DisplayGroupInfo[Hiển thị thông tin nhóm]
    
    DisplayGroupInfo --> GroupAction{Người dùng chọn}
    
    %% Edit Group Info
    GroupAction -->|Chỉnh sửa| CheckAdmin{Là admin?}
    CheckAdmin -->|Không| ShowError3[Hiển thị lỗi: Chỉ admin mới có quyền]
    ShowError3 --> DisplayGroupInfo
    CheckAdmin -->|Có| EditGroupScreen[Màn hình chỉnh sửa]
    EditGroupScreen --> UpdateInfo[Cập nhật thông tin]
    UpdateInfo --> UpdateConversation[Update conversations<br/>name, description, avatar_url]
    UpdateConversation --> CreateEditMessage[Tạo tin nhắn hệ thống<br/>"X đã cập nhật thông tin nhóm"]
    CreateEditMessage --> BroadcastUpdate[Broadcast update cho thành viên]
    BroadcastUpdate --> ShowSuccess2[Hiển thị thành công]
    ShowSuccess2 --> DisplayGroupInfo
    
    %% Add Members
    GroupAction -->|Thêm thành viên| CheckAdminAdd{Là admin?}
    CheckAdminAdd -->|Không| ShowError3
    CheckAdminAdd -->|Có| SelectNewMembers[Chọn thành viên mới từ bạn bè]
    SelectNewMembers --> FilterExisting[Lọc bỏ thành viên đã có]
    FilterExisting --> AddNewMembers[Thêm vào conversation_participants]
    AddNewMembers --> CreateAddMessage[Tạo tin nhắn hệ thống<br/>"X đã thêm Y vào nhóm"]
    CreateAddMessage --> NotifyNewMembers[Thông báo cho thành viên mới]
    NotifyNewMembers --> ShowSuccess3[Hiển thị thành công]
    ShowSuccess3 --> DisplayGroupInfo
    
    %% Remove Members
    GroupAction -->|Xóa thành viên| CheckAdminRemove{Là admin?}
    CheckAdminRemove -->|Không| ShowError3
    CheckAdminRemove -->|Có| SelectRemoveMember[Chọn thành viên để xóa]
    SelectRemoveMember --> ConfirmRemove{Xác nhận xóa?}
    ConfirmRemove -->|Không| DisplayGroupInfo
    ConfirmRemove -->|Có| RemoveMember[Xóa khỏi conversation_participants]
    RemoveMember --> CreateRemoveMessage[Tạo tin nhắn hệ thống<br/>"X đã xóa Y khỏi nhóm"]
    CreateRemoveMessage --> NotifyRemoved[Thông báo cho người bị xóa]
    NotifyRemoved --> ShowSuccess4[Hiển thị thành công]
    ShowSuccess4 --> DisplayGroupInfo
    
    %% Leave Group
    GroupAction -->|Rời nhóm| ConfirmLeave{Xác nhận rời nhóm?}
    ConfirmLeave -->|Không| DisplayGroupInfo
    ConfirmLeave -->|Có| CheckLastAdmin{Là admin duy nhất?}
    CheckLastAdmin -->|Có| ShowError4[Hiển thị lỗi: Cần chuyển quyền admin<br/>trước khi rời nhóm]
    ShowError4 --> DisplayGroupInfo
    CheckLastAdmin -->|Không| LeaveGroup[Rời khỏi nhóm]
    LeaveGroup --> RemoveSelf[Xóa khỏi conversation_participants]
    RemoveSelf --> CreateLeaveMessage[Tạo tin nhắn hệ thống<br/>"X đã rời khỏi nhóm"]
    CreateLeaveMessage --> NotifyMembers[Thông báo cho thành viên còn lại]
    NotifyMembers --> ShowSuccess5[Hiển thị thành công]
    ShowSuccess5 --> DisplayGroups
    
    %% Delete Group
    GroupAction -->|Xóa nhóm| CheckCreator{Là người tạo?}
    CheckCreator -->|Không| ShowError5[Hiển thị lỗi: Chỉ người tạo mới có quyền xóa]
    ShowError5 --> DisplayGroupInfo
    CheckCreator -->|Có| ConfirmDelete{Xác nhận xóa nhóm?}
    ConfirmDelete -->|Không| DisplayGroupInfo
    ConfirmDelete -->|Có| DeleteGroup[Xóa nhóm]
    DeleteGroup --> DeleteMessages[Xóa tất cả tin nhắn]
    DeleteMessages --> DeleteParticipants[Xóa tất cả participants]
    DeleteParticipants --> DeleteConversation[Xóa conversation]
    DeleteConversation --> NotifyAllMembers[Thông báo cho tất cả thành viên]
    NotifyAllMembers --> ShowSuccess6[Hiển thị thành công]
    ShowSuccess6 --> DisplayGroups
    
    %% Chat in Group
    UserAction -->|Mở chat nhóm| OpenGroupChat[Mở màn hình chat nhóm]
    OpenGroupChat --> LoadGroupMessages[Tải tin nhắn nhóm]
    LoadGroupMessages --> SetupGroupRealtime[Thiết lập Realtime cho nhóm]
    SetupGroupRealtime --> GroupChatActive[Chat nhóm hoạt động]
    GroupChatActive --> DisplayGroups
    
    DisplayGroups --> End([Kết thúc])
    
    style Start fill:#4ade80
    style End fill:#f87171
    style CreateGroupRecord fill:#a78bfa
    style BroadcastUpdate fill:#fbbf24
    style CheckAdmin fill:#f472b6
    style CheckCreator fill:#f472b6
```

## Mô tả luồng hoạt động

### 1. Tạo nhóm mới (Create Group)

**Thông tin cần thiết:**
- Tên nhóm (bắt buộc)
- Mô tả nhóm (tùy chọn)
- Avatar nhóm (tùy chọn)
- Danh sách thành viên (ít nhất 2 người)

**Quy trình:**
1. Người dùng nhập thông tin nhóm
2. Chọn thành viên từ danh sách bạn bè
3. Validate: Tên nhóm không rỗng, ít nhất 2 thành viên
4. Upload avatar (nếu có) lên Supabase Storage
5. Insert vào bảng `conversations`:
   ```sql
   INSERT INTO conversations (
     is_group, name, description, 
     avatar_url, created_by
   ) VALUES (
     true, 'Tên nhóm', 'Mô tả',
     'url_avatar', 'user_id'
   )
   ```
6. Thêm creator vào `conversation_participants` với role = 'admin'
7. Thêm các thành viên với role = 'member'
8. Tạo tin nhắn hệ thống: "X đã tạo nhóm"
9. Gửi thông báo cho tất cả thành viên

### 2. Xem thông tin nhóm (View Group Info)

**Hiển thị:**
- Tên nhóm, mô tả, avatar
- Danh sách thành viên (với role: admin/member)
- Số lượng thành viên
- Người tạo nhóm
- Ngày tạo

**Actions có thể thực hiện:**
- Chỉnh sửa thông tin (chỉ admin)
- Thêm thành viên (chỉ admin)
- Xóa thành viên (chỉ admin)
- Rời nhóm (tất cả thành viên)
- Xóa nhóm (chỉ người tạo)

### 3. Chỉnh sửa thông tin nhóm (Edit Group)

**Quyền hạn:** Chỉ admin

**Có thể chỉnh sửa:**
- Tên nhóm
- Mô tả nhóm
- Avatar nhóm

**Quy trình:**
1. Kiểm tra quyền admin
2. Cập nhật thông tin trong bảng `conversations`
3. Tạo tin nhắn hệ thống: "X đã cập nhật thông tin nhóm"
4. Broadcast update cho tất cả thành viên qua Realtime

### 4. Thêm thành viên (Add Members)

**Quyền hạn:** Chỉ admin

**Quy trình:**
1. Kiểm tra quyền admin
2. Hiển thị danh sách bạn bè chưa có trong nhóm
3. Chọn thành viên muốn thêm
4. Insert vào `conversation_participants` với role = 'member'
5. Tạo tin nhắn hệ thống: "X đã thêm Y, Z vào nhóm"
6. Gửi thông báo cho thành viên mới

**Giới hạn:**
- Có thể có giới hạn số lượng thành viên tối đa (ví dụ: 256 người)

### 5. Xóa thành viên (Remove Members)

**Quyền hạn:** Chỉ admin

**Quy trình:**
1. Kiểm tra quyền admin
2. Chọn thành viên muốn xóa (không thể xóa admin khác)
3. Xác nhận xóa
4. Delete khỏi `conversation_participants`
5. Tạo tin nhắn hệ thống: "X đã xóa Y khỏi nhóm"
6. Thông báo cho người bị xóa

**Lưu ý:**
- Không thể xóa admin khác (cần demote trước)
- Người bị xóa không thể xem tin nhắn mới nhưng vẫn giữ lịch sử chat cũ

### 6. Rời nhóm (Leave Group)

**Quyền hạn:** Tất cả thành viên

**Quy trình:**
1. Xác nhận rời nhóm
2. Kiểm tra nếu là admin duy nhất:
   - Nếu có: Yêu cầu chuyển quyền admin cho người khác trước
   - Nếu không: Cho phép rời nhóm
3. Delete khỏi `conversation_participants`
4. Tạo tin nhắn hệ thống: "X đã rời khỏi nhóm"
5. Thông báo cho thành viên còn lại

**Edge case:**
- Nếu là thành viên cuối cùng, tự động xóa nhóm

### 7. Xóa nhóm (Delete Group)

**Quyền hạn:** Chỉ người tạo nhóm (created_by)

**Quy trình:**
1. Kiểm tra quyền người tạo
2. Xác nhận xóa nhóm (cảnh báo: không thể khôi phục)
3. Xóa tất cả tin nhắn trong nhóm
4. Xóa tất cả participants
5. Xóa conversation
6. Thông báo cho tất cả thành viên

**Cascade Delete:**
```sql
-- Tự động xóa nhờ ON DELETE CASCADE
DELETE FROM conversations WHERE id = 'group_id';
-- Sẽ tự động xóa:
-- - messages
-- - conversation_participants
-- - typing_indicators
-- - message_reads
```

### 8. Chat trong nhóm (Group Chat)

**Tương tự chat 1-1 nhưng có thêm:**
- Hiển thị tên người gửi cho mỗi tin nhắn
- Hiển thị avatar người gửi
- Typing indicator hiển thị "X, Y đang gõ..." (nhiều người)
- Mention members: @username
- Reply to message trong context nhóm

**Realtime:**
- Sử dụng cùng cơ chế Broadcast như chat 1-1
- Topic: `c:<group_id_short>`
- Tất cả thành viên subscribe cùng channel

## Phân quyền (Roles & Permissions)

### Admin
- Chỉnh sửa thông tin nhóm
- Thêm/xóa thành viên
- Promote/demote members
- Rời nhóm (nếu không phải admin duy nhất)

### Member
- Gửi tin nhắn
- Xem thông tin nhóm
- Rời nhóm

### Creator (người tạo)
- Tất cả quyền của Admin
- Xóa nhóm
- Không thể bị xóa khỏi nhóm bởi admin khác

## Database Schema

### conversations table
```sql
id UUID PRIMARY KEY
is_group BOOLEAN DEFAULT false
name TEXT (cho nhóm)
description TEXT (cho nhóm)
avatar_url TEXT (cho nhóm)
created_by UUID (người tạo nhóm)
created_at TIMESTAMP
updated_at TIMESTAMP
```

### conversation_participants table
```sql
id UUID PRIMARY KEY
conversation_id UUID
user_id UUID
role TEXT ('admin' | 'member')
joined_at TIMESTAMP
unread_count INTEGER
```

## Services liên quan
- `GroupService`: Quản lý tất cả logic liên quan đến nhóm
- `ChatService`: Xử lý tin nhắn trong nhóm
- `StorageService`: Upload avatar nhóm
