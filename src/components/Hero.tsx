"use client";
import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import Link from "next/link";

type HeroProps = {
  title: string;
  subtitle: string;
  images: string[];
  buttonText: string;
};

export default function Hero({ title, subtitle, images, buttonText }: HeroProps) {
  const [index, setIndex] = useState(0);

  // Tự động chuyển ảnh sau 4 giây
  useEffect(() => {
    if (!images || images.length <= 1) return;
    const timer = setInterval(() => {
      setIndex((prev) => (prev + 1) % images.length);
    }, 4000);
    return () => clearInterval(timer);
  }, [images]);

  const currentImages = images && images.length > 0 ? images : ["https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=800"];

  return (
    <section className="max-w-7xl mx-auto px-6 py-24 grid md:grid-cols-2 gap-12 items-center">
      <motion.div initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.8 }}>
        <p className="text-cyan text-sm uppercase tracking-widest mb-4">✦ Hiệu năng vượt trội</p>
        <h1 className="font-display text-5xl md:text-6xl font-extrabold leading-tight">
          {title}
        </h1>
        <p className="text-muted mt-6 text-lg">{subtitle}</p>
        <div className="mt-8 flex gap-4">
          <Link href="/products" className="btn-brand">{buttonText}</Link>
          <Link href="/#contact" className="px-6 py-3 rounded-xl border border-cyan/40 text-cyan hover:bg-cyan/10 transition">Tư vấn ngay</Link>
        </div>
      </motion.div>

      <motion.div initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: 1 }} className="relative">
        {/* Vòng sáng background */}
        <div className="absolute inset-0 bg-gradient-brand blur-3xl opacity-30 rounded-full" />
        
        {/* Khung chứa ảnh Slider */}
        <div className="relative aspect-square md:aspect-[4/3] rounded-2xl overflow-hidden bg-card border border-white/5 shadow-2xl">
          <AnimatePresence mode="wait">
            <motion.img
              key={index}
              src={currentImages[index]}
              alt="PC Banner"
              initial={{ opacity: 0, scale: 1.1, filter: "blur(10px)" }}
              animate={{ opacity: 1, scale: 1, filter: "blur(0px)" }}
              exit={{ opacity: 0, scale: 0.95, filter: "blur(10px)" }}
              transition={{ duration: 0.8, ease: "easeInOut" }}
              className="absolute inset-0 w-full h-full object-cover"
            />
          </AnimatePresence>
        </div>

        {/* Nút chấm tròn chuyển ảnh (Dots) */}
        {currentImages.length > 1 && (
          <div className="absolute -bottom-6 left-1/2 -translate-x-1/2 flex gap-2">
            {currentImages.map((_, i) => (
              <button
                key={i}
                onClick={() => setIndex(i)}
                className={`h-2.5 rounded-full transition-all duration-300 ${
                  i === index ? "w-8 bg-cyan" : "w-2.5 bg-white/30 hover:bg-white/60"
                }`}
                aria-label={`Chuyển đến ảnh ${i + 1}`}
              />
            ))}
          </div>
        )}
      </motion.div>
    </section>
  );
}
