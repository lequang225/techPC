#!/bin/bash
set -e
cd "$(dirname "$0")"

echo ""
echo "════════════════════════════════════════════════"
echo "  🖼️ CẬP NHẬT: BANNER SLIDER NHIỀU ẢNH"
echo "════════════════════════════════════════════════"
echo ""

# 1. Cập nhật Prisma Schema (Đổi bannerImage thành bannerImages)
echo "🗄 Đang cập nhật Database Schema..."
# Xóa dòng bannerImage cũ
sed -i '/bannerImage/d' prisma/schema.prisma
# Thêm bannerImages vào trước bannerButton
sed -i '/bannerButton/i\  bannerImages    String[]' prisma/schema.prisma

# 2. Cập nhật API Settings
echo "🔌 Đang cập nhật API..."
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
  const { bannerTitle, bannerSubtitle, bannerImages, bannerButton, footerAddress, footerPhone, footerEmail } = body;

  const settings = await prisma.setting.upsert({
    where: { id: "global" },
    update: { bannerTitle, bannerSubtitle, bannerImages, bannerButton, footerAddress, footerPhone, footerEmail },
    create: { id: "global", bannerTitle, bannerSubtitle, bannerImages, bannerButton, footerAddress, footerPhone, footerEmail },
  });

  return NextResponse.json(settings);
}
EOF

# 3. Cập nhật Form Settings (Cho phép upload nhiều ảnh)
echo "🎨 Đang cập nhật Admin Form..."
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
    bannerButton: "",
    footerAddress: "",
    footerPhone: "",
    footerEmail: "",
  });
  const [bannerImgs, setBannerImgs] = useState<UploadedImage[]>([]);
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
          bannerButton: data.bannerButton || "",
          footerAddress: data.footerAddress || "",
          footerPhone: data.footerPhone || "",
          footerEmail: data.footerEmail || "",
        });
        // Map mảng string thành mảng object cho ImageUploader
        if (data.bannerImages && Array.isArray(data.bannerImages)) {
          setBannerImgs(data.bannerImages.map((url: string, i: number) => ({ url, isMain: i === 0 })));
        }
        setLoading(false);
      });
  }, []);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    const body = { ...form, bannerImages: bannerImgs.map((img) => img.url) };
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
          <label className="block text-sm mb-1">Hình ảnh Banner (Có thể tải lên nhiều ảnh để chạy Slide)</label>
          <ImageUploader images={bannerImgs} setImages={setBannerImgs} onError={(m) => addToast("error", m)} />
        </div>
      </div>

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

# 4. Cập nhật Hero Component (Hiệu ứng Slide mượt mà)
echo "🎨 Đang tạo hiệu ứng chuyển ảnh..."
cat > src/components/Hero.tsx << 'EOF'
"use client";
import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import Link from "next/link";

type HeroProps = {
  title: string;
  subtitle: string;
  images: string[];
  buttonText: string;
};

export default function Hero({ title, subtitle, images, buttonText }: HeroProps) {
  const [index, setIndex] = useState(0);

  // Tự động chuyển ảnh sau 4 giây
  useEffect(() => {
    if (!images || images.length <= 1) return;
    const timer = setInterval(() => {
      setIndex((prev) => (prev + 1) % images.length);
    }, 4000);
    return () => clearInterval(timer);
  }, [images]);

  const currentImages = images && images.length > 0 ? images : ["https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=800"];

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
        {/* Vòng sáng background */}
        <div className="absolute inset-0 bg-gradient-brand blur-3xl opacity-30 rounded-full" />
        
        {/* Khung chứa ảnh Slider */}
        <div className="relative aspect-square md:aspect-[4/3] rounded-2xl overflow-hidden bg-card border border-white/5 shadow-2xl">
          <AnimatePresence mode="wait">
            <motion.img
              key={index}
              src={currentImages[index]}
              alt="PC Banner"
              initial={{ opacity: 0, scale: 1.1, filter: "blur(10px)" }}
              animate={{ opacity: 1, scale: 1, filter: "blur(0px)" }}
              exit={{ opacity: 0, scale: 0.95, filter: "blur(10px)" }}
              transition={{ duration: 0.8, ease: "easeInOut" }}
              className="absolute inset-0 w-full h-full object-cover"
            />
          </AnimatePresence>
        </div>

        {/* Nút chấm tròn chuyển ảnh (Dots) */}
        {currentImages.length > 1 && (
          <div className="absolute -bottom-6 left-1/2 -translate-x-1/2 flex gap-2">
            {currentImages.map((_, i) => (
              <button
                key={i}
                onClick={() => setIndex(i)}
                className={`h-2.5 rounded-full transition-all duration-300 ${
                  i === index ? "w-8 bg-cyan" : "w-2.5 bg-white/30 hover:bg-white/60"
                }`}
                aria-label={`Chuyển đến ảnh ${i + 1}`}
              />
            ))}
          </div>
        )}
      </motion.div>
    </section>
  );
}
EOF

# 5. Cập nhật trang chủ (Truyền mảng ảnh vào Hero)
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
        images={settings?.bannerImages || []}
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
echo "  ✅ CẬP NHẬT BANNER SLIDER THÀNH CÔNG!"
echo "════════════════════════════════════════════════"
echo ""
echo "👉 BẮT BUỘC: Chạy lệnh sau để cập nhật Database (Sẽ hỏi bạn có reset không, hãy bấm Y):"
echo "   npx prisma db push"
echo ""
