-- =============================================================================
-- BÀI TẬP 06: CHUYÊN ĐỀ HÀM CỬA SỔ (WINDOW FUNCTIONS & ADVANCED ANALYTICS)
-- Kỹ thuật phân tích dữ liệu lớn: ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, CUMULATIVE SUM
-- =============================================================================

USE HeThongDatVeXeOnline;
GO

-- 1. SO SÁNH DOANH THU THÁNG HIỆN TẠI VỚI THÁNG TRƯỚC SỬ DỤNG LAG()
WITH DoanhThuThang AS (
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
       DoanhThu - LAG(DoanhThu, 1, 0) OVER (ORDER BY Nam, Thang) AS TangTruongGiaTri,
       ROUND(((DoanhThu - LAG(DoanhThu, 1, 0) OVER (ORDER BY Nam, Thang)) * 100.0) / 
             NULLIF(LAG(DoanhThu, 1, 0) OVER (ORDER BY Nam, Thang), 0), 2) AS PhanTramTangTruong
FROM DoanhThuThang;
GO

-- 2. TÍNH DOANH THU TÍCH LŨY (CUMULATIVE RUNNING TOTAL)
WITH DoanhThuNgay AS (
    SELECT CAST(c.ThoiDiemKhoiHanh AS DATE) AS Ngay,
           SUM(v.GiaBanThucTe) AS DoanhThuNgay
    FROM CHUYEN_XE c
    JOIN DAT_CHO d ON c.MaChuyen = d.MaChuyen
    JOIN VE v ON d.MaDatCho = v.MaDatCho AND v.TrangThai IN (N'Có hiệu lực', N'Đã sử dụng')
    GROUP BY CAST(c.ThoiDiemKhoiHanh AS DATE)
)
SELECT Ngay, DoanhThuNgay,
       SUM(DoanhThuNgay) OVER (ORDER BY Ngay ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS DoanhThuLuyKe
FROM DoanhThuNgay;
GO

-- 3. TÌM KHOẢNG THỜI GIAN NGHỈ GIỮA 2 CHUYẾN LIÊN TIẾP CỦA XE SỬ DỤNG LEAD()
WITH ChuyenLienTiep AS (
    SELECT c.BienSoXe, c.MaChuyen AS ChuyenHienTai,
           c.ThoiDiemDuKienKetThuc AS GioKetThucHienTai,
           LEAD(c.MaChuyen) OVER (PARTITION BY c.BienSoXe ORDER BY c.ThoiDiemKhoiHanh) AS ChuyenKeTiep,
           LEAD(c.ThoiDiemKhoiHanh) OVER (PARTITION BY c.BienSoXe ORDER BY c.ThoiDiemKhoiHanh) AS GioKhoiHanhKeTiep
    FROM CHUYEN_XE c
)
SELECT BienSoXe, ChuyenHienTai, GioKetThucHienTai, ChuyenKeTiep, GioKhoiHanhKeTiep,
       DATEDIFF(MINUTE, GioKetThucHienTai, GioKhoiHanhKeTiep) AS ThoiGianNghiPhut
FROM ChuyenLienTiep
WHERE ChuyenKeTiep IS NOT NULL;
GO
