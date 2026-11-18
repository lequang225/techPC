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
