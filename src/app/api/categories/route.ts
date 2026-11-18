import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";
import { slugify } from "@/lib/slug";

export async function GET() {
  const categories = await prisma.category.findMany({
    include: { _count: { select: { products: true } } },
    orderBy: { createdAt: "asc" },
  });
  return NextResponse.json(categories);
}

export async function POST(req: NextRequest) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const { name } = await req.json();
  if (!name?.trim()) return NextResponse.json({ error: "Tên không hợp lệ" }, { status: 400 });

  const slug = slugify(name);
  const exists = await prisma.category.findFirst({ where: { OR: [{ name }, { slug }] } });
  if (exists) return NextResponse.json({ error: "Danh mục đã tồn tại" }, { status: 409 });

  const category = await prisma.category.create({ data: { name, slug } });
  return NextResponse.json(category);
}
