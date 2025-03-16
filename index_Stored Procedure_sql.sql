USE BanHangQuaMang;
---Tạo 7-10 index cần thiết cho các bảng
-- Index trên bảng Khách Hàng để tăng tốc tìm kiếm theo Email
CREATE INDEX IX_KhachHang_Email ON KhachHang(Email);

SELECT name, object_id, type_desc
FROM sys.indexes
WHERE object_id = OBJECT_ID('KhachHang');
-- Index trên bảng Sản Phẩm để hỗ trợ tìm kiếm nhanh theo Mã Sản Phẩm
CREATE INDEX IX_SanPham_MaSP ON SanPham(MaSanPham);

SELECT name, object_id, type_desc
FROM sys.indexes
WHERE object_id = OBJECT_ID('SanPham');
-- Index trên bảng Đơn Hàng để tối ưu tìm kiếm theo Mã Đơn Hàng
CREATE INDEX IX_DonHang_MaDH ON DonHang(MaDH);

-- Index trên bảng Chi Tiết Đơn Hàng để tăng tốc truy vấn theo Mã Đơn Hàng
CREATE INDEX IX_ChiTietDonHang_MaDH ON ChiTietDonHang(MaDH);

-- Index trên bảng Lịch Sử Truy Cập để tối ưu hóa truy vấn theo Mã Khách Hàng
CREATE INDEX IX_LichSuTruyCap_MaKH ON LichSuTruyCap(MaKH);

go
---Xây dựng 10 Stored Procedure(không tham số, có tham số, có OUTPUT)
-- 1. Lấy danh sách tất cả khách hàng
CREATE PROCEDURE sp_LayDanhSachKhachHang
AS
BEGIN
    SELECT * FROM KhachHang;
END;
GO
EXEC sp_LayDanhSachKhachHang;
-- 2. Lấy danh sách sản phẩm có giá trên mức chỉ định
CREATE PROCEDURE sp_LaySanPhamGiaCao
    @GiaMin DECIMAL(18,2)
AS
BEGIN
    SELECT * FROM SanPham WHERE Gia > @GiaMin;
END;
GO
EXEC sp_LaySanPhamGiaCao @GiaMin = 500000;
-- 3. Lấy đơn hàng của một khách hàng theo mã khách hàng
CREATE PROCEDURE sp_LayDonHangTheoKhachHang
    @MaKH INT
AS
BEGIN
    SELECT * FROM DonHang WHERE MaKH = @MaKH;
END;
GO
EXEC sp_LayDonHangTheoKhachHang @MaKH = 1;
-- 4. Thêm mới khách hàng
CREATE PROCEDURE sp_ThemKhachHang
    @TenKH NVARCHAR(100),
    @DiaChi NVARCHAR(255),
    @NoiNhanHang NVARCHAR(255),
    @SoDienThoai NVARCHAR(15),
    @Email NVARCHAR(100),
    @MatKhau NVARCHAR(255)
AS
BEGIN
    INSERT INTO KhachHang (TenKH, DiaChi, NoiNhanHang, SoDienThoai, Email, MatKhau, ThoiGianTruyCapCuoi)
    VALUES (@TenKH, @DiaChi, @NoiNhanHang, @SoDienThoai, @Email, @MatKhau, GETDATE());
END;
GO
EXEC sp_ThemKhachHang @TenKH = N'Nguyễn Văn C', @DiaChi = N'HCM', @NoiNhanHang = N'Quận Hoàn Kiếm',
                       @SoDienThoai = '0298767854', @Email = 'a@example.com', @MatKhau = '234213';
					   select * from KhachHang
-- 5. Cập nhật thông tin khách hàng
CREATE PROCEDURE sp_CapNhatThongTinKhachHang
    @MaKH INT,
    @TenKH NVARCHAR(100),
    @DiaChi NVARCHAR(255),
    @NoiNhanHang NVARCHAR(255),
    @SoDienThoai NVARCHAR(15),
    @Email NVARCHAR(100)
AS
BEGIN
    UPDATE KhachHang
    SET TenKH = @TenKH, DiaChi = @DiaChi, NoiNhanHang = @NoiNhanHang, 
        SoDienThoai = @SoDienThoai, Email = @Email
    WHERE MaKH = @MaKH;
END;
GO
EXEC sp_CapNhatThongTinKhachHang @MaKH = 1, @TenKH = N'Tran Thi B', @DiaChi = N'HCM',
                                 @NoiNhanHang = N'HCM', @SoDienThoai = '0988767897', @Email = 'b@example.com';
								 select * from KhachHang
-- 6. Xóa khách hàng theo mã khách hàng
CREATE PROCEDURE sp_XoaKhachHang
    @MaKH INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Xóa dữ liệu liên quan trong bảng ChiTietDonHang
    DELETE FROM ChiTietDonHang WHERE MaDH IN (SELECT MaDH FROM DonHang WHERE MaKH = @MaKH);

    -- Xóa dữ liệu liên quan trong bảng QuanLyDonHang
    DELETE FROM QuanLyDonHang WHERE MaDH IN (SELECT MaDH FROM DonHang WHERE MaKH = @MaKH);

    -- Xóa dữ liệu liên quan trong bảng DonHang
    DELETE FROM DonHang WHERE MaKH = @MaKH;

    -- Xóa dữ liệu liên quan trong bảng LichSuTruyCap
    DELETE FROM LichSuTruyCap WHERE MaKH = @MaKH;

    -- Xóa dữ liệu liên quan trong bảng TaiKhoanKhachHang
    DELETE FROM TaiKhoanKhachHang WHERE MaKH = @MaKH;

    -- Cuối cùng xóa khách hàng
    DELETE FROM KhachHang WHERE MaKH = @MaKH;
END;
GO
EXEC sp_XoaKhachHang @MaKH = 15;
select * from KhachHang
-- 7. Lấy doanh thu theo ngày
CREATE PROCEDURE sp_LayDoanhThuTheoNgay
    @Ngay DATE
AS
BEGIN
    SELECT SUM(ctdh.SoLuong * ctdh.DonGia) AS DoanhThu
    FROM DonHang dh
    INNER JOIN ChiTietDonHang ctdh ON dh.MaDH = ctdh.MaDH
    WHERE CONVERT(DATE, dh.NgayDatHang) = @Ngay;
END;
GO
EXEC sp_LayDoanhThuTheoNgay @Ngay = '2025-03-10';
-- 8. Thêm đơn hàng mới
CREATE PROCEDURE sp_ThemDonHang
    @MaKH INT,
    @MaDH INT OUTPUT
AS
BEGIN
    INSERT INTO DonHang (MaKH, NgayDatHang)
    VALUES (@MaKH, GETDATE());

    SET @MaDH = SCOPE_IDENTITY();
END;
GO
DECLARE @MaDH INT;
EXEC sp_ThemDonHang @MaKH = 2, @MaDH = @MaDH OUTPUT;
SELECT @MaDH AS 'Mã đơn hàng mới';
-- 9. Kiểm tra số lượng sản phẩm trong kho (giả định cột SoLuong tồn tại)
CREATE PROCEDURE sp_KiemTraSoLuongSanPham
    @MaSP INT,
    @SoLuongConLai INT OUTPUT
AS
BEGIN
    SELECT @SoLuongConLai = COUNT(*)
    FROM ChiTietDonHang
    WHERE MaSP = @MaSP;
END;
GO
DECLARE @SoLuongConLai INT;
EXEC sp_KiemTraSoLuongSanPham @MaSP = 3, @SoLuongConLai = @SoLuongConLai OUTPUT;
SELECT @SoLuongConLai AS 'Số lượng còn lại';
-- 10. Lấy danh sách khách hàng có số đơn hàng lớn hơn một giá trị chỉ định
CREATE PROCEDURE sp_LayKhachHangNhieuDonHang
    @SoDonHangMin INT
AS
BEGIN
    SELECT kh.MaKH, kh.TenKH, COUNT(dh.MaDH) AS TongSoDonHang
    FROM KhachHang kh
    INNER JOIN DonHang dh ON kh.MaKH = dh.MaKH
    GROUP BY kh.MaKH, kh.TenKH
    HAVING COUNT(dh.MaDH) > @SoDonHangMin;
END;
GO
EXEC sp_LayKhachHangNhieuDonHang @SoDonHangMin = 3;
go

