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
