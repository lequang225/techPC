"use client";
import Link from "next/link";
import { motion } from "framer-motion";
import type { Product } from "@/types";

export default function ProductCard({ product, index = 0 }: { product: Product; index?: number }) {
  const mainImg = product.images.find((i) => i.isMain) || product.images[0];

  return (
    <motion.div
      initial={{ opacity: 0, y: 40 }}
      whileInView={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay: index * 0.08 }}
      viewport={{ once: true }}
      className="card card-hover overflow-hidden group"
    >
      <Link href={`/products/${product.slug}`}>
        <div className="aspect-[4/3] overflow-hidden bg-black/40">
          <img
            src={mainImg?.url || "/placeholder.png"}
            alt={product.name}
            className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
          />
        </div>
        <div className="p-5">
          <h3 className="font-display font-semibold text-lg">{product.name}</h3>
          <p className="text-muted text-sm mt-1 line-clamp-2">{product.shortDesc}</p>
          <div className="mt-4 flex items-baseline gap-2">
            <span className="text-cyan text-xl font-bold">{product.price.toLocaleString("vi-VN")}đ</span>
            {product.oldPrice && (
              <span className="text-muted text-sm line-through">{product.oldPrice.toLocaleString("vi-VN")}đ</span>
            )}
          </div>
        </div>
      </Link>
    </motion.div>
  );
}
