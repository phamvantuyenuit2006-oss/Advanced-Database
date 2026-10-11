# 🚀 Advanced Database Systems - Bài Tập & Đồ Án Cơ Sở Dữ Liệu Nâng Cao

Kho lưu trữ toàn bộ các bài tập thực hành, đồ án chuyên sâu và giải pháp kỹ thuật môn **Cơ sở Dữ liệu Nâng cao (Advanced Database Systems)**, xây dựng và kiểm thử hoàn chỉnh trên hệ quản trị **Microsoft SQL Server 2022**.

---

## 📑 Cấu Trúc Đề Tài Theo Logic Từng Phần

Mã nguồn và báo cáo được phân chia khoa học thành 5 chủ đề chuyên biệt từ nền tảng thiết kế đến các kỹ thuật tối ưu và phân tích dữ liệu lớn:

```
Advanced-Database/
├── Topic-01-Relational-Design-and-Constraints/
│   ├── 01_QLDETAI_SinhVien.sql
│   └── 02_QuanLy_NhanSu_DuAn.sql
├── Topic-02-Complex-Queries-and-Advanced-Joins/
│   ├── 01_QuanLy_BenhVien_KhamChuaBenh.sql
│   └── 02_QuanLy_DaoTao_DaiHoc.sql
├── Topic-03-Advanced-Business-Rules-and-Triggers/
│   └── 01_QuanLy_BanHang_TonKho_Trigger.sql
├── Topic-04-Window-Functions-and-Analytics/
│   └── 01_Advanced_Window_Functions.sql
└── Topic-05-Comprehensive-Capstone-Project-Online-Bus-Ticketing/
    ├── HeThongDatVeXeOnline_FullScript.sql
    ├── ERD_HeThongDatVeXeOnline.png
    ├── Bao_Cao_CSDL_He_Thong_Dat_Ve_Xe_Online.docx
    └── Bao_Cao_CSDL_He_Thong_Dat_Ve_Xe_Online.pdf
```

---

## 🌟 Chi Tiết Từng Phần Kiến Thức

### 🔹 Topic 01: Thiết Kế Mô Hình Quan Hệ & Ràng Buộc Toàn Vẹn Cơ Bản
- **Nội dung:** Thiết kế cấu trúc bảng, khóa chính (PK), khóa ngoại (FK), UNIQUE, NOT NULL và các CHECK constraints phức hợp.
- **Bài toán minh họa:**
  - `01_QLDETAI_SinhVien.sql`: Quản lý sinh viên nghiên cứu khoa học, bảng kết hợp $N-N$ `THAMGIA` có thuộc tính riêng `VAITRO`, `KETQUA`.
  - `02_QuanLy_NhanSu_DuAn.sql`: Quản trị nhân sự & đề án công ty; xử lý quan hệ tự tham chiếu đệ quy (Recursive Foreign Key) giữa Quản lý và Nhân viên; quan hệ $1-N$ giữa Nhân viên và Thân nhân có ràng buộc `ON DELETE CASCADE`.

---

### 🔹 Topic 02: Truy Vấn Phức Hợp, Đa Bảng (Complex Joins & Subqueries)
- **Nội dung:** Kỹ thuật kết nối đa bảng (Inner Join, Left Outer Join, Full Outer Join), truy vấn lồng tương quan (Correlated Subqueries), toán tử tập hợp (`EXISTS`, `NOT EXISTS`, `IN`, `ALL`, `ANY`) kết hợp mệnh đề `GROUP BY` và `HAVING`.
- **Bài toán minh họa:**
  - `01_QuanLy_BenhVien_KhamChuaBenh.sql`: Hệ thống bệnh án & kê đơn thuốc. Tìm bệnh nhân chưa từng phát sinh đơn thuốc bằng `NOT EXISTS`; tổng hợp doanh thu viện phí và tiền thuốc.
  - `02_QuanLy_DaoTao_DaiHoc.sql`: Quản lý đào tạo theo tín chỉ; phân cấp Khoa - Bộ môn - Giảng viên - Học phần - Lớp học phần.

---

### 🔹 Topic 03: Ràng Buộc Nghiệp Vụ Nâng Cao & Triggers Tự Động Hóa
- **Nội dung:** Cơ chế kích hoạt (`AFTER INSERT`, `AFTER UPDATE`), quản lý giao dịch và phòng vệ toàn vẹn bằng `ROLLBACK TRANSACTION`.
- **Bài toán minh họa:**
  - `01_QuanLy_BanHang_TonKho_Trigger.sql`: Hệ thống xuất bán và đồng bộ kho hàng. Trigger tự động kiểm tra số lượng tồn khả dụng, chặn xuất bán nếu tồn kho âm và tự động giảm trừ số lượng tồn của kho xuất tương ứng.

---

### 🔹 Topic 04: Hàm Cửa Sổ & Phân Tích Dữ Liệu Lớn (Window Functions)
- **Nội dung:** Kỹ thuật OLAP và phân tích thứ hạng, dữ liệu nối tiếp không cần tự join bảng:
  - Phân tích thứ hạng: `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`.
  - Phân tích chuỗi thời gian: `LAG()` (so sánh với kỳ trước), `LEAD()` (dự báo/so sánh với kỳ sau).
  - Tích lũy dòng tiền: `SUM(...) OVER (ORDER BY ... ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`.

---

### 🔹 Topic 05: Đồ Án Tổng Hợp - Hệ Thống Đặt Vé Xe Online Liên Tỉnh (Capstone Project)
Đồ án lớn giải quyết trọn vẹn bài toán vận tải liên tỉnh quy mô toàn quốc:
- **Kiến trúc dữ liệu:** 11 bảng chuẩn hóa, hỗ trợ nhiều nhà xe, quản lý sơ đồ chỗ ngồi 2 tầng (Ghế, Giường nằm, Limousine, Cabin).
- **Thuật toán cốt lõi (Chỗ-Đoạn):** Giải quyết bài toán một chỗ ngồi trên chuyến $A \rightarrow B \rightarrow C \rightarrow D \rightarrow E$ được bán cho nhiều chặng không chồng lấn bằng bất đẳng thức:
  $$\text{ThuTu}(Don_1) < \text{ThuTu}(Tra_2) \quad \text{AND} \quad \text{ThuTu}(Tra_1) > \text{ThuTu}(Don_2)$$
- **Trigger bảo vệ toàn vẹn:** Ngăn chặn tuyệt đối việc bán trùng chỗ trên các chặng giao nhau; xe chạy trùng lịch; xe không thuộc nhà xe khai thác tuyến.
- **Bộ 52 câu truy vấn SQL:** Hoàn thành 100% từ câu 1 đến câu 52 theo đúng yêu cầu đề bài.
- **Tài liệu nộp hoàn chỉnh:** Kèm ảnh sơ đồ [ERD_HeThongDatVeXeOnline.png](Topic-05-Comprehensive-Capstone-Project-Online-Bus-Ticketing/ERD_HeThongDatVeXeOnline.png) và Báo cáo phân tích chuyên sâu [Bao_Cao_CSDL_He_Thong_Dat_Ve_Xe_Online.pdf](Topic-05-Comprehensive-Capstone-Project-Online-Bus-Ticketing/Bao_Cao_CSDL_He_Thong_Dat_Ve_Xe_Online.pdf).

---

## 🛠 Hướng Dẫn Cài Đặt & Thực Thi

### 1. Yêu cầu môi trường
- Hệ điều hành: Windows 10/11
- Hệ quản trị CSDL: Microsoft SQL Server 2019 / 2022 (Developer hoặc Enterprise Edition)
- Công cụ: SQL Server Management Studio (SSMS) hoặc Azure Data Studio

### 2. Thực thi qua dòng lệnh (Command Line / PowerShell)
Mở PowerShell tại thư mục dự án và chạy với tiện ích `sqlcmd`:

```powershell
# Thực thi Đồ án lớn Đặt vé xe online (Khởi tạo CSDL + Data + 52 Truy vấn)
sqlcmd -E -S localhost -I -f 65001 -i "Topic-05-Comprehensive-Capstone-Project-Online-Bus-Ticketing/HeThongDatVeXeOnline_FullScript.sql"
```

---

## 👨‍💻 Thông Tin Tác Giả
- **Sinh viên:** Phạm Văn Tuyển
- **GitHub:** [@phamvantuyenuit2006-oss](https://github.com/phamvantuyenuit2006-oss)
- **Học phần:** Cơ sở Dữ liệu & Cơ sở Dữ liệu Nâng cao
