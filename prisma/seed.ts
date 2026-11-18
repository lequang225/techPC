import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  const hashed = await bcrypt.hash("admin123", 10);
  await prisma.user.upsert({
    where: { username: "admin" },
    update: {},
    create: { username: "admin", password: hashed },
  });

  const categories = [
    { name: "PC Gaming", slug: "pc-gaming" },
    { name: "PC Văn phòng", slug: "pc-van-phong" },
    { name: "PC Đồ họa", slug: "pc-do-hoa" },
    { name: "PC Mini", slug: "pc-mini" },
  ];
  for (const c of categories) {
    await prisma.category.upsert({ where: { slug: c.slug }, update: {}, create: c });
  }

  const gaming = await prisma.category.findUnique({ where: { slug: "pc-gaming" } });
  const office = await prisma.category.findUnique({ where: { slug: "pc-van-phong" } });

  const sampleProducts = [
    {
      name: "PC Gaming RTX 4070 Super",
      slug: "pc-gaming-rtx-4070-super",
      shortDesc: "i7-14700F • RTX 4070 Super • 32GB DDR5 • SSD 1TB",
      price: 25990000,
      oldPrice: 29990000,
      stock: 10,
      categoryId: gaming?.id,
      images: ["https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=800"],
    },
    {
      name: "PC Văn phòng i5-12400",
      slug: "pc-van-phong-i5-12400",
      shortDesc: "i5-12400 • 16GB DDR4 • SSD 512GB",
      price: 12490000,
      stock: 20,
      categoryId: office?.id,
      images: ["https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=800"],
    },
  ];

  for (const p of sampleProducts) {
    const { images, ...data } = p;
    await prisma.product.upsert({
      where: { slug: p.slug },
      update: {},
      create: {
        ...data,
        images: { create: images.map((url, i) => ({ url, isMain: i === 0, order: i })) },
      },
    });
  }
  console.log("✅ Seed xong. Admin: admin / admin123");
}

main().finally(() => prisma.$disconnect());
