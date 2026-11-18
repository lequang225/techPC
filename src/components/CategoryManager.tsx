"use client";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useRouter } from "next/navigation";

type Category = { id: string; name: string; slug: string; _count: { products: number } };

export default function CategoryManager({ initial }: { initial: Category[] }) {
  const router = useRouter();
  const [items, setItems] = useState(initial);
  const [newName, setNewName] = useState("");
  const [editing, setEditing] = useState<string | null>(null);
  const [editName, setEditName] = useState("");
  const [error, setError] = useState("");

  const refresh = async () => {
    const res = await fetch("/api/categories");
    const data = await res.json();
    setItems(data);
    router.refresh();
  };

  const add = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    if (!newName.trim()) return;
    const res = await fetch("/api/categories", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name: newName.trim() }),
    });
    if (!res.ok) { const j = await res.json(); setError(j.error); return; }
    setNewName("");
    await refresh();
  };

  const saveEdit = async (id: string) => {
    setError("");
    const res = await fetch(`/api/categories/${id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name: editName.trim() }),
    });
    if (!res.ok) { const j = await res.json(); setError(j.error); return; }
    setEditing(null);
    await refresh();
  };

  const del = async (id: string) => {
    setError("");
    if (!confirm("Xoá danh mục này?")) return;
    const res = await fetch(`/api/categories/${id}`, { method: "DELETE" });
    if (!res.ok) { const j = await res.json(); setError(j.error); return; }
    await refresh();
  };

  return (
    <div className="space-y-6">
      <form onSubmit={add} className="card p-6 flex gap-3 items-start">
        <div className="flex-1">
          <label className="block text-sm mb-1 text-muted">Thêm danh mục mới</label>
          <input value={newName} onChange={(e) => setNewName(e.target.value)} placeholder="VD: PC Workstation" className="w-full bg-black/40 border border-white/10 rounded-lg px-4 py-2 focus:border-cyan outline-none" />
        </div>
        <button type="submit" className="btn-brand mt-6">+ Thêm</button>
      </form>

      {error && (
        <motion.p initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} className="text-red-400 text-sm bg-red-500/10 px-4 py-2 rounded-lg">
          ⚠ {error}
        </motion.p>
      )}

      <div className="card overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-white/5 text-muted">
            <tr>
              <th className="text-left p-4">Tên danh mục</th>
              <th className="text-left p-4">Slug</th>
              <th className="text-left p-4">Sản phẩm</th>
              <th className="text-right p-4">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <AnimatePresence>
              {items.map((c) => (
                <motion.tr key={c.id} layout initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0, x: -20 }} className="border-t border-white/5">
                  <td className="p-4">
                    {editing === c.id ? (
                      <input autoFocus value={editName} onChange={(e) => setEditName(e.target.value)} onKeyDown={(e) => e.key === "Enter" && saveEdit(c.id)} className="bg-black/40 border border-cyan/50 rounded px-2 py-1 w-full outline-none" />
                    ) : (
                      <span className="font-medium">{c.name}</span>
                    )}
                  </td>
                  <td className="p-4 text-muted font-mono text-xs">{c.slug}</td>
                  <td className="p-4">
                    <span className="bg-cyan/10 text-cyan px-2 py-0.5 rounded text-xs">{c._count.products} SP</span>
                  </td>
                  <td className="p-4 text-right space-x-3">
                    {editing === c.id ? (
                      <>
                        <button type="button" onClick={() => saveEdit(c.id)} className="text-emerald-400 hover:underline">💾 Lưu</button>
                        <button type="button" onClick={() => setEditing(null)} className="text-muted hover:underline">Huỷ</button>
                      </>
                    ) : (
                      <>
                        <button type="button" onClick={() => { setEditing(c.id); setEditName(c.name); }} className="text-cyan hover:underline">✏ Sửa</button>
                        <button type="button" onClick={() => del(c.id)} className="text-red-400 hover:underline">🗑 Xoá</button>
                      </>
                    )}
                  </td>
                </motion.tr>
              ))}
            </AnimatePresence>
          </tbody>
        </table>
        {items.length === 0 && <p className="text-center text-muted py-8">Chưa có danh mục nào</p>}
      </div>
    </div>
  );
}
