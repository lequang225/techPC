"use client";
import { signIn } from "next-auth/react";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";

export default function LoginPage() {
  const router = useRouter();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true); setError("");
    const res = await signIn("credentials", { username, password, redirect: false });
    setLoading(false);
    if (res?.error) setError("Sai tài khoản hoặc mật khẩu");
    else router.push("/admin");
  };

  return (
    <div className="min-h-[80vh] flex items-center justify-center px-6">
      <motion.form onSubmit={submit} initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} className="card p-8 w-full max-w-md">
        <h1 className="font-display text-2xl font-bold text-center mb-1 gradient-text">◆ TechPC</h1>
        <p className="text-center text-muted text-sm mb-6">Đăng nhập quản trị</p>
        <label className="block text-sm mb-1">Tên đăng nhập</label>
        <input value={username} onChange={(e) => setUsername(e.target.value)} className="w-full bg-black/40 border border-white/10 rounded-lg px-4 py-2 mb-4 focus:border-cyan outline-none" required />
        <label className="block text-sm mb-1">Mật khẩu</label>
        <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} className="w-full bg-black/40 border border-white/10 rounded-lg px-4 py-2 mb-4 focus:border-cyan outline-none" required />
        {error && <p className="text-red-400 text-sm mb-3">{error}</p>}
        <button disabled={loading} className="btn-brand w-full">{loading ? "Đang đăng nhập..." : "Đăng nhập"}</button>
        <p className="text-xs text-muted text-center mt-4">Demo: admin / admin123</p>
      </motion.form>
    </div>
  );
}
