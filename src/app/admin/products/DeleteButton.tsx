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
