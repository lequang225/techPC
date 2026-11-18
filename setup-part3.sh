#!/bin/bash
set -e
cd "$(dirname "$0")"

echo ""
echo "════════════════════════════════════════════════"
echo "  🔌 TechPC Setup — PHẦN 3/3 (API + Pages)"
echo "════════════════════════════════════════════════"
echo ""

mkdir -p src/app/api/auth/"[...nextauth]"
mkdir -p src/app/api/upload
mkdir -p src/app/api/products/"[id]"
mkdir -p src/app/api/categories/"[id]"
mkdir -p src/app/api/admin/password
mkdir -p src/app/products/"[slug]"
mkdir -p src/app/login
mkdir -p src/app/admin/products/new
mkdir -p src/app/admin/products/"[id]"/edit
mkdir -p src/app/admin/categories
mkdir -p src/app/admin/settings

echo "🔌 Đang tạo API Routes (7 file)..."

cat > 'src/app/api/auth/[...nextauth]/route.ts' << 'EOF'
import NextAuth from "next-auth";
import { authOptions } from "@/lib/auth";
const handler = NextAuth(authOptions);
export { handler as GET, handler as POST };
EOF

cat > src/app/api/upload/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { uploadFile } from "@/lib/upload";

export const runtime = "nodejs";

export async function POST(req: NextRequest) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const formData = await req.formData();
  const files = formData.getAll("files") as File[];
  if (!files.length) return NextResponse.json({ error: "No files" }, { status: 400 });

  const urls = await Promise.all(files.map(uploadFile));
  return NextResponse.json({ urls });
}
EOF

cat > src/app/api/products/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { slugify } from "@/lib/slug";

export async function GET() {
  const products = await prisma.product.findMany({
    where: { isActive: true },
    include: { images: { orderBy: { order: "asc" } }, category: true },
    orderBy: { createdAt: "desc" },
  });
  return NextResponse.json(products);
}

export async function POST(req: NextRequest) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const body = await req.json();
  const { name, shortDesc, longDesc, price, oldPrice, stock, isActive, categoryId, images } = body;
  const slug = slugify(name) + "-" + Date.now().toString(36);

  const product = await prisma.product.create({
    data: {
      name, slug, shortDesc, longDesc,
      price: Number(price) || 0,
      oldPrice: oldPrice ? Number(oldPrice) : null,
      stock: Number(stock) || 0,
      isActive: !!isActive,
      categoryId: categoryId || null,
      images: {
        create: (images as { url: string; isMain: boolean }[]).map((img, i) => ({
          url: img.url, isMain: img.isMain, order: i,
        })),
      },
    },
    include: { images: true },
  });
  return NextResponse.json(product);
}
EOF

cat > 'src/app/api/products/[id]/route.ts' << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const body = await req.json();
  const { name, shortDesc, longDesc, price, oldPrice, stock, isActive, categoryId, images } = body;

  await prisma.image.deleteMany({ where: { productId: params.id } });

  const product = await prisma.product.update({
    where: { id: params.id },
    data: {
      name, shortDesc, longDesc,
      price: Number(price) || 0,
      oldPrice: oldPrice ? Number(oldPrice) : null,
      stock: Number(stock) || 0,
      isActive: !!isActive,
      categoryId: categoryId || null,
      images: {
        create: (images as { url: string; isMain: boolean }[]).map((img, i) => ({
          url: img.url, isMain: img.isMain, order: i,
        })),
      },
    },
    include: { images: true },
  });
  return NextResponse.json(product);
}

export async function DELETE(_: NextRequest, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  await prisma.product.delete({ where: { id: params.id } });
  return NextResponse.json({ ok: true });
}
EOF

cat > src/app/api/categories/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { slugify } from "@/lib/slug";

export async function GET() {
  const categories = await prisma.category.findMany({
    include: { _count: { select: { products: true } } },
    orderBy: { createdAt: "asc" },
  });
  return NextResponse.json(categories);
}

export async function POST(req: NextRequest) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const { name } = await req.json();
  if (!name?.trim()) return NextResponse.json({ error: "Tên không hợp lệ" }, { status: 400 });

  const slug = slugify(name);
  const exists = await prisma.category.findFirst({ where: { OR: [{ name }, { slug }] } });
  if (exists) return NextResponse.json({ error: "Danh mục đã tồn tại" }, { status: 409 });

  const category = await prisma.category.create({ data: { name, slug } });
  return NextResponse.json(category);
}
EOF

cat > 'src/app/api/categories/[id]/route.ts' << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { slugify } from "@/lib/slug";

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const { name } = await req.json();
  if (!name?.trim()) return NextResponse.json({ error: "Tên không hợp lệ" }, { status: 400 });

  const category = await prisma.category.update({
    where: { id: params.id },
    data: { name, slug: slugify(name) },
  });
  return NextResponse.json(category);
}

export async function DELETE(_: NextRequest, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const count = await prisma.product.count({ where: { categoryId: params.id } });
  if (count > 0) {
    return NextResponse.json(
      { error: `Còn ${count} sản phẩm trong danh mục này, không thể xoá` },
      { status: 400 }
    );
  }
  await prisma.category.delete({ where: { id: params.id } });
  return NextResponse.json({ ok: true });
}
EOF

cat > src/app/api/admin/password/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import bcrypt from "bcryptjs";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";

export async function POST(req: NextRequest) {
  const session = await getServerSession(authOptions);
  if (!session?.user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const { currentPassword, newPassword, confirmPassword } = await req.json();

  if (!currentPassword || !newPassword || !confirmPassword)
    return NextResponse.json({ error: "Vui lòng điền đầy đủ" }, { status: 400 });
  if (newPassword.length < 6)
    return NextResponse.json({ error: "Mật khẩu mới tối thiểu 6 ký tự" }, { status: 400 });
  if (newPassword !== confirmPassword)
    return NextResponse.json({ error: "Mật khẩu xác nhận không khớp" }, { status: 400 });
  if (newPassword === currentPassword)
    return NextResponse.json({ error: "Mật khẩu mới phải khác mật khẩu cũ" }, { status: 400 });

  const user = await prisma.user.findUnique({ where: { username: session.user.name as string } });
  if (!user) return NextResponse.json({ error: "Không tìm thấy user" }, { status: 404 });

  const ok = await bcrypt.compare(currentPassword, user.password);
  if (!ok) return NextResponse.json({ error: "Mật khẩu hiện tại không đúng" }, { status: 400 });

  const hashed = await bcrypt.hash(newPassword, 10);
  await prisma.user.update({ where: { id: user.id }, data: { password: hashed } });

  return NextResponse.json({ ok: true, message: "Đổi mật khẩu thành công" });
}
EOF

echo "📄 Đang tạo Pages (18 file)..."

cat > src/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import url("https://fonts.googleapis.com/css2?family=Poppins:wght@600;700;800&family=Inter:wght@400;500;600&display=swap");

html { scroll-behavior: smooth; }
body {
  background: #0a0e1a;
  color: #f5f7fa;
  font-family: "Inter", system-ui, sans-serif;
}

.gradient-text {
  background: linear-gradient(135deg, #00e5ff 0%, #7c3aed 100%);
  background-size: 200% auto;
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  animation: shine 4s linear infinite;
}
@keyframes shine { to { background-position: 200% center; } }

.btn-brand {
  background: linear-gradient(135deg, #00e5ff, #7c3aed);
  background-size: 200% auto;
  transition: background-position .5s;
  color: #0a0e1a;
  font-weight: 600;
  border-radius: 12px;
  padding: .75rem 1.5rem;
  display: inline-block;
}
.btn-brand:hover { background-position: right center; box-shadow: 0 0 24px rgba(0,229,255,.6); }
.btn-brand:disabled { opacity: .6; cursor: not-allowed; }

.card { background: #131a2b; border-radius: 16px; border: 1px solid rgba(255,255,255,.05); }
.card-hover { transition: transform .3s, box-shadow .3s, border-color .3s; }
.card-hover:hover { transform: translateY(-8px); border-color: #00e5ff; box-shadow: 0 12px 40px rgba(0,229,255,.15); }
EOF

cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from "next";
import "./globals.css";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import ScrollProgress from "@/components/ScrollProgress";
import Particles from "@/components/Particles";

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

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="vi">
      <body>
        <Particles />
        <ScrollProgress />
        <Navbar />
        <main className="min-h-screen">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
EOF

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

  const orgSchema = {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: "TechPC",
    url: process.env.NEXTAUTH_URL || "http://localhost:3000",
    contactPoint: { "@type": "ContactPoint", telephone: "1900-1234", contactType: "customer service", areaServed: "VN" },
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
      <Hero />
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

cat > src/app/not-found.tsx << 'EOF'
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
EOF

cat > src/app/robots.ts << 'EOF'
import { MetadataRoute } from "next";
const SITE_URL = process.env.NEXTAUTH_URL || "http://localhost:3000";
export default function robots(): MetadataRoute.Robots {
  return {
    rules: [{ userAgent: "*", allow: "/", disallow: ["/admin", "/api", "/login"] }],
    sitemap: `${SITE_URL}/sitemap.xml`,
    host: SITE_URL,
  };
}
EOF

cat > src/app/sitemap.ts << 'EOF'
import { MetadataRoute } from "next";
import { prisma } from "@/lib/prisma";

const SITE_URL = process.env.NEXTAUTH_URL || "http://localhost:3000";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const products = await prisma.product.findMany({
    where: { isActive: true },
    select: { slug: true, updatedAt: true },
  });

  const productUrls: MetadataRoute.Sitemap = products.map((p) => ({
    url: `${SITE_URL}/products/${p.slug}`,
    lastModified: p.updatedAt,
    changeFrequency: "weekly",
    priority: 0.8,
  }));

  return [
    { url: SITE_URL, lastModified: new Date(), changeFrequency: "daily", priority: 1 },
    { url: `${SITE_URL}/products`, lastModified: new Date(), changeFrequency: "daily", priority: 0.9 },
    ...productUrls,
  ];
}
EOF

cat > src/app/products/page.tsx << 'EOF'
import type { Metadata } from "next";
import ProductCard from "@/components/ProductCard";
import { prisma } from "@/lib/prisma";

export const metadata: Metadata = {
  title: "Tất cả sản phẩm",
  description: "Khám phá toàn bộ PC Gaming, Đồ họa, Văn phòng, Mini tại TechPC.",
  alternates: { canonical: "/products" },
};

export const dynamic = "force-dynamic";

export default async function ProductsPage() {
  const products = await prisma.product.findMany({
    where: { isActive: true },
    include: { images: { orderBy: { order: "asc" } }, category: true },
    orderBy: { createdAt: "desc" },
  });

  return (
    <div className="max-w-7xl mx-auto px-6 py-16">
      <h1 className="font-display text-4xl font-bold mb-10">
        Tất cả <span className="gradient-text">sản phẩm</span>
      </h1>
      <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
        {products.map((p, i) => <ProductCard key={p.id} product={p} index={i} />)}
      </div>
      {products.length === 0 && <p className="text-muted text-center py-12">Chưa có sản phẩm nào.</p>}
    </div>
  );
}
EOF

cat > 'src/app/products/[slug]/page.tsx' << 'EOF'
import type { Metadata } from "next";
import ImageGallery from "@/components/ImageGallery";
import StructuredData from "@/components/StructuredData";
import { prisma } from "@/lib/prisma";
import { notFound } from "next/navigation";

const SITE_URL = process.env.NEXTAUTH_URL || "http://localhost:3000";

export async function generateMetadata({ params }: { params: { slug: string } }): Promise<Metadata> {
  const product = await prisma.product.findUnique({
    where: { slug: params.slug },
    include: { images: { orderBy: { order: "asc" } } },
  });
  if (!product) return { title: "Không tìm thấy sản phẩm" };
  const mainImg = product.images[0]?.url;
  const url = `${SITE_URL}/products/${product.slug}`;
  return {
    title: product.name,
    description: product.shortDesc || `Mua ${product.name} chính hãng, bảo hành 36 tháng tại TechPC.`,
    alternates: { canonical: url },
    openGraph: { type: "website", url, title: product.name, description: product.shortDesc || "", images: mainImg ? [{ url: mainImg }] : [] },
    twitter: { card: "summary_large_image", title: product.name, description: product.shortDesc || "", images: mainImg ? [mainImg] : [] },
  };
}

export const dynamic = "force-dynamic";

export default async function ProductDetail({ params }: { params: { slug: string } }) {
  const product = await prisma.product.findUnique({
    where: { slug: params.slug },
    include: { images: { orderBy: { order: "asc" } }, category: true },
  });
  if (!product) notFound();

  const productSchema = {
    "@context": "https://schema.org",
    "@type": "Product",
    name: product.name,
    description: product.shortDesc || "",
    image: product.images.map((i) => i.url),
    sku: product.id,
    brand: { "@type": "Brand", name: "TechPC" },
    offers: {
      "@type": "Offer",
      url: `${SITE_URL}/products/${product.slug}`,
      priceCurrency: "VND", price: product.price,
      availability: product.stock > 0 ? "https://schema.org/InStock" : "https://schema.org/OutOfStock",
      seller: { "@type": "Organization", name: "TechPC" },
    },
  };

  return (
    <>
      <StructuredData data={productSchema} />
      <div className="max-w-7xl mx-auto px-6 py-16 grid md:grid-cols-2 gap-12">
        <ImageGallery images={product.images} />
        <div>
          {product.category && <p className="text-cyan text-sm uppercase mb-2">{product.category.name}</p>}
          <h1 className="font-display text-3xl md:text-4xl font-bold">{product.name}</h1>
          <p className="text-muted mt-3">{product.shortDesc}</p>
          <div className="mt-6 flex items-baseline gap-3">
            <span className="text-cyan text-3xl font-bold">{product.price.toLocaleString("vi-VN")}đ</span>
            {product.oldPrice && <span className="text-muted line-through">{product.oldPrice.toLocaleString("vi-VN")}đ</span>}
          </div>
          <p className="mt-6 text-muted whitespace-pre-line">{product.longDesc || "Chưa có mô tả chi tiết."}</p>
          <div className="mt-8 flex gap-3">
            <button className="btn-brand">🛒 Thêm vào giỏ</button>
            <button className="px-6 py-3 rounded-xl border border-cyan/40 text-cyan hover:bg-cyan/10 transition">Tư vấn</button>
          </div>
          <p className="mt-4 text-sm text-muted">Còn {product.stock} sản phẩm • Bảo hành 36 tháng</p>
        </div>
      </div>
    </>
  );
}
EOF

cat > src/app/login/page.tsx << 'EOF'
"use client";
import { signIn } from "next-auth/react";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";

export default function LoginPage() {
  const router = useRouter();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true); setError("");
    const res = await signIn("credentials", { username, password, redirect: false });
    setLoading(false);
    if (res?.error) setError("Sai tài khoản hoặc mật khẩu");
    else router.push("/admin");
  };

  return (
    <div className="min-h-[80vh] flex items-center justify-center px-6">
      <motion.form onSubmit={submit} initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} className="card p-8 w-full max-w-md">
        <h1 className="font-display text-2xl font-bold text-center mb-1 gradient-text">◆ TechPC</h1>
        <p className="text-center text-muted text-sm mb-6">Đăng nhập quản trị</p>
        <label className="block text-sm mb-1">Tên đăng nhập</label>
        <input value={username} onChange={(e) => setUsername(e.target.value)} className="w-full bg-black/40 border border-white/10 rounded-lg px-4 py-2 mb-4 focus:border-cyan outline-none" required />
        <label className="block text-sm mb-1">Mật khẩu</label>
        <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} className="w-full bg-black/40 border border-white/10 rounded-lg px-4 py-2 mb-4 focus:border-cyan outline-none" required />
        {error && <p className="text-red-400 text-sm mb-3">{error}</p>}
        <button disabled={loading} className="btn-brand w-full">{loading ? "Đang đăng nhập..." : "Đăng nhập"}</button>
        <p className="text-xs text-muted text-center mt-4">Demo: admin / admin123</p>
      </motion.form>
    </div>
  );
}
EOF

cat > src/app/login/layout.tsx << 'EOF'
import type { Metadata } from "next";
export const metadata: Metadata = { title: "Đăng nhập", robots: { index: false, follow: false } };
export default function LoginLayout({ children }: { children: React.ReactNode }) {
  return <>{children}</>;
}
EOF

cat > src/app/admin/layout.tsx << 'EOF'
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
EOF

cat > src/app/admin/page.tsx << 'EOF'
import { prisma } from "@/lib/prisma";
export const dynamic = "force-dynamic";
export default async function AdminDashboard() {
  const [productCount, imageCount, categoryCount] = await Promise.all([
    prisma.product.count(), prisma.image.count(), prisma.category.count(),
  ]);
  const cards = [
    { label: "Sản phẩm", value: productCount },
    { label: "Danh mục", value: categoryCount },
    { label: "Hình ảnh", value: imageCount },
  ];
  return (
    <div>
      <h1 className="font-display text-3xl font-bold mb-6">📊 Dashboard</h1>
      <div className="grid md:grid-cols-3 gap-6">
        {cards.map((c) => (
          <div key={c.label} className="card p-6">
            <p className="text-muted text-sm">{c.label}</p>
            <p className="font-display text-4xl font-bold gradient-text mt-2">{c.value}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
EOF

cat > src/app/admin/products/page.tsx << 'EOF'
import Link from "next/link";
import { prisma } from "@/lib/prisma";
import DeleteButton from "./DeleteButton";
export const dynamic = "force-dynamic";
export default async function AdminProducts() {
  const products = await prisma.product.findMany({
    include: { images: { orderBy: { order: "asc" } } },
    orderBy: { createdAt: "desc" },
  });
  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="font-display text-3xl font-bold">📦 Sản phẩm</h1>
        <Link href="/admin/products/new" className="btn-brand text-sm">+ Thêm sản phẩm</Link>
      </div>
      <div className="card overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-white/5 text-muted">
            <tr>
              <th className="text-left p-4">Ảnh</th>
              <th className="text-left p-4">Tên</th>
              <th className="text-left p-4">Giá</th>
              <th className="text-left p-4">Trạng thái</th>
              <th className="text-right p-4">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {products.map((p) => (
              <tr key={p.id} className="border-t border-white/5">
                <td className="p-4">{p.images[0] ? <img src={p.images[0].url} className="w-14 h-14 rounded-lg object-cover" /> : <div className="w-14 h-14 bg-white/5 rounded-lg" />}</td>
                <td className="p-4 font-medium">{p.name}</td>
                <td className="p-4 text-cyan">{p.price.toLocaleString("vi-VN")}đ</td>
                <td className="p-4"><span className={p.isActive ? "text-emerald-400" : "text-muted"}>{p.isActive ? "● Hiện" : "○ Ẩn"}</span></td>
                <td className="p-4 text-right space-x-3">
                  <Link href={`/admin/products/${p.id}/edit`} className="text-cyan hover:underline">✏ Sửa</Link>
                  <DeleteButton id={p.id} />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {products.length === 0 && <p className="text-center text-muted py-8">Chưa có sản phẩm</p>}
      </div>
    </div>
  );
}
EOF

cat > src/app/admin/products/DeleteButton.tsx << 'EOF'
"use client";
import { useRouter } from "next/navigation";
export default function DeleteButton({ id }: { id: string }) {
  const router = useRouter();
  const del = async () => {
    if (!confirm("Xoá sản phẩm này?")) return;
    await fetch(`/api/products/${id}`, { method: "DELETE" });
    router.refresh();
  };
  return <button onClick={del} className="text-red-400 hover:underline">🗑 Xoá</button>;
}
EOF

cat > src/app/admin/products/new/page.tsx << 'EOF'
import { prisma } from "@/lib/prisma";
import ProductForm from "@/components/ProductForm";
export default async function NewProduct() {
  const categories = await prisma.category.findMany();
  return (
    <div>
      <h1 className="font-display text-3xl font-bold mb-6">➕ Thêm sản phẩm</h1>
      <ProductForm categories={categories} />
    </div>
  );
}
EOF

cat > 'src/app/admin/products/[id]/edit/page.tsx' << 'EOF'
import { prisma } from "@/lib/prisma";
import ProductForm from "@/components/ProductForm";
import { notFound } from "next/navigation";
export default async function EditProduct({ params }: { params: { id: string } }) {
  const [product, categories] = await Promise.all([
    prisma.product.findUnique({ where: { id: params.id }, include: { images: { orderBy: { order: "asc" } } } }),
    prisma.category.findMany(),
  ]);
  if (!product) notFound();
  return (
    <div>
      <h1 className="font-display text-3xl font-bold mb-6">✏ Sửa sản phẩm</h1>
      <ProductForm categories={categories} product={product} />
    </div>
  );
}
EOF

cat > src/app/admin/categories/page.tsx << 'EOF'
import { prisma } from "@/lib/prisma";
import CategoryManager from "@/components/CategoryManager";
export const dynamic = "force-dynamic";
export default async function AdminCategories() {
  const categories = await prisma.category.findMany({
    include: { _count: { select: { products: true } } },
    orderBy: { createdAt: "asc" },
  });
  return (
    <div>
      <h1 className="font-display text-3xl font-bold mb-6">🏷 Danh mục</h1>
      <CategoryManager initial={categories} />
    </div>
  );
}
EOF

cat > src/app/admin/settings/page.tsx << 'EOF'
import PasswordForm from "@/components/PasswordForm";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
export default async function AdminSettings() {
  const session = await getServerSession(authOptions);
  return (
    <div>
      <h1 className="font-display text-3xl font-bold mb-6">⚙️ Cài đặt</h1>
      <div className="card p-6 mb-8">
        <p className="text-muted text-sm mb-1">Đang đăng nhập với tài khoản</p>
        <p className="font-display text-xl font-semibold gradient-text">👤 {session?.user?.name}</p>
      </div>
      <PasswordForm />
    </div>
  );
}
EOF

echo ""
echo "════════════════════════════════════════════════"
echo "  ✅ PHẦN 3/3 HOÀN TẤT!"
echo "════════════════════════════════════════════════"
echo ""
echo "🎉 CHÚC MỪNG! Dự án TechPC đã được tạo đầy đủ."
echo "👉 Bây giờ bạn hãy chạy lệnh: npm run dev"
echo "👉 Mở trình duyệt: http://localhost:3000"
echo ""
