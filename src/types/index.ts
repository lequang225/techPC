export type ProductImage = { id: string; url: string; isMain: boolean; order: number };

export type Product = {
  id: string;
  name: string;
  slug: string;
  shortDesc: string | null;
  longDesc: string | null;
  price: number;
  oldPrice: number | null;
  stock: number;
  isActive: boolean;
  images: ProductImage[];
  category?: { name: string; slug: string } | null;
};
