import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";

export async function GET() {
  let settings = await prisma.setting.findUnique({ where: { id: "global" } });
  if (!settings) {
    settings = await prisma.setting.create({ data: { id: "global" } });
  }
  return NextResponse.json(settings);
}

export async function PUT(req: NextRequest) {
  const session = await getServerSession(authOptions);
  if (!session) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const body = await req.json();
  const { bannerTitle, bannerSubtitle, bannerImages, bannerButton, footerAddress, footerPhone, footerEmail } = body;

  const settings = await prisma.setting.upsert({
    where: { id: "global" },
    update: { bannerTitle, bannerSubtitle, bannerImages, bannerButton, footerAddress, footerPhone, footerEmail },
    create: { id: "global", bannerTitle, bannerSubtitle, bannerImages, bannerButton, footerAddress, footerPhone, footerEmail },
  });

  return NextResponse.json(settings);
}
