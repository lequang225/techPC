"use client";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

export default function ImageGallery({ images }: { images: { url: string }[] }) {
  const [active, setActive] = useState(0);
  const [zoom, setZoom] = useState(false);
  if (!images.length) return null;

  return (
    <>
      <div className="space-y-4">
        <motion.div
          key={active}
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          className="aspect-square rounded-2xl overflow-hidden bg-black/40 cursor-zoom-in"
          onClick={() => setZoom(true)}
        >
          <img src={images[active].url} className="w-full h-full object-cover" />
        </motion.div>
        <div className="grid grid-cols-4 gap-3">
          {images.map((img, i) => (
            <button
              key={i}
              onClick={() => setActive(i)}
              className={`aspect-square rounded-lg overflow-hidden border-2 transition ${i === active ? "border-cyan shadow-[0_0_16px_rgba(0,229,255,.5)]" : "border-transparent opacity-70 hover:opacity-100"}`}
            >
              <img src={img.url} className="w-full h-full object-cover" />
            </button>
          ))}
        </div>
      </div>

      <AnimatePresence>
        {zoom && (
          <motion.div
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 bg-black/90 flex items-center justify-center p-8 cursor-zoom-out"
            onClick={() => setZoom(false)}
          >
            <motion.img
              initial={{ scale: 0.7 }} animate={{ scale: 1 }}
              src={images[active].url} className="max-w-full max-h-full rounded-xl"
            />
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
