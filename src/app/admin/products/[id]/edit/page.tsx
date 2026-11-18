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
