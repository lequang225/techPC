"use client";
import { motion, AnimatePresence } from "framer-motion";

export type ToastData = { id: number; type: "success" | "error"; message: string };

export default function Toast({ toasts }: { toasts: ToastData[] }) {
  return (
    <div className="fixed bottom-6 right-6 z-50 space-y-3">
      <AnimatePresence>
        {toasts.map((t) => (
          <motion.div
            key={t.id}
            initial={{ opacity: 0, x: 100 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 100 }}
            className={`px-5 py-3 rounded-xl shadow-lg font-medium text-sm ${t.type === "success" ? "bg-emerald-500 text-white" : "bg-red-500 text-white"}`}
          >
            {t.message}
          </motion.div>
        ))}
      </AnimatePresence>
    </div>
  );
}
