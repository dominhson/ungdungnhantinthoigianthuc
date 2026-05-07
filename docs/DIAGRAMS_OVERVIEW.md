# Tổng quan Sơ đồ hoạt động - Realtime Chat App

## 📊 Tổng quan

Dự án này bao gồm **6 sơ đồ hoạt động chi tiết** mô tả toàn bộ luồng hoạt động của hệ thống chat realtime được xây dựng với Flutter và Supabase.

## 🎨 Hai phiên bản

### 1. Mermaid (Markdown-based)
📁 **Thư mục:** `docs/`  
📄 **Files:** `Activity_Diagram_X_*.md`

**Ưu điểm:**
- ✅ Render trực tiếp trên GitHub/GitLab
- ✅ Xem ngay trong VS Code (với extension)
- ✅ Dễ version control (text-based)
- ✅ Không cần cài đặt thêm

**Xem sơ đồ:**
- Mở file `.md` trên GitHub → Tự động render
- VS Code: Cài extension "Markdown Preview Mermaid Support"
- Online: https://mermaid.live/

### 2. PlantUML (Professional)
📁 **Thư mục:** `docs/plantuml/`  
📄 **Files:** `XX_*_flow.puml`

**Ưu điểm:**
- ✅ Chất lượng cao, chuyên nghiệp
- ✅ Export PNG/SVG/PDF dễ dàng
- ✅ Nhiều tùy chỉnh hơn
- ✅ Hỗ trợ swimlanes tốt hơn

**Xem sơ đồ:**
- VS Code: Cài extension "PlantUML"
- Online: https://www.plantuml.com/plantuml/uml/
- Command line: `plantuml file.puml`

## 📋 Danh sách Sơ đồ

| # | Tên | Mermaid | PlantUML | Mô tả |
|---|-----|---------|----------|-------|
| 1 | Authentication Flow | [MD](./Activity_Diagram_1_Authentication.md) | [PUML](./plantuml/01_authentication_flow.puml) | Đăng nhập, đăng ký, quản lý session |
| 2 | Friend Management | [MD](./Activity_Diagram_2_Friend_Management.md) | [PUML](./plantuml/02_friend_management_flow.puml) | Quản lý bạn bè, lời mời kết bạn |
| 3 | Realtime Chat | [MD](./Activity_Diagram_3_Realtime_Chat.md) | [PUML](./plantuml/03_realtime_chat_flow.puml) | Gửi/nhận tin nhắn realtime |
| 4 | Online Status | [MD](./Activity_Diagram_4_Online_Status.md) | [PUML](./plantuml/04_online_status_flow.puml) | Quản lý trạng thái online/offline |
| 5 | Group Chat | [MD](./Activity_Diagram_5_Group_Chat.md) | [PUML](./plantuml/05_group_chat_flow.puml) | Tạo và quản lý nhóm chat |
| 6 | Media Handling | [MD](./Activity_Diagram_6_Media_Handling.md) | [PUML](./plantuml/06_media_handling_flow.puml) | Upload/download media |

## 🚀 Quick Start

### Xem sơ đồ Mermaid

**Trên GitHub:**
```
1. Mở file Activity_Diagram_X_*.md
2. Sơ đồ tự động render
```

**Trong VS Code:**
```
1. Cài extension: Markdown Preview Mermaid Support
2. Mở file .md
3. Nhấn Ctrl+Shift+V để preview
```

### Xem sơ đồ PlantUML

**Trong VS Code:**
```bash
# 1. Cài extension PlantUML
# 2. Mở file .puml
# 3. Nhấn Alt+D để preview
```

**Export PNG/SVG:**
```bash
cd docs/plantuml
./export_diagrams.sh  # Linux/Mac
export_diagrams.bat   # Windows
```

## 📖 Hướng dẫn chi tiết

- **Mermaid:** Xem [ACTIVITY_DIAGRAMS_INDEX.md](./ACTIVITY_DIAGRAMS_INDEX.md)
- **PlantUML:** Xem [PLANTUML_GUIDE.md](./PLANTUML_GUIDE.md)

## 🎯 Sơ đồ nào phù hợp với bạn?

### Chọn Mermaid nếu:
- ✅ Bạn muốn xem nhanh trên GitHub
- ✅ Không muốn cài đặt thêm tool
- ✅ Ưu tiên version control đơn giản
- ✅ Cần embed vào documentation

### Chọn PlantUML nếu:
- ✅ Cần chất lượng cao cho presentation
- ✅ Muốn export PNG/SVG/PDF
- ✅ Cần nhiều tùy chỉnh về style
- ✅ Làm việc với sơ đồ phức tạp

## 📊 So sánh chi tiết

| Tiêu chí | Mermaid | PlantUML |
|----------|---------|----------|
| **Cài đặt** | Không cần | Cần Java + PlantUML |
| **Render trên GitHub** | ✅ Có | ❌ Không |
| **Export PNG/SVG** | ⚠️ Qua tool | ✅ Dễ dàng |
| **Chất lượng** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Tùy chỉnh** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Học習 curve** | Dễ | Trung bình |
| **Swimlanes** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Version control** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

## 🛠️ Tools & Extensions

### VS Code Extensions

**Cho Mermaid:**
- Markdown Preview Mermaid Support
- Mermaid Markdown Syntax Highlighting

**Cho PlantUML:**
- PlantUML (jebbs.plantuml)
- PlantUML Previewer

### Online Editors

**Mermaid:**
- https://mermaid.live/
- https://mermaid-js.github.io/mermaid-live-editor/

**PlantUML:**
- https://www.plantuml.com/plantuml/uml/
- https://plantuml-editor.kkeisuke.com/

## 📦 Export Options

### Mermaid
```bash
# Sử dụng mermaid-cli
npm install -g @mermaid-js/mermaid-cli
mmdc -i diagram.md -o diagram.png
```

### PlantUML
```bash
# Export tất cả
cd docs/plantuml
./export_diagrams.sh

# Export một file
plantuml -tpng 01_authentication_flow.puml
plantuml -tsvg 01_authentication_flow.puml
plantuml -tpdf 01_authentication_flow.puml
```

## 🎨 Themes & Styling

### Mermaid Themes
```mermaid
%%{init: {'theme':'dark'}}%%
%%{init: {'theme':'forest'}}%%
%%{init: {'theme':'neutral'}}%%
```

### PlantUML Themes
```plantuml
!theme vibrant
!theme bluegray
!theme sketchy
```

## 📚 Tài liệu tham khảo

### Mermaid
- [Official Documentation](https://mermaid-js.github.io/mermaid/)
- [Flowchart Syntax](https://mermaid-js.github.io/mermaid/#/flowchart)
- [Live Editor](https://mermaid.live/)

### PlantUML
- [Official Documentation](https://plantuml.com/)
- [Activity Diagram](https://plantuml.com/activity-diagram-beta)
- [Theme Gallery](https://plantuml.com/theme)

## 🤝 Contributing

Khi thêm sơ đồ mới:

1. **Tạo cả 2 phiên bản:**
   - Mermaid: `Activity_Diagram_X_Name.md`
   - PlantUML: `XX_name_flow.puml`

2. **Đảm bảo consistency:**
   - Cùng nội dung
   - Cùng màu sắc (tương đương)
   - Cùng structure

3. **Cập nhật documentation:**
   - Thêm vào bảng danh sách
   - Cập nhật README
   - Thêm mô tả

4. **Test:**
   - Render Mermaid trên GitHub
   - Export PlantUML sang PNG/SVG
   - Kiểm tra readability

## 📄 License
MIT License

---

## 📞 Support

Nếu có vấn đề:
1. Kiểm tra [PLANTUML_GUIDE.md](./PLANTUML_GUIDE.md) cho PlantUML
2. Kiểm tra [ACTIVITY_DIAGRAMS_INDEX.md](./ACTIVITY_DIAGRAMS_INDEX.md) cho Mermaid
3. Xem Troubleshooting section trong các guide

---

**Tạo bởi:** Kiro AI Assistant  
**Ngày tạo:** May 7, 2026  
**Phiên bản:** 1.0.0

**Tech Stack:**
- Frontend: Flutter
- Backend: Supabase (PostgreSQL + Realtime)
- Diagrams: Mermaid + PlantUML
