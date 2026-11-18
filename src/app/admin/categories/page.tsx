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
