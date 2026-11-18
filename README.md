# 💻 TechPC - Website Giới thiệu & Quản trị Máy vi tính

Chào mừng bạn đến với **TechPC**! Đây là một dự án website full-stack hiện đại, được thiết kế để giới thiệu các cấu hình máy vi tính (PC Gaming, Đồ họa, Văn phòng) với giao diện "Tech Premium" (tối, neon, nhiều hiệu ứng chuyển động mượt mà). 

Dự án bao gồm 2 phần chính:
1. **Trang khách hàng (Client):** Xem sản phẩm, xem chi tiết cấu hình, banner chạy slide.
2. **Trang Quản trị (Admin):** Quản lý sản phẩm, danh mục, tải lên nhiều ảnh, thay đổi banner/footer và bảo mật tài khoản.

---

## 🚀 1. Công nghệ sử dụng (Tech Stack)

*   **Framework:** Next.js 14 (App Router)
*   **Ngôn ngữ:** TypeScript
*   **Giao diện & CSS:** Tailwind CSS
*   **Hiệu ứng chuyển động:** Framer Motion
*   **Cơ sở dữ liệu:** PostgreSQL
*   **ORM:** Prisma
*   **Xác thực (Auth):** NextAuth.js (Credentials)
*   **Lưu trữ ảnh:** Local (thư mục `public/uploads`) hoặc AWS S3.

---

## ✨ 2. Tính năng nổi bật

### Dành cho Khách hàng (Frontend)
*   **Trang chủ:** Banner tự động chạy slide nhiều ảnh với hiệu ứng mờ (blur) và zoom nhẹ. Các hạt sáng bay (Particles) tạo không gian công nghệ.
*   **Danh sách sản phẩm:** Hiển thị dạng thẻ (Card) với hiệu ứng hover nhấc lên và phát sáng.
*   **Chi tiết sản phẩm:** Xem nhiều ảnh (Gallery), phóng to ảnh (Lightbox), xem thông số và giá cả.
*   **Tối ưu SEO:** Tự động tạo Sitemap, Robots.txt, thẻ meta Open Graph và Structured Data (JSON-LD) cho từng sản phẩm.

### Dành cho Quản trị viên (Admin Dashboard)
*   **Đăng nhập bảo mật:** Sử dụng NextAuth và mã hóa mật khẩu bằng bcrypt.
*   **Quản lý Sản phẩm (CRUD):** Thêm, sửa, xóa sản phẩm.
*   **Upload đa hình ảnh:** Kéo thả nhiều ảnh cùng lúc, chọn ảnh đại diện (Main Image), có thanh tiến trình.
*   **Quản lý Danh mục:** Thêm, sửa, xóa danh mục. Chặn xóa nếu danh mục đang có sản phẩm.
*   **Cài đặt giao diện:** Tùy chỉnh Banner (tiêu đề, mô tả, ảnh slide) và thông tin Footer (địa chỉ, SĐT, email).
*   **Bảo mật tài khoản:** Tính năng đổi mật khẩu Admin.

---

## 🛠️ 3. Hướng dẫn cài đặt dưới Local (Máy tính)

### Yêu cầu hệ thống
*   Node.js (Khuyến nghị bản 20.x LTS)
*   PostgreSQL (Bản 14 trở lên)
*   npm hoặc yarn

### Các bước cài đặt

**Bước 1: Clone dự án và cài đặt thư viện**
```bash
git clone <link-github-cua-ban> techpc
cd techpc
npm install
Bước 2: Cấu hình biến môi trường
Tạo file .env từ file mẫu:

bash
cp .env.example .env
Mở file .env và điền thông tin Database của bạn:

env
DATABASE_URL="postgresql://user:password@localhost:5432/techpc?schema=public"
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="chuoi-bi-mat-cua-ban" # Tạo bằng lệnh: openssl rand -base64 32
Bước 3: Khởi tạo Cơ sở dữ liệu

bash
# Tạo các bảng trong database
npx prisma db push

# Nạp dữ liệu mẫu (Tài khoản admin, danh mục, sản phẩm mẫu)
npm run db:seed
Bước 4: Chạy dự án

bash
npm run dev
Mở trình duyệt truy cập: http://localhost:3000
