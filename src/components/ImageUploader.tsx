"use client";
import { useState, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";

export type UploadedImage = { url: string; isMain: boolean };

export default function ImageUploader({
  images, setImages, onError,
}: {
  images: UploadedImage[];
  setImages: (imgs: UploadedImage[]) => void;
  onError: (msg: string) => void;
}) {
  const [uploading, setUploading] = useState(false);
  const [drag, setDrag] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  const handleFiles = async (files: FileList | File[]) => {
    setUploading(true);
    try {
      const fd = new FormData();
      Array.from(files).forEach((f) => fd.append("files", f));
      const res = await fetch("/api/upload", { method: "POST", body: fd });
      if (!res.ok) throw new Error("Upload thất bại");
      const { urls } = await res.json();
      const newImgs = (urls as string[]).map((url) => ({ url, isMain: false }));
      const merged = [...images, ...newImgs];
      if (!merged.some((i) => i.isMain) && merged.length) merged[0].isMain = true;
      setImages(merged);
    } catch (e: any) {
      onError(e.message);
    } finally {
      setUploading(false);
    }
  };

  const remove = (idx: number) => {
    const next = images.filter((_, i) => i !== idx);
    if (!next.some((i) => i.isMain) && next.length) next[0].isMain = true;
    setImages(next);
  };

  const setMain = (idx: number) =>
    setImages(images.map((img, i) => ({ ...img, isMain: i === idx })));

  return (
    <div className="space-y-4">
      <div
        onDragOver={(e) => { e.preventDefault(); setDrag(true); }}
        onDragLeave={() => setDrag(false)}
        onDrop={(e) => { e.preventDefault(); setDrag(false); handleFiles(e.dataTransfer.files); }}
        onClick={() => inputRef.current?.click()}
        className={`border-2 border-dashed rounded-xl p-8 text-center cursor-pointer transition ${drag ? "border-cyan bg-cyan/5" : "border-white/10 hover:border-cyan/40"}`}
      >
        <input
          ref={inputRef}
          type="file"
          multiple
          accept="image/*"
          className="hidden"
          onChange={(e) => e.target.files && handleFiles(e.target.files)}
        />
        <p className="text-4xl mb-2">☁️</p>
        <p className="text-muted">Kéo & thả ảnh vào đây hoặc <span className="text-cyan underline">chọn ảnh</span></p>
        <p className="text-xs text-muted mt-2">JPG, PNG, WEBP — nhiều ảnh cùng lúc</p>
      </div>

      {uploading && (
        <div className="h-1 bg-white/10 rounded overflow-hidden">
          <motion.div className="h-full bg-gradient-brand" initial={{ width: "0%" }} animate={{ width: "100%" }} transition={{ duration: 1.5 }} />
        </div>
      )}

      <div className="grid grid-cols-3 md:grid-cols-5 gap-3">
        <AnimatePresence>
          {images.map((img, i) => (
            <motion.div
              key={img.url}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.6 }}
              className={`relative aspect-square rounded-lg overflow-hidden border-2 ${img.isMain ? "border-cyan shadow-[0_0_16px_rgba(0,229,255,.6)]" : "border-white/10"}`}
            >
              <img src={img.url} className="w-full h-full object-cover" />
              <button type="button" onClick={() => remove(i)} className="absolute top-1 right-1 bg-red-500 text-white rounded-full w-6 h-6 text-xs">✕</button>
              <button type="button" onClick={() => setMain(i)} className={`absolute bottom-1 left-1 text-xs px-2 py-0.5 rounded ${img.isMain ? "bg-cyan text-black font-bold" : "bg-black/70 text-white"}`}>
                {img.isMain ? "⭐ Chính" : "Đặt chính"}
              </button>
            </motion.div>
          ))}
        </AnimatePresence>
      </div>
    </div>
  );
}
