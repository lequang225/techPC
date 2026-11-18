"use client";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { signOut } from "next-auth/react";

export default function PasswordForm() {
  const [form, setForm] = useState({ currentPassword: "", newPassword: "", confirmPassword: "" });
  const [loading, setLoading] = useState(false);
  const [toast, setToast] = useState<{ type: "success" | "error"; msg: string } | null>(null);
  const [show, setShow] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setToast(null);
    const res = await fetch("/api/admin/password", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(form),
    });
    const data = await res.json();
    setLoading(false);

    if (res.ok) {
      setToast({ type: "success", msg: data.message + " — Đăng xuất sau 2 giây..." });
      setForm({ currentPassword: "", newPassword: "", confirmPassword: "" });
      setTimeout(() => signOut({ callbackUrl: "/login" }), 2000);
    } else {
      setToast({ type: "error", msg: data.error });
    }
  };

  const input = "w-full bg-black/40 border border-white/10 rounded-lg px-4 py-2 pr-12 mb-4 focus:border-cyan outline-none";

  return (
    <form onSubmit={submit} className="card p-8 max-w-lg">
      <div className="flex items-center gap-3 mb-6">
        <span className="text-3xl">🔐</span>
        <div>
          <h2 className="font-display text-xl font-semibold">Đổi mật khẩu</h2>
          <p className="text-muted text-sm">Cập nhật mật khẩu đăng nhập admin</p>
        </div>
      </div>

      <div className="relative">
        <label className="block text-sm mb-1">Mật khẩu hiện tại</label>
        <input type={show ? "text" : "password"} value={form.currentPassword} onChange={(e) => setForm({ ...form, currentPassword: e.target.value })} className={input} required />
      </div>

      <div className="relative">
        <label className="block text-sm mb-1">Mật khẩu mới (≥ 6 ký tự)</label>
        <input type={show ? "text" : "password"} value={form.newPassword} onChange={(e) => setForm({ ...form, newPassword: e.target.value })} className={input} required />
      </div>

      <div className="relative">
        <label className="block text-sm mb-1">Xác nhận mật khẩu mới</label>
        <input type={show ? "text" : "password"} value={form.confirmPassword} onChange={(e) => setForm({ ...form, confirmPassword: e.target.value })} className={input} required />
        <button type="button" onClick={() => setShow(!show)} className="absolute right-3 top-9 text-muted hover:text-cyan">
          {show ? "🙈" : "👁"}
        </button>
      </div>

      <AnimatePresence>
        {toast && (
          <motion.p initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }} className={`mb-4 px-4 py-2 rounded-lg text-sm ${toast.type === "success" ? "bg-emerald-500/15 text-emerald-400" : "bg-red-500/15 text-red-400"}`}>
            {toast.type === "success" ? "✓ " : "⚠ "}{toast.msg}
          </motion.p>
        )}
      </AnimatePresence>

      <button disabled={loading} className="btn-brand w-full">{loading ? "Đang cập nhật..." : "💾 Cập nhật mật khẩu"}</button>
    </form>
  );
}
