import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const body = await req.json();
  const { name, shortDesc, longDesc, price, oldPrice, stock, isActive, categoryId, images } = body;

  await prisma.image.deleteMany({ where: { productId: params.id } });

  const product = await prisma.product.update({
    where: { id: params.id },
    data: {
      name, shortDesc, longDesc,
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

export async function DELETE(_: NextRequest, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  await prisma.product.delete({ where: { id: params.id } });
  return NextResponse.json({ ok: true });
}
