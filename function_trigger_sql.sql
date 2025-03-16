USE BanHangQuaMang;

--Tạo 10 function (trả về kiểu vô hướng, bảng, biến bảng)
--Trả về kiểu vô hướng
-- 1. Trả về tổng số đơn hàng của một khách hàng
CREATE FUNCTION fn_TongSoDonHang(@MaKH INT) RETURNS INT
AS
BEGIN
    DECLARE @Tong INT;
    SELECT @Tong = COUNT(*) FROM DonHang WHERE MaKH = @MaKH;
    RETURN @Tong;
END;
SELECT dbo.fn_TongSoDonHang(1) AS TongSoDonHang;
-- 2. Lấy số lượng sản phẩm trong kho theo mã sản phẩm
CREATE FUNCTION fn_SoLuongSanPham (@MaSP INT)
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT;
    SELECT @SoLuong = SUM(SoLuong) FROM ChiTietDonHang WHERE MaSP = @MaSP;
    RETURN ISNULL(@SoLuong, 0);
END;
GO
-- Kiểm tra
SELECT dbo.fn_SoLuongSanPham(1) AS SoLuongTonKho;

-- 3. Trả về bảng danh sách sản phẩm có giá cao hơn mức chỉ định
CREATE FUNCTION fn_SanPhamGiaCaoHon(@GiaMin DECIMAL(18,2)) RETURNS TABLE
AS
RETURN (
    SELECT * FROM SanPham WHERE Gia > @GiaMin
);
SELECT * FROM dbo.fn_SanPhamGiaCaoHon(1000000);
--Trả về bảng
-- 4. Lấy danh sách đơn hàng của một khách hàng
CREATE FUNCTION fn_DanhSachDonHang (@MaKH INT)
RETURNS TABLE
AS
RETURN
(
    SELECT MaDH, NgayDatHang 
    FROM DonHang
    WHERE MaKH = @MaKH
);
GO
-- Kiểm tra
SELECT * FROM fn_DanhSachDonHang(1);
--5.  Lấy danh sách sản phẩm trong một đơn hàng
CREATE FUNCTION fn_ChiTietDonHang (@MaDH INT)
RETURNS TABLE
AS
RETURN
(
    SELECT ctdh.MaSP, sp.TenSP, ctdh.SoLuong, ctdh.DonGia
    FROM ChiTietDonHang ctdh
    JOIN SanPham sp ON ctdh.MaSP = sp.MaSP
    WHERE ctdh.MaDH = @MaDH
);
GO

-- Kiểm tra
SELECT * FROM fn_ChiTietDonHang(2);
---6. Lấy danh sách khách hàng đã đặt hàng trong tháng cụ thể
CREATE FUNCTION fn_KhachHangTheoThang (@Thang INT, @Nam INT)
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT kh.MaKH, kh.TenKH, kh.Email
    FROM KhachHang kh
    JOIN DonHang dh ON kh.MaKH = dh.MaKH
    WHERE MONTH(dh.NgayDatHang) = @Thang AND YEAR(dh.NgayDatHang) = @Nam
);
GO
-- Kiểm tra
SELECT * FROM fn_KhachHangTheoThang(3, 2025);

--Trả về kiểu biến bảng
---7. Lấy danh sách sản phẩm có giá cao hơn mức giá nhập vào
CREATE FUNCTION fn_SanPhamGiaCaoHon (@Gia DECIMAL(18,2))
RETURNS @SanPham TABLE (
    MaSP INT,
    TenSP NVARCHAR(100),
    Gia DECIMAL(18,2)
)
AS
BEGIN
    INSERT INTO @SanPham
    SELECT MaSP, TenSP, Gia
    FROM SanPham
    WHERE Gia > @Gia;
    
    RETURN;
END;
GO
-- Kiểm tra
SELECT * FROM fn_SanPhamGiaCaoHon(50000);

---8.Lấy 5 khách hàng gần đây đã đặt hàng
CREATE FUNCTION fn_KhachHangGanNhat ()
RETURNS @KhachHang TABLE (
    MaKH INT,
    TenKH NVARCHAR(100),
    Email NVARCHAR(100),
    NgayDatHang DATETIME
)
AS
BEGIN
    INSERT INTO @KhachHang
    SELECT TOP 5 kh.MaKH, kh.TenKH, kh.Email, dh.NgayDatHang
    FROM KhachHang kh
    JOIN DonHang dh ON kh.MaKH = dh.MaKH
    ORDER BY dh.NgayDatHang DESC;
    
    RETURN;
END;
GO
-- Kiểm tra
SELECT * FROM fn_KhachHangGanNhat();

--9.Lấy tổng doanh thu theo từng khách hàng
CREATE FUNCTION fn_DoanhThuTungKhachHang ()
RETURNS @DoanhThu TABLE (
    MaKH INT,
    TenKH NVARCHAR(100),
    TongDoanhThu DECIMAL(18,2)
)
AS
BEGIN
    INSERT INTO @DoanhThu
    SELECT kh.MaKH, kh.TenKH, SUM(ctdh.SoLuong * ctdh.DonGia)
    FROM KhachHang kh
    JOIN DonHang dh ON kh.MaKH = dh.MaKH
    JOIN ChiTietDonHang ctdh ON dh.MaDH = ctdh.MaDH
    GROUP BY kh.MaKH, kh.TenKH;

    RETURN;
END;
GO

-- Kiểm tra
SELECT * FROM fn_DoanhThuTungKhachHang();

---10. lấy danh sách sản phẩm có giá trong khoảng nhất định:
CREATE FUNCTION fn_SanPhamTrongKhoangGia (@GiaMin DECIMAL(18,2), @GiaMax DECIMAL(18,2))
RETURNS @DanhSachSanPham TABLE (
    MaSP INT,
    TenSP NVARCHAR(100),
    Gia DECIMAL(18,2)
)
AS
BEGIN
    INSERT INTO @DanhSachSanPham
    SELECT MaSP, TenSP, Gia
    FROM SanPham
    WHERE Gia BETWEEN @GiaMin AND @GiaMax;

    RETURN;
END;
GO

-- Kiểm tra function với khoảng giá cụ thể
SELECT * FROM fn_SanPhamTrongKhoangGia(100000, 2000000);

---TRIGGER
---1
CREATE TRIGGER trg_CheckKhachHang ON KhachHang
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE Email NOT LIKE '%@%.%')
    BEGIN
        RAISERROR ('Email không hợp lệ.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
INSERT INTO KhachHang (TenKH, DiaChi, NoiNhanHang, SoDienThoai, Email, MatKhau) 
VALUES ('Nguyen Van A', 'Hanoi', 'Hanoi', '0123456789', 'a@gmail.com', '123456');
--2. Trigger kiểm tra khi xóa đơn hàng
CREATE TRIGGER trg_PreventDeleteDonHang ON DonHang
INSTEAD OF DELETE
AS
BEGIN
    PRINT 'Không thể xóa đơn hàng đã có sản phẩm liên quan.';
END;
DELETE FROM DonHang WHERE MaDH = 1;
--3. Trigger kiểm tra khi cập nhật giá sản phẩm
CREATE TRIGGER trg_CheckGiaSanPham ON SanPham
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE Gia <= 0)
    BEGIN
        RAISERROR ('Giá sản phẩm phải lớn hơn 0.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
UPDATE SanPham SET Gia = -1 WHERE MaSP = 1;
--4. Trigger kiểm soát trạng thái đơn hàng
CREATE TRIGGER trg_RestrictDonHangStatus ON QuanLyDonHang
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE TrangThai NOT IN ('Chờ xử lý', 'Đã xác nhận', 'Hoàn thành'))
    BEGIN
        RAISERROR ('Trạng thái đơn hàng không hợp lệ.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
UPDATE QuanLyDonHang SET TrangThai = 'Sai trạng thái' WHERE MaDH = 1;
--5. ngăn chặn xóa khách hàng nếu họ đã có đơn hàng trong hệ thống.
CREATE TRIGGER trg_PreventDeleteKhachHang ON KhachHang
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted d JOIN DonHang dh ON d.MaKH = dh.MaKH)
    BEGIN
        RAISERROR ('Không thể xóa khách hàng có đơn hàng.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE FROM KhachHang WHERE MaKH IN (SELECT MaKH FROM deleted);
    END
END;
GO
DELETE FROM KhachHang WHERE MaKH = 1;

--6. Trigger kiểm tra khi thêm tài khoản khách hàng
CREATE TRIGGER trg_CheckTaiKhoanKhachHang ON TaiKhoanKhachHang
AFTER INSERT
AS
BEGIN
    PRINT 'Tài khoản khách hàng mới đã được tạo.';
END;
INSERT INTO TaiKhoanKhachHang (MaKH, TenDangNhap, MatKhau) 
VALUES ((SELECT TOP 1 MaKH FROM KhachHang ORDER BY MaKH DESC), 'new_user', 'secure_password');
--7. Trigger kiểm soát cập nhật thời gian truy cập
CREATE TRIGGER trg_UpdateThoiGianTruyCap ON LichSuTruyCap
AFTER INSERT
AS
BEGIN
    UPDATE KhachHang
    SET ThoiGianTruyCapCuoi = GETDATE()
    FROM KhachHang KH
    INNER JOIN inserted I ON KH.MaKH = I.MaKH;
END;
INSERT INTO LichSuTruyCap (MaKH) VALUES (1);