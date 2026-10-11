-- =============================================================================
-- TRƯỜNG ĐẠI HỌC SÀI GÒN - KHOA CÔNG NGHỆ THÔNG TIN
-- HỌC PHẦN: HỆ THỐNG CƠ SỞ DỮ LIỆU / THIẾT KẾ & LẬP TRÌNH CSDL
-- ĐỒ ÁN MÔN HỌC: HỆ THỐNG ĐẶT VÉ XE ONLINE LIÊN TỈNH
-- HỆ QUẢN TRỊ CSDL: MICROSOFT SQL SERVER 2022
-- ĐẦY ĐỦ: CREATE DATABASE, CREATE TABLE, RÀNG BUỘC TOÀN VẸN, DỮ LIỆU KIỂM THỬ VÀ 52 CÂU TRUY VẤN
-- =============================================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'HeThongDatVeXeOnline')
BEGIN
    ALTER DATABASE HeThongDatVeXeOnline SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HeThongDatVeXeOnline;
END
GO

CREATE DATABASE HeThongDatVeXeOnline;
GO

USE HeThongDatVeXeOnline;
GO

-- =============================================================================
-- PHẦN I. DDL: KHỞI TẠO CÁC BẢNG VÀ RÀNG BUỘC TOÀN VẸN CƠ SỞ
-- =============================================================================

-- 1. BẢNG NHÀ XE (NHA_XE)
CREATE TABLE NHA_XE (
    MaNhaXe VARCHAR(20) NOT NULL,
    TenNhaXe NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(255) NULL,
    SoDienThoai VARCHAR(20) NOT NULL,
    Email VARCHAR(100) NULL,
    TrangThai NVARCHAR(30) DEFAULT N'Hoạt động',
    CONSTRAINT PK_NhaXe PRIMARY KEY (MaNhaXe),
    CONSTRAINT UQ_NhaXe_Ten UNIQUE (TenNhaXe),
    CONSTRAINT UQ_NhaXe_SDT UNIQUE (SoDienThoai)
);
GO

-- 2. BẢNG XE (XE)
CREATE TABLE XE (
    BienSoXe VARCHAR(20) NOT NULL,
    MaNhaXe VARCHAR(20) NOT NULL,
    LoaiXe NVARCHAR(50) NOT NULL, -- Ghế ngồi, Giường nằm, Limousine, Cabin
    SoChoThietKe INT NOT NULL,
    NgayDuaVaoSuDung DATE NULL,
    TrangThai NVARCHAR(30) DEFAULT N'Hoạt động',
    CONSTRAINT PK_Xe PRIMARY KEY (BienSoXe),
    CONSTRAINT FK_Xe_NhaXe FOREIGN KEY (MaNhaXe) REFERENCES NHA_XE(MaNhaXe),
    CONSTRAINT CK_Xe_SoCho CHECK (SoChoThietKe > 0),
    CONSTRAINT CK_Xe_LoaiXe CHECK (LoaiXe IN (N'Ghế ngồi', N'Giường nằm', N'Limousine', N'Cabin'))
);
GO

-- 3. BẢNG CHỖ TRÊN XE (CHO_NGOI)
CREATE TABLE CHO_NGOI (
    BienSoXe VARCHAR(20) NOT NULL,
    MaCho VARCHAR(10) NOT NULL, -- A01, A02, B01,...
    Tang INT DEFAULT 1,
    LoaiCho NVARCHAR(50) DEFAULT N'Tiêu chuẩn',
    TrangThaiSuDung NVARCHAR(30) DEFAULT N'Sẵn sàng',
    CONSTRAINT PK_ChoNgoi PRIMARY KEY (BienSoXe, MaCho),
    CONSTRAINT FK_ChoNgoi_Xe FOREIGN KEY (BienSoXe) REFERENCES XE(BienSoXe) ON DELETE CASCADE,
    CONSTRAINT CK_ChoNgoi_Tang CHECK (Tang IN (1, 2))
);
GO

-- 4. BẢNG ĐỊA ĐIỂM (DIA_DIEM)
CREATE TABLE DIA_DIEM (
    MaDiaDiem VARCHAR(20) NOT NULL,
    TenDiaDiem NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(255) NULL,
    TinhThanh NVARCHAR(100) NOT NULL,
    QuanHuyen NVARCHAR(100) NULL,
    LoaiDiaDiem NVARCHAR(50) DEFAULT N'Bến xe',
    CONSTRAINT PK_DiaDiem PRIMARY KEY (MaDiaDiem),
    CONSTRAINT UQ_DiaDiem_Ten UNIQUE (TenDiaDiem)
);
GO

-- 5. BẢNG TUYẾN XE (TUYEN_XE)
CREATE TABLE TUYEN_XE (
    MaTuyen VARCHAR(20) NOT NULL,
    MaNhaXe VARCHAR(20) NOT NULL,
    TenTuyen NVARCHAR(150) NOT NULL,
    KhoangCachKm DECIMAL(8,2) NULL,
    TrangThai NVARCHAR(30) DEFAULT N'Hoạt động',
    CONSTRAINT PK_TuyenXe PRIMARY KEY (MaTuyen),
    CONSTRAINT FK_TuyenXe_NhaXe FOREIGN KEY (MaNhaXe) REFERENCES NHA_XE(MaNhaXe)
);
GO

-- 6. BẢNG CHI TIẾT TUYẾN (CHI_TIET_TUYEN)
CREATE TABLE CHI_TIET_TUYEN (
    MaTuyen VARCHAR(20) NOT NULL,
    MaDiaDiem VARCHAR(20) NOT NULL,
    ThuTu INT NOT NULL,
    ChoDon BIT NOT NULL DEFAULT 1,
    ChoTra BIT NOT NULL DEFAULT 1,
    SoPhutDuKien INT NOT NULL DEFAULT 0,
    CONSTRAINT PK_ChiTietTuyen PRIMARY KEY (MaTuyen, MaDiaDiem),
    CONSTRAINT FK_CTT_Tuyen FOREIGN KEY (MaTuyen) REFERENCES TUYEN_XE(MaTuyen) ON DELETE CASCADE,
    CONSTRAINT FK_CTT_DiaDiem FOREIGN KEY (MaDiaDiem) REFERENCES DIA_DIEM(MaDiaDiem),
    CONSTRAINT UQ_CTT_ThuTu UNIQUE (MaTuyen, ThuTu),
    CONSTRAINT CK_CTT_ThuTu CHECK (ThuTu >= 1),
    CONSTRAINT CK_CTT_SoPhut CHECK (SoPhutDuKien >= 0)
);
GO

-- 7. BẢNG CHUYẾN XE (CHUYEN_XE)
CREATE TABLE CHUYEN_XE (
    MaChuyen VARCHAR(20) NOT NULL,
    MaTuyen VARCHAR(20) NOT NULL,
    BienSoXe VARCHAR(20) NOT NULL,
    ThoiDiemKhoiHanh DATETIME2 NOT NULL,
    ThoiDiemDuKienKetThuc DATETIME2 NOT NULL,
    TrangThai NVARCHAR(30) DEFAULT N'Sắp khởi hành',
    CONSTRAINT PK_ChuyenXe PRIMARY KEY (MaChuyen),
    CONSTRAINT FK_ChuyenXe_Tuyen FOREIGN KEY (MaTuyen) REFERENCES TUYEN_XE(MaTuyen),
    CONSTRAINT FK_ChuyenXe_Xe FOREIGN KEY (BienSoXe) REFERENCES XE(BienSoXe),
    CONSTRAINT CK_ChuyenXe_ThoiGian CHECK (ThoiDiemDuKienKetThuc > ThoiDiemKhoiHanh)
);
GO

-- 8. BẢNG NGƯỜI ĐẶT VÉ / KHÁCH HÀNG (KHACH_HANG)
CREATE TABLE KHACH_HANG (
    MaKhachHang VARCHAR(20) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(20) NOT NULL,
    Email VARCHAR(100) NULL,
    NgayDangKy DATE DEFAULT CAST(GETDATE() AS DATE),
    TrangThai NVARCHAR(30) DEFAULT N'Hoạt động',
    CONSTRAINT PK_KhachHang PRIMARY KEY (MaKhachHang),
    CONSTRAINT UQ_KhachHang_SDT UNIQUE (SoDienThoai)
);
GO

-- 9. BẢNG ĐẶT CHỖ (DAT_CHO)
CREATE TABLE DAT_CHO (
    MaDatCho VARCHAR(20) NOT NULL,
    MaKhachHang VARCHAR(20) NOT NULL,
    MaChuyen VARCHAR(20) NOT NULL,
    ThoiDiemDat DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ThongTinLienHe NVARCHAR(255) NULL,
    TrangThai NVARCHAR(30) DEFAULT N'Chờ thanh toán',
    CONSTRAINT PK_DatCho PRIMARY KEY (MaDatCho),
    CONSTRAINT FK_DatCho_KhachHang FOREIGN KEY (MaKhachHang) REFERENCES KHACH_HANG(MaKhachHang),
    CONSTRAINT FK_DatCho_Chuyen FOREIGN KEY (MaChuyen) REFERENCES CHUYEN_XE(MaChuyen),
    CONSTRAINT CK_DatCho_TrangThai CHECK (TrangThai IN (N'Chờ thanh toán', N'Đã xác nhận', N'Đã hủy', N'Hết hạn'))
);
GO

-- 10. BẢNG VÉ (VE)
CREATE TABLE VE (
    MaVe VARCHAR(20) NOT NULL,
    MaDatCho VARCHAR(20) NOT NULL,
    BienSoXe VARCHAR(20) NOT NULL,
    MaCho VARCHAR(10) NOT NULL,
    MaDiemDon VARCHAR(20) NOT NULL,
    MaDiemTra VARCHAR(20) NOT NULL,
    HoTenNguoiDi NVARCHAR(100) NOT NULL,
    SoDienThoaiNguoiDi VARCHAR(20) NULL,
    GiaBanThucTe DECIMAL(18,2) NOT NULL,
    TrangThai NVARCHAR(30) DEFAULT N'Có hiệu lực',
    ThoiDiemHuy DATETIME2 NULL,
    LyDoHuy NVARCHAR(255) NULL,
    TienHoan DECIMAL(18,2) DEFAULT 0,
    CONSTRAINT PK_Ve PRIMARY KEY (MaVe),
    CONSTRAINT FK_Ve_DatCho FOREIGN KEY (MaDatCho) REFERENCES DAT_CHO(MaDatCho),
    CONSTRAINT FK_Ve_ChoNgoi FOREIGN KEY (BienSoXe, MaCho) REFERENCES CHO_NGOI(BienSoXe, MaCho),
    CONSTRAINT FK_Ve_DiemDon FOREIGN KEY (MaDiemDon) REFERENCES DIA_DIEM(MaDiaDiem),
    CONSTRAINT FK_Ve_DiemTra FOREIGN KEY (MaDiemTra) REFERENCES DIA_DIEM(MaDiaDiem),
    CONSTRAINT CK_Ve_GiaBan CHECK (GiaBanThucTe >= 0),
    CONSTRAINT CK_Ve_TienHoan CHECK (TienHoan >= 0 AND TienHoan <= GiaBanThucTe),
    CONSTRAINT CK_Ve_TrangThai CHECK (TrangThai IN (N'Có hiệu lực', N'Đã sử dụng', N'Đã hủy'))
);
GO

-- 11. BẢNG GIAO DỊCH THANH TOÁN (THANH_TOAN)
CREATE TABLE THANH_TOAN (
    MaGiaoDich VARCHAR(20) NOT NULL,
    MaDatCho VARCHAR(20) NOT NULL,
    ThoiDiemGiaoDich DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    SoTien DECIMAL(18,2) NOT NULL,
    PhuongThuc NVARCHAR(50) NOT NULL,
    MaThamChieu VARCHAR(100) NULL,
    TrangThai NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_ThanhToan PRIMARY KEY (MaGiaoDich),
    CONSTRAINT FK_ThanhToan_DatCho FOREIGN KEY (MaDatCho) REFERENCES DAT_CHO(MaDatCho),
    CONSTRAINT CK_ThanhToan_SoTien CHECK (SoTien >= 0),
    CONSTRAINT CK_ThanhToan_TrangThai CHECK (TrangThai IN (N'Khởi tạo', N'Thành công', N'Thất bại'))
);
GO

-- RÀNG BUỘC 18: Tối đa 1 giao dịch thanh toán thành công cho mỗi đặt chỗ
CREATE UNIQUE NONCLUSTERED INDEX UQ_ThanhToan_DatCho_ThanhCong
ON THANH_TOAN (MaDatCho)
WHERE TrangThai = N'Thành công';
GO

-- =============================================================================
-- PHẦN II. CÁC TRIGGER RÀNG BUỘC NGHIỆP VỤ NÂNG CAO (NẰM NGOÀI DDL CƠ BẢN)
-- =============================================================================

-- TRIGGER 1: Kiểm tra Xe thuộc đúng Nhà xe khai thác Tuyến khi thêm/sửa Chuyến xe (Ràng buộc 6)
CREATE TRIGGER TRG_ChuyenXe_KiemTraNhaXe
ON CHUYEN_XE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN TUYEN_XE t ON i.MaTuyen = t.MaTuyen
        JOIN XE x ON i.BienSoXe = x.BienSoXe
        WHERE t.MaNhaXe <> x.MaNhaXe
    )
    BEGIN
        RAISERROR (N'Lỗi Ràng buộc 6: Xe được phân công cho chuyến phải thuộc chính Nhà xe khai thác tuyến!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- TRIGGER 2: Kiểm tra Xe không bị trùng thời gian hoạt động giữa các chuyến (Ràng buộc 7)
CREATE TRIGGER TRG_ChuyenXe_KiemTraTrungThoiGianXe
ON CHUYEN_XE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN CHUYEN_XE c ON i.BienSoXe = c.BienSoXe AND i.MaChuyen <> c.MaChuyen
        WHERE i.ThoiDiemKhoiHanh < c.ThoiDiemDuKienKetThuc
          AND i.ThoiDiemDuKienKetThuc > c.ThoiDiemKhoiHanh
          AND c.TrangThai <> N'Đã hủy'
    )
    BEGIN
        RAISERROR (N'Lỗi Ràng buộc 7: Một xe không được thực hiện hai chuyến có thời gian hoạt động chồng lấn!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- TRIGGER 3: Kiểm tra vé hợp lệ về Xe, Điểm đón, Điểm trả, Thứ tự đón/trả và Chống chồng lấn chỗ (Ràng buộc 10, 11, 12, 13)
CREATE TRIGGER TRG_Ve_KiemTraNghiepVuVaChongChongLan
ON VE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 10. Chỗ của vé phải thuộc đúng xe đang chạy chuyến
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN DAT_CHO d ON i.MaDatCho = d.MaDatCho
        JOIN CHUYEN_XE c ON d.MaChuyen = c.MaChuyen
        WHERE i.BienSoXe <> c.BienSoXe
    )
    BEGIN
        RAISERROR (N'Lỗi Ràng buộc 10: Chỗ của vé phải thuộc đúng xe thực hiện chuyến đi!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 11 & 12. Điểm đón và điểm trả phải thuộc tuyến của chuyến và Thứ tự Đón < Thứ tự Trả
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN DAT_CHO d ON i.MaDatCho = d.MaDatCho
        JOIN CHUYEN_XE c ON d.MaChuyen = c.MaChuyen
        LEFT JOIN CHI_TIET_TUYEN ctt_don ON c.MaTuyen = ctt_don.MaTuyen AND i.MaDiemDon = ctt_don.MaDiaDiem
        LEFT JOIN CHI_TIET_TUYEN ctt_tra ON c.MaTuyen = ctt_tra.MaTuyen AND i.MaDiemTra = ctt_tra.MaDiaDiem
        WHERE ctt_don.MaDiaDiem IS NULL 
           OR ctt_tra.MaDiaDiem IS NULL 
           OR ctt_don.ChoDon = 0 
           OR ctt_tra.ChoTra = 0 
           OR ctt_don.ThuTu >= ctt_tra.ThuTu
    )
    BEGIN
        RAISERROR (N'Lỗi Ràng buộc 11, 12: Điểm đón và trả phải thuộc tuyến, cho phép đón/trả và Thứ tự đón phải nhỏ hơn thứ tự trả!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- 13. RÀNG BUỘC CỐT LÕI: Không được bán cùng một chỗ cho các đoạn hành trình bị chồng lấn (Chỉ xét vé có hiệu lực/đã sử dụng)
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN DAT_CHO di ON i.MaDatCho = di.MaDatCho
        JOIN CHUYEN_XE ci ON di.MaChuyen = ci.MaChuyen
        JOIN CHI_TIET_TUYEN i_don ON ci.MaTuyen = i_don.MaTuyen AND i.MaDiemDon = i_don.MaDiaDiem
        JOIN CHI_TIET_TUYEN i_tra ON ci.MaTuyen = i_tra.MaTuyen AND i.MaDiemTra = i_tra.MaDiaDiem
        JOIN VE v ON v.MaVe <> i.MaVe 
                 AND v.BienSoXe = i.BienSoXe 
                 AND v.MaCho = i.MaCho
                 AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
        JOIN DAT_CHO dv ON v.MaDatCho = dv.MaDatCho AND dv.MaChuyen = ci.MaChuyen
        JOIN CHI_TIET_TUYEN v_don ON ci.MaTuyen = v_don.MaTuyen AND v.MaDiemDon = v_don.MaDiaDiem
        JOIN CHI_TIET_TUYEN v_tra ON ci.MaTuyen = v_tra.MaTuyen AND v.MaDiemTra = v_tra.MaDiaDiem
        WHERE i.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
          -- Đoạn 1: [i_don.ThuTu, i_tra.ThuTu], Đoạn 2: [v_don.ThuTu, v_tra.ThuTu]
          -- Hai đoạn chồng lấn khi và chỉ khi: i_don < v_tra AND i_tra > v_don
          AND i_don.ThuTu < v_tra.ThuTu 
          AND i_tra.ThuTu > v_don.ThuTu
    )
    BEGIN
        RAISERROR (N'Lỗi Ràng buộc 13: Phát hiện xung đột chồng lấn chỗ ngồi trên cùng chuyến xe!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- =============================================================================
-- PHẦN III. INSERT DỮ LIỆU MẪU KIỂM THỬ CÓ CHỦ ĐÍCH (ĐÁP ỨNG ĐẦY ĐỦ CÁC TIÊU CHÍ)
-- =============================================================================

-- 1. BẢNG NHA_XE (5 nhà xe >= 4)
INSERT INTO NHA_XE (MaNhaXe, TenNhaXe, DiaChi, SoDienThoai, Email, TrangThai) VALUES
('NX01', N'Công ty Cổ phần Xe khách Phương Trang (FUTA Bus Lines)', N'Số 01 Tô Hiến Thành, Phường 3, TP. Đà Lạt, Lâm Đồng', '19006067', 'hotro@futabus.vn', N'Hoạt động'),
('NX02', N'Công ty TNHH Tập đoàn Mai Linh (Mai Linh Express)', N'Số 64 Hai Bà Trưng, Phường Bến Nghé, Quận 1, TP.HCM', '19006789', 'cskh@mailinh.vn', N'Hoạt động'),
('NX03', N'Công ty TNHH Vận tải Hoàng Long (Hoàng Long Asia)', N'Số 05 Phạm Ngũ Lão, Lương Khánh Thiện, Ngô Quyền, Hải Phòng', '02253920920', 'contact@hoanglongasia.com', N'Hoạt động'),
('NX04', N'Công ty TNHH Thành Bưởi', N'Số 266 Lê Hồng Phong, Phường 4, Quận 5, TP.HCM', '19006079', 'thanhbuoi@thanhbuoi.com.vn', N'Hoạt động'),
('NX05', N'Công ty TNHH Vận tải Kumho Samco Buslines', N'Số 292 Đinh Bộ Lĩnh, Phường 26, Bình Thạnh, TP.HCM', '02835112112', 'info@kumhosamco.com.vn', N'Hoạt động');
GO

-- 2. BẢNG XE (15 xe >= 12 xe; có xe chưa từng chạy chuyến: 51B-999.99)
INSERT INTO XE (BienSoXe, MaNhaXe, LoaiXe, SoChoThietKe, NgayDuaVaoSuDung, TrangThai) VALUES
('51B-111.11', 'NX01', N'Giường nằm', 34, '2023-01-15', N'Hoạt động'),
('51B-111.22', 'NX01', N'Limousine', 22, '2023-03-20', N'Hoạt động'),
('51B-111.33', 'NX01', N'Cabin', 20, '2024-02-10', N'Hoạt động'),
('51B-222.11', 'NX02', N'Giường nằm', 34, '2022-05-18', N'Hoạt động'),
('51B-222.22', 'NX02', N'Ghế ngồi', 28, '2022-08-25', N'Hoạt động'),
('51B-222.33', 'NX02', N'Limousine', 22, '2023-11-05', N'Hoạt động'),
('15B-333.11', 'NX03', N'Cabin', 20, '2023-06-12', N'Hoạt động'),
('15B-333.22', 'NX03', N'Giường nằm', 34, '2022-12-01', N'Hoạt động'),
('15B-333.33', 'NX03', N'Limousine', 22, '2024-01-18', N'Hoạt động'),
('51B-444.11', 'NX04', N'Limousine', 22, '2023-04-10', N'Hoạt động'),
('51B-444.22', 'NX04', N'Giường nằm', 34, '2023-09-15', N'Hoạt động'),
('51B-444.33', 'NX04', N'Cabin', 20, '2024-03-01', N'Hoạt động'),
('51B-555.11', 'NX05', N'Limousine', 22, '2023-07-20', N'Hoạt động'),
('51B-555.22', 'NX05', N'Ghế ngồi', 28, '2022-10-30', N'Hoạt động'),
-- Xe kiểm thử: Xe chưa từng được bố trí chuyến nào (phục vụ câu truy vấn 24)
('51B-999.99', 'NX01', N'Cabin', 20, '2024-05-01', N'Hoạt động');
GO

-- 3. BẢNG CHO_NGOI (Đủ các chỗ cho từng xe; mẫu chuẩn cho xe chạy kiểm thử chính)
-- Sinh các chỗ cho 15 xe
DECLARE @BienSo VARCHAR(20);
DECLARE @i INT;
DECLARE @MaCho VARCHAR(10);

DECLARE cur_xe CURSOR FOR SELECT BienSoXe, SoChoThietKe FROM XE;
OPEN cur_xe;
DECLARE @SoCho INT;
FETCH NEXT FROM cur_xe INTO @BienSo, @SoCho;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @i = 1;
    WHILE @i <= @SoCho
    BEGIN
        SET @MaCho = CASE 
            WHEN @i <= (@SoCho / 2) THEN 'A' + RIGHT('0' + CAST(@i AS VARCHAR(2)), 2)
            ELSE 'B' + RIGHT('0' + CAST(@i - (@SoCho / 2) AS VARCHAR(2)), 2)
        END;
        INSERT INTO CHO_NGOI (BienSoXe, MaCho, Tang, LoaiCho, TrangThaiSuDung)
        VALUES (
            @BienSo, 
            @MaCho, 
            CASE WHEN @i <= (@SoCho / 2) THEN 1 ELSE 2 END,
            N'Tiêu chuẩn', 
            N'Sẵn sàng'
        );
        SET @i = @i + 1;
    END
    FETCH NEXT FROM cur_xe INTO @BienSo, @SoCho;
END
CLOSE cur_xe;
DEALLOCATE cur_xe;
GO

-- 4. BẢNG DIA_DIEM (12 địa điểm từ 8 tỉnh/thành phố >= 8 điểm, >= 5 tỉnh)
INSERT INTO DIA_DIEM (MaDiaDiem, TenDiaDiem, DiaChi, TinhThanh, QuanHuyen, LoaiDiaDiem) VALUES
('DD_HN', N'Bến xe Nước Ngầm Hà Nội', N'Số 01 Ngọc Hồi, Hoàng Liệt', N'Hà Nội', N'Hoàng Mai', N'Bến xe'),
('DD_NB', N'Bến xe TP. Ninh Bình', N'Đường Lê Thái Tổ, Thanh Bình', N'Ninh Bình', N'TP. Ninh Bình', N'Bến xe'),
('DD_TH', N'Bến xe Phía Nam Thanh Hóa', N'Đường Lê Hoàn, P. Nam Ngạn', N'Thanh Hóa', N'TP. Thanh Hóa', N'Bến xe'),
('DD_VI', N'Bến xe Bắc Vinh', N'Xã Nghi Liên, TP. Vinh', N'Nghệ An', N'TP. Vinh', N'Bến xe'),
('DD_HT', N'Bến xe TP. Hà Tĩnh', N'Đường Hà Huy Tập, Nam Hà', N'Hà Tĩnh', N'TP. Hà Tĩnh', N'Bến xe'),
('DD_DH', N'Bến xe Đồng Hới', N'Quốc Lộ 1A, Lộc Ninh', N'Quảng Bình', N'Đồng Hới', N'Bến xe'),
('DD_HU', N'Bến xe Phía Nam Huế', N'Số 57 An Dương Vương, An Đông', N'Thừa Thiên Huế', N'TP. Huế', N'Bến xe'),
('DD_DN', N'Bến xe Trung tâm Đà Nẵng', N'Số 185 Tôn Đức Thắng, Hòa Minh', N'Đà Nẵng', N'Liên Chiểu', N'Bến xe'),
('DD_NT', N'Bến xe Phía Nam Nha Trang', N'Đường 23/10, Vĩnh Trung', N'Khánh Hòa', N'TP. Nha Trang', N'Bến xe'),
('DD_DL', N'Bến xe Liên tỉnh Đà Lạt', N'Số 01 Tô Hiến Thành, Phường 3', N'Lâm Đồng', N'TP. Đà Lạt', N'Bến xe'),
('DD_SG', N'Bến xe Miền Đông Mới (TP.HCM)', N'Số 501 Hoàng Hữu Nam, Long Bình', N'TP. Hồ Chí Minh', N'TP. Thủ Đức', N'Bến xe'),
('DD_CT', N'Bến xe Trung tâm Cần Thơ', N'Đường dẫn cầu Cần Thơ, Hưng Thạnh', N'Cần Thơ', N'Cái Răng', N'Bến xe');
GO

-- 5. BẢNG TUYEN_XE (7 tuyến >= 6 tuyến)
INSERT INTO TUYEN_XE (MaTuyen, MaNhaXe, TenTuyen, KhoangCachKm, TrangThai) VALUES
-- Tuyến T01: Tuyến chuẩn kiểm thử chỗ-đoạn 5 điểm: Hà Nội -> Thanh Hóa -> Vinh -> Huế -> Đà Nẵng (A->B->C->D->E)
('T01', 'NX03', N'Hà Nội - Thanh Hóa - Vinh - Huế - Đà Nẵng', 780.0, N'Hoạt động'),
-- Tuyến T02: TP.HCM - Đà Lạt (3 điểm)
('T02', 'NX01', N'TP.HCM - Phan Thiết - Đà Lạt', 310.0, N'Hoạt động'),
-- Tuyến T03: TP.HCM - Cần Thơ (3 điểm)
('T03', 'NX01', N'TP.HCM - Tiền Giang - Cần Thơ', 170.0, N'Hoạt động'),
-- Tuyến T04: TP.HCM - Nha Trang - Đà Nẵng (4 điểm)
('T04', 'NX02', N'TP.HCM - Phan Thiết - Nha Trang - Đà Nẵng', 960.0, N'Hoạt động'),
-- Tuyến T05: Hà Nội - Ninh Bình - Vinh (3 điểm)
('T05', 'NX03', N'Hà Nội - Ninh Bình - Vinh', 300.0, N'Hoạt động'),
-- Tuyến T06: TP.HCM - Đà Lạt (Thành Bưởi)
('T06', 'NX04', N'TP.HCM - Bảo Lộc - Đà Lạt', 305.0, N'Hoạt động'),
-- Tuyến T07: Tuyến kiểm thử chưa có chuyến nào trong quý 4 (câu 26)
('T07', 'NX05', N'TP.HCM - Vũng Tàu', 105.0, N'Hoạt động');
GO

-- 6. BẢNG CHI TIẾT TUYẾN (CHI_TIET_TUYEN)
-- Tuyến T01: Hành trình 5 điểm A->B->C->D->E
INSERT INTO CHI_TIET_TUYEN (MaTuyen, MaDiaDiem, ThuTu, ChoDon, ChoTra, SoPhutDuKien) VALUES
('T01', 'DD_HN', 1, 1, 0, 0),      -- Điểm A: Đầu tuyến, chỉ đón
('T01', 'DD_TH', 2, 1, 1, 180),    -- Điểm B: Đón & Trả
('T01', 'DD_VI', 3, 1, 1, 360),    -- Điểm C: Đón & Trả
('T01', 'DD_HU', 4, 1, 1, 660),    -- Điểm D: Đón & Trả
('T01', 'DD_DN', 5, 0, 1, 840);    -- Điểm E: Cuối tuyến, chỉ trả

-- Tuyến T02: TP.HCM -> Đà Lạt
INSERT INTO CHI_TIET_TUYEN (MaTuyen, MaDiaDiem, ThuTu, ChoDon, ChoTra, SoPhutDuKien) VALUES
('T02', 'DD_SG', 1, 1, 0, 0),
('T02', 'DD_NT', 2, 1, 1, 240),
('T02', 'DD_DL', 3, 0, 1, 420);

-- Tuyến T03: TP.HCM -> Cần Thơ
INSERT INTO CHI_TIET_TUYEN (MaTuyen, MaDiaDiem, ThuTu, ChoDon, ChoTra, SoPhutDuKien) VALUES
('T03', 'DD_SG', 1, 1, 0, 0),
('T03', 'DD_CT', 2, 0, 1, 210);

-- Tuyến T04: TP.HCM -> Nha Trang -> Đà Nẵng
INSERT INTO CHI_TIET_TUYEN (MaTuyen, MaDiaDiem, ThuTu, ChoDon, ChoTra, SoPhutDuKien) VALUES
('T04', 'DD_SG', 1, 1, 0, 0),
('T04', 'DD_NT', 2, 1, 1, 480),
('T04', 'DD_DN', 3, 0, 1, 960);

-- Tuyến T05: Hà Nội -> Ninh Bình -> Vinh
INSERT INTO CHI_TIET_TUYEN (MaTuyen, MaDiaDiem, ThuTu, ChoDon, ChoTra, SoPhutDuKien) VALUES
('T05', 'DD_HN', 1, 1, 0, 0),
('T05', 'DD_NB', 2, 1, 1, 120),
('T05', 'DD_VI', 3, 0, 1, 330);

-- Tuyến T06: TP.HCM -> Đà Lạt
INSERT INTO CHI_TIET_TUYEN (MaTuyen, MaDiaDiem, ThuTu, ChoDon, ChoTra, SoPhutDuKien) VALUES
('T06', 'DD_SG', 1, 1, 0, 0),
('T06', 'DD_DL', 2, 0, 1, 390);

-- Tuyến T07: 2 điểm
INSERT INTO CHI_TIET_TUYEN (MaTuyen, MaDiaDiem, ThuTu, ChoDon, ChoTra, SoPhutDuKien) VALUES
('T07', 'DD_SG', 1, 1, 0, 0),
('T07', 'DD_CT', 2, 0, 1, 180);
GO

-- 7. BẢNG CHUYEN_XE (32 Chuyến xe >= 30, trải trên 3 tháng: Tháng 10, 11, 12 năm 2026)
-- Tuyến T01 (Hoàng Long - NX03, Xe 15B-333.11):
INSERT INTO CHUYEN_XE (MaChuyen, MaTuyen, BienSoXe, ThoiDiemKhoiHanh, ThoiDiemDuKienKetThuc, TrangThai) VALUES
-- Chuyến C01: Chuyến kiểm thử chỗ-đoạn chính A->B->C->D->E ngày 20/10/2026
('C01', 'T01', '15B-333.11', '2026-10-20 06:00:00', '2026-10-20 20:30:00', N'Hoàn thành'),
('C02', 'T01', '15B-333.11', '2026-10-22 06:00:00', '2026-10-22 20:30:00', N'Hoàn thành'),
('C03', 'T01', '15B-333.22', '2026-11-05 06:00:00', '2026-11-05 20:30:00', N'Hoàn thành'),
('C04', 'T01', '15B-333.22', '2026-11-12 06:00:00', '2026-11-12 20:30:00', N'Hoàn thành'),
('C05', 'T01', '15B-333.33', '2026-12-01 06:00:00', '2026-12-01 20:30:00', N'Hoàn thành'),
('C06', 'T01', '15B-333.33', '2026-12-15 06:00:00', '2026-12-15 20:30:00', N'Hoàn thành'),

-- Tuyến T02 (Phương Trang - NX01, Xe 51B-111.11, 51B-111.22):
('C07', 'T02', '51B-111.11', '2026-10-05 07:00:00', '2026-10-05 14:00:00', N'Hoàn thành'),
('C08', 'T02', '51B-111.11', '2026-10-15 07:00:00', '2026-10-15 14:00:00', N'Hoàn thành'),
('C09', 'T02', '51B-111.22', '2026-11-02 08:00:00', '2026-11-02 15:00:00', N'Hoàn thành'),
('C10', 'T02', '51B-111.22', '2026-11-16 08:00:00', '2026-11-16 15:00:00', N'Hoàn thành'),
('C11', 'T02', '51B-111.33', '2026-12-03 08:00:00', '2026-12-03 15:00:00', N'Hoàn thành'),
('C12', 'T02', '51B-111.33', '2026-12-20 08:00:00', '2026-12-20 15:00:00', N'Hoàn thành'),

-- Tuyến T03 (Phương Trang - NX01, Xe 51B-111.11, 51B-111.22):
('C13', 'T03', '51B-111.11', '2026-10-08 06:00:00', '2026-10-08 09:30:00', N'Hoàn thành'),
('C14', 'T03', '51B-111.11', '2026-10-18 06:00:00', '2026-10-18 09:30:00', N'Hoàn thành'),
('C15', 'T03', '51B-111.22', '2026-11-04 06:00:00', '2026-11-04 09:30:00', N'Hoàn thành'),
('C16', 'T03', '51B-111.22', '2026-11-20 06:00:00', '2026-11-20 09:30:00', N'Hoàn thành'),
('C17', 'T03', '51B-111.33', '2026-12-05 06:00:00', '2026-12-05 09:30:00', N'Hoàn thành'),
('C18', 'T03', '51B-111.33', '2026-12-25 06:00:00', '2026-12-25 09:30:00', N'Hoàn thành'),

-- Tuyến T04 (Mai Linh - NX02, Xe 51B-222.11, 51B-222.22, 51B-222.33):
('C19', 'T04', '51B-222.11', '2026-10-10 18:00:00', '2026-10-11 10:00:00', N'Hoàn thành'),
('C20', 'T04', '51B-222.11', '2026-10-25 18:00:00', '2026-10-26 10:00:00', N'Hoàn thành'),
('C21', 'T04', '51B-222.22', '2026-11-08 18:00:00', '2026-11-09 10:00:00', N'Hoàn thành'),
('C22', 'T04', '51B-222.22', '2026-11-22 18:00:00', '2026-11-23 10:00:00', N'Hoàn thành'),
('C23', 'T04', '51B-222.33', '2026-12-10 18:00:00', '2026-12-11 10:00:00', N'Hoàn thành'),
('C24', 'T04', '51B-222.33', '2026-12-28 18:00:00', '2026-12-29 10:00:00', N'Hoàn thành'),

-- Tuyến T05 (Hoàng Long - NX03, Xe 15B-333.11, 15B-333.22):
('C25', 'T05', '15B-333.11', '2026-10-12 07:30:00', '2026-10-12 13:00:00', N'Hoàn thành'),
('C26', 'T05', '15B-333.22', '2026-11-10 07:30:00', '2026-11-10 13:00:00', N'Hoàn thành'),
('C27', 'T05', '15B-333.33', '2026-12-12 07:30:00', '2026-12-12 13:00:00', N'Hoàn thành'),

-- Tuyến T06 (Thành Bưởi - NX04, Xe 51B-444.11, 51B-444.22, 51B-444.33):
('C28', 'T06', '51B-444.11', '2026-10-14 22:00:00', '2026-10-15 04:30:00', N'Hoàn thành'),
('C29', 'T06', '51B-444.22', '2026-11-14 22:00:00', '2026-11-15 04:30:00', N'Hoàn thành'),
('C30', 'T06', '51B-444.33', '2026-12-18 22:00:00', '2026-12-19 04:30:00', N'Hoàn thành'),

-- Chuyến C31: Chuyến gần đầy
('C31', 'T02', '51B-111.22', '2026-10-28 07:00:00', '2026-10-28 14:00:00', N'Hoàn thành'),
-- Chuyến C32: Chuyến kiểm thử CHƯA BÁN VÉ NÀO (phục vụ câu truy vấn 25)
('C32', 'T03', '51B-111.11', '2026-12-30 06:00:00', '2026-12-30 09:30:00', N'Sắp khởi hành');
GO

-- 8. BẢNG KHACH_HANG (42 khách hàng >= 40 khách hàng)
-- Có khách chưa từng đặt (KH40, KH41, KH42), khách đặt 1 lần, khách đặt nhiều lần, khách mua nhiều nhà xe, khách hủy >= 3 vé (KH06)
INSERT INTO KHACH_HANG (MaKhachHang, HoTen, SoDienThoai, Email, NgayDangKy) VALUES
('KH01', N'Nguyễn Văn An', '0903111001', 'nguyenvanan@gmail.com', '2026-08-01'),
('KH02', N'Trần Thị Bích', '0903111002', 'tranthibich@gmail.com', '2026-08-05'),
('KH03', N'Lê Hoàng Cường', '0903111003', 'lehoangcuong@gmail.com', '2026-08-10'),
('KH04', N'Phạm Thu Dung', '0903111004', 'phamthudung@gmail.com', '2026-08-12'),
('KH05', N'Hoàng Trọng Em', '0903111005', 'hoangtrongem@gmail.com', '2026-08-15'),
-- KH06: Khách hàng kiểm thử đã hủy >= 3 vé (phục vụ câu truy vấn 40)
('KH06', N'Đặng Thanh Phong', '0903111006', 'dangthanhphong@gmail.com', '2026-08-20'),
-- KH07: Khách hàng mua vé của ít nhất 3 nhà xe (NX01, NX02, NX03) (phục vụ câu truy vấn 27)
('KH07', N'Vũ Đình Giáp', '0903111007', 'vudinhgiap@gmail.com', '2026-08-22'),
('KH08', N'Bùi Thị Hạnh', '0903111008', 'buithihanh@gmail.com', '2026-08-25'),
('KH09', N'Đỗ Minh Khang', '0903111009', 'dominhkhang@gmail.com', '2026-09-01'),
('KH10', N'Ngô Thị Lan', '0903111010', 'ngothilan@gmail.com', '2026-09-02'),
('KH11', N'Dương Văn Mạnh', '0903111011', 'duongvanmanh@gmail.com', '2026-09-05'),
('KH12', N'Lý Cẩm Nga', '0903111012', 'lycamnga@gmail.com', '2026-09-08'),
('KH13', N'Đinh Hữu Oanh', '0903111013', 'dinhhuuoanh@gmail.com', '2026-09-10'),
('KH14', N'Trịnh Xuân Phúc', '0903111014', 'trinhxuanphuc@gmail.com', '2026-09-12'),
('KH15', N'Mai Như Quỳnh', '0903111015', 'mainhuquynh@gmail.com', '2026-09-15'),
('KH16', N'Cao Thành Rạng', '0903111016', 'caothanhrang@gmail.com', '2026-09-18'),
('KH17', N'Hồ Ngọc Sơn', '0903111017', 'hongocson@gmail.com', '2026-09-20'),
('KH18', N'Phan Thanh Tâm', '0903111018', 'phanthanhtam@gmail.com', '2026-09-22'),
('KH19', N'Võ Cẩm Uyên', '0903111019', 'vocamuyen@gmail.com', '2026-09-25'),
('KH20', N'Lâm Quốc Việt', '0903111020', 'lamquocviet@gmail.com', '2026-09-28'),
('KH21', N'Hà Thúy Vy', '0903111021', 'hathuyvy@gmail.com', '2026-10-01'),
('KH22', N'Tạ Quang Xuân', '0903111022', 'taquangxuan@gmail.com', '2026-10-02'),
('KH23', N'Quách Bảo Yến', '0903111023', 'quachbaoyen@gmail.com', '2026-10-03'),
('KH24', N'Lương Gia An', '0903111024', 'luonggiaan@gmail.com', '2026-10-04'),
('KH25', N'Trương Mỹ Bình', '0903111025', 'truongmybinh@gmail.com', '2026-10-05'),
('KH26', N'Thái Văn Cảnh', '0903111026', 'thaivancanh@gmail.com', '2026-10-06'),
('KH27', N'Tô Hồng Diệp', '0903111027', 'tohongdiep@gmail.com', '2026-10-07'),
('KH28', N'Ân Gia Hào', '0903111028', 'angiahao@gmail.com', '2026-10-08'),
('KH29', N'Diệp Tố Như', '0903111029', 'dieptonhu@gmail.com', '2026-10-09'),
('KH30', N'Nghiêm Quốc Kiệt', '0903111030', 'nghiemquockiet@gmail.com', '2026-10-10'),
('KH31', N'Khưu Vĩnh Phát', '0903111031', 'khuuvinhphat@gmail.com', '2026-10-11'),
('KH32', N'Âu Dương Phong', '0903111032', 'auduongphong@gmail.com', '2026-10-12'),
('KH33', N'Mã Siêu Long', '0903111033', 'masieulong@gmail.com', '2026-10-13'),
('KH34', N'Quan Vân Trường', '0903111034', 'quanvantruong@gmail.com', '2026-10-14'),
('KH35', N'Triệu Tử Long', '0903111035', 'trieutulong@gmail.com', '2026-10-15'),
('KH36', N'Gia Cát Lượng', '0903111036', 'giacatluong@gmail.com', '2026-10-16'),
('KH37', N'Chu Du Đạt', '0903111037', 'chududat@gmail.com', '2026-10-17'),
('KH38', N'Lỗ Túc Huy', '0903111038', 'lotuchuy@gmail.com', '2026-10-18'),
('KH39', N'Tư Mã Ý Hoàng', '0903111039', 'tumayhoang@gmail.com', '2026-10-19'),
-- KH40, KH41, KH42: Khách hàng CHƯA TỪNG ĐẶT VÉ (phục vụ câu truy vấn 23)
('KH40', N'Lưu Bị Đức', '0903111040', 'luubiduc@gmail.com', '2026-10-20'),
('KH41', N'Tôn Quyền Sách', '0903111041', 'tonquyensach@gmail.com', '2026-10-21'),
('KH42', N'Tào Tháo Thao', '0903111042', 'taothaothao@gmail.com', '2026-10-22');
GO

-- 9. BẢNG DAT_CHO (65 lượt đặt chỗ >= 60 lượt)
INSERT INTO DAT_CHO (MaDatCho, MaKhachHang, MaChuyen, ThoiDiemDat, ThongTinLienHe, TrangThai) VALUES
-- Các lượt đặt trên chuyến C01 (Tuyến A->B->C->D->E ngày 20/10/2026):
('DC01', 'KH01', 'C01', '2026-10-18 08:30:00', N'Nguyễn Văn An - 0903111001', N'Đã xác nhận'),
('DC02', 'KH02', 'C01', '2026-10-18 09:15:00', N'Trần Thị Bích - 0903111002', N'Đã xác nhận'),
('DC03', 'KH03', 'C01', '2026-10-18 10:00:00', N'Lê Hoàng Cường - 0903111003', N'Đã xác nhận'),
('DC04', 'KH04', 'C01', '2026-10-18 10:30:00', N'Phạm Thu Dung - 0903111004', N'Đã xác nhận'),
('DC05', 'KH05', 'C01', '2026-10-18 11:00:00', N'Hoàng Trọng Em - 0903111005', N'Đã xác nhận'),
('DC06', 'KH07', 'C01', '2026-10-18 14:00:00', N'Vũ Đình Giáp - 0903111007', N'Đã xác nhận'),
('DC07', 'KH08', 'C01', '2026-10-18 15:30:00', N'Bùi Thị Hạnh - 0903111008', N'Đã xác nhận'),

-- Các lượt đặt trên chuyến C02, C03, C04, C05, C06 (Hoàng Long):
('DC08', 'KH09', 'C02', '2026-10-21 09:00:00', N'Đỗ Minh Khang', N'Đã xác nhận'),
('DC09', 'KH10', 'C02', '2026-10-21 10:00:00', N'Ngô Thị Lan', N'Đã xác nhận'),
('DC10', 'KH11', 'C03', '2026-11-03 08:00:00', N'Dương Văn Mạnh', N'Đã xác nhận'),
('DC11', 'KH12', 'C03', '2026-11-03 14:00:00', N'Lý Cẩm Nga', N'Đã xác nhận'),
('DC12', 'KH13', 'C04', '2026-11-10 11:00:00', N'Đinh Hữu Oanh', N'Đã xác nhận'),
('DC13', 'KH14', 'C05', '2026-11-28 09:00:00', N'Trịnh Xuân Phúc', N'Đã xác nhận'),
('DC14', 'KH15', 'C06', '2026-12-13 10:00:00', N'Mai Như Quỳnh', N'Đã xác nhận'),

-- Đặt chỗ của KH06: KHÁCH HỦY NHIỀU VÉ (hủy 3 lần đặt chỗ DC15, DC16, DC17)
('DC15', 'KH06', 'C02', '2026-10-21 08:00:00', N'Đặng Thanh Phong - Hủy vé 1', N'Đã hủy'),
('DC16', 'KH06', 'C03', '2026-11-01 09:00:00', N'Đặng Thanh Phong - Hủy vé 2', N'Đã hủy'),
('DC17', 'KH06', 'C04', '2026-11-08 10:00:00', N'Đặng Thanh Phong - Hủy vé 3', N'Đã hủy'),

-- Đặt chỗ của KH07: Mua nhiều nhà xe (NX01, NX02, NX03)
('DC18', 'KH07', 'C07', '2026-10-03 08:00:00', N'Vũ Đình Giáp (Đi FUTA)', N'Đã xác nhận'),
('DC19', 'KH07', 'C19', '2026-10-08 09:00:00', N'Vũ Đình Giáp (Đi Mai Linh)', N'Đã xác nhận'),

-- Đặt chỗ trên các chuyến Phương Trang C07 -> C18:
('DC20', 'KH16', 'C07', '2026-10-03 10:00:00', N'Cao Thành Rạng', N'Đã xác nhận'),
('DC21', 'KH17', 'C07', '2026-10-03 11:00:00', N'Hồ Ngọc Sơn', N'Đã xác nhận'),
('DC22', 'KH18', 'C08', '2026-10-13 09:00:00', N'Phan Thanh Tâm', N'Đã xác nhận'),
('DC23', 'KH19', 'C08', '2026-10-13 14:00:00', N'Võ Cẩm Uyên', N'Đã xác nhận'),
('DC24', 'KH20', 'C09', '2026-10-31 08:00:00', N'Lâm Quốc Việt', N'Đã xác nhận'),
('DC25', 'KH21', 'C09', '2026-10-31 10:00:00', N'Hà Thúy Vy', N'Đã xác nhận'),
('DC26', 'KH22', 'C10', '2026-11-14 09:00:00', N'Tạ Quang Xuân', N'Đã xác nhận'),
('DC27', 'KH23', 'C10', '2026-11-14 15:00:00', N'Quách Bảo Yến', N'Đã xác nhận'),
('DC28', 'KH24', 'C11', '2026-12-01 08:00:00', N'Lương Gia An', N'Đã xác nhận'),
('DC29', 'KH25', 'C12', '2026-12-18 09:00:00', N'Trương Mỹ Bình', N'Đã xác nhận'),

-- Tuyến T03 (C13 -> C18):
('DC30', 'KH26', 'C13', '2026-10-06 08:00:00', N'Thái Văn Cảnh', N'Đã xác nhận'),
('DC31', 'KH27', 'C13', '2026-10-06 10:00:00', N'Tô Hồng Diệp', N'Đã xác nhận'),
('DC32', 'KH28', 'C14', '2026-10-16 09:00:00', N'Ân Gia Hào', N'Đã xác nhận'),
('DC33', 'KH29', 'C15', '2026-11-02 08:00:00', N'Diệp Tố Như', N'Đã xác nhận'),
('DC34', 'KH30', 'C16', '2026-11-18 09:00:00', N'Nghiêm Quốc Kiệt', N'Đã xác nhận'),
('DC35', 'KH31', 'C17', '2026-12-03 08:00:00', N'Khưu Vĩnh Phát', N'Đã xác nhận'),
('DC36', 'KH32', 'C18', '2026-12-23 09:00:00', N'Âu Dương Phong', N'Đã xác nhận'),

-- Tuyến T04 Mai Linh (C19 -> C24):
('DC37', 'KH33', 'C19', '2026-10-08 10:00:00', N'Mã Siêu Long', N'Đã xác nhận'),
('DC38', 'KH34', 'C20', '2026-10-23 08:00:00', N'Quan Vân Trường', N'Đã xác nhận'),
('DC39', 'KH35', 'C20', '2026-10-23 11:00:00', N'Triệu Tử Long', N'Đã xác nhận'),
('DC40', 'KH36', 'C21', '2026-11-06 09:00:00', N'Gia Cát Lượng', N'Đã xác nhận'),
('DC41', 'KH37', 'C22', '2026-11-20 08:00:00', N'Chu Du Đạt', N'Đã xác nhận'),
('DC42', 'KH38', 'C23', '2026-12-08 09:00:00', N'Lỗ Túc Huy', N'Đã xác nhận'),
('DC43', 'KH39', 'C24', '2026-12-26 10:00:00', N'Tư Mã Ý Hoàng', N'Đã xác nhận'),

-- Tuyến T05 & T06 (C25 -> C30):
('DC44', 'KH01', 'C25', '2026-10-10 08:00:00', N'Nguyễn Văn An', N'Đã xác nhận'),
('DC45', 'KH02', 'C26', '2026-11-08 09:00:00', N'Trần Thị Bích', N'Đã xác nhận'),
('DC46', 'KH03', 'C27', '2026-12-10 10:00:00', N'Lê Hoàng Cường', N'Đã xác nhận'),
('DC47', 'KH04', 'C28', '2026-10-12 08:00:00', N'Phạm Thu Dung', N'Đã xác nhận'),
('DC48', 'KH05', 'C29', '2026-11-12 09:00:00', N'Hoàng Trọng Em', N'Đã xác nhận'),
('DC49', 'KH08', 'C30', '2026-12-16 10:00:00', N'Bùi Thị Hạnh', N'Đã xác nhận'),

-- Chuyến C31 (Chuyến gần đầy - bán 8 lượt đặt, nhiều vé):
('DC50', 'KH09', 'C31', '2026-10-26 08:00:00', N'Đỗ Minh Khang', N'Đã xác nhận'),
('DC51', 'KH10', 'C31', '2026-10-26 09:00:00', N'Ngô Thị Lan', N'Đã xác nhận'),
('DC52', 'KH11', 'C31', '2026-10-26 10:00:00', N'Dương Văn Mạnh', N'Đã xác nhận'),
('DC53', 'KH12', 'C31', '2026-10-26 11:00:00', N'Lý Cẩm Nga', N'Đã xác nhận'),
('DC54', 'KH13', 'C31', '2026-10-26 13:00:00', N'Đinh Hữu Oanh', N'Đã xác nhận'),
('DC55', 'KH14', 'C31', '2026-10-26 14:00:00', N'Trịnh Xuân Phúc', N'Đã xác nhận'),
('DC56', 'KH15', 'C31', '2026-10-26 15:00:00', N'Mai Như Quỳnh', N'Đã xác nhận'),
('DC57', 'KH16', 'C31', '2026-10-26 16:00:00', N'Cao Thành Rạng', N'Đã xác nhận'),

-- Khách mua từ 5 vé trở lên (KH01 đặt thêm DC58 gồm 3 vé nữa):
('DC58', 'KH01', 'C02', '2026-10-21 11:00:00', N'Nguyễn Văn An mua thêm', N'Đã xác nhận'),

-- Đặt chỗ chưa thanh toán thành công (phục vụ kiểm thử tình huống bắt buộc):
('DC59', 'KH17', 'C08', '2026-10-14 09:00:00', N'Hồ Ngọc Sơn - Chưa TT', N'Chờ thanh toán'),
('DC60', 'KH18', 'C09', '2026-11-01 10:00:00', N'Phan Thanh Tâm - Chưa TT', N'Chờ thanh toán'),
('DC61', 'KH19', 'C14', '2026-10-17 08:00:00', N'Võ Cẩm Uyên - Chưa TT', N'Chờ thanh toán'),
('DC62', 'KH20', 'C15', '2026-11-03 09:00:00', N'Lâm Quốc Việt - Chưa TT', N'Chờ thanh toán'),
('DC63', 'KH21', 'C21', '2026-11-07 10:00:00', N'Hà Thúy Vy - Chưa TT', N'Chờ thanh toán'),
('DC64', 'KH22', 'C22', '2026-11-21 11:00:00', N'Tạ Quang Xuân - Chưa TT', N'Chờ thanh toán'),
('DC65', 'KH23', 'C28', '2026-10-13 14:00:00', N'Quách Bảo Yến - Chưa TT', N'Chờ thanh toán');
GO

-- 10. BẢNG VE (135 vé >= 120 vé)
-- =========================================================================================
-- ĐẶC BIỆT: CÁC VÉ TRÊN CHUYẾN C01 (XE 15B-333.11, TUYẾN T01: HN(A) -> TH(B) -> VI(C) -> HU(D) -> DN(E))
-- ĐÁP ỨNG CHÍNH XÁC YÊU CẦU KIỂM THỬ CHỖ-ĐOẠN TRANG 6:
-- • Chỗ A01: Vé V001 (A -> C) và Vé V002 (C -> E) [DÙNG CHUNG HỢP LỆ VÌ KHÔNG CHỒNG LẤN]
-- • Chỗ A02: Vé V003 (A -> B), Vé V004 (B -> D), Vé V005 (D -> E) [DÙNG NỐI TIẾP HỢP LỆ]
-- • Chỗ A03: Vé V006 (A -> E) [CHIẾM TRỌN HÀNH TRÌNH, KHÔNG BÁN ĐƯỢC CHO BẤT KỲ ĐOẠN NÀO]
-- • Chỗ A04: Hoàn toàn không có vé nào [CHỖ HOÀN TOÀN TRỐNG]
-- =========================================================================================
INSERT INTO VE (MaVe, MaDatCho, BienSoXe, MaCho, MaDiemDon, MaDiemTra, HoTenNguoiDi, SoDienThoaiNguoiDi, GiaBanThucTe, TrangThai, ThoiDiemHuy, LyDoHuy, TienHoan) VALUES
-- Test case A01:
('V001', 'DC01', '15B-333.11', 'A01', 'DD_HN', 'DD_VI', N'Nguyễn Văn An', '0903111001', 300000, N'Đã sử dụng', NULL, NULL, 0),
('V002', 'DC02', '15B-333.11', 'A01', 'DD_VI', 'DD_DN', N'Trần Thị Bích', '0903111002', 350000, N'Đã sử dụng', NULL, NULL, 0),

-- Test case A02:
('V003', 'DC03', '15B-333.11', 'A02', 'DD_HN', 'DD_TH', N'Lê Hoàng Cường', '0903111003', 150000, N'Đã sử dụng', NULL, NULL, 0),
('V004', 'DC04', '15B-333.11', 'A02', 'DD_TH', 'DD_HU', N'Phạm Thu Dung', '0903111004', 380000, N'Đã sử dụng', NULL, NULL, 0),
('V005', 'DC05', '15B-333.11', 'A02', 'DD_HU', 'DD_DN', N'Hoàng Trọng Em', '0903111005', 180000, N'Đã sử dụng', NULL, NULL, 0),

-- Test case A03:
('V006', 'DC06', '15B-333.11', 'A03', 'DD_HN', 'DD_DN', N'Vũ Đình Giáp', '0903111007', 600000, N'Đã sử dụng', NULL, NULL, 0),

-- Vé khác trên C01:
('V007', 'DC07', '15B-333.11', 'A05', 'DD_HN', 'DD_VI', N'Bùi Thị Hạnh', '0903111008', 300000, N'Đã sử dụng', NULL, NULL, 0),
('V008', 'DC07', '15B-333.11', 'A06', 'DD_VI', 'DD_DN', N'Bùi Tuấn Hưng', '0903111008', 350000, N'Đã sử dụng', NULL, NULL, 0);

-- VÉ ĐÃ HỦY CỦA KH06 (Đặng Thanh Phong - Hủy 3 vé V009, V010, V011 để test câu 40):
INSERT INTO VE (MaVe, MaDatCho, BienSoXe, MaCho, MaDiemDon, MaDiemTra, HoTenNguoiDi, SoDienThoaiNguoiDi, GiaBanThucTe, TrangThai, ThoiDiemHuy, LyDoHuy, TienHoan) VALUES
('V009', 'DC15', '15B-333.11', 'A01', 'DD_HN', 'DD_DN', N'Đặng Thanh Phong', '0903111006', 600000, N'Đã hủy', '2026-10-21 14:00:00', N'Có việc bận đột xuất', 500000),
('V010', 'DC16', '15B-333.22', 'A02', 'DD_HN', 'DD_DN', N'Đặng Thanh Phong', '0903111006', 600000, N'Đã hủy', '2026-11-02 10:00:00', N'Thay đổi lịch công tác', 500000),
('V011', 'DC17', '15B-333.22', 'A03', 'DD_HN', 'DD_DN', N'Đặng Thanh Phong', '0903111006', 600000, N'Đã hủy', '2026-11-09 11:00:00', N'Ốm đau đột xuất', 550000);

-- CÁC VÉ TRÊN CHUYẾN C02 -> C31:
INSERT INTO VE (MaVe, MaDatCho, BienSoXe, MaCho, MaDiemDon, MaDiemTra, HoTenNguoiDi, SoDienThoaiNguoiDi, GiaBanThucTe, TrangThai, ThoiDiemHuy, LyDoHuy, TienHoan) VALUES
('V012', 'DC08', '15B-333.11', 'A02', 'DD_HN', 'DD_DN', N'Đỗ Minh Khang', '0903111009', 600000, N'Có hiệu lực', NULL, NULL, 0),
('V013', 'DC09', '15B-333.11', 'A03', 'DD_HN', 'DD_HU', N'Ngô Thị Lan', '0903111010', 450000, N'Có hiệu lực', NULL, NULL, 0),
('V014', 'DC10', '15B-333.22', 'A01', 'DD_HN', 'DD_DN', N'Dương Văn Mạnh', '0903111011', 600000, N'Có hiệu lực', NULL, NULL, 0),
('V015', 'DC11', '15B-333.22', 'A04', 'DD_HN', 'DD_VI', N'Lý Cẩm Nga', '0903111012', 300000, N'Có hiệu lực', NULL, NULL, 0),
('V016', 'DC12', '15B-333.22', 'A01', 'DD_HN', 'DD_DN', N'Đinh Hữu Oanh', '0903111013', 600000, N'Có hiệu lực', NULL, NULL, 0),
('V017', 'DC13', '15B-333.33', 'A01', 'DD_HN', 'DD_DN', N'Trịnh Xuân Phúc', '0903111014', 600000, N'Có hiệu lực', NULL, NULL, 0),
('V018', 'DC14', '15B-333.33', 'A01', 'DD_HN', 'DD_DN', N'Mai Như Quỳnh', '0903111015', 600000, N'Có hiệu lực', NULL, NULL, 0),

-- Vé của KH07 mua ở FUTA (C07) và Mai Linh (C19):
('V019', 'DC18', '51B-111.11', 'A01', 'DD_SG', 'DD_DL', N'Vũ Đình Giáp', '0903111007', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V020', 'DC19', '51B-222.11', 'A01', 'DD_SG', 'DD_DN', N'Vũ Đình Giáp', '0903111007', 550000, N'Có hiệu lực', NULL, NULL, 0),

-- Vé FUTA TP.HCM -> Đà Lạt (C07 -> C12):
('V021', 'DC20', '51B-111.11', 'A02', 'DD_SG', 'DD_DL', N'Cao Thành Rạng', '0903111016', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V022', 'DC21', '51B-111.11', 'A03', 'DD_SG', 'DD_NT', N'Hồ Ngọc Sơn', '0903111017', 240000, N'Có hiệu lực', NULL, NULL, 0),
('V023', 'DC22', '51B-111.11', 'A01', 'DD_SG', 'DD_DL', N'Phan Thanh Tâm', '0903111018', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V024', 'DC23', '51B-111.11', 'A02', 'DD_SG', 'DD_DL', N'Võ Cẩm Uyên', '0903111019', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V025', 'DC24', '51B-111.22', 'A01', 'DD_SG', 'DD_DL', N'Lâm Quốc Việt', '0903111020', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V026', 'DC25', '51B-111.22', 'A02', 'DD_SG', 'DD_NT', N'Hà Thúy Vy', '0903111021', 240000, N'Có hiệu lực', NULL, NULL, 0),
('V027', 'DC26', '51B-111.22', 'A01', 'DD_SG', 'DD_DL', N'Tạ Quang Xuân', '0903111022', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V028', 'DC27', '51B-111.22', 'A02', 'DD_SG', 'DD_DL', N'Quách Bảo Yến', '0903111023', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V029', 'DC28', '51B-111.33', 'A01', 'DD_SG', 'DD_DL', N'Lương Gia An', '0903111024', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V030', 'DC29', '51B-111.33', 'A01', 'DD_SG', 'DD_DL', N'Trương Mỹ Bình', '0903111025', 320000, N'Có hiệu lực', NULL, NULL, 0),

-- Vé Tuyến T03 TP.HCM -> Cần Thơ (C13 -> C18):
('V031', 'DC30', '51B-111.11', 'A01', 'DD_SG', 'DD_CT', N'Thái Văn Cảnh', '0903111026', 160000, N'Có hiệu lực', NULL, NULL, 0),
('V032', 'DC31', '51B-111.11', 'A02', 'DD_SG', 'DD_CT', N'Tô Hồng Diệp', '0903111027', 160000, N'Có hiệu lực', NULL, NULL, 0),
('V033', 'DC32', '51B-111.11', 'A01', 'DD_SG', 'DD_CT', N'Ân Gia Hào', '0903111028', 160000, N'Có hiệu lực', NULL, NULL, 0),
('V034', 'DC33', '51B-111.22', 'A01', 'DD_SG', 'DD_CT', N'Diệp Tố Như', '0903111029', 160000, N'Có hiệu lực', NULL, NULL, 0),
('V035', 'DC34', '51B-111.22', 'A01', 'DD_SG', 'DD_CT', N'Nghiêm Quốc Kiệt', '0903111030', 160000, N'Có hiệu lực', NULL, NULL, 0),
('V036', 'DC35', '51B-111.33', 'A01', 'DD_SG', 'DD_CT', N'Khưu Vĩnh Phát', '0903111031', 160000, N'Có hiệu lực', NULL, NULL, 0),
('V037', 'DC36', '51B-111.33', 'A01', 'DD_SG', 'DD_CT', N'Âu Dương Phong', '0903111032', 160000, N'Có hiệu lực', NULL, NULL, 0),

-- Vé Tuyến T04 Mai Linh (C19 -> C24):
('V038', 'DC37', '51B-222.11', 'A02', 'DD_SG', 'DD_DN', N'Mã Siêu Long', '0903111033', 550000, N'Có hiệu lực', NULL, NULL, 0),
('V039', 'DC38', '51B-222.11', 'A01', 'DD_SG', 'DD_NT', N'Quan Vân Trường', '0903111034', 300000, N'Có hiệu lực', NULL, NULL, 0),
('V040', 'DC39', '51B-222.11', 'A02', 'DD_NT', 'DD_DN', N'Triệu Tử Long', '0903111035', 300000, N'Có hiệu lực', NULL, NULL, 0),
('V041', 'DC40', '51B-222.22', 'A01', 'DD_SG', 'DD_DN', N'Gia Cát Lượng', '0903111036', 550000, N'Có hiệu lực', NULL, NULL, 0),
('V042', 'DC41', '51B-222.22', 'A01', 'DD_SG', 'DD_DN', N'Chu Du Đạt', '0903111037', 550000, N'Có hiệu lực', NULL, NULL, 0),
('V043', 'DC42', '51B-222.33', 'A01', 'DD_SG', 'DD_DN', N'Lỗ Túc Huy', '0903111038', 550000, N'Có hiệu lực', NULL, NULL, 0),
('V044', 'DC43', '51B-222.33', 'A01', 'DD_SG', 'DD_DN', N'Tư Mã Ý Hoàng', '0903111039', 550000, N'Có hiệu lực', NULL, NULL, 0),

-- Vé Tuyến T05 Hoàng Long (C25 -> C27):
('V045', 'DC44', '15B-333.11', 'A01', 'DD_HN', 'DD_VI', N'Nguyễn Văn An', '0903111001', 250000, N'Có hiệu lực', NULL, NULL, 0),
('V046', 'DC45', '15B-333.22', 'A01', 'DD_HN', 'DD_VI', N'Trần Thị Bích', '0903111002', 250000, N'Có hiệu lực', NULL, NULL, 0),
('V047', 'DC46', '15B-333.33', 'A01', 'DD_HN', 'DD_NB', N'Lê Hoàng Cường', '0903111003', 120000, N'Có hiệu lực', NULL, NULL, 0),

-- Vé Tuyến T06 Thành Bưởi (C28 -> C30):
('V048', 'DC47', '51B-444.11', 'A01', 'DD_SG', 'DD_DL', N'Phạm Thu Dung', '0903111004', 310000, N'Có hiệu lực', NULL, NULL, 0),
('V049', 'DC48', '51B-444.22', 'A01', 'DD_SG', 'DD_DL', N'Hoàng Trọng Em', '0903111005', 310000, N'Có hiệu lực', NULL, NULL, 0),
('V050', 'DC49', '51B-444.33', 'A01', 'DD_SG', 'DD_DL', N'Bùi Thị Hạnh', '0903111008', 310000, N'Có hiệu lực', NULL, NULL, 0),

-- CHUYẾN C31 (CHUYẾN GẦN ĐẦY - BÁN 16 VÉ V051 -> V066 ĐỂ TEST CÂU TRUY VẤN VỀ DOANH THU & CHỖ GẦN ĐẦY):
('V051', 'DC50', '51B-111.22', 'A01', 'DD_SG', 'DD_DL', N'Đỗ Minh Khang', '0903111009', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V052', 'DC50', '51B-111.22', 'A02', 'DD_SG', 'DD_DL', N'Đỗ Minh Quân', '0903111009', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V053', 'DC51', '51B-111.22', 'A03', 'DD_SG', 'DD_DL', N'Ngô Thị Lan', '0903111010', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V054', 'DC51', '51B-111.22', 'A04', 'DD_SG', 'DD_DL', N'Ngô Văn Tuấn', '0903111010', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V055', 'DC52', '51B-111.22', 'A05', 'DD_SG', 'DD_DL', N'Dương Văn Mạnh', '0903111011', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V056', 'DC52', '51B-111.22', 'A06', 'DD_SG', 'DD_DL', N'Dương Thị Mơ', '0903111011', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V057', 'DC53', '51B-111.22', 'A07', 'DD_SG', 'DD_DL', N'Lý Cẩm Nga', '0903111012', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V058', 'DC53', '51B-111.22', 'A08', 'DD_SG', 'DD_DL', N'Lý Hoàng Nam', '0903111012', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V059', 'DC54', '51B-111.22', 'A09', 'DD_SG', 'DD_DL', N'Đinh Hữu Oanh', '0903111013', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V060', 'DC54', '51B-111.22', 'A10', 'DD_SG', 'DD_DL', N'Đinh Hữu Phúc', '0903111013', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V061', 'DC55', '51B-111.22', 'A11', 'DD_SG', 'DD_DL', N'Trịnh Xuân Phúc', '0903111014', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V062', 'DC55', '51B-111.22', 'B01', 'DD_SG', 'DD_DL', N'Trịnh Thị Thảo', '0903111014', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V063', 'DC56', '51B-111.22', 'B02', 'DD_SG', 'DD_DL', N'Mai Như Quỳnh', '0903111015', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V064', 'DC56', '51B-111.22', 'B03', 'DD_SG', 'DD_DL', N'Mai Văn Quang', '0903111015', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V065', 'DC57', '51B-111.22', 'B04', 'DD_SG', 'DD_DL', N'Cao Thành Rạng', '0903111016', 320000, N'Có hiệu lực', NULL, NULL, 0),
('V066', 'DC57', '51B-111.22', 'B05', 'DD_SG', 'DD_DL', N'Cao Mỹ Lệ', '0903111016', 320000, N'Có hiệu lực', NULL, NULL, 0),

-- KH01 MUA THÊM 3 VÉ TRÊN DC58 (KH01 TỔNG CỘNG >= 5 VÉ ĐỂ TEST CÂU 20):
('V067', 'DC58', '15B-333.11', 'A04', 'DD_HN', 'DD_DN', N'Nguyễn Văn An', '0903111001', 600000, N'Có hiệu lực', NULL, NULL, 0),
('V068', 'DC58', '15B-333.11', 'A05', 'DD_HN', 'DD_DN', N'Nguyễn Thị Mai', '0903111001', 600000, N'Có hiệu lực', NULL, NULL, 0),
('V069', 'DC58', '15B-333.11', 'A06', 'DD_HN', 'DD_DN', N'Nguyễn Văn Tuấn', '0903111001', 600000, N'Có hiệu lực', NULL, NULL, 0);
GO

-- SINH TIẾP BỔ SUNG CÁC VÉ TỪ V070 ĐẾN V135 CHO ĐỦ 135 VÉ (>= 120 VÉ)
-- Rải trên các đặt chỗ từ DC08 đến DC57 để phân bố đều
DECLARE @v INT = 70;
DECLARE @MaV VARCHAR(20);
DECLARE @MaDC VARCHAR(20);
DECLARE @MaC VARCHAR(10);
DECLARE @BSX VARCHAR(20);

DECLARE @MaTuyenCur VARCHAR(20);
DECLARE @DiemDonCur VARCHAR(20), @DiemTraCur VARCHAR(20);

WHILE @v <= 135
BEGIN
    SET @MaV = 'V' + RIGHT('000' + CAST(@v AS VARCHAR(3)), 3);
    -- Chọn các đặt chỗ DC20 -> DC29 (Tuyến T02), DC30 -> DC36 (Tuyến T03), DC37 -> DC43 (Tuyến T04), DC47 -> DC49 (T06)
    SET @MaDC = 'DC' + RIGHT('0' + CAST(20 + (@v % 30) AS VARCHAR(2)), 2);
    SET @MaC = 'B' + RIGHT('0' + CAST(1 + (@v % 8) AS VARCHAR(2)), 2);
    
    -- Lấy Biển số xe và Tuyến của chuyến
    SELECT @BSX = c.BienSoXe, @MaTuyenCur = c.MaTuyen
    FROM DAT_CHO d
    JOIN CHUYEN_XE c ON d.MaChuyen = c.MaChuyen
    WHERE d.MaDatCho = @MaDC;

    -- Lấy điểm đầu (chỉ đón) và điểm cuối (chỉ trả) của tuyến đó
    SELECT TOP 1 @DiemDonCur = MaDiaDiem FROM CHI_TIET_TUYEN WHERE MaTuyen = @MaTuyenCur AND ChoDon = 1 ORDER BY ThuTu ASC;
    SELECT TOP 1 @DiemTraCur = MaDiaDiem FROM CHI_TIET_TUYEN WHERE MaTuyen = @MaTuyenCur AND ChoTra = 1 ORDER BY ThuTu DESC;

    -- Thêm vé vào bảng
    INSERT INTO VE (MaVe, MaDatCho, BienSoXe, MaCho, MaDiemDon, MaDiemTra, HoTenNguoiDi, SoDienThoaiNguoiDi, GiaBanThucTe, TrangThai)
    VALUES (
        @MaV, 
        @MaDC, 
        @BSX, 
        @MaC, 
        @DiemDonCur, 
        @DiemTraCur, 
        N'Hành khách phụ ' + CAST(@v AS VARCHAR(3)), 
        '0903999' + RIGHT('000' + CAST(@v AS VARCHAR(3)), 3), 
        320000, 
        N'Có hiệu lực'
    );
    
    SET @v = @v + 1;
END;
GO

-- 11. BẢNG THANH_TOAN (75 giao dịch thanh toán >= 70)
-- ĐẦY ĐỦ: Thanh toán thành công ngay, Thất bại rồi Thành công (DC01, DC03,...), Chưa thanh toán
INSERT INTO THANH_TOAN (MaGiaoDich, MaDatCho, ThoiDiemGiaoDich, SoTien, PhuongThuc, MaThamChieu, TrangThai) VALUES
-- DC01: Thất bại lần 1, Thành công lần 2 (Kiểm thử tình huống bắt buộc)
('TT001', 'DC01', '2026-10-18 08:31:00', 300000, N'VNPay', 'VNP_FAIL_001', N'Thất bại'),
('TT002', 'DC01', '2026-10-18 08:35:00', 300000, N'Momo', 'MOMO_OK_001', N'Thành công'),

-- DC02: Thành công ngay lần đầu
('TT003', 'DC02', '2026-10-18 09:16:00', 350000, N'Chuyển khoản', 'VCB_OK_002', N'Thành công'),

-- DC03: Thất bại lần 1, Thành công lần 2
('TT004', 'DC03', '2026-10-18 10:02:00', 150000, N'Thẻ tín dụng', 'VISA_FAIL_003', N'Thất bại'),
('TT005', 'DC03', '2026-10-18 10:05:00', 150000, N'VNPay', 'VNP_OK_003', N'Thành công'),

-- DC04 đến DC58: Đều thanh toán thành công
('TT006', 'DC04', '2026-10-18 10:32:00', 380000, N'Momo', 'MOMO_OK_004', N'Thành công'),
('TT007', 'DC05', '2026-10-18 11:02:00', 180000, N'Chuyển khoản', 'TCB_OK_005', N'Thành công'),
('TT008', 'DC06', '2026-10-18 14:02:00', 600000, N'VNPay', 'VNP_OK_006', N'Thành công'),
('TT009', 'DC07', '2026-10-18 15:32:00', 650000, N'Momo', 'MOMO_OK_007', N'Thành công'),
('TT010', 'DC08', '2026-10-21 09:02:00', 600000, N'Chuyển khoản', 'MB_OK_008', N'Thành công'),
('TT011', 'DC09', '2026-10-21 10:02:00', 450000, N'VNPay', 'VNP_OK_009', N'Thành công'),
('TT012', 'DC10', '2026-11-03 08:02:00', 600000, N'Momo', 'MOMO_OK_010', N'Thành công'),
('TT013', 'DC11', '2026-11-03 14:02:00', 300000, N'Chuyển khoản', 'ACB_OK_011', N'Thành công'),
('TT014', 'DC12', '2026-11-10 11:02:00', 600000, N'Thẻ tín dụng', 'VISA_OK_012', N'Thành công'),
('TT015', 'DC13', '2026-11-28 09:02:00', 600000, N'VNPay', 'VNP_OK_013', N'Thành công'),
('TT016', 'DC14', '2026-12-13 10:02:00', 600000, N'Momo', 'MOMO_OK_014', N'Thành công'),

-- DC15, 16, 17: Đã thanh toán trước khi hủy
('TT017', 'DC15', '2026-10-21 08:02:00', 600000, N'Chuyển khoản', 'VCB_OK_015', N'Thành công'),
('TT018', 'DC16', '2026-11-01 09:02:00', 600000, N'VNPay', 'VNP_OK_016', N'Thành công'),
('TT019', 'DC17', '2026-11-08 10:02:00', 600000, N'Momo', 'MOMO_OK_017', N'Thành công'),

-- DC18 đến DC58:
('TT020', 'DC18', '2026-10-03 08:02:00', 320000, N'Chuyển khoản', 'TCB_OK_018', N'Thành công'),
('TT021', 'DC19', '2026-10-08 09:02:00', 550000, N'VNPay', 'VNP_OK_019', N'Thành công'),
('TT022', 'DC20', '2026-10-03 10:02:00', 320000, N'Momo', 'MOMO_OK_020', N'Thành công'),
('TT023', 'DC21', '2026-10-03 11:02:00', 240000, N'Chuyển khoản', 'MB_OK_021', N'Thành công'),
('TT024', 'DC22', '2026-10-13 09:02:00', 320000, N'VNPay', 'VNP_OK_022', N'Thành công'),
('TT025', 'DC23', '2026-10-13 14:02:00', 320000, N'Momo', 'MOMO_OK_023', N'Thành công'),
('TT026', 'DC24', '2026-10-31 08:02:00', 320000, N'Chuyển khoản', 'VCB_OK_024', N'Thành công'),
('TT027', 'DC25', '2026-10-31 10:02:00', 240000, N'Thẻ tín dụng', 'VISA_OK_025', N'Thành công'),
('TT028', 'DC26', '2026-11-14 09:02:00', 320000, N'VNPay', 'VNP_OK_026', N'Thành công'),
('TT029', 'DC27', '2026-11-14 15:02:00', 320000, N'Momo', 'MOMO_OK_027', N'Thành công'),
('TT030', 'DC28', '2026-12-01 08:02:00', 320000, N'Chuyển khoản', 'TCB_OK_028', N'Thành công'),
('TT031', 'DC29', '2026-12-18 09:02:00', 320000, N'VNPay', 'VNP_OK_029', N'Thành công'),
('TT032', 'DC30', '2026-10-06 08:02:00', 160000, N'Momo', 'MOMO_OK_030', N'Thành công'),
('TT033', 'DC31', '2026-10-06 10:02:00', 160000, N'Chuyển khoản', 'MB_OK_031', N'Thành công'),
('TT034', 'DC32', '2026-10-16 09:02:00', 160000, N'VNPay', 'VNP_OK_032', N'Thành công'),
('TT035', 'DC33', '2026-11-02 08:02:00', 160000, N'Momo', 'MOMO_OK_033', N'Thành công'),
('TT036', 'DC34', '2026-11-18 09:02:00', 160000, N'Chuyển khoản', 'VCB_OK_034', N'Thành công'),
('TT037', 'DC35', '2026-12-03 08:02:00', 160000, N'VNPay', 'VNP_OK_035', N'Thành công'),
('TT038', 'DC36', '2026-12-23 09:02:00', 160000, N'Momo', 'MOMO_OK_036', N'Thành công'),
('TT039', 'DC37', '2026-10-08 10:02:00', 550000, N'Chuyển khoản', 'ACB_OK_037', N'Thành công'),
('TT040', 'DC38', '2026-10-23 08:02:00', 300000, N'VNPay', 'VNP_OK_038', N'Thành công'),
('TT041', 'DC39', '2026-10-23 11:02:00', 300000, N'Momo', 'MOMO_OK_039', N'Thành công'),
('TT042', 'DC40', '2026-11-06 09:02:00', 550000, N'Chuyển khoản', 'TCB_OK_040', N'Thành công'),
('TT043', 'DC41', '2026-11-20 08:02:00', 550000, N'Thẻ tín dụng', 'VISA_OK_041', N'Thành công'),
('TT044', 'DC42', '2026-12-08 09:02:00', 550000, N'VNPay', 'VNP_OK_042', N'Thành công'),
('TT045', 'DC43', '2026-12-26 10:02:00', 550000, N'Momo', 'MOMO_OK_043', N'Thành công'),
('TT046', 'DC44', '2026-10-10 08:02:00', 250000, N'Chuyển khoản', 'MB_OK_044', N'Thành công'),
('TT047', 'DC45', '2026-11-08 09:02:00', 250000, N'VNPay', 'VNP_OK_045', N'Thành công'),
('TT048', 'DC46', '2026-12-10 10:02:00', 120000, N'Momo', 'MOMO_OK_046', N'Thành công'),
('TT049', 'DC47', '2026-10-12 08:02:00', 310000, N'Chuyển khoản', 'VCB_OK_047', N'Thành công'),
('TT050', 'DC48', '2026-11-12 09:02:00', 310000, N'VNPay', 'VNP_OK_048', N'Thành công'),
('TT051', 'DC49', '2026-12-16 10:02:00', 310000, N'Momo', 'MOMO_OK_049', N'Thành công'),
('TT052', 'DC50', '2026-10-26 08:02:00', 640000, N'Chuyển khoản', 'TCB_OK_050', N'Thành công'),
('TT053', 'DC51', '2026-10-26 09:02:00', 640000, N'VNPay', 'VNP_OK_051', N'Thành công'),
('TT054', 'DC52', '2026-10-26 10:02:00', 640000, N'Momo', 'MOMO_OK_052', N'Thành công'),
('TT055', 'DC53', '2026-10-26 11:02:00', 640000, N'Chuyển khoản', 'MB_OK_053', N'Thành công'),
('TT056', 'DC54', '2026-10-26 13:02:00', 640000, N'VNPay', 'VNP_OK_054', N'Thành công'),
('TT057', 'DC55', '2026-10-26 14:02:00', 640000, N'Momo', 'MOMO_OK_055', N'Thành công'),
('TT058', 'DC56', '2026-10-26 15:02:00', 640000, N'Chuyển khoản', 'VCB_OK_056', N'Thành công'),
('TT059', 'DC57', '2026-10-26 16:02:00', 640000, N'VNPay', 'VNP_OK_057', N'Thành công'),
('TT060', 'DC58', '2026-10-21 11:05:00', 1800000, N'Chuyển khoản', 'VCB_OK_058', N'Thành công'),

-- CÁC GIAO DỊCH THẤT BẠI CỦA CÁC ĐẶT CHỖ CHƯA THANH TOÁN (DC59 -> DC65 để test tình huống):
('TT061', 'DC59', '2026-10-14 09:05:00', 320000, N'Momo', 'MOMO_ERR_059', N'Thất bại'),
('TT062', 'DC60', '2026-11-01 10:05:00', 320000, N'VNPay', 'VNP_ERR_060', N'Thất bại'),
('TT063', 'DC61', '2026-10-17 08:05:00', 160000, N'Thẻ tín dụng', 'VISA_ERR_061', N'Thất bại'),
('TT064', 'DC62', '2026-11-03 09:05:00', 160000, N'Momo', 'MOMO_ERR_062', N'Thất bại'),
('TT065', 'DC63', '2026-11-07 10:05:00', 550000, N'Chuyển khoản', 'TCB_ERR_063', N'Thất bại'),
('TT066', 'DC64', '2026-11-21 11:05:00', 550000, N'VNPay', 'VNP_ERR_064', N'Thất bại'),
('TT067', 'DC65', '2026-10-13 14:05:00', 310000, N'Momo', 'MOMO_ERR_065', N'Thất bại'),

-- Thêm một số giao dịch Khởi tạo / Thất bại khác để đạt 75 giao dịch >= 70:
('TT068', 'DC59', '2026-10-14 09:02:00', 320000, N'Chuyển khoản', NULL, N'Khởi tạo'),
('TT069', 'DC60', '2026-11-01 10:02:00', 320000, N'VNPay', NULL, N'Khởi tạo'),
('TT070', 'DC61', '2026-10-17 08:02:00', 160000, N'Momo', NULL, N'Khởi tạo'),
('TT071', 'DC62', '2026-11-03 09:02:00', 160000, N'Thẻ tín dụng', NULL, N'Khởi tạo'),
('TT072', 'DC63', '2026-11-07 10:02:00', 550000, N'VNPay', NULL, N'Khởi tạo'),
('TT073', 'DC64', '2026-11-21 11:02:00', 550000, N'Momo', NULL, N'Khởi tạo'),
('TT074', 'DC65', '2026-10-13 14:02:00', 310000, N'Chuyển khoản', NULL, N'Khởi tạo'),
('TT075', 'DC02', '2026-10-18 09:15:30', 350000, N'Momo', 'MOMO_FAIL_002', N'Thất bại');
GO

-- =============================================================================
-- PHẦN IV. ĐẦY ĐỦ 52 CÂU TRUY VẤN SQL THEO ĐÚNG SỐ THỨ TỰ ĐỀ BÀI (TỪ CÂU 1 ĐẾN 52)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- NHÓM A. TRUY VẤN CƠ BẢN VÀ JOIN (CÂU 1 -> CÂU 10)
-- -----------------------------------------------------------------------------

-- Câu 1: Liệt kê các nhà xe đang hoạt động.
SELECT MaNhaXe, TenNhaXe, SoDienThoai, Email, DiaChi, TrangThai
FROM NHA_XE
WHERE TrangThai = N'Hoạt động';
GO

-- Câu 2: Liệt kê các xe của từng nhà xe.
SELECT nx.MaNhaXe, nx.TenNhaXe, x.BienSoXe, x.LoaiXe, x.SoChoThietKe, x.TrangThai
FROM NHA_XE nx
JOIN XE x ON nx.MaNhaXe = x.MaNhaXe
ORDER BY nx.MaNhaXe, x.BienSoXe;
GO

-- Câu 3: Liệt kê các tuyến của một nhà xe (ví dụ nhà xe 'NX01' - FUTA).
SELECT t.MaTuyen, t.TenTuyen, t.KhoangCachKm, t.TrangThai, nx.TenNhaXe
FROM TUYEN_XE t
JOIN NHA_XE nx ON t.MaNhaXe = nx.MaNhaXe
WHERE nx.MaNhaXe = 'NX01';
GO

-- Câu 4: Liệt kê các điểm của một tuyến theo đúng thứ tự (ví dụ tuyến 'T01').
SELECT ctt.ThuTu, dd.MaDiaDiem, dd.TenDiaDiem, dd.TinhThanh, ctt.ChoDon, ctt.ChoTra, ctt.SoPhutDuKien
FROM CHI_TIET_TUYEN ctt
JOIN DIA_DIEM dd ON ctt.MaDiaDiem = dd.MaDiaDiem
WHERE ctt.MaTuyen = 'T01'
ORDER BY ctt.ThuTu ASC;
GO

-- Câu 5: Liệt kê các chuyến chạy trong một ngày (ví dụ ngày 20/10/2026).
SELECT c.MaChuyen, t.TenTuyen, c.BienSoXe, c.ThoiDiemKhoiHanh, c.ThoiDiemDuKienKetThuc, c.TrangThai
FROM CHUYEN_XE c
JOIN TUYEN_XE t ON c.MaTuyen = t.MaTuyen
WHERE CAST(c.ThoiDiemKhoiHanh AS DATE) = '2026-10-20'
ORDER BY c.ThoiDiemKhoiHanh ASC;
GO

-- Câu 6: Tìm các chuyến có thể phục vụ hành trình từ điểm A đến điểm B (ví dụ: Hà Nội -> Đà Nẵng).
SELECT c.MaChuyen, t.TenTuyen, nx.TenNhaXe, c.BienSoXe, c.ThoiDiemKhoiHanh,
       dd_don.TenDiaDiem AS DiemDon, dd_tra.TenDiaDiem AS DiemTra
FROM CHUYEN_XE c
JOIN TUYEN_XE t ON c.MaTuyen = t.MaTuyen
JOIN NHA_XE nx ON t.MaNhaXe = nx.MaNhaXe
JOIN CHI_TIET_TUYEN ctt_don ON t.MaTuyen = ctt_don.MaTuyen
JOIN DIA_DIEM dd_don ON ctt_don.MaDiaDiem = dd_don.MaDiaDiem
JOIN CHI_TIET_TUYEN ctt_tra ON t.MaTuyen = ctt_tra.MaTuyen
JOIN DIA_DIEM dd_tra ON ctt_tra.MaDiaDiem = dd_tra.MaDiaDiem
WHERE dd_don.TenDiaDiem LIKE N'%Hà Nội%'
  AND dd_tra.TenDiaDiem LIKE N'%Đà Nẵng%'
  AND ctt_don.ChoDon = 1
  AND ctt_tra.ChoTra = 1
  AND ctt_don.ThuTu < ctt_tra.ThuTu;
GO

-- Câu 7: Liệt kê chuyến cùng tuyến, nhà xe và xe thực hiện.
SELECT c.MaChuyen, t.TenTuyen, nx.TenNhaXe, c.BienSoXe, x.LoaiXe, 
       c.ThoiDiemKhoiHanh, c.ThoiDiemDuKienKetThuc, c.TrangThai
FROM CHUYEN_XE c
JOIN TUYEN_XE t ON c.MaTuyen = t.MaTuyen
JOIN NHA_XE nx ON t.MaNhaXe = nx.MaNhaXe
JOIN XE x ON c.BienSoXe = x.BienSoXe
ORDER BY c.ThoiDiemKhoiHanh DESC;
GO

-- Câu 8: Liệt kê thông tin các vé trong một đặt chỗ (ví dụ đặt chỗ 'DC01').
SELECT v.MaVe, v.MaDatCho, v.MaCho, v.BienSoXe, dd_don.TenDiaDiem AS DiemDon, 
       dd_tra.TenDiaDiem AS DiemTra, v.HoTenNguoiDi, v.GiaBanThucTe, v.TrangThai
FROM VE v
JOIN DIA_DIEM dd_don ON v.MaDiemDon = dd_don.MaDiaDiem
JOIN DIA_DIEM dd_tra ON v.MaDiemTra = dd_tra.MaDiaDiem
WHERE v.MaDatCho = 'DC01';
GO

-- Câu 9: Liệt kê hành khách, chỗ, điểm đón và điểm trả của từng vé.
SELECT v.MaVe, v.HoTenNguoiDi, v.SoDienThoaiNguoiDi, v.BienSoXe, v.MaCho,
       dd_don.TenDiaDiem AS DiemDon, dd_tra.TenDiaDiem AS DiemTra, v.GiaBanThucTe, v.TrangThai
FROM VE v
JOIN DIA_DIEM dd_don ON v.MaDiemDon = dd_don.MaDiaDiem
JOIN DIA_DIEM dd_tra ON v.MaDiemTra = dd_tra.MaDiaDiem
ORDER BY v.MaVe;
GO

-- Câu 10: Liệt kê các giao dịch thanh toán của từng đặt chỗ.
SELECT d.MaDatCho, d.MaKhachHang, tt.MaGiaoDich, tt.ThoiDiemGiaoDich, 
       tt.SoTien, tt.PhuongThuc, tt.MaThamChieu, tt.TrangThai
FROM DAT_CHO d
LEFT JOIN THANH_TOAN tt ON d.MaDatCho = tt.MaDatCho
ORDER BY d.MaDatCho, tt.ThoiDiemGiaoDich;
GO

-- -----------------------------------------------------------------------------
-- NHÓM B. GROUP BY - HAVING (CÂU 11 -> CÂU 22)
-- -----------------------------------------------------------------------------

-- Câu 11: Đếm số xe của từng nhà xe.
SELECT nx.MaNhaXe, nx.TenNhaXe, COUNT(x.BienSoXe) AS SoLuongXe
FROM NHA_XE nx
LEFT JOIN XE x ON nx.MaNhaXe = x.MaNhaXe
GROUP BY nx.MaNhaXe, nx.TenNhaXe
ORDER BY SoLuongXe DESC;
GO

-- Câu 12: Đếm số tuyến của từng nhà xe.
SELECT nx.MaNhaXe, nx.TenNhaXe, COUNT(t.MaTuyen) AS SoLuongTuyen
FROM NHA_XE nx
LEFT JOIN TUYEN_XE t ON nx.MaNhaXe = t.MaNhaXe
GROUP BY nx.MaNhaXe, nx.TenNhaXe
ORDER BY SoLuongTuyen DESC;
GO

-- Câu 13: Đếm số chuyến của từng tuyến.
SELECT t.MaTuyen, t.TenTuyen, COUNT(c.MaChuyen) AS SoLuongChuyen
FROM TUYEN_XE t
LEFT JOIN CHUYEN_XE c ON t.MaTuyen = c.MaTuyen
GROUP BY t.MaTuyen, t.TenTuyen
ORDER BY SoLuongChuyen DESC;
GO

-- Câu 14: Đếm số vé bán được của từng chuyến (chỉ tính vé có hiệu lực hoặc đã sử dụng).
SELECT c.MaChuyen, t.TenTuyen, c.ThoiDiemKhoiHanh, 
       COUNT(v.MaVe) AS SoVeBanDuoc
FROM CHUYEN_XE c
JOIN TUYEN_XE t ON c.MaTuyen = t.MaTuyen
LEFT JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
LEFT JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY c.MaChuyen, t.TenTuyen, c.ThoiDiemKhoiHanh
ORDER BY SoVeBanDuoc DESC;
GO

-- Câu 15: Tính doanh thu từng chuyến (tổng giá bán thực tế vé có hiệu lực hoặc đã sử dụng).
SELECT c.MaChuyen, t.TenTuyen, c.ThoiDiemKhoiHanh,
       ISNULL(SUM(v.GiaBanThucTe), 0) AS DoanhThu
FROM CHUYEN_XE c
JOIN TUYEN_XE t ON c.MaTuyen = t.MaTuyen
LEFT JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
LEFT JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY c.MaChuyen, t.TenTuyen, c.ThoiDiemKhoiHanh
ORDER BY DoanhThu DESC;
GO

-- Câu 16: Tính doanh thu từng tuyến.
SELECT t.MaTuyen, t.TenTuyen,
       ISNULL(SUM(v.GiaBanThucTe), 0) AS DoanhThuTuyen
FROM TUYEN_XE t
JOIN CHUYEN_XE c ON t.MaTuyen = c.MaTuyen
JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY t.MaTuyen, t.TenTuyen
ORDER BY DoanhThuTuyen DESC;
GO

-- Câu 17: Tính doanh thu từng nhà xe.
SELECT nx.MaNhaXe, nx.TenNhaXe,
       ISNULL(SUM(v.GiaBanThucTe), 0) AS TongDoanhThu
FROM NHA_XE nx
JOIN TUYEN_XE t ON nx.MaNhaXe = t.MaNhaXe
JOIN CHUYEN_XE c ON t.MaTuyen = c.MaTuyen
JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY nx.MaNhaXe, nx.TenNhaXe
ORDER BY TongDoanhThu DESC;
GO

-- Câu 18: Tính doanh thu theo tháng.
SELECT YEAR(c.ThoiDiemKhoiHanh) AS Nam,
       MONTH(c.ThoiDiemKhoiHanh) AS Thang,
       ISNULL(SUM(v.GiaBanThucTe), 0) AS DoanhThuThang
FROM CHUYEN_XE c
JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY YEAR(c.ThoiDiemKhoiHanh), MONTH(c.ThoiDiemKhoiHanh)
ORDER BY Nam, Thang;
GO

-- Câu 19: Tìm những chuyến bán từ 5 vé trở lên.
SELECT c.MaChuyen, t.TenTuyen, c.ThoiDiemKhoiHanh,
       COUNT(v.MaVe) AS SoVeBan
FROM CHUYEN_XE c
JOIN TUYEN_XE t ON c.MaTuyen = t.MaTuyen
JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY c.MaChuyen, t.TenTuyen, c.ThoiDiemKhoiHanh
HAVING COUNT(v.MaVe) >= 5
ORDER BY SoVeBan DESC;
GO

-- Câu 20: Tìm khách hàng mua từ 5 vé trở lên.
SELECT kh.MaKhachHang, kh.HoTen, kh.SoDienThoai,
       COUNT(v.MaVe) AS TongSoVeMua
FROM KHACH_HANG kh
JOIN DAT_CHO d ON kh.MaKhachHang = d.MaKhachHang
JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY kh.MaKhachHang, kh.HoTen, kh.SoDienThoai
HAVING COUNT(v.MaVe) >= 5
ORDER BY TongSoVeMua DESC;
GO

-- Câu 21: Tìm tuyến có số chuyến lớn hơn trung bình.
WITH ThongKeTuyen AS (
    SELECT t.MaTuyen, t.TenTuyen, COUNT(c.MaChuyen) AS SoChuyen
    FROM TUYEN_XE t
    LEFT JOIN CHUYEN_XE c ON t.MaTuyen = c.MaTuyen
    GROUP BY t.MaTuyen, t.TenTuyen
)
SELECT MaTuyen, TenTuyen, SoChuyen
FROM ThongKeTuyen
WHERE SoChuyen > (SELECT AVG(CAST(SoChuyen AS FLOAT)) FROM ThongKeTuyen)
ORDER BY SoChuyen DESC;
GO

-- Câu 22: Tìm nhà xe có doanh thu cao nhất.
SELECT TOP 1 WITH TIES nx.MaNhaXe, nx.TenNhaXe,
       ISNULL(SUM(v.GiaBanThucTe), 0) AS DoanhThuCaoNhat
FROM NHA_XE nx
JOIN TUYEN_XE t ON nx.MaNhaXe = t.MaNhaXe
JOIN CHUYEN_XE c ON t.MaTuyen = c.MaTuyen
JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY nx.MaNhaXe, nx.TenNhaXe
ORDER BY DoanhThuCaoNhat DESC;
GO

-- -----------------------------------------------------------------------------
-- NHÓM C. SUBQUERY - EXISTS - NOT EXISTS (CÂU 23 -> CÂU 30)
-- -----------------------------------------------------------------------------

-- Câu 23: Tìm khách hàng chưa từng đặt vé.
SELECT kh.MaKhachHang, kh.HoTen, kh.SoDienThoai, kh.Email
FROM KHACH_HANG kh
WHERE NOT EXISTS (
    SELECT 1 FROM DAT_CHO d WHERE d.MaKhachHang = kh.MaKhachHang
);
GO

-- Câu 24: Tìm xe chưa từng được sử dụng cho chuyến nào.
SELECT x.BienSoXe, x.MaNhaXe, x.LoaiXe, x.SoChoThietKe
FROM XE x
WHERE NOT EXISTS (
    SELECT 1 FROM CHUYEN_XE c WHERE c.BienSoXe = x.BienSoXe
);
GO

-- Câu 25: Tìm chuyến chưa bán vé nào.
SELECT c.MaChuyen, t.TenTuyen, c.BienSoXe, c.ThoiDiemKhoiHanh
FROM CHUYEN_XE c
JOIN TUYEN_XE t ON c.MaTuyen = t.MaTuyen
WHERE NOT EXISTS (
    SELECT 1 
    FROM DAT_CHO d 
    JOIN VE v ON d.MaDatCho = v.MaDatCho
    WHERE d.MaChuyen = c.MaChuyen
);
GO

-- Câu 26: Tìm tuyến chưa có chuyến trong một khoảng thời gian (ví dụ: Tháng 10/2026).
SELECT t.MaTuyen, t.TenTuyen, t.MaNhaXe
FROM TUYEN_XE t
WHERE NOT EXISTS (
    SELECT 1 
    FROM CHUYEN_XE c 
    WHERE c.MaTuyen = t.MaTuyen
      AND c.ThoiDiemKhoiHanh >= '2026-10-01' 
      AND c.ThoiDiemKhoiHanh < '2026-11-01'
);
GO

-- Câu 27: Tìm khách hàng đã mua vé của ít nhất 3 nhà xe khác nhau.
SELECT kh.MaKhachHang, kh.HoTen, kh.SoDienThoai,
       COUNT(DISTINCT nx.MaNhaXe) AS SoNhaXeDaMua
FROM KHACH_HANG kh
JOIN DAT_CHO d ON kh.MaKhachHang = d.MaKhachHang
JOIN CHUYEN_XE c ON d.MaChuyen = c.MaChuyen
JOIN TUYEN_XE t ON c.MaTuyen = t.MaTuyen
JOIN NHA_XE nx ON t.MaNhaXe = nx.MaNhaXe
JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY kh.MaKhachHang, kh.HoTen, kh.SoDienThoai
HAVING COUNT(DISTINCT nx.MaNhaXe) >= 3;
GO

-- Câu 28: Tìm khách hàng có tổng chi tiêu cao hơn mức trung bình của tất cả khách hàng có phát sinh chi tiêu.
WITH ChiTieuKhachHang AS (
    SELECT kh.MaKhachHang, kh.HoTen, 
           SUM(v.GiaBanThucTe) AS TongChiTieu
    FROM KHACH_HANG kh
    JOIN DAT_CHO d ON kh.MaKhachHang = d.MaKhachHang
    JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
    GROUP BY kh.MaKhachHang, kh.HoTen
)
SELECT MaKhachHang, HoTen, TongChiTieu
FROM ChiTieuKhachHang
WHERE TongChiTieu > (SELECT AVG(TongChiTieu) FROM ChiTieuKhachHang)
ORDER BY TongChiTieu DESC;
GO

-- Câu 29: Tìm chuyến có doanh thu cao nhất.
SELECT TOP 1 WITH TIES c.MaChuyen, t.TenTuyen, c.ThoiDiemKhoiHanh,
       SUM(v.GiaBanThucTe) AS DoanhThuCaoNhat
FROM CHUYEN_XE c
JOIN TUYEN_XE t ON c.MaTuyen = t.MaTuyen
JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY c.MaChuyen, t.TenTuyen, c.ThoiDiemKhoiHanh
ORDER BY DoanhThuCaoNhat DESC;
GO

-- Câu 30: Tìm khách hàng mua nhiều vé nhất.
SELECT TOP 1 WITH TIES kh.MaKhachHang, kh.HoTen, kh.SoDienThoai,
       COUNT(v.MaVe) AS TongSoVe
FROM KHACH_HANG kh
JOIN DAT_CHO d ON kh.MaKhachHang = d.MaKhachHang
JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY kh.MaKhachHang, kh.HoTen, kh.SoDienThoai
ORDER BY TongSoVe DESC;
GO

-- -----------------------------------------------------------------------------
-- NHÓM D. TRUY VẤN NGHIỆP VỤ KHÓ & QUẢN LÝ CHỖ THEO ĐOẠN (CÂU 31 -> CÂU 40)
-- -----------------------------------------------------------------------------

-- Câu 31: Tìm các chỗ hoàn toàn chưa có vé trên một chuyến (ví dụ chuyến 'C01').
SELECT cn.MaCho, cn.Tang, cn.LoaiCho
FROM CHUYEN_XE c
JOIN CHO_NGOI cn ON c.BienSoXe = cn.BienSoXe
WHERE c.MaChuyen = 'C01'
  AND NOT EXISTS (
      SELECT 1 
      FROM DAT_CHO d
      JOIN VE v ON d.MaDatCho = v.MaDatCho
      WHERE d.MaChuyen = c.MaChuyen
        AND v.MaCho = cn.MaCho
        AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
  )
ORDER BY cn.MaCho;
GO

-- Câu 32: Với một chuyến ('C01') và đoạn Hà Nội (A) -> Huế (D) cho trước, tìm các chỗ có thể bán cho khách mới.
-- Quy tắc: Chỗ khả dụng nếu KHÔNG có vé nào đã bán bị chồng lấn với đoạn [ThuTuDon, ThuTuTra] = [1, 4]
DECLARE @MaChuyenParam VARCHAR(20) = 'C01';
DECLARE @DiemDonParam VARCHAR(20) = 'DD_HN'; -- ThuTu = 1
DECLARE @DiemTraParam VARCHAR(20) = 'DD_HU'; -- ThuTu = 4

DECLARE @TuyenParam VARCHAR(20);
DECLARE @ThuTuDon INT, @ThuTuTra INT;

SELECT @TuyenParam = MaTuyen FROM CHUYEN_XE WHERE MaChuyen = @MaChuyenParam;
SELECT @ThuTuDon = ThuTu FROM CHI_TIET_TUYEN WHERE MaTuyen = @TuyenParam AND MaDiaDiem = @DiemDonParam;
SELECT @ThuTuTra = ThuTu FROM CHI_TIET_TUYEN WHERE MaTuyen = @TuyenParam AND MaDiaDiem = @DiemTraParam;

SELECT cn.MaCho, cn.Tang, cn.LoaiCho
FROM CHUYEN_XE c
JOIN CHO_NGOI cn ON c.BienSoXe = cn.BienSoXe
WHERE c.MaChuyen = @MaChuyenParam
  AND NOT EXISTS (
      SELECT 1
      FROM DAT_CHO d
      JOIN VE v ON d.MaDatCho = v.MaDatCho
      JOIN CHI_TIET_TUYEN ctt_v_don ON c.MaTuyen = ctt_v_don.MaTuyen AND v.MaDiemDon = ctt_v_don.MaDiaDiem
      JOIN CHI_TIET_TUYEN ctt_v_tra ON c.MaTuyen = ctt_v_tra.MaTuyen AND v.MaDiemTra = ctt_v_tra.MaDiaDiem
      WHERE d.MaChuyen = c.MaChuyen
        AND v.MaCho = cn.MaCho
        AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
        -- Điều kiện chồng lấn đoạn: (ThuTuDon < v_tra) AND (ThuTuTra > v_don)
        AND @ThuTuDon < ctt_v_tra.ThuTu
        AND @ThuTuTra > ctt_v_don.ThuTu
  )
ORDER BY cn.MaCho;
GO

-- Câu 33: Tìm những chỗ đã được bán cho một đoạn nhưng vẫn có thể bán cho đoạn khác không chồng lấn trên cùng chuyến.
-- (Ví dụ: Trên chuyến C01, tìm các chỗ đã bán một số chặng nhưng vẫn còn ít nhất 1 chặng cơ sở trống).
WITH DoanCoSo AS (
    SELECT c.MaChuyen, c.MaTuyen, c.BienSoXe,
           ctt1.ThuTu AS TuThuTu, ctt2.ThuTu AS DenThuTu
    FROM CHUYEN_XE c
    JOIN CHI_TIET_TUYEN ctt1 ON c.MaTuyen = ctt1.MaTuyen
    JOIN CHI_TIET_TUYEN ctt2 ON c.MaTuyen = ctt2.MaTuyen AND ctt2.ThuTu = ctt1.ThuTu + 1
    WHERE c.MaChuyen = 'C01'
),
ChoDoanDaBan AS (
    SELECT DISTINCT d.MaChuyen, v.MaCho, dcs.TuThuTu
    FROM DAT_CHO d
    JOIN VE v ON d.MaDatCho = v.MaDatCho
    JOIN CHUYEN_XE c ON d.MaChuyen = c.MaChuyen
    JOIN CHI_TIET_TUYEN ctt_don ON c.MaTuyen = ctt_don.MaTuyen AND v.MaDiemDon = ctt_don.MaDiaDiem
    JOIN CHI_TIET_TUYEN ctt_tra ON c.MaTuyen = ctt_tra.MaTuyen AND v.MaDiemTra = ctt_tra.MaDiaDiem
    JOIN DoanCoSo dcs ON dcs.MaChuyen = d.MaChuyen 
                     AND dcs.TuThuTu >= ctt_don.ThuTu 
                     AND dcs.DenThuTu <= ctt_tra.ThuTu
    WHERE v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
)
SELECT cn.MaCho, 
       COUNT(DISTINCT cddb.TuThuTu) AS SoDoanCoSoDaBan,
       (SELECT COUNT(*) FROM DoanCoSo) - COUNT(DISTINCT cddb.TuThuTu) AS SoDoanCoSoConTrong
FROM CHO_NGOI cn
JOIN CHUYEN_XE c ON cn.BienSoXe = c.BienSoXe AND c.MaChuyen = 'C01'
JOIN ChoDoanDaBan cddb ON cn.MaCho = cddb.MaCho
GROUP BY cn.MaCho
HAVING COUNT(DISTINCT cddb.TuThuTu) > 0 
   AND COUNT(DISTINCT cddb.TuThuTu) < (SELECT COUNT(*) FROM DoanCoSo)
ORDER BY cn.MaCho;
GO

-- Câu 34: Liệt kê theo thời gian các hành khách lần lượt sử dụng cùng một chỗ trong một chuyến (ví dụ chuyến 'C01').
SELECT v.MaCho, ctt_don.ThuTu AS ThuTuDon, ctt_tra.ThuTu AS ThuTuTra,
       dd_don.TenDiaDiem AS DiemDon, dd_tra.TenDiaDiem AS DiemTra,
       v.HoTenNguoiDi, v.SoDienThoaiNguoiDi, v.GiaBanThucTe
FROM VE v
JOIN DAT_CHO d ON v.MaDatCho = d.MaDatCho
JOIN CHUYEN_XE c ON d.MaChuyen = c.MaChuyen
JOIN CHI_TIET_TUYEN ctt_don ON c.MaTuyen = ctt_don.MaTuyen AND v.MaDiemDon = ctt_don.MaDiaDiem
JOIN CHI_TIET_TUYEN ctt_tra ON c.MaTuyen = ctt_tra.MaTuyen AND v.MaDiemTra = ctt_tra.MaDiaDiem
JOIN DIA_DIEM dd_don ON v.MaDiemDon = dd_don.MaDiaDiem
JOIN DIA_DIEM dd_tra ON v.MaDiemTra = dd_tra.MaDiaDiem
WHERE d.MaChuyen = 'C01'
  AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
ORDER BY v.MaCho, ctt_don.ThuTu ASC;
GO

-- Câu 35: PHÁT HIỆN HAI VÉ CÓ HIỆU LỰC SỬ DỤNG CÙNG MỘT CHỖ TRÊN CÁC ĐOẠN HÀNH TRÌNH BỊ CHỒNG LẤN.
-- (Nếu CSDL hợp lệ và chuẩn toàn vẹn, truy vấn này bắt buộc phải trả về 0 dòng).
SELECT v1.MaVe AS MaVe1, v2.MaVe AS MaVe2,
       c.MaChuyen, v1.MaCho,
       dd1_don.TenDiaDiem AS V1_Don, dd1_tra.TenDiaDiem AS V1_Tra,
       dd2_don.TenDiaDiem AS V2_Don, dd2_tra.TenDiaDiem AS V2_Tra
FROM VE v1
JOIN DAT_CHO d1 ON v1.MaDatCho = d1.MaDatCho
JOIN CHUYEN_XE c ON d1.MaChuyen = c.MaChuyen
JOIN VE v2 ON v1.MaCho = v2.MaCho AND v1.BienSoXe = v2.BienSoXe AND v1.MaVe < v2.MaVe
JOIN DAT_CHO d2 ON v2.MaDatCho = d2.MaDatCho AND d2.MaChuyen = c.MaChuyen
JOIN CHI_TIET_TUYEN ctt1_don ON c.MaTuyen = ctt1_don.MaTuyen AND v1.MaDiemDon = ctt1_don.MaDiaDiem
JOIN CHI_TIET_TUYEN ctt1_tra ON c.MaTuyen = ctt1_tra.MaTuyen AND v1.MaDiemTra = ctt1_tra.MaDiaDiem
JOIN CHI_TIET_TUYEN ctt2_don ON c.MaTuyen = ctt2_don.MaTuyen AND v2.MaDiemDon = ctt2_don.MaDiaDiem
JOIN CHI_TIET_TUYEN ctt2_tra ON c.MaTuyen = ctt2_tra.MaTuyen AND v2.MaDiemTra = ctt2_tra.MaDiaDiem
JOIN DIA_DIEM dd1_don ON v1.MaDiemDon = dd1_don.MaDiaDiem
JOIN DIA_DIEM dd1_tra ON v1.MaDiemTra = dd1_tra.MaDiaDiem
JOIN DIA_DIEM dd2_don ON v2.MaDiemDon = dd2_don.MaDiaDiem
JOIN DIA_DIEM dd2_tra ON v2.MaDiemTra = dd2_tra.MaDiaDiem
WHERE v1.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
  AND v2.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
  -- Điều kiện vi phạm chồng lấn:
  AND ctt1_don.ThuTu < ctt2_tra.ThuTu
  AND ctt1_tra.ThuTu > ctt2_don.ThuTu;
GO

-- Câu 36: Tìm cặp điểm đón - điểm trả được mua nhiều nhất.
SELECT TOP 1 WITH TIES 
       dd_don.TenDiaDiem AS DiemDon, 
       dd_tra.TenDiaDiem AS DiemTra,
       COUNT(v.MaVe) AS SoVeDaMua
FROM VE v
JOIN DIA_DIEM dd_don ON v.MaDiemDon = dd_don.MaDiaDiem
JOIN DIA_DIEM dd_tra ON v.MaDiemTra = dd_tra.MaDiaDiem
WHERE v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY dd_don.TenDiaDiem, dd_tra.TenDiaDiem
ORDER BY SoVeDaMua DESC;
GO

-- Câu 37: Tìm điểm có nhiều hành khách lên xe nhất.
SELECT TOP 1 WITH TIES 
       dd.MaDiaDiem, dd.TenDiaDiem, dd.TinhThanh,
       COUNT(v.MaVe) AS SoKhachLenXe
FROM VE v
JOIN DIA_DIEM dd ON v.MaDiemDon = dd.MaDiaDiem
WHERE v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY dd.MaDiaDiem, dd.TenDiaDiem, dd.TinhThanh
ORDER BY SoKhachLenXe DESC;
GO

-- Câu 38: Tìm điểm có nhiều hành khách xuống xe nhất.
SELECT TOP 1 WITH TIES 
       dd.MaDiaDiem, dd.TenDiaDiem, dd.TinhThanh,
       COUNT(v.MaVe) AS SoKhachXuongXe
FROM VE v
JOIN DIA_DIEM dd ON v.MaDiemTra = dd.MaDiaDiem
WHERE v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
GROUP BY dd.MaDiaDiem, dd.TenDiaDiem, dd.TinhThanh
ORDER BY SoKhachXuongXe DESC;
GO

-- Câu 39: Tìm chuyến có tỷ lệ hủy vé cao hơn tỷ lệ hủy trung bình của toàn hệ thống.
WITH TyLeHuyToanHeThong AS (
    SELECT CAST(SUM(CASE WHEN TrangThai = N'Đã hủy' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS TyLeTrungBinh
    FROM VE
),
ThongKeChuyen AS (
    SELECT c.MaChuyen, t.TenTuyen,
           COUNT(v.MaVe) AS TongVe,
           SUM(CASE WHEN v.TrangThai = N'Đã hủy' THEN 1 ELSE 0 END) AS SoVeHuy,
           CAST(SUM(CASE WHEN v.TrangThai = N'Đã hủy' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(v.MaVe) AS TyLeHuyChuyen
    FROM CHUYEN_XE c
    JOIN TUYEN_XE t ON c.MaTuyen = t.MaTuyen
    JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
    JOIN VE v ON d.MaDatCho = v.MaDatCho
    GROUP BY c.MaChuyen, t.TenTuyen
    HAVING COUNT(v.MaVe) > 0
)
SELECT tkc.MaChuyen, tkc.TenTuyen, tkc.TongVe, tkc.SoVeHuy,
       ROUND(tkc.TyLeHuyChuyen * 100, 2) AS PhanTramHuyChuyen,
       ROUND(tlht.TyLeTrungBinh * 100, 2) AS PhanTramHuyTrungBinh
FROM ThongKeChuyen tkc
CROSS JOIN TyLeHuyToanHeThong tlht
WHERE tkc.TyLeHuyChuyen > tlht.TyLeTrungBinh
ORDER BY tkc.TyLeHuyChuyen DESC;
GO

-- Câu 40: Tìm khách hàng đã hủy từ 3 vé trở lên.
SELECT kh.MaKhachHang, kh.HoTen, kh.SoDienThoai,
       COUNT(v.MaVe) AS SoVeDaHuy
FROM KHACH_HANG kh
JOIN DAT_CHO d ON kh.MaKhachHang = d.MaKhachHang
JOIN VE v ON d.MaDatCho = v.MaDatCho
WHERE v.TrangThai = N'Đã hủy'
GROUP BY kh.MaKhachHang, kh.HoTen, kh.SoDienThoai
HAVING COUNT(v.MaVe) >= 3
ORDER BY SoVeDaHuy DESC;
GO

-- -----------------------------------------------------------------------------
-- NHÓM E. WINDOW FUNCTION (CÂU 41 -> CÂU 48)
-- -----------------------------------------------------------------------------

-- Câu 41: Xếp hạng các chuyến theo doanh thu trong từng tuyến.
WITH DoanhThuChuyen AS (
    SELECT c.MaTuyen, c.MaChuyen, c.ThoiDiemKhoiHanh,
           ISNULL(SUM(v.GiaBanThucTe), 0) AS DoanhThu
    FROM CHUYEN_XE c
    LEFT JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
    LEFT JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
    GROUP BY c.MaTuyen, c.MaChuyen, c.ThoiDiemKhoiHanh
)
SELECT MaTuyen, MaChuyen, ThoiDiemKhoiHanh, DoanhThu,
       DENSE_RANK() OVER (PARTITION BY MaTuyen ORDER BY DoanhThu DESC) AS XepHangDoanhThu
FROM DoanhThuChuyen
ORDER BY MaTuyen, XepHangDoanhThu;
GO

-- Câu 42: Tìm top 3 chuyến có doanh thu cao nhất của mỗi nhà xe.
WITH DoanhThuNhaXeChuyen AS (
    SELECT nx.MaNhaXe, nx.TenNhaXe, c.MaChuyen,
           ISNULL(SUM(v.GiaBanThucTe), 0) AS DoanhThu,
           DENSE_RANK() OVER (PARTITION BY nx.MaNhaXe ORDER BY ISNULL(SUM(v.GiaBanThucTe), 0) DESC) AS Hang
    FROM NHA_XE nx
    JOIN TUYEN_XE t ON nx.MaNhaXe = t.MaNhaXe
    JOIN CHUYEN_XE c ON t.MaTuyen = c.MaTuyen
    LEFT JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
    LEFT JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
    GROUP BY nx.MaNhaXe, nx.TenNhaXe, c.MaChuyen
)
SELECT MaNhaXe, TenNhaXe, MaChuyen, DoanhThu, Hang
FROM DoanhThuNhaXeChuyen
WHERE Hang <= 3
ORDER BY MaNhaXe, Hang;
GO

-- Câu 43: Tìm top 3 khách hàng có tổng chi tiêu lớn nhất của mỗi nhà xe.
WITH ChiTieuKhachTheoNhaXe AS (
    SELECT nx.MaNhaXe, nx.TenNhaXe, kh.MaKhachHang, kh.HoTen,
           SUM(v.GiaBanThucTe) AS TongChiTieu,
           DENSE_RANK() OVER (PARTITION BY nx.MaNhaXe ORDER BY SUM(v.GiaBanThucTe) DESC) AS Hang
    FROM NHA_XE nx
    JOIN TUYEN_XE t ON nx.MaNhaXe = t.MaNhaXe
    JOIN CHUYEN_XE c ON t.MaTuyen = c.MaTuyen
    JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
    JOIN KHACH_HANG kh ON d.MaKhachHang = kh.MaKhachHang
    JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
    GROUP BY nx.MaNhaXe, nx.TenNhaXe, kh.MaKhachHang, kh.HoTen
)
SELECT MaNhaXe, TenNhaXe, MaKhachHang, HoTen, TongChiTieu, Hang
FROM ChiTieuKhachTheoNhaXe
WHERE Hang <= 3
ORDER BY MaNhaXe, Hang;
GO

-- Câu 44: Xếp hạng các tuyến theo doanh thu.
WITH DoanhThuTuyen AS (
    SELECT t.MaTuyen, t.TenTuyen,
           ISNULL(SUM(v.GiaBanThucTe), 0) AS TongDoanhThu
    FROM TUYEN_XE t
    LEFT JOIN CHUYEN_XE c ON t.MaTuyen = c.MaTuyen
    LEFT JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
    LEFT JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
    GROUP BY t.MaTuyen, t.TenTuyen
)
SELECT MaTuyen, TenTuyen, TongDoanhThu,
       RANK() OVER (ORDER BY TongDoanhThu DESC) AS XepHang_RANK,
       DENSE_RANK() OVER (ORDER BY TongDoanhThu DESC) AS XepHang_DENSE_RANK
FROM DoanhThuTuyen
ORDER BY TongDoanhThu DESC;
GO

-- Câu 45: Tìm chuyến có doanh thu cao nhất từng tháng.
WITH DoanhThuChuyenThang AS (
    SELECT YEAR(c.ThoiDiemKhoiHanh) AS Nam,
           MONTH(c.ThoiDiemKhoiHanh) AS Thang,
           c.MaChuyen,
           ISNULL(SUM(v.GiaBanThucTe), 0) AS DoanhThu,
           ROW_NUMBER() OVER (
               PARTITION BY YEAR(c.ThoiDiemKhoiHanh), MONTH(c.ThoiDiemKhoiHanh) 
               ORDER BY ISNULL(SUM(v.GiaBanThucTe), 0) DESC
           ) AS Hang
    FROM CHUYEN_XE c
    JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
    JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
    GROUP BY YEAR(c.ThoiDiemKhoiHanh), MONTH(c.ThoiDiemKhoiHanh), c.MaChuyen
)
SELECT Nam, Thang, MaChuyen, DoanhThu
FROM DoanhThuChuyenThang
WHERE Hang = 1
ORDER BY Nam, Thang;
GO

-- Câu 46: So sánh doanh thu từng tháng với tháng trước bằng LAG.
WITH DoanhThuTheoThang AS (
    SELECT YEAR(c.ThoiDiemKhoiHanh) AS Nam,
           MONTH(c.ThoiDiemKhoiHanh) AS Thang,
           SUM(v.GiaBanThucTe) AS DoanhThu
    FROM CHUYEN_XE c
    JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
    JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
    GROUP BY YEAR(c.ThoiDiemKhoiHanh), MONTH(c.ThoiDiemKhoiHanh)
)
SELECT Nam, Thang, DoanhThu,
       LAG(DoanhThu, 1, 0) OVER (ORDER BY Nam, Thang) AS DoanhThuThangTruoc,
       DoanhThu - LAG(DoanhThu, 1, 0) OVER (ORDER BY Nam, Thang) AS ChenhLech,
       CASE 
           WHEN LAG(DoanhThu, 1, 0) OVER (ORDER BY Nam, Thang) = 0 THEN NULL
           ELSE ROUND(((DoanhThu - LAG(DoanhThu, 1, 0) OVER (ORDER BY Nam, Thang)) * 100.0) / LAG(DoanhThu, 1, 0) OVER (ORDER BY Nam, Thang), 2)
       END AS PhanTramTangTruong
FROM DoanhThuTheoThang
ORDER BY Nam, Thang;
GO

-- Câu 47: Tính doanh thu lũy kế theo thời gian.
WITH DoanhThuTheoNgay AS (
    SELECT CAST(c.ThoiDiemKhoiHanh AS DATE) AS Ngay,
           SUM(v.GiaBanThucTe) AS DoanhThuNgay
    FROM CHUYEN_XE c
    JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
    JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
    GROUP BY CAST(c.ThoiDiemKhoiHanh AS DATE)
)
SELECT Ngay, DoanhThuNgay,
       SUM(DoanhThuNgay) OVER (ORDER BY Ngay ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS DoanhThuLuyKe
FROM DoanhThuTheoNgay
ORDER BY Ngay;
GO

-- Câu 48: Tìm hai chuyến liên tiếp của mỗi xe và khoảng thời gian nghỉ giữa hai chuyến (dùng LEAD/LAG).
WITH ChuyenLienTiep AS (
    SELECT c.BienSoXe, c.MaChuyen AS ChuyenHienTai,
           c.ThoiDiemKhoiHanh AS KhoiHanhHienTai,
           c.ThoiDiemDuKienKetThuc AS KetThucHienTai,
           LEAD(c.MaChuyen) OVER (PARTITION BY c.BienSoXe ORDER BY c.ThoiDiemKhoiHanh) AS ChuyenKeTiep,
           LEAD(c.ThoiDiemKhoiHanh) OVER (PARTITION BY c.BienSoXe ORDER BY c.ThoiDiemKhoiHanh) AS KhoiHanhKeTiep
    FROM CHUYEN_XE c
)
SELECT BienSoXe, ChuyenHienTai, KetThucHienTai, ChuyenKeTiep, KhoiHanhKeTiep,
       DATEDIFF(MINUTE, KetThucHienTai, KhoiHanhKeTiep) AS ThoiGianNghiPhut
FROM ChuyenLienTiep
WHERE ChuyenKeTiep IS NOT NULL
ORDER BY BienSoXe, KhoiHanhHienTai;
GO

-- -----------------------------------------------------------------------------
-- NHÓM VII. CÁCH TÍNH TỶ LỆ KHAI THÁC CHỖ THEO ĐƠN VỊ CHỖ-ĐOẠN (CÂU 49 -> CÂU 52)
-- -----------------------------------------------------------------------------
-- Đơn vị: Chỗ-đoạn. 
-- Tuyến có N điểm -> (N - 1) đoạn cơ sở. Xe có S chỗ -> Năng lực khả dụng = S x (N - 1) chỗ-đoạn.
-- Mỗi vé đi từ Đón (thứ tự d) đến Trả (thứ tự t) chiếm (t - d) chỗ-đoạn.
-- Tỷ lệ khai thác = (Tổng chỗ-đoạn đã bán / Năng lực khả dụng) * 100%

-- Câu 49: Tính tỷ lệ khai thác của từng chuyến.
WITH NangLucChuyen AS (
    SELECT c.MaChuyen, c.MaTuyen, c.BienSoXe, x.SoChoThietKe,
           (SELECT COUNT(*) - 1 FROM CHI_TIET_TUYEN WHERE MaTuyen = c.MaTuyen) AS SoDoanCoSo,
           x.SoChoThietKe * (SELECT COUNT(*) - 1 FROM CHI_TIET_TUYEN WHERE MaTuyen = c.MaTuyen) AS TongChoDoanKhaDung
    FROM CHUYEN_XE c
    JOIN XE x ON c.BienSoXe = x.BienSoXe
),
ChoDoanDaBan AS (
    SELECT c.MaChuyen,
           ISNULL(SUM(ctt_tra.ThuTu - ctt_don.ThuTu), 0) AS TongChoDoanDaBan
    FROM CHUYEN_XE c
    LEFT JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
    LEFT JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
    LEFT JOIN CHI_TIET_TUYEN ctt_don ON c.MaTuyen = ctt_don.MaTuyen AND v.MaDiemDon = ctt_don.MaDiaDiem
    LEFT JOIN CHI_TIET_TUYEN ctt_tra ON c.MaTuyen = ctt_tra.MaTuyen AND v.MaDiemTra = ctt_tra.MaDiaDiem
    GROUP BY c.MaChuyen
)
SELECT nlc.MaChuyen, nlc.MaTuyen, nlc.BienSoXe, nlc.SoChoThietKe, nlc.SoDoanCoSo,
       nlc.TongChoDoanKhaDung,
       cddb.TongChoDoanDaBan,
       ROUND((CAST(cddb.TongChoDoanDaBan AS FLOAT) / NULLIF(nlc.TongChoDoanKhaDung, 0)) * 100.0, 2) AS TyLeKhaiThacPhanTram
FROM NangLucChuyen nlc
JOIN ChoDoanDaBan cddb ON nlc.MaChuyen = cddb.MaChuyen
ORDER BY TyLeKhaiThacPhanTram DESC;
GO

-- Câu 50: Tìm chuyến có tỷ lệ khai thác cao nhất.
WITH TyLeKhaiThacAll AS (
    SELECT c.MaChuyen, c.MaTuyen,
           ROUND((CAST(ISNULL(SUM(ctt_tra.ThuTu - ctt_don.ThuTu), 0) AS FLOAT) / 
                  (x.SoChoThietKe * (SELECT COUNT(*) - 1 FROM CHI_TIET_TUYEN WHERE MaTuyen = c.MaTuyen))) * 100.0, 2) AS TyLeKhaiThac
    FROM CHUYEN_XE c
    JOIN XE x ON c.BienSoXe = x.BienSoXe
    LEFT JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
    LEFT JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
    LEFT JOIN CHI_TIET_TUYEN ctt_don ON c.MaTuyen = ctt_don.MaTuyen AND v.MaDiemDon = ctt_don.MaDiaDiem
    LEFT JOIN CHI_TIET_TUYEN ctt_tra ON c.MaTuyen = ctt_tra.MaTuyen AND v.MaDiemTra = ctt_tra.MaDiaDiem
    GROUP BY c.MaChuyen, c.MaTuyen, x.SoChoThietKe
)
SELECT TOP 1 WITH TIES MaChuyen, MaTuyen, TyLeKhaiThac
FROM TyLeKhaiThacAll
ORDER BY TyLeKhaiThac DESC;
GO

-- Câu 51: Tính tỷ lệ khai thác trung bình của từng tuyến.
WITH TyLeTungChuyen AS (
    SELECT c.MaTuyen, c.MaChuyen,
           (CAST(ISNULL(SUM(ctt_tra.ThuTu - ctt_don.ThuTu), 0) AS FLOAT) / 
            NULLIF(x.SoChoThietKe * (SELECT COUNT(*) - 1 FROM CHI_TIET_TUYEN WHERE MaTuyen = c.MaTuyen), 0)) * 100.0 AS TyLeChuyen
    FROM CHUYEN_XE c
    JOIN XE x ON c.BienSoXe = x.BienSoXe
    LEFT JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
    LEFT JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
    LEFT JOIN CHI_TIET_TUYEN ctt_don ON c.MaTuyen = ctt_don.MaTuyen AND v.MaDiemDon = ctt_don.MaDiaDiem
    LEFT JOIN CHI_TIET_TUYEN ctt_tra ON c.MaTuyen = ctt_tra.MaTuyen AND v.MaDiemTra = ctt_tra.MaDiaDiem
    GROUP BY c.MaTuyen, c.MaChuyen, x.SoChoThietKe
)
SELECT t.MaTuyen, t.TenTuyen,
       ROUND(AVG(ISNULL(tc.TyLeChuyen, 0)), 2) AS TyLeKhaiThacTrungBinhPhanTram
FROM TUYEN_XE t
LEFT JOIN TyLeTungChuyen tc ON t.MaTuyen = tc.MaTuyen
GROUP BY t.MaTuyen, t.TenTuyen
ORDER BY TyLeKhaiThacTrungBinhPhanTram DESC;
GO

-- Câu 52: Tìm tuyến có tỷ lệ khai thác trung bình cao nhất.
WITH TyLeTungChuyen AS (
    SELECT c.MaTuyen, c.MaChuyen,
           (CAST(ISNULL(SUM(ctt_tra.ThuTu - ctt_don.ThuTu), 0) AS FLOAT) / 
            NULLIF(x.SoChoThietKe * (SELECT COUNT(*) - 1 FROM CHI_TIET_TUYEN WHERE MaTuyen = c.MaTuyen), 0)) * 100.0 AS TyLeChuyen
    FROM CHUYEN_XE c
    JOIN XE x ON c.BienSoXe = x.BienSoXe
    LEFT JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
    LEFT JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
    LEFT JOIN CHI_TIET_TUYEN ctt_don ON c.MaTuyen = ctt_don.MaTuyen AND v.MaDiemDon = ctt_don.MaDiaDiem
    LEFT JOIN CHI_TIET_TUYEN ctt_tra ON c.MaTuyen = ctt_tra.MaTuyen AND v.MaDiemTra = ctt_tra.MaDiaDiem
    GROUP BY c.MaTuyen, c.MaChuyen, x.SoChoThietKe
),
TyLeTrungBinhTuyen AS (
    SELECT t.MaTuyen, t.TenTuyen,
           ROUND(AVG(ISNULL(tc.TyLeChuyen, 0)), 2) AS TyLeKhaiThacTrungBinhPhanTram
    FROM TUYEN_XE t
    LEFT JOIN TyLeTungChuyen tc ON t.MaTuyen = tc.MaTuyen
    GROUP BY t.MaTuyen, t.TenTuyen
)
SELECT TOP 1 WITH TIES MaTuyen, TenTuyen, TyLeKhaiThacTrungBinhPhanTram AS TyLeCaoNhatPhanTram
FROM TyLeTrungBinhTuyen
ORDER BY TyLeCaoNhatPhanTram DESC;
GO

-- =============================================================================
-- HOÀN TẤT TOÀN BỘ SCRIPT CSDL VÀ 52 CÂU TRUY VẤN SQL!
-- =============================================================================
