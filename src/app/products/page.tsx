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
