"use client";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import ImageUploader, { UploadedImage } from "./ImageUploader";
import Toast, { ToastData } from "./Toast";

export default function SettingsForm() {
  const router = useRouter();
  const [form, setForm] = useState({
    bannerTitle: "",
    bannerSubtitle: "",
    bannerButton: "",
    footerAddress: "",
    footerPhone: "",
    footerEmail: "",
  });
  const [bannerImgs, setBannerImgs] = useState<UploadedImage[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [toasts, setToasts] = useState<ToastData[]>([]);

  const addToast = (type: "success" | "error", message: string) => {
    const id = Date.now();
    setToasts((t) => [...t, { id, type, message }]);
    setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 3000);
  };

  useEffect(() => {
    fetch("/api/settings")
      .then((res) => res.json())
      .then((data) => {
        setForm({
          bannerTitle: data.bannerTitle || "",
          bannerSubtitle: data.bannerSubtitle || "",
          bannerButton: data.bannerButton || "",
          footerAddress: data.footerAddress || "",
          footerPhone: data.footerPhone || "",
          footerEmail: data.footerEmail || "",
        });
        // Map mảng string thành mảng object cho ImageUploader
        if (data.bannerImages && Array.isArray(data.bannerImages)) {
          setBannerImgs(data.bannerImages.map((url: string, i: number) => ({ url, isMain: i === 0 })));
        }
        setLoading(false);
      });
  }, []);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    const body = { ...form, bannerImages: bannerImgs.map((img) => img.url) };
    const res = await fetch("/api/settings", {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
    setSaving(false);
    if (res.ok) {
      addToast("success", "Lưu cài đặt thành công!");
      router.refresh();
    } else {
      addToast("error", "Có lỗi xảy ra khi lưu");
    }
  };

  const input = "w-full bg-black/40 border border-white/10 rounded-lg px-4 py-2 mb-4 focus:border-cyan outline-none";

  if (loading) return <p className="text-muted">Đang tải dữ liệu...</p>;

  return (
    <form onSubmit={submit} className="card p-8 space-y-8 max-w-4xl">
      <div>
        <h3 className="font-display text-xl font-bold mb-4 text-cyan border-b border-white/10 pb-2">🖼️ Cài đặt Banner (Trang chủ)</h3>
        <div className="grid md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm mb-1">Tiêu đề chính</label>
            <input value={form.bannerTitle} onChange={(e) => setForm({ ...form, bannerTitle: e.target.value })} className={input} required />
          </div>
          <div>
            <label className="block text-sm mb-1">Chữ trên nút bấm</label>
            <input value={form.bannerButton} onChange={(e) => setForm({ ...form, bannerButton: e.target.value })} className={input} required />
          </div>
        </div>
        <div>
          <label className="block text-sm mb-1">Tiêu đề phụ (Mô tả)</label>
          <textarea value={form.bannerSubtitle} onChange={(e) => setForm({ ...form, bannerSubtitle: e.target.value })} rows={2} className={input} required />
        </div>
        <div>
          <label className="block text-sm mb-1">Hình ảnh Banner (Có thể tải lên nhiều ảnh để chạy Slide)</label>
          <ImageUploader images={bannerImgs} setImages={setBannerImgs} onError={(m) => addToast("error", m)} />
        </div>
      </div>

      <div>
        <h3 className="font-display text-xl font-bold mb-4 text-cyan border-b border-white/10 pb-2">📍 Cài đặt Footer (Chân trang)</h3>
        <div className="grid md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm mb-1">Số điện thoại / Hotline</label>
            <input value={form.footerPhone} onChange={(e) => setForm({ ...form, footerPhone: e.target.value })} className={input} required />
          </div>
          <div>
            <label className="block text-sm mb-1">Email liên hệ</label>
            <input value={form.footerEmail} onChange={(e) => setForm({ ...form, footerEmail: e.target.value })} className={input} required />
          </div>
        </div>
        <div>
          <label className="block text-sm mb-1">Địa chỉ</label>
          <input value={form.footerAddress} onChange={(e) => setForm({ ...form, footerAddress: e.target.value })} className={input} required />
        </div>
      </div>

      <div className="flex justify-end pt-4 border-t border-white/10">
        <button disabled={saving} className="btn-brand">{saving ? "Đang lưu..." : "💾 Lưu tất cả cài đặt"}</button>
      </div>

      <Toast toasts={toasts} />
    </form>
  );
}
