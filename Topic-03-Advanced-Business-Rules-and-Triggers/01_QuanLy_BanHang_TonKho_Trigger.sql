-- =============================================================================
-- BÀI TẬP 05: HỆ THỐNG QUẢN LÝ BÁN HÀNG & TRỪ TỒN KHO TỰ ĐỘNG (QuanLyBanHangVaKho)
-- Kỹ thuật nâng cao: AFTER INSERT/UPDATE TRIGGER, TRANSACTION ROLLBACK, RÀNG BUỘC TỒN KHO ÂM
-- =============================================================================

USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLyBanHangVaKho')
    DROP DATABASE QuanLyBanHangVaKho;
GO
CREATE DATABASE QuanLyBanHangVaKho;
GO
USE QuanLyBanHangVaKho;
GO

CREATE TABLE LOAI_SAN_PHAM (
    MaLoai VARCHAR(10) PRIMARY KEY,
    TenLoai NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE SAN_PHAM (
    MaSP VARCHAR(20) PRIMARY KEY,
    TenSP NVARCHAR(100) NOT NULL,
    MaLoai VARCHAR(10) FOREIGN KEY REFERENCES LOAI_SAN_PHAM(MaLoai),
    DonGiaBan DECIMAL(18,2) CHECK (DonGiaBan >= 0),
    TrangThai NVARCHAR(30) DEFAULT N'Đang kinh doanh'
);
GO

CREATE TABLE KHO (
    MaKho VARCHAR(10) PRIMARY KEY,
    TenKho NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(200) NULL
);
GO

CREATE TABLE TON_KHO (
    MaKho VARCHAR(10) NOT NULL FOREIGN KEY REFERENCES KHO(MaKho),
    MaSP VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES SAN_PHAM(MaSP),
    SoLuongTon INT NOT NULL DEFAULT 0,
    PRIMARY KEY (MaKho, MaSP),
    CONSTRAINT CK_TonKho_SoLuong CHECK (SoLuongTon >= 0) -- Ràng buộc không cho âm kho
);
GO

CREATE TABLE DON_HANG (
    MaDonHang VARCHAR(20) PRIMARY KEY,
    NgayDat DATETIME2 DEFAULT SYSDATETIME(),
    MaKhoXuat VARCHAR(10) FOREIGN KEY REFERENCES KHO(MaKho),
    TongTien DECIMAL(18,2) DEFAULT 0,
    TrangThai NVARCHAR(30) DEFAULT N'Chờ xử lý'
);
GO

CREATE TABLE CHI_TIET_DON_HANG (
    MaDonHang VARCHAR(20) FOREIGN KEY REFERENCES DON_HANG(MaDonHang),
    MaSP VARCHAR(20) FOREIGN KEY REFERENCES SAN_PHAM(MaSP),
    SoLuong INT CHECK (SoLuong > 0),
    DonGia DECIMAL(18,2) CHECK (DonGia >= 0),
    PRIMARY KEY (MaDonHang, MaSP)
);
GO

-- TRIGGER QUAN TRỌNG: TỰ ĐỘNG TRỪ TỒN KHO KHI PHÁT SINH CHI TIẾT ĐƠN HÀNG
CREATE TRIGGER TRG_ChiTietDonHang_TruKho
ON CHI_TIET_DON_HANG
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Kiểm tra nếu số lượng tồn trong kho không đủ đáp ứng
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN DON_HANG dh ON i.MaDonHang = dh.MaDonHang
        JOIN TON_KHO tk ON dh.MaKhoXuat = tk.MaKho AND i.MaSP = tk.MaSP
        WHERE tk.SoLuongTon < i.SoLuong
    )
    BEGIN
        RAISERROR (N'Lỗi: Số lượng tồn kho không đủ để xuất bán cho đơn hàng này!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Cập nhật trừ kho tự động
    UPDATE tk
    SET tk.SoLuongTon = tk.SoLuongTon - i.SoLuong
    FROM TON_KHO tk
    JOIN inserted i ON tk.MaSP = i.MaSP
    JOIN DON_HANG dh ON i.MaDonHang = dh.MaDonHang AND tk.MaKho = dh.MaKhoXuat;
END;
GO

-- DỮ LIỆU KIỂM THỬ TRIGGER
INSERT INTO LOAI_SAN_PHAM VALUES ('L01', N'Đồ uống đóng chai');
INSERT INTO SAN_PHAM VALUES ('SP01', N'Cà phê rang xay Robusta 500g', 'L01', 120000, N'Đang kinh doanh');
INSERT INTO KHO VALUES ('KHO_TONG', N'Kho Tổng Miền Nam', N'TP.HCM');
INSERT INTO TON_KHO VALUES ('KHO_TONG', 'SP01', 50);

-- Tạo đơn hàng
INSERT INTO DON_HANG VALUES ('DH001', SYSDATETIME(), 'KHO_TONG', 240000, N'Đã duyệt');

-- Bán 2 sản phẩm (Thành công -> kho còn 48)
INSERT INTO CHI_TIET_DON_HANG VALUES ('DH001', 'SP01', 2, 120000);

-- Kiểm tra tồn kho sau khi trừ:
SELECT tk.MaKho, sp.TenSP, tk.SoLuongTon
FROM TON_KHO tk JOIN SAN_PHAM sp ON tk.MaSP = sp.MaSP;
GO
