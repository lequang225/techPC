"use client";
import Link from "next/link";
import { useEffect, useState } from "react";

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 30);
    window.addEventListener("scroll", onScroll);
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <header className={`sticky top-0 z-40 transition-all ${scrolled ? "backdrop-blur-xl bg-bg/80 border-b border-white/5" : "bg-transparent"}`}>
      <nav className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
        <Link href="/" className="font-display text-2xl font-extrabold gradient-text">◆ TechPC</Link>
        <ul className="hidden md:flex gap-8 text-sm text-muted">
          <li><Link href="/" className="hover:text-cyan transition">Trang chủ</Link></li>
          <li><Link href="/products" className="hover:text-cyan transition">Sản phẩm</Link></li>
          <li><Link href="/#why" className="hover:text-cyan transition">Vì sao chọn</Link></li>
          <li><Link href="/login" className="hover:text-cyan transition">Đăng nhập</Link></li>
        </ul>
      </nav>
    </header>
  );
}
