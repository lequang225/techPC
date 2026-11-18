import Link from "next/link";

export default function NotFound() {
  return (
    <div className="min-h-[70vh] flex flex-col items-center justify-center px-6 text-center">
      <h1 className="font-display text-8xl font-extrabold gradient-text">404</h1>
      <p className="text-xl mt-4">Trang bạn tìm không tồn tại</p>
      <p className="text-muted mt-2">Có thể sản phẩm đã được gỡ hoặc đường dẫn bị sai.</p>
      <Link href="/" className="btn-brand mt-8">← Về trang chủ</Link>
    </div>
  );
}
