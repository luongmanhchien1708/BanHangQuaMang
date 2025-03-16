CREATE DATABASE BanHangQuaMang;
GO
USE BanHangQuaMang;
GO

-- Bảng Khách Hàng
CREATE TABLE KhachHang (
    MaKH INT IDENTITY(1,1) PRIMARY KEY,
    TenKH NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(255),
    NoiNhanHang NVARCHAR(255),
    SoDienThoai NVARCHAR(15) UNIQUE NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    MatKhau NVARCHAR(255) NOT NULL, -- Mã hóa mật khẩu khi lưu thực tế
    ThoiGianTruyCapCuoi DATETIME
);
-- Bảng Sản Phẩm
CREATE TABLE SanPham (
    MaSP INT IDENTITY(1,1) PRIMARY KEY,
    TenSP NVARCHAR(100) NOT NULL,
    MaSanPham NVARCHAR(50) UNIQUE NOT NULL,
    MoTa NVARCHAR(500),
    Gia DECIMAL(18,2) NOT NULL
);

-- Bảng Đơn Hàng
CREATE TABLE DonHang (
    MaDH INT IDENTITY(1,1) PRIMARY KEY,
    MaKH INT NOT NULL,
    NgayDatHang DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
);

-- Bảng Chi Tiết Đơn Hàng
CREATE TABLE ChiTietDonHang (
    MaChiTiet INT IDENTITY(1,1) PRIMARY KEY,
    MaDH INT NOT NULL,
    MaSP INT NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong > 0),
    DonGia DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (MaDH) REFERENCES DonHang(MaDH),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);

-- Bảng Lịch Sử Truy Cập
CREATE TABLE LichSuTruyCap (
    MaLichSu INT IDENTITY(1,1) PRIMARY KEY,
    MaKH INT NOT NULL,
    ThoiGian DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
);

-- Bảng Tài Khoản Khách Hàng
CREATE TABLE TaiKhoanKhachHang (
    MaKH INT PRIMARY KEY,
    TenDangNhap NVARCHAR(100) UNIQUE NOT NULL,
    MatKhau NVARCHAR(255) NOT NULL, -- Mã hóa mật khẩu khi lưu
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
);

-- Bảng Quản Trị Viên
CREATE TABLE QuanTriVien (
    MaAdmin INT IDENTITY(1,1) PRIMARY KEY,
    TenDangNhap NVARCHAR(100) UNIQUE NOT NULL,
    MatKhau NVARCHAR(255) NOT NULL
);

-- Bảng Quản Lý Đơn Hàng
CREATE TABLE QuanLyDonHang (
    MaQL INT IDENTITY(1,1) PRIMARY KEY,
    MaAdmin INT NOT NULL,
    MaDH INT NOT NULL,
    TrangThai NVARCHAR(50) NOT NULL DEFAULT 'Chờ xử lý',
    FOREIGN KEY (MaAdmin) REFERENCES QuanTriVien(MaAdmin),
    FOREIGN KEY (MaDH) REFERENCES DonHang(MaDH)
);

-- Truy vấn INSERT
INSERT INTO KhachHang (TenKH, DiaChi, NoiNhanHang, SoDienThoai, Email, MatKhau, ThoiGianTruyCapCuoi) VALUES
('Nguyen Van A', 'Hanoi', 'Hanoi', '0123456789', 'a@gmail.com', '123456', '2025-03-10 10:30:00'),
('Tran Thi B', 'HCM', 'HCM', '0987654321', 'b@gmail.com', 'abcdef', '2025-03-11 12:00:00'),
('Le Van C', 'Da Nang', 'Da Nang', '0981234567', 'c@gmail.com', 'pass123', '2025-03-12 08:45:00'),
('Pham Thi D', 'Hue', 'Hue', '0976543210', 'd@gmail.com', 'pass456', '2025-03-10 09:15:00'),
('Hoang Van E', 'Hai Phong', 'Hai Phong', '0912345678', 'e@gmail.com', 'pass789', '2025-03-09 14:20:00'),
('Bui Thi F', 'Can Tho', 'Can Tho', '0934567891', 'f@gmail.com', 'passabc', '2025-03-08 16:10:00'),
('Do Van G', 'Vinh', 'Vinh', '0923456782', 'g@gmail.com', 'passdef', '2025-03-07 18:05:00'),
('Ngo Thi H', 'Quang Ninh', 'Quang Ninh', '0901234567', 'h@gmail.com', 'passghi', '2025-03-06 11:30:00'),
('Dinh Van I', 'Bac Ninh', 'Bac Ninh', '0898765432', 'i@gmail.com', 'passjkl', '2025-03-05 13:50:00'),
('Tran Thi J', 'Nha Trang', 'Nha Trang', '0887654321', 'j@gmail.com', 'passmno', '2025-03-04 17:25:00');
go
INSERT INTO SanPham (TenSP, MaSanPham, MoTa, Gia) VALUES
('Laptop Dell', 'LAP001', 'Laptop Dell Inspiron', 18000000),
('Điện thoại Samsung', 'DT002', 'Samsung Galaxy S22', 20000000),
('Máy ảnh Canon', 'CAM003', 'Canon EOS 1500D', 15000000),
('Tai nghe Sony', 'HEAD004', 'Tai nghe Sony WH-1000XM4', 7000000),
('Bàn phím cơ', 'KB005', 'Bàn phím cơ gaming', 2500000),
('Chuột Logitech', 'MOUSE006', 'Chuột Logitech G502', 1200000),
('Màn hình LG', 'MON007', 'Màn hình LG 24 inch', 3500000),
('Loa Bluetooth JBL', 'SPEAK008', 'Loa JBL Charge 4', 3000000),
('Ổ cứng SSD 1TB', 'SSD009', 'SSD Samsung 1TB', 2200000),
('Máy in HP', 'PRINT010', 'Máy in HP LaserJet', 4000000);
go
INSERT INTO DonHang (MaKH, NgayDatHang) VALUES
(1, '2025-03-01 10:15:00'),
(2, '2025-03-02 14:30:00'),
(3, '2025-03-03 09:45:00'),
(4, '2025-03-04 11:20:00'),
(5, '2025-03-05 16:10:00'),
(6, '2025-03-06 13:55:00'),
(7, '2025-03-07 08:30:00'),
(8, '2025-03-08 17:40:00'),
(9, '2025-03-09 19:00:00'),
(10, '2025-03-10 12:25:00');
go
INSERT INTO ChiTietDonHang (MaDH, MaSP, SoLuong, DonGia) VALUES
(1, 2, 2, 20000000),
(2, 3, 1, 15000000),
(3, 4, 3, 7000000),
(4, 5, 1, 2500000),
(5, 6, 2, 1200000),
(6, 7, 1, 3500000),
(7, 8, 1, 3000000),
(8, 9, 2, 2200000),
(9, 10, 1, 4000000),
(10, 1, 2, 18000000);
go
-- Chèn dữ liệu vào bảng Lịch Sử Truy Cập
INSERT INTO LichSuTruyCap (MaKH, ThoiGian) VALUES
(1, '2025-03-10 08:30:00'),
(2, '2025-03-11 10:15:00'),
(3, '2025-03-12 14:45:00'),
(4, '2025-03-13 16:20:00'),
(5, '2025-03-14 18:10:00'),
(6, '2025-03-15 09:00:00'),
(7, '2025-03-16 11:30:00'),
(8, '2025-03-17 13:50:00'),
(9, '2025-03-18 15:40:00'),
(10, '2025-03-19 17:25:00');

-- Chèn dữ liệu vào bảng Tài Khoản Khách Hàng
INSERT INTO TaiKhoanKhachHang (MaKH, TenDangNhap, MatKhau) VALUES
(1, 'user1', 'password1'),
(2, 'user2', 'password2'),
(3, 'user3', 'password3'),
(4, 'user4', 'password4'),
(5, 'user5', 'password5'),
(6, 'user6', 'password6'),
(7, 'user7', 'password7'),
(8, 'user8', 'password8'),
(9, 'user9', 'password9'),
(10, 'user10', 'password10');

-- Chèn dữ liệu vào bảng Quản Trị Viên
INSERT INTO QuanTriVien (TenDangNhap, MatKhau) VALUES
('admin1', 'adminpass1'),
('admin2', 'adminpass2'),
('admin3', 'adminpass3'),
('admin4', 'adminpass4'),
('admin5', 'adminpass5');

-- Chèn dữ liệu vào bảng Quản Lý Đơn Hàng
INSERT INTO QuanLyDonHang (MaAdmin, MaDH, TrangThai) VALUES
(1, 1, 'Đã giao'),
(2, 2, 'Đang xử lý'),
(3, 3, 'Chờ xác nhận'),
(1, 4, 'Đã hủy'),
(2, 5, 'Đang vận chuyển'),
(3, 6, 'Đã giao'),
(4, 7, 'Chờ xác nhận'),
(5, 8, 'Đang xử lý'),
(1, 9, 'Đã hủy'),
(2, 10, 'Đang vận chuyển');


    
