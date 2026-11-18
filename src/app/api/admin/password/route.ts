import { NextRequest, NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import bcrypt from "bcryptjs";
import { authOptions } from "@/lib/auth";
import { prisma } from "@/lib/prisma";

export async function POST(req: NextRequest) {
  const session = await getServerSession(authOptions);
  if (!session?.user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const { currentPassword, newPassword, confirmPassword } = await req.json();

  if (!currentPassword || !newPassword || !confirmPassword)
    return NextResponse.json({ error: "Vui lòng điền đầy đủ" }, { status: 400 });
  if (newPassword.length < 6)
    return NextResponse.json({ error: "Mật khẩu mới tối thiểu 6 ký tự" }, { status: 400 });
  if (newPassword !== confirmPassword)
    return NextResponse.json({ error: "Mật khẩu xác nhận không khớp" }, { status: 400 });
  if (newPassword === currentPassword)
    return NextResponse.json({ error: "Mật khẩu mới phải khác mật khẩu cũ" }, { status: 400 });

  const user = await prisma.user.findUnique({ where: { username: session.user.name as string } });
  if (!user) return NextResponse.json({ error: "Không tìm thấy user" }, { status: 404 });

  const ok = await bcrypt.compare(currentPassword, user.password);
  if (!ok) return NextResponse.json({ error: "Mật khẩu hiện tại không đúng" }, { status: 400 });

  const hashed = await bcrypt.hash(newPassword, 10);
  await prisma.user.update({ where: { id: user.id }, data: { password: hashed } });

  return NextResponse.json({ ok: true, message: "Đổi mật khẩu thành công" });
}
