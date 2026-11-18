#!/bin/bash
set -e
cd "$(dirname "$0")"

echo ""
echo "════════════════════════════════════════════════"
echo "  ⚙️ CẬP NHẬT TÍNH NĂNG: SETTINGS (BANNER + FOOTER)"
echo "════════════════════════════════════════════════"
echo ""

# 1. Cập nhật Prisma Schema
echo "🗄 Đang cập nhật Prisma Schema..."
cat >> prisma/schema.prisma << 'EOF'

model Setting {
  id              String   @id @default("global")
  bannerTitle     String   @default("Build PC mơ ước của bạn")
  bannerSubtitle  String   @default("Cấu hình cao cấp — Bảo hành 36 tháng — Giao hàng 2h toàn quốc.")
  bannerImage     String   @default("https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=800")
  bannerButton    String   @default("Xem sản phẩm →")
  footerAddress   String   @default("Địa chỉ: 123 Nguyễn Trãi, TP.HCM")
  footerPhone     String   @default("Hotline: 1900 1234")
  footerEmail     String   @default("Email: contact@techpc.vn")
}
EOF

# 2. Tạo API Settings
echo "🔌 Đang tạo API Settings..."
mkdir -p src/app/api/settings
cat > src/app/api/settings/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";

export async function GET() {
  let settings = await prisma.setting.findUnique({ where: { id: "global" } });
  if (!settings) {
    settings = await prisma.setting.create({ data: { id: "global" } });
  }
  return NextResponse.json(settings);
}

export async function PUT(req: NextRequest) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const body = await req.json();
  const { bannerTitle, bannerSubtitle, bannerImage, bannerButton, footerAddress, footerPhone, footerEmail } = body;

  const settings = await prisma.setting.upsert({
    where: { id: "global" },
    update: { bannerTitle, bannerSubtitle, bannerImage, bannerButton, footerAddress, footerPhone, footerEmail },
    create: { id: "global", bannerTitle, bannerSubtitle, bannerImage, bannerButton, footerAddress, footerPhone, footerEmail },
  });

  return NextResponse.json(settings);
}
EOF

# 3. Tạo Component Form Settings trong Admin
echo "🎨 Đang tạo Admin Form..."
cat > src/components/SettingsForm.tsx << 'EOF'
"use client";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import ImageUploader, { UploadedImage } from "./ImageUploader";
import Toast, { ToastData } from "./Toast";

export default function SettingsForm() {
  const router = useRouter();
  const [form, setForm] = useState({
    bannerTitle: "",
    bannerSubtitle: "",
    bannerImage: "",
    bannerButton: "",
    footerAddress: "",
    footerPhone: "",
    footerEmail: "",
  });
  const [bannerImg, setBannerImg] = useState<UploadedImage[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [toasts, setToasts] = useState<ToastData[]>([]);

  const addToast = (type: "success" | "error", message: string) => {
    const id = Date.now();
    setToasts((t) => [...t, { id, type, message }]);
    setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 3000);
  };

  useEffect(() => {
    fetch("/api/settings")
      .then((res) => res.json())
      .then((data) => {
        setForm({
          bannerTitle: data.bannerTitle || "",
          bannerSubtitle: data.bannerSubtitle || "",
          bannerImage: data.bannerImage || "",
          bannerButton: data.bannerButton || "",
          footerAddress: data.footerAddress || "",
          footerPhone: data.footerPhone || "",
          footerEmail: data.footerEmail || "",
        });
        if (data.bannerImage) {
          setBannerImg([{ url: data.bannerImage, isMain: true }]);
        }
        setLoading(false);
      });
  }, []);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    const body = { ...form, bannerImage: bannerImg[0]?.url || "" };
    const res = await fetch("/api/settings", {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
    setSaving(false);
    if (res.ok) {
      addToast("success", "Lưu cài đặt thành công!");
      router.refresh();
    } else {
      addToast("error", "Có lỗi xảy ra khi lưu");
    }
  };

  const input = "w-full bg-black/40 border border-white/10 rounded-lg px-4 py-2 mb-4 focus:border-cyan outline-none";

  if (loading) return <p className="text-muted">Đang tải dữ liệu...</p>;

  return (
    <form onSubmit={submit} className="card p-8 space-y-8 max-w-4xl">
      {/* PHẦN BANNER */}
      <div>
        <h3 className="font-display text-xl font-bold mb-4 text-cyan border-b border-white/10 pb-2">🖼️ Cài đặt Banner (Trang chủ)</h3>
        <div className="grid md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm mb-1">Tiêu đề chính</label>
            <input value={form.bannerTitle} onChange={(e) => setForm({ ...form, bannerTitle: e.target.value })} className={input} required />
          </div>
          <div>
            <label className="block text-sm mb-1">Chữ trên nút bấm</label>
            <input value={form.bannerButton} onChange={(e) => setForm({ ...form, bannerButton: e.target.value })} className={input} required />
          </div>
        </div>
        <div>
          <label className="block text-sm mb-1">Tiêu đề phụ (Mô tả)</label>
          <textarea value={form.bannerSubtitle} onChange={(e) => setForm({ ...form, bannerSubtitle: e.target.value })} rows={2} className={input} required />
        </div>
        <div>
          <label className="block text-sm mb-1">Hình ảnh Banner</label>
          <ImageUploader images={bannerImg} setImages={setBannerImg} onError={(m) => addToast("error", m)} />
        </div>
      </div>

      {/* PHẦN FOOTER */}
      <div>
        <h3 className="font-display text-xl font-bold mb-4 text-cyan border-b border-white/10 pb-2">📍 Cài đặt Footer (Chân trang)</h3>
        <div className="grid md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm mb-1">Số điện thoại / Hotline</label>
            <input value={form.footerPhone} onChange={(e) => setForm({ ...form, footerPhone: e.target.value })} className={input} required />
          </div>
          <div>
            <label className="block text-sm mb-1">Email liên hệ</label>
            <input value={form.footerEmail} onChange={(e) => setForm({ ...form, footerEmail: e.target.value })} className={input} required />
          </div>
        </div>
        <div>
          <label className="block text-sm mb-1">Địa chỉ</label>
          <input value={form.footerAddress} onChange={(e) => setForm({ ...form, footerAddress: e.target.value })} className={input} required />
        </div>
      </div>

      <div className="flex justify-end pt-4 border-t border-white/10">
        <button disabled={saving} className="btn-brand">{saving ? "Đang lưu..." : "💾 Lưu tất cả cài đặt"}</button>
      </div>

      <Toast toasts={toasts} />
    </form>
  );
}
EOF

# 4. Cập nhật trang Admin Settings (gộp chung với Đổi mật khẩu)
echo "📄 Đang cập nhật trang Admin Settings..."
cat > src/app/admin/settings/page.tsx << 'EOF'
import PasswordForm from "@/components/PasswordForm";
import SettingsForm from "@/components/SettingsForm";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";

export default async function AdminSettings() {
  const session = await getServerSession(authOptions);
  return (
    <div>
      <h1 className="font-display text-3xl font-bold mb-6">⚙️ Cài đặt hệ thống</h1>
      
      <div className="card p-6 mb-8 max-w-4xl bg-gradient-to-r from-cyan/10 to-purple/10 border-cyan/20">
        <p className="text-muted text-sm mb-1">Đang đăng nhập với tài khoản quản trị</p>
        <p className="font-display text-xl font-semibold text-white">👤 {session?.user?.name}</p>
      </div>

      {/* Form cấu hình giao diện */}
      <div className="mb-12">
        <SettingsForm />
      </div>

      {/* Form đổi mật khẩu */}
      <div>
        <PasswordForm />
      </div>
    </div>
  );
}
EOF

# 5. Cập nhật Hero Component (nhận dữ liệu từ props)
echo "🎨 Đang cập nhật Hero.tsx..."
cat > src/components/Hero.tsx << 'EOF'
"use client";
import { motion } from "framer-motion";
import Link from "next/link";

type HeroProps = {
  title: string;
  subtitle: string;
  image: string;
  buttonText: string;
};

export default function Hero({ title, subtitle, image, buttonText }: HeroProps) {
  return (
    <section className="max-w-7xl mx-auto px-6 py-24 grid md:grid-cols-2 gap-12 items-center">
      <motion.div initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.8 }}>
        <p className="text-cyan text-sm uppercase tracking-widest mb-4">✦ Hiệu năng vượt trội</p>
        <h1 className="font-display text-5xl md:text-6xl font-extrabold leading-tight">
          {title}
        </h1>
        <p className="text-muted mt-6 text-lg">{subtitle}</p>
        <div className="mt-8 flex gap-4">
          <Link href="/products" className="btn-brand">{buttonText}</Link>
          <Link href="/#contact" className="px-6 py-3 rounded-xl border border-cyan/40 text-cyan hover:bg-cyan/10 transition">Tư vấn ngay</Link>
        </div>
      </motion.div>

      <motion.div initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: 1 }} className="relative">
        <div className="absolute inset-0 bg-gradient-brand blur-3xl opacity-30 rounded-full" />
        {image ? (
          <img src={image} alt="PC Gaming" className="relative rounded-2xl shadow-2xl animate-float w-full object-cover" />
        ) : (
          <div className="relative aspect-square bg-card rounded-2xl flex items-center justify-center text-muted border border-white/10">Chưa có ảnh banner</div>
        )}
      </motion.div>
    </section>
  );
}
EOF

# 6. Cập nhật Footer Component (nhận dữ liệu từ props)
echo "🎨 Đang cập nhật Footer.tsx..."
cat > src/components/Footer.tsx << 'EOF'
type FooterProps = {
  address: string;
  phone: string;
  email: string;
};

export default function Footer({ address, phone, email }: FooterProps) {
  return (
    <footer className="border-t border-white/5 mt-24 py-10 text-center text-muted text-sm">
      <p className="font-display text-xl gradient-text font-extrabold mb-4">◆ TechPC</p>
      <p>{address}</p>
      <p className="mt-1">{phone} • {email}</p>
      <p className="mt-4 text-xs opacity-70">© {new Date().getFullYear()} TechPC. All rights reserved.</p>
    </footer>
  );
}
EOF

# 7. Cập nhật Layout (truyền data cho Footer)
echo "📄 Đang cập nhật Layout.tsx..."
cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from "next";
import "./globals.css";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import ScrollProgress from "@/components/ScrollProgress";
import Particles from "@/components/Particles";
import { prisma } from "@/lib/prisma";

const SITE_URL = process.env.NEXTAUTH_URL || "http://localhost:3000";
const SITE_NAME = "TechPC";
const SITE_DESC = "Máy vi tính cao cấp — PC Gaming, Đồ họa, Văn phòng. Bảo hành 36 tháng, giao hàng 2h toàn quốc.";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: { default: `${SITE_NAME} — Máy vi tính cao cấp`, template: `%s | ${SITE_NAME}` },
  description: SITE_DESC,
  keywords: ["máy vi tính", "PC gaming", "PC đồ họa", "PC văn phòng", "build PC", "TechPC"],
  authors: [{ name: SITE_NAME }],
  openGraph: {
    type: "website", locale: "vi_VN", url: SITE_URL, siteName: SITE_NAME,
    title: `${SITE_NAME} — Máy vi tính cao cấp`, description: SITE_DESC,
    images: [{ url: "/og-image.jpg", width: 1200, height: 630, alt: SITE_NAME }],
  },
  twitter: { card: "summary_large_image", title: `${SITE_NAME} — Máy vi tính cao cấp`, description: SITE_DESC, images: ["/og-image.jpg"] },
  robots: { index: true, follow: true },
  alternates: { canonical: SITE_URL },
};

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  let settings = await prisma.setting.findUnique({ where: { id: "global" } });
  if (!settings) {
    settings = await prisma.setting.create({ data: { id: "global" } });
  }

  return (
    <html lang="vi">
      <body>
        <Particles />
        <ScrollProgress />
        <Navbar />
        <main className="min-h-screen">{children}</main>
        <Footer address={settings.footerAddress} phone={settings.footerPhone} email={settings.footerEmail} />
      </body>
    </html>
  );
}
EOF

# 8. Cập nhật Trang chủ (truyền data cho Hero)
echo "📄 Đang cập nhật Page.tsx..."
cat > src/app/page.tsx << 'EOF'
import Hero from "@/components/Hero";
import ProductCard from "@/components/ProductCard";
import AnimatedCounter from "@/components/AnimatedCounter";
import StructuredData from "@/components/StructuredData";
import { prisma } from "@/lib/prisma";

export const dynamic = "force-dynamic";

export default async function Home() {
  const products = await prisma.product.findMany({
    where: { isActive: true },
    include: { images: { orderBy: { order: "asc" } }, category: true },
    take: 8,
    orderBy: { createdAt: "desc" },
  });

  const settings = await prisma.setting.findUnique({ where: { id: "global" } });

  const orgSchema = {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: "TechPC",
    url: process.env.NEXTAUTH_URL || "http://localhost:3000",
    contactPoint: { "@type": "ContactPoint", telephone: settings?.footerPhone || "", contactType: "customer service", areaServed: "VN" },
  };

  const stats = [
    { label: "Sản phẩm", value: products.length + 500 },
    { label: "Khách hàng", value: 1200 },
    { label: "Đánh giá 5★", value: 490 },
    { label: "Hỗ trợ 24/7", value: 24 },
  ];

  return (
    <>
      <StructuredData data={orgSchema} />
      
      <Hero 
        title={settings?.bannerTitle || "Build PC mơ ước của bạn"}
        subtitle={settings?.bannerSubtitle || ""}
        image={settings?.bannerImage || ""}
        buttonText={settings?.bannerButton || "Xem sản phẩm"}
      />

      <section className="max-w-7xl mx-auto px-6 py-16 grid grid-cols-2 md:grid-cols-4 gap-6">
        {stats.map((s) => (
          <div key={s.label} className="card p-6 text-center">
            <p className="font-display text-3xl font-bold gradient-text"><AnimatedCounter to={s.value} /></p>
            <p className="text-muted text-sm mt-1">{s.label}</p>
          </div>
        ))}
      </section>

      <section className="max-w-7xl mx-auto px-6 py-16">
        <h2 className="font-display text-3xl md:text-4xl font-bold text-center mb-12">
          <span className="gradient-text">Sản phẩm nổi bật</span>
        </h2>
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          {products.map((p, i) => <ProductCard key={p.id} product={p} index={i} />)}
        </div>
      </section>

      <section id="why" className="max-w-7xl mx-auto px-6 py-16 grid md:grid-cols-3 gap-6">
        {[
          { icon: "🛡️", title: "Bảo hành 36 tháng", desc: "Cam kết chính hãng" },
          { icon: "🚚", title: "Giao hàng 2h", desc: "Toàn quốc, miễn phí nội thành" },
          { icon: "💳", title: "Trả góp 0%", desc: "Duyệt nhanh, thủ tục đơn giản" },
        ].map((f) => (
          <div key={f.title} className="card p-8 text-center card-hover">
            <div className="text-4xl mb-3">{f.icon}</div>
            <h3 className="font-display font-semibold text-lg">{f.title}</h3>
            <p className="text-muted text-sm mt-2">{f.desc}</p>
          </div>
        ))}
      </section>
    </>
  );
}
EOF

echo ""
echo "════════════════════════════════════════════════"
echo "  ✅ CẬP NHẬT THÀNH CÔNG!"
echo "════════════════════════════════════════════════"
echo ""
echo "👉 Bây giờ bạn chạy 2 lệnh sau để đồng bộ Database:"
echo "   1. npx prisma db push"
echo "   2. npm run dev"
echo ""
