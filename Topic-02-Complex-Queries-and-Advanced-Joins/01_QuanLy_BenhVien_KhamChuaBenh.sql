-- =============================================================================
-- BÀI TẬP 03: QUẢN LÝ KHÁM CHỮA BỆNH TẠI BỆNH VIỆN (QuanLyBenhVien)
-- Kỹ thuật: Multi-table JOIN, Subqueries (EXISTS, NOT EXISTS, IN, ALL, ANY), GROUP BY & HAVING
-- =============================================================================

USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLyBenhVien')
    DROP DATABASE QuanLyBenhVien;
GO
CREATE DATABASE QuanLyBenhVien;
GO
USE QuanLyBenhVien;
GO

CREATE TABLE Khoa (
    MaKhoa VARCHAR(10) PRIMARY KEY,
    TenKhoa NVARCHAR(100) NOT NULL,
    TruongKhoa NVARCHAR(100) NULL
);
GO

CREATE TABLE BacSi (
    MaBS VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    ChuyenMon NVARCHAR(100) NOT NULL,
    MaKhoa VARCHAR(10) FOREIGN KEY REFERENCES Khoa(MaKhoa)
);
GO

CREATE TABLE BenhNhan (
    MaBN VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE NOT NULL,
    GioiTinh NVARCHAR(5) CHECK (GioiTinh IN (N'Nam', N'Nữ')),
    DiaChi NVARCHAR(200) NULL,
    SoBHYT VARCHAR(20) NULL
);
GO

CREATE TABLE LanKham (
    MaKham VARCHAR(10) PRIMARY KEY,
    MaBN VARCHAR(10) FOREIGN KEY REFERENCES BenhNhan(MaBN),
    MaBS VARCHAR(10) FOREIGN KEY REFERENCES BacSi(MaBS),
    NgayKham DATE NOT NULL,
    ChuanDoan NVARCHAR(200) NOT NULL,
    TienKham DECIMAL(12,2) DEFAULT 150000
);
GO

CREATE TABLE DonThuoc (
    MaKham VARCHAR(10) FOREIGN KEY REFERENCES LanKham(MaKham),
    TenThuoc NVARCHAR(100) NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong > 0),
    DonGia DECIMAL(12,2) NOT NULL CHECK (DonGia >= 0),
    PRIMARY KEY (MaKham, TenThuoc)
);
GO

-- INSERT DỮ LIỆU MẪU
INSERT INTO Khoa VALUES ('K01', N'Nội Tổng Quát', N'BS.CKII Nguyễn Văn An'), ('K02', N'Ngoại Thần Kinh', N'TS. Lê Hoàng');
INSERT INTO BacSi VALUES ('BS01', N'Nguyễn Văn An', N'Nội khoa', 'K01'), ('BS02', N'Trần Thị Mai', N'Tim mạch', 'K01'), ('BS03', N'Lê Hoàng', N'Phẫu thuật', 'K02');
INSERT INTO BenhNhan VALUES 
('BN01', N'Phạm Văn Nam', '1980-05-15', N'Nam', N'Quận 1, TP.HCM', 'BHYT001'),
('BN02', N'Đỗ Thị Hoa', '1992-10-20', N'Nữ', N'Quận 5, TP.HCM', 'BHYT002'),
('BN03', N'Vũ Đình Khoa', '2005-02-12', N'Nam', N'Thủ Đức, TP.HCM', NULL);

INSERT INTO LanKham VALUES 
('LK01', 'BN01', 'BS01', '2026-09-10', N'Viêm phế quản cấp', 200000),
('LK02', 'BN02', 'BS02', '2026-09-15', N'Rối loạn nhịp tim', 250000),
('LK03', 'BN01', 'BS02', '2026-10-01', N'Tái khám tim mạch', 150000);

INSERT INTO DonThuoc VALUES 
('LK01', N'Paracetamol 500mg', 20, 2000),
('LK01', N'Amoxicillin 500mg', 14, 5000),
('LK02', N'Aspirin 81mg', 30, 3000);
GO

-- BỘ TRUY VẤN PHỨC HỢP:
-- 1. Tìm bệnh nhân chưa từng kê đơn thuốc (NOT EXISTS)
SELECT bn.MaBN, bn.HoTen, bn.SoBHYT
FROM BenhNhan bn
WHERE NOT EXISTS (
    SELECT 1 FROM LanKham lk JOIN DonThuoc dt ON lk.MaKham = dt.MaKham WHERE lk.MaBN = bn.MaBN
);

-- 2. Thống kê tổng tiền khám & thuốc của từng bệnh nhân (GROUP BY & SUM)
SELECT bn.MaBN, bn.HoTen, 
       COUNT(DISTINCT lk.MaKham) AS SoLanKham,
       ISNULL(SUM(lk.TienKham), 0) + ISNULL(SUM(dt.SoLuong * dt.DonGia), 0) AS TongChiPhi
FROM BenhNhan bn
LEFT JOIN LanKham lk ON bn.MaBN = lk.MaBN
LEFT JOIN DonThuoc dt ON lk.MaKham = dt.MaKham
GROUP BY bn.MaBN, bn.HoTen
ORDER BY TongChiPhi DESC;
GO
