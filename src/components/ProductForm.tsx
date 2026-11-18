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
