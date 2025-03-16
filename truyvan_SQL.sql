USE BanHangQuaMang;
--Truy vấn SELECT
SELECT * FROM KhachHang;
SELECT TenSP, Gia FROM SanPham;
SELECT * FROM DonHang WHERE NgayDatHang > '2025-01-01';

-- Truy vấn UPDATE
UPDATE KhachHang SET DiaChi = 'Da Nang' WHERE MaKH = 1;
UPDATE SanPham SET Gia = 19000000 WHERE MaSanPham = 'LAP001';

-- Truy vấn DELETE
DELETE FROM ChiTietDonHang WHERE MaChiTiet = 1;
DELETE FROM KhachHang WHERE MaKH = 2;
go
--Truy vấn INNER JOIN :Lấy danh sách đơn hàng kèm theo thông tin khách hàng
SELECT DonHang.MaDH, KhachHang.TenKH, DonHang.NgayDatHang
FROM DonHang
INNER JOIN KhachHang ON DonHang.MaKH = KhachHang.MaKH;
go
--Lấy danh sách các sản phẩm trong từng đơn hàng
SELECT DonHang.MaDH, SanPham.TenSP, ChiTietDonHang.SoLuong, ChiTietDonHang.DonGia
FROM ChiTietDonHang
INNER JOIN DonHang ON ChiTietDonHang.MaDH = DonHang.MaDH
INNER JOIN SanPham ON ChiTietDonHang.MaSP = SanPham.MaSP;
go
-- GROUP BY:  Đếm số lượng đơn hàng của từng khách hàng
SELECT KhachHang.TenKH, COUNT(DonHang.MaDH) AS SoLuongDonHang
FROM DonHang
INNER JOIN KhachHang ON DonHang.MaKH = KhachHang.MaKH
GROUP BY KhachHang.TenKH;
go
-- Tổng số lượng sản phẩm đã bán theo từng sản phẩm
SELECT SanPham.TenSP, SUM(ChiTietDonHang.SoLuong) AS TongSoLuongBan
FROM ChiTietDonHang
INNER JOIN SanPham ON ChiTietDonHang.MaSP = SanPham.MaSP
GROUP BY SanPham.TenSP;
go
--HAVING : .Lấy danh sách sản phẩm có tổng doanh thu lớn hơn 10 triệu
SELECT SanPham.TenSP, SUM(ChiTietDonHang.SoLuong * ChiTietDonHang.DonGia) AS DoanhThu
FROM ChiTietDonHang
INNER JOIN SanPham ON ChiTietDonHang.MaSP = SanPham.MaSP
GROUP BY SanPham.TenSP
HAVING SUM(ChiTietDonHang.SoLuong * ChiTietDonHang.DonGia) > 10000000;
go
--SUBQUERY (Truy vấn con): Lấy sản phẩm có giá cao nhất
SELECT * 
FROM SanPham
WHERE Gia = (SELECT MAX(Gia) FROM SanPham);
go
--Lấy khách hàng có lần truy cập cuối cùng gần đây nhất
SELECT * 
FROM KhachHang
WHERE ThoiGianTruyCapCuoi = (SELECT MAX(ThoiGianTruyCapCuoi) FROM KhachHang);
go
---tạo 7-10 view từ cơ bản đến nâng cao
CREATE VIEW v_DanhSachKhachHang AS
SELECT MaKH, TenKH, DiaChi, Email, SoDienThoai FROM KhachHang;
SELECT * FROM v_DanhSachKhachHang;

CREATE VIEW v_DonHangChiTiet AS
SELECT dh.MaDH, kh.TenKH, dh.NgayDatHang, sp.TenSP, ctdh.SoLuong, ctdh.DonGia
FROM DonHang dh
INNER JOIN KhachHang kh ON dh.MaKH = kh.MaKH
INNER JOIN ChiTietDonHang ctdh ON dh.MaDH = ctdh.MaDH
INNER JOIN SanPham sp ON ctdh.MaSP = sp.MaSP;
SELECT * FROM v_DonHangChiTiet

CREATE VIEW v_TopSanPhamBanChay AS
SELECT sp.TenSP, SUM(ctdh.SoLuong) AS TongSoLuong
FROM ChiTietDonHang ctdh
INNER JOIN SanPham sp ON ctdh.MaSP = sp.MaSP
GROUP BY sp.TenSP
HAVING SUM(ctdh.SoLuong) > 5;
SELECT * FROM v_TopSanPhamBanChay;

CREATE VIEW v_DoanhThuTheoNgay AS
SELECT CONVERT(DATE, dh.NgayDatHang) AS Ngay, SUM(ctdh.SoLuong * ctdh.DonGia) AS DoanhThu
FROM DonHang dh
INNER JOIN ChiTietDonHang ctdh ON dh.MaDH = ctdh.MaDH
GROUP BY CONVERT(DATE, dh.NgayDatHang);
SELECT * FROM v_DoanhThuTheoNgay;

CREATE VIEW v_LichSuTruyCapKhachHang AS
SELECT kh.TenKH, ls.ThoiGian FROM LichSuTruyCap ls
INNER JOIN KhachHang kh ON ls.MaKH = kh.MaKH;
SELECT * FROM v_LichSuTruyCapKhachHang;

CREATE VIEW v_SanPhamGiaCao AS
SELECT TenSP, Gia FROM SanPham WHERE Gia > 10000000;
SELECT * FROM v_SanPhamGiaCao;

CREATE VIEW v_KhachHangVaSoDonHang AS
SELECT kh.TenKH, COUNT(dh.MaDH) AS SoDonHang
FROM KhachHang kh
LEFT JOIN DonHang dh ON kh.MaKH = dh.MaKH
GROUP BY kh.TenKH;
SELECT * FROM v_KhachHangVaSoDonHang;

