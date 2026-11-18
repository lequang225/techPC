"use client";
import Link from "next/link";
import { signOut } from "next-auth/react";
import { usePathname } from "next/navigation";

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const links = [
    { href: "/admin", label: "📊 Dashboard" },
    { href: "/admin/products", label: "📦 Sản phẩm" },
    { href: "/admin/products/new", label: "➕ Thêm sản phẩm" },
    { href: "/admin/categories", label: "🏷 Danh mục" },
    { href: "/admin/settings", label: "⚙️ Cài đặt" },
  ];
  return (
    <div className="grid md:grid-cols-[240px_1fr] min-h-screen">
      <aside className="border-r border-white/5 bg-card/50 p-6">
        <h2 className="font-display font-extrabold gradient-text text-xl mb-6">◆ TechPC Admin</h2>
        <nav className="space-y-2">
          {links.map((l) => (
            <Link key={l.href} href={l.href} className={`block px-4 py-2 rounded-lg transition ${pathname === l.href ? "bg-cyan/10 text-cyan" : "text-muted hover:text-ink"}`}>
              {l.label}
            </Link>
          ))}
        </nav>
        <button onClick={() => signOut({ callbackUrl: "/login" })} className="mt-8 w-full text-sm text-red-400 hover:text-red-300">🚪 Đăng xuất</button>
      </aside>
      <main className="p-8">{children}</main>
    </div>
  );
}
