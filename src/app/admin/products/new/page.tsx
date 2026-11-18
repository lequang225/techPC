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
