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
