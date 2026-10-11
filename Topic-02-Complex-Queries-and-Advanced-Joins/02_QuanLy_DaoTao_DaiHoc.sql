-- =============================================================================
-- BÀI TẬP 04: QUẢN LÝ ĐÀO TẠO ĐẠI HỌC THEO HỌC CHẾ TÍN CHỈ (QL_DaoTaoDaiHoc)
-- Kỹ thuật: Phân cấp Khoa - Bộ môn - Giảng viên - Học phần - Đăng ký học tập
-- =============================================================================

USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QL_DaoTaoDaiHoc')
    DROP DATABASE QL_DaoTaoDaiHoc;
GO
CREATE DATABASE QL_DaoTaoDaiHoc;
GO
USE QL_DaoTaoDaiHoc;
GO

CREATE TABLE KHOA (
    MaKhoa VARCHAR(10) PRIMARY KEY,
    TenKhoa NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE BO_MON (
    MaBoMon VARCHAR(10) PRIMARY KEY,
    TenBoMon NVARCHAR(100) NOT NULL,
    MaKhoa VARCHAR(10) FOREIGN KEY REFERENCES KHOA(MaKhoa)
);
GO

CREATE TABLE GIANG_VIEN (
    MaGV VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    HocVi NVARCHAR(50) DEFAULT N'Thạc sĩ',
    MaBoMon VARCHAR(10) FOREIGN KEY REFERENCES BO_MON(MaBoMon)
);
GO

CREATE TABLE HOC_PHAN (
    MaHocPhan VARCHAR(10) PRIMARY KEY,
    TenHocPhan NVARCHAR(100) NOT NULL,
    SoTinChi INT CHECK (SoTinChi > 0),
    MaBoMon VARCHAR(10) FOREIGN KEY REFERENCES BO_MON(MaBoMon)
);
GO

CREATE TABLE LOP_HOC_PHAN (
    MaLopHP VARCHAR(20) PRIMARY KEY,
    MaHocPhan VARCHAR(10) FOREIGN KEY REFERENCES HOC_PHAN(MaHocPhan),
    MaGV VARCHAR(10) FOREIGN KEY REFERENCES GIANG_VIEN(MaGV),
    HocKy VARCHAR(10) NOT NULL,
    NamHoc VARCHAR(20) NOT NULL,
    SiSoToiDa INT DEFAULT 60
);
GO

INSERT INTO KHOA VALUES ('CNTT', N'Khoa Công nghệ Thông tin'), ('KHTN', N'Khoa Khoa học Tự nhiên');
INSERT INTO BO_MON VALUES ('HTTT', N'Hệ thống Thông tin', 'CNTT'), ('KHMT', N'Khoa học Máy tính', 'CNTT');
INSERT INTO GIANG_VIEN VALUES ('GV01', N'TS. Trần Minh Nhật', N'Tiến sĩ', 'HTTT'), ('GV02', N'ThS. Lê Thanh Tâm', N'Thạc sĩ', 'KHMT');
INSERT INTO HOC_PHAN VALUES ('HP01', N'Cơ sở Dữ liệu Nâng cao', 3, 'HTTT'), ('HP02', N'Hệ Quản trị CSDL', 3, 'HTTT');
INSERT INTO LOP_HOC_PHAN VALUES ('LHP_CSDL_01', 'HP01', 'GV01', 'HK1', '2026-2027', 60);
GO
