import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { slugify } from "@/lib/slug";

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const { name } = await req.json();
  if (!name?.trim()) return NextResponse.json({ error: "Tên không hợp lệ" }, { status: 400 });

  const category = await prisma.category.update({
    where: { id: params.id },
    data: { name, slug: slugify(name) },
  });
  return NextResponse.json(category);
}

export async function DELETE(_: NextRequest, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const count = await prisma.product.count({ where: { categoryId: params.id } });
  if (count > 0) {
    return NextResponse.json(
      { error: `Còn ${count} sản phẩm trong danh mục này, không thể xoá` },
      { status: 400 }
    );
  }
  await prisma.category.delete({ where: { id: params.id } });
  return NextResponse.json({ ok: true });
}
