import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { slugify } from "@/lib/slug";

export async function GET() {
  const products = await prisma.product.findMany({
    where: { isActive: true },
    include: { images: { orderBy: { order: "asc" } }, category: true },
    orderBy: { createdAt: "desc" },
  });
  return NextResponse.json(products);
}

export async function POST(req: NextRequest) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const body = await req.json();
  const { name, shortDesc, longDesc, price, oldPrice, stock, isActive, categoryId, images } = body;
  const slug = slugify(name) + "-" + Date.now().toString(36);

  const product = await prisma.product.create({
    data: {
      name, slug, shortDesc, longDesc,
      price: Number(price) || 0,
      oldPrice: oldPrice ? Number(oldPrice) : null,
      stock: Number(stock) || 0,
      isActive: !!isActive,
      categoryId: categoryId || null,
      images: {
        create: (images as { url: string; isMain: boolean }[]).map((img, i) => ({
          url: img.url, isMain: img.isMain, order: i,
        })),
      },
    },
    include: { images: true },
  });
  return NextResponse.json(product);
}
