#!/bin/bash
set -e
cd "$(dirname "$0")"

echo ""
echo "════════════════════════════════════════════════"
echo "  🎨 TechPC Setup — PHẦN 2/3 (Components)"
echo "════════════════════════════════════════════════"
echo ""

echo "🎨 Đang tạo 14 components..."

# 1. Particles
cat > src/components/Particles.tsx << 'EOF'
"use client";
import { useEffect, useRef } from "react";

export default function Particles() {
  const ref = useRef<HTMLCanvasElement>(null);
  useEffect(() => {
    const canvas = ref.current!;
    const ctx = canvas.getContext("2d")!;
    const resize = () => { canvas.width = innerWidth; canvas.height = innerHeight; };
    resize(); window.addEventListener("resize", resize);

    const ps = Array.from({ length: 60 }, () => ({
      x: Math.random() * canvas.width,
      y: Math.random() * canvas.height,
      vx: (Math.random() - 0.5) * 0.4,
      vy: (Math.random() - 0.5) * 0.4,
      r: Math.random() * 2 + 0.5,
      c: Math.random() > 0.5 ? "#00E5FF" : "#7C3AED",
    }));

    let raf = 0;
    const loop = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      for (const p of ps) {
        p.x += p.vx; p.y += p.vy;
        if (p.x < 0 || p.x > canvas.width) p.vx *= -1;
        if (p.y < 0 || p.y > canvas.height) p.vy *= -1;
        ctx.globalAlpha = 0.6;
        ctx.fillStyle = p.c;
        ctx.beginPath(); ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2); ctx.fill();
      }
      raf = requestAnimationFrame(loop);
    };
    loop();
    return () => { cancelAnimationFrame(raf); window.removeEventListener("resize", resize); };
  }, []);
  return <canvas ref={ref} className="fixed inset-0 -z-10 pointer-events-none opacity-50" />;
}
EOF

# 2. ScrollProgress
cat > src/components/ScrollProgress.tsx << 'EOF'
"use client";
import { motion, useScroll, useSpring } from "framer-motion";

export default function ScrollProgress() {
  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, { stiffness: 120, damping: 25 });
  return (
    <motion.div
      style={{ scaleX }}
      className="fixed top-0 left-0 right-0 h-[3px] origin-left z-50 bg-gradient-brand"
    />
  );
}
EOF

# 3. Navbar
cat > src/components/Navbar.tsx << 'EOF'
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
EOF

# 4. Footer
cat > src/components/Footer.tsx << 'EOF'
export default function Footer() {
  return (
    <footer className="border-t border-white/5 mt-24 py-10 text-center text-muted text-sm">
      <p className="font-display text-xl gradient-text font-extrabold mb-2">◆ TechPC</p>
      <p>Địa chỉ: 123 Nguyễn Trãi, TP.HCM • Hotline: 1900 1234</p>
      <p className="mt-2">© {new Date().getFullYear()} TechPC. All rights reserved.</p>
    </footer>
  );
}
EOF

# 5. Hero
cat > src/components/Hero.tsx << 'EOF'
"use client";
import { motion } from "framer-motion";
import Link from "next/link";

export default function Hero() {
  return (
    <section className="max-w-7xl mx-auto px-6 py-24 grid md:grid-cols-2 gap-12 items-center">
      <motion.div initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.8 }}>
        <p className="text-cyan text-sm uppercase tracking-widest mb-4">✦ Hiệu năng vượt trội</p>
        <h1 className="font-display text-5xl md:text-6xl font-extrabold leading-tight">
          Build PC <span className="gradient-text">mơ ước</span> của bạn
        </h1>
        <p className="text-muted mt-6 text-lg">
          Cấu hình cao cấp — Bảo hành 36 tháng — Giao hàng 2h toàn quốc.
        </p>
        <div className="mt-8 flex gap-4">
          <Link href="/products" className="btn-brand">Xem sản phẩm →</Link>
          <Link href="/#contact" className="px-6 py-3 rounded-xl border border-cyan/40 text-cyan hover:bg-cyan/10 transition">Tư vấn ngay</Link>
        </div>
      </motion.div>

      <motion.div initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: 1 }} className="relative">
        <div className="absolute inset-0 bg-gradient-brand blur-3xl opacity-30 rounded-full" />
        <img
          src="https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=800"
          alt="PC Gaming"
          className="relative rounded-2xl shadow-2xl animate-float"
          style={{ width: "100%" }}
        />
      </motion.div>
    </section>
  );
}
EOF

# 6. AnimatedCounter
cat > src/components/AnimatedCounter.tsx << 'EOF'
"use client";
import { animate, useInView } from "framer-motion";
import { useEffect, useRef, useState } from "react";

export default function AnimatedCounter({ to }: { to: number }) {
  const ref = useRef<HTMLSpanElement>(null);
  const inView = useInView(ref, { once: true });
  const [display, setDisplay] = useState(0);

  useEffect(() => {
    if (!inView) return;
    const controls = animate(0, to, {
      duration: 1.8,
      onUpdate: (v) => setDisplay(Math.round(v)),
    });
    return () => controls.stop();
  }, [inView, to]);

  return <span ref={ref}>{display.toLocaleString("vi-VN")}</span>;
}
EOF

# 7. ProductCard
cat > src/components/ProductCard.tsx << 'EOF'
"use client";
import Link from "next/link";
import { motion } from "framer-motion";
import type { Product } from "@/types";

export default function ProductCard({ product, index = 0 }: { product: Product; index?: number }) {
  const mainImg = product.images.find((i) => i.isMain) || product.images[0];

  return (
    <motion.div
      initial={{ opacity: 0, y: 40 }}
      whileInView={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay: index * 0.08 }}
      viewport={{ once: true }}
      className="card card-hover overflow-hidden group"
    >
      <Link href={`/products/${product.slug}`}>
        <div className="aspect-[4/3] overflow-hidden bg-black/40">
          <img
            src={mainImg?.url || "/placeholder.png"}
            alt={product.name}
            className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
          />
        </div>
        <div className="p-5">
          <h3 className="font-display font-semibold text-lg">{product.name}</h3>
          <p className="text-muted text-sm mt-1 line-clamp-2">{product.shortDesc}</p>
          <div className="mt-4 flex items-baseline gap-2">
            <span className="text-cyan text-xl font-bold">{product.price.toLocaleString("vi-VN")}đ</span>
            {product.oldPrice && (
              <span className="text-muted text-sm line-through">{product.oldPrice.toLocaleString("vi-VN")}đ</span>
            )}
          </div>
        </div>
      </Link>
    </motion.div>
  );
}
EOF

# 8. ImageGallery
cat > src/components/ImageGallery.tsx << 'EOF'
"use client";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

export default function ImageGallery({ images }: { images: { url: string }[] }) {
  const [active, setActive] = useState(0);
  const [zoom, setZoom] = useState(false);
  if (!images.length) return null;

  return (
    <>
      <div className="space-y-4">
        <motion.div
          key={active}
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          className="aspect-square rounded-2xl overflow-hidden bg-black/40 cursor-zoom-in"
          onClick={() => setZoom(true)}
        >
          <img src={images[active].url} className="w-full h-full object-cover" />
        </motion.div>
        <div className="grid grid-cols-4 gap-3">
          {images.map((img, i) => (
            <button
              key={i}
              onClick={() => setActive(i)}
              className={`aspect-square rounded-lg overflow-hidden border-2 transition ${i === active ? "border-cyan shadow-[0_0_16px_rgba(0,229,255,.5)]" : "border-transparent opacity-70 hover:opacity-100"}`}
            >
              <img src={img.url} className="w-full h-full object-cover" />
            </button>
          ))}
        </div>
      </div>

      <AnimatePresence>
        {zoom && (
          <motion.div
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 bg-black/90 flex items-center justify-center p-8 cursor-zoom-out"
            onClick={() => setZoom(false)}
          >
            <motion.img
              initial={{ scale: 0.7 }} animate={{ scale: 1 }}
              src={images[active].url} className="max-w-full max-h-full rounded-xl"
            />
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
EOF

# 9. Toast
cat > src/components/Toast.tsx << 'EOF'
"use client";
import { motion, AnimatePresence } from "framer-motion";

export type ToastData = { id: number; type: "success" | "error"; message: string };

export default function Toast({ toasts }: { toasts: ToastData[] }) {
  return (
    <div className="fixed bottom-6 right-6 z-50 space-y-3">
      <AnimatePresence>
        {toasts.map((t) => (
          <motion.div
            key={t.id}
            initial={{ opacity: 0, x: 100 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 100 }}
            className={`px-5 py-3 rounded-xl shadow-lg font-medium text-sm ${t.type === "success" ? "bg-emerald-500 text-white" : "bg-red-500 text-white"}`}
          >
            {t.message}
          </motion.div>
        ))}
      </AnimatePresence>
    </div>
  );
}
EOF

# 10. ImageUploader
cat > src/components/ImageUploader.tsx << 'EOF'
"use client";
import { useState, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";

export type UploadedImage = { url: string; isMain: boolean };

export default function ImageUploader({
  images, setImages, onError,
}: {
  images: UploadedImage[];
  setImages: (imgs: UploadedImage[]) => void;
  onError: (msg: string) => void;
}) {
  const [uploading, setUploading] = useState(false);
  const [drag, setDrag] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  const handleFiles = async (files: FileList | File[]) => {
    setUploading(true);
    try {
      const fd = new FormData();
      Array.from(files).forEach((f) => fd.append("files", f));
      const res = await fetch("/api/upload", { method: "POST", body: fd });
      if (!res.ok) throw new Error("Upload thất bại");
      const { urls } = await res.json();
      const newImgs = (urls as string[]).map((url) => ({ url, isMain: false }));
      const merged = [...images, ...newImgs];
      if (!merged.some((i) => i.isMain) && merged.length) merged[0].isMain = true;
      setImages(merged);
    } catch (e: any) {
      onError(e.message);
    } finally {
      setUploading(false);
    }
  };

  const remove = (idx: number) => {
    const next = images.filter((_, i) => i !== idx);
    if (!next.some((i) => i.isMain) && next.length) next[0].isMain = true;
    setImages(next);
  };

  const setMain = (idx: number) =>
    setImages(images.map((img, i) => ({ ...img, isMain: i === idx })));

  return (
    <div className="space-y-4">
      <div
        onDragOver={(e) => { e.preventDefault(); setDrag(true); }}
        onDragLeave={() => setDrag(false)}
        onDrop={(e) => { e.preventDefault(); setDrag(false); handleFiles(e.dataTransfer.files); }}
        onClick={() => inputRef.current?.click()}
        className={`border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition ${drag ? "border-cyan bg-cyan/5" : "border-white/10 hover:border-cyan/40"}`}
      >
        <input
          ref={inputRef}
          type="file"
          multiple
          accept="image/*"
          className="hidden"
          onChange={(e) => e.target.files && handleFiles(e.target.files)}
        />
        <p className="text-4xl mb-2">☁️</p>
        <p className="text-muted">Kéo & thả ảnh vào đây hoặc <span className="text-cyan underline">chọn ảnh</span></p>
        <p className="text-xs text-muted mt-2">JPG, PNG, WEBP — nhiều ảnh cùng lúc</p>
      </div>

      {uploading && (
        <div className="h-1 bg-white/10 rounded overflow-hidden">
          <motion.div className="h-full bg-gradient-brand" initial={{ width: "0%" }} animate={{ width: "100%" }} transition={{ duration: 1.5 }} />
        </div>
      )}

      <div className="grid grid-cols-3 md:grid-cols-5 gap-3">
        <AnimatePresence>
          {images.map((img, i) => (
            <motion.div
              key={img.url}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.6 }}
              className={`relative aspect-square rounded-lg overflow-hidden border-2 ${img.isMain ? "border-cyan shadow-[0_0_16px_rgba(0,229,255,.6)]" : "border-white/10"}`}
            >
              <img src={img.url} className="w-full h-full object-cover" />
              <button type="button" onClick={() => remove(i)} className="absolute top-1 right-1 bg-red-500 text-white rounded-full w-6 h-6 text-xs">✕</button>
              <button type="button" onClick={() => setMain(i)} className={`absolute bottom-1 left-1 text-xs px-2 py-0.5 rounded ${img.isMain ? "bg-cyan text-black font-bold" : "bg-black/70 text-white"}`}>
                {img.isMain ? "⭐ Chính" : "Đặt chính"}
              </button>
            </motion.div>
          ))}
        </AnimatePresence>
      </div>
    </div>
  );
}
EOF

# 11. ProductForm
cat > src/components/ProductForm.tsx << 'EOF'
"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import ImageUploader, { UploadedImage } from "./ImageUploader";
import Toast, { ToastData } from "./Toast";

type Props = {
  categories: { id: string; name: string }[];
  product?: {
    id: string;
    name: string;
    shortDesc: string | null;
    longDesc: string | null;
    price: number;
    oldPrice: number | null;
    stock: number;
    isActive: boolean;
    categoryId: string | null;
    images: { url: string; isMain: boolean }[];
  };
};

export default function ProductForm({ categories, product }: Props) {
  const router = useRouter();
  const [form, setForm] = useState({
    name: product?.name || "",
    shortDesc: product?.shortDesc || "",
    longDesc: product?.longDesc || "",
    price: product?.price || 0,
    oldPrice: product?.oldPrice || 0,
    stock: product?.stock || 0,
    isActive: product?.isActive ?? true,
    categoryId: product?.categoryId || "",
  });
  const [images, setImages] = useState<UploadedImage[]>(
    product?.images.map((i) => ({ url: i.url, isMain: i.isMain })) || []
  );
  const [toasts, setToasts] = useState<ToastData[]>([]);
  const [saving, setSaving] = useState(false);

  const addToast = (type: "success" | "error", message: string) => {
    const id = Date.now();
    setToasts((t) => [...t, { id, type, message }]);
    setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 3000);
  };

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!images.length) return addToast("error", "Vui lòng thêm ít nhất 1 ảnh");
    setSaving(true);
    const body = { ...form, images };
    const url = product ? `/api/products/${product.id}` : "/api/products";
    const method = product ? "PUT" : "POST";
    const res = await fetch(url, {
      method,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
    setSaving(false);
    if (res.ok) {
      addToast("success", "Lưu thành công!");
      setTimeout(() => router.push("/admin/products"), 800);
    } else addToast("error", "Có lỗi xảy ra");
  };

  const input = "w-full bg-black/40 border border-white/10 rounded-lg px-4 py-2 mb-4 focus:border-cyan outline-none";

  return (
    <form onSubmit={submit} className="card p-8 space-y-4">
      <div className="grid md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm mb-1">Tên sản phẩm *</label>
          <input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} className={input} required />
        </div>
        <div>
          <label className="block text-sm mb-1">Danh mục</label>
          <select value={form.categoryId} onChange={(e) => setForm({ ...form, categoryId: e.target.value })} className={input}>
            <option value="">— Chọn —</option>
            {categories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
        </div>
        <div>
          <label className="block text-sm mb-1">Giá (đ) *</label>
          <input type="number" value={form.price} onChange={(e) => setForm({ ...form, price: +e.target.value })} className={input} required />
        </div>
        <div>
          <label className="block text-sm mb-1">Giá cũ (đ)</label>
          <input type="number" value={form.oldPrice} onChange={(e) => setForm({ ...form, oldPrice: +e.target.value })} className={input} />
        </div>
        <div>
          <label className="block text-sm mb-1">Số lượng</label>
          <input type="number" value={form.stock} onChange={(e) => setForm({ ...form, stock: +e.target.value })} className={input} />
        </div>
        <div className="flex items-end">
          <label className="flex items-center gap-2 mb-4">
            <input type="checkbox" checked={form.isActive} onChange={(e) => setForm({ ...form, isActive: e.target.checked })} />
            Hiển thị
          </label>
        </div>
      </div>

      <div>
        <label className="block text-sm mb-1">Mô tả ngắn</label>
        <textarea value={form.shortDesc} onChange={(e) => setForm({ ...form, shortDesc: e.target.value })} rows={2} className={input} />
      </div>
      <div>
        <label className="block text-sm mb-1">Mô tả chi tiết</label>
        <textarea value={form.longDesc} onChange={(e) => setForm({ ...form, longDesc: e.target.value })} rows={5} className={input} />
      </div>

      <div>
        <h3 className="font-display font-semibold mb-3">📸 Hình ảnh</h3>
        <ImageUploader images={images} setImages={setImages} onError={(m) => addToast("error", m)} />
      </div>

      <div className="flex gap-3 justify-end pt-4">
        <button type="button" onClick={() => router.back()} className="px-6 py-3 rounded-xl border border-white/10 hover:bg-white/5">Huỷ</button>
        <button disabled={saving} className="btn-brand">{saving ? "Đang lưu..." : "💾 Lưu sản phẩm"}</button>
      </div>

      <Toast toasts={toasts} />
    </form>
  );
}
EOF

# 12. CategoryManager
cat > src/components/CategoryManager.tsx << 'EOF'
"use client";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useRouter } from "next/navigation";

type Category = { id: string; name: string; slug: string; _count: { products: number } };

export default function CategoryManager({ initial }: { initial: Category[] }) {
  const router = useRouter();
  const [items, setItems] = useState(initial);
  const [newName, setNewName] = useState("");
  const [editing, setEditing] = useState<string | null>(null);
  const [editName, setEditName] = useState("");
  const [error, setError] = useState("");

  const refresh = async () => {
    const res = await fetch("/api/categories");
    const data = await res.json();
    setItems(data);
    router.refresh();
  };

  const add = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    if (!newName.trim()) return;
    const res = await fetch("/api/categories", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name: newName.trim() }),
    });
    if (!res.ok) { const j = await res.json(); setError(j.error); return; }
    setNewName("");
    await refresh();
  };

  const saveEdit = async (id: string) => {
    setError("");
    const res = await fetch(`/api/categories/${id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name: editName.trim() }),
    });
    if (!res.ok) { const j = await res.json(); setError(j.error); return; }
    setEditing(null);
    await refresh();
  };

  const del = async (id: string) => {
    setError("");
    if (!confirm("Xoá danh mục này?")) return;
    const res = await fetch(`/api/categories/${id}`, { method: "DELETE" });
    if (!res.ok) { const j = await res.json(); setError(j.error); return; }
    await refresh();
  };

  return (
    <div className="space-y-6">
      <form onSubmit={add} className="card p-6 flex gap-3 items-start">
        <div className="flex-1">
          <label className="block text-sm mb-1 text-muted">Thêm danh mục mới</label>
          <input value={newName} onChange={(e) => setNewName(e.target.value)} placeholder="VD: PC Workstation" className="w-full bg-black/40 border border-white/10 rounded-lg px-4 py-2 focus:border-cyan outline-none" />
        </div>
        <button type="submit" className="btn-brand mt-6">+ Thêm</button>
      </form>

      {error && (
        <motion.p initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} className="text-red-400 text-sm bg-red-500/10 px-4 py-2 rounded-lg">
          ⚠ {error}
        </motion.p>
      )}

      <div className="card overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-white/5 text-muted">
            <tr>
              <th className="text-left p-4">Tên danh mục</th>
              <th className="text-left p-4">Slug</th>
              <th className="text-left p-4">Sản phẩm</th>
              <th className="text-right p-4">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <AnimatePresence>
              {items.map((c) => (
                <motion.tr key={c.id} layout initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0, x: -20 }} className="border-t border-white/5">
                  <td className="p-4">
                    {editing === c.id ? (
                      <input autoFocus value={editName} onChange={(e) => setEditName(e.target.value)} onKeyDown={(e) => e.key === "Enter" && saveEdit(c.id)} className="bg-black/40 border border-cyan/50 rounded px-2 py-1 w-full outline-none" />
                    ) : (
                      <span className="font-medium">{c.name}</span>
                    )}
                  </td>
                  <td className="p-4 text-muted font-mono text-xs">{c.slug}</td>
                  <td className="p-4">
                    <span className="bg-cyan/10 text-cyan px-2 py-0.5 rounded text-xs">{c._count.products} SP</span>
                  </td>
                  <td className="p-4 text-right space-x-3">
                    {editing === c.id ? (
                      <>
                        <button type="button" onClick={() => saveEdit(c.id)} className="text-emerald-400 hover:underline">💾 Lưu</button>
                        <button type="button" onClick={() => setEditing(null)} className="text-muted hover:underline">Huỷ</button>
                      </>
                    ) : (
                      <>
                        <button type="button" onClick={() => { setEditing(c.id); setEditName(c.name); }} className="text-cyan hover:underline">✏ Sửa</button>
                        <button type="button" onClick={() => del(c.id)} className="text-red-400 hover:underline">🗑 Xoá</button>
                      </>
                    )}
                  </td>
                </motion.tr>
              ))}
            </AnimatePresence>
          </tbody>
        </table>
        {items.length === 0 && <p className="text-center text-muted py-8">Chưa có danh mục nào</p>}
      </div>
    </div>
  );
}
EOF

# 13. PasswordForm
cat > src/components/PasswordForm.tsx << 'EOF'
"use client";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { signOut } from "next-auth/react";

export default function PasswordForm() {
  const [form, setForm] = useState({ currentPassword: "", newPassword: "", confirmPassword: "" });
  const [loading, setLoading] = useState(false);
  const [toast, setToast] = useState<{ type: "success" | "error"; msg: string } | null>(null);
  const [show, setShow] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setToast(null);
    const res = await fetch("/api/admin/password", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(form),
    });
    const data = await res.json();
    setLoading(false);

    if (res.ok) {
      setToast({ type: "success", msg: data.message + " — Đăng xuất sau 2 giây..." });
      setForm({ currentPassword: "", newPassword: "", confirmPassword: "" });
      setTimeout(() => signOut({ callbackUrl: "/login" }), 2000);
    } else {
      setToast({ type: "error", msg: data.error });
    }
  };

  const input = "w-full bg-black/40 border border-white/10 rounded-lg px-4 py-2 pr-12 mb-4 focus:border-cyan outline-none";

  return (
    <form onSubmit={submit} className="card p-8 max-w-lg">
      <div className="flex items-center gap-3 mb-6">
        <span className="text-3xl">🔐</span>
        <div>
          <h2 className="font-display text-xl font-semibold">Đổi mật khẩu</h2>
          <p className="text-muted text-sm">Cập nhật mật khẩu đăng nhập admin</p>
        </div>
      </div>

      <div className="relative">
        <label className="block text-sm mb-1">Mật khẩu hiện tại</label>
        <input type={show ? "text" : "password"} value={form.currentPassword} onChange={(e) => setForm({ ...form, currentPassword: e.target.value })} className={input} required />
      </div>

      <div className="relative">
        <label className="block text-sm mb-1">Mật khẩu mới (≥ 6 ký tự)</label>
        <input type={show ? "text" : "password"} value={form.newPassword} onChange={(e) => setForm({ ...form, newPassword: e.target.value })} className={input} required />
      </div>

      <div className="relative">
        <label className="block text-sm mb-1">Xác nhận mật khẩu mới</label>
        <input type={show ? "text" : "password"} value={form.confirmPassword} onChange={(e) => setForm({ ...form, confirmPassword: e.target.value })} className={input} required />
        <button type="button" onClick={() => setShow(!show)} className="absolute right-3 top-9 text-muted hover:text-cyan">
          {show ? "🙈" : "👁"}
        </button>
      </div>

      <AnimatePresence>
        {toast && (
          <motion.p initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }} className={`mb-4 px-4 py-2 rounded-lg text-sm ${toast.type === "success" ? "bg-emerald-500/15 text-emerald-400" : "bg-red-500/15 text-red-400"}`}>
            {toast.type === "success" ? "✓ " : "⚠ "}{toast.msg}
          </motion.p>
        )}
      </AnimatePresence>

      <button disabled={loading} className="btn-brand w-full">{loading ? "Đang cập nhật..." : "💾 Cập nhật mật khẩu"}</button>
    </form>
  );
}
EOF

# 14. StructuredData
cat > src/components/StructuredData.tsx << 'EOF'
export default function StructuredData({ data }: { data: Record<string, unknown> }) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}
EOF

echo ""
echo "════════════════════════════════════════════════"
echo "  ✅ PHẦN 2/3 HOÀN TẤT!"
echo "════════════════════════════════════════════════"
echo ""
echo "📊 Đã tạo thành công 14 components giao diện."
echo "👉 Bước tiếp theo: Reply 'tiếp 3' để nhận script tạo API và Pages (Phần 3/3)."
echo ""
