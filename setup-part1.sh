#!/bin/bash
set -e

# ============================================================
# TechPC — SETUP PHẦN 1/3
# Bootstrap (Node + PostgreSQL + DB) + Config + Prisma + Lib
# ============================================================

PROJECT_DIR="${1:-$HOME/techpc}"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo ""
echo "════════════════════════════════════════════════"
echo "  🚀 TechPC Setup — PHẦN 1/3"
echo "  📁 Dự án: $PROJECT_DIR"
echo "════════════════════════════════════════════════"
echo ""

# ---------- 1. BOOTSTRAP MÔI TRƯỜNG ----------
echo "🔍 Kiểm tra môi trường..."

if ! command -v node &> /dev/null; then
  echo "📦 Cài Node.js 20 LTS..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
fi
echo "✅ Node: $(node -v) | npm: $(npm -v)"

if ! command -v psql &> /dev/null; then
  echo "📦 Cài PostgreSQL..."
  sudo apt update
  sudo apt install -y postgresql postgresql-contrib
  sudo systemctl start postgresql
  sudo systemctl enable postgresql
fi
echo "✅ PostgreSQL: $(psql --version | awk '{print $3}')"

sudo systemctl start postgresql 2>/dev/null || true

# ---------- 2. TẠO DATABASE + USER ----------
echo ""
echo "🗄 Cấu hình database..."

DB_NAME="techpc"
DB_USER="techpc_user"
DB_PASS="${DB_PASS:-TechPC2024}"

sudo -u postgres psql <<SQL 2>/dev/null || true
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB_USER') THEN
    CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';
  END IF;
END
\$\$;
SQL

if ! sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1; then
  sudo -u postgres createdb -O $DB_USER $DB_NAME
fi

sudo -u postgres psql -d $DB_NAME -c "GRANT ALL ON SCHEMA public TO $DB_USER;" 2>/dev/null || true
sudo -u postgres psql -d $DB_NAME -c "ALTER SCHEMA public OWNER TO $DB_USER;" 2>/dev/null || true

echo "✅ DB: $DB_NAME | User: $DB_USER | Pass: $DB_PASS"
echo ""

# ---------- 3. TẠO CẤU TRÚC THƯ MỤC ----------
echo "📁 Tạo cấu trúc thư mục..."

mkdir -p prisma
mkdir -p public/uploads
mkdir -p src/app/api/auth/"[...nextauth]"
mkdir -p src/app/api/upload
mkdir -p src/app/api/products/"[id]"
mkdir -p src/app/api/categories/"[id]"
mkdir -p src/app/api/admin/password
mkdir -p src/app/products/"[slug]"
mkdir -p src/app/login
mkdir -p src/app/admin/products/new
mkdir -p src/app/admin/products/"[id]"/edit
mkdir -p src/app/admin/categories
mkdir -p src/app/admin/settings
mkdir -p src/components
mkdir -p src/lib
mkdir -p src/types
touch public/uploads/.gitkeep

# ---------- 4. FILE CONFIG ----------
echo "📝 Tạo file config..."

cat > package.json << 'EOF'
{
  "name": "techpc",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "prisma generate && next build",
    "start": "next start",
    "lint": "next lint",
    "db:push": "prisma db push",
    "db:migrate": "prisma migrate dev",
    "db:seed": "tsx prisma/seed.ts",
    "db:studio": "prisma studio",
    "postinstall": "prisma generate"
  },
  "dependencies": {
    "@aws-sdk/client-s3": "^3.600.0",
    "@prisma/client": "^5.16.1",
    "bcryptjs": "^2.4.3",
    "framer-motion": "^11.2.10",
    "next": "14.2.4",
    "next-auth": "^4.24.7",
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@types/bcryptjs": "^2.4.6",
    "@types/node": "^20.14.9",
    "@types/react": "^18.3.3",
    "@types/react-dom": "^18.3.0",
    "autoprefixer": "^10.4.19",
    "postcss": "^8.4.39",
    "prisma": "^5.16.1",
    "tailwindcss": "^3.4.4",
    "tsx": "^4.16.2",
    "typescript": "^5.5.2"
  }
}
EOF

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

cat > next.config.mjs << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "*.amazonaws.com" },
      { protocol: "https", hostname: "images.unsplash.com" }
    ],
  },
};
export default nextConfig;
EOF

cat > tailwind.config.ts << 'EOF'
import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        bg: "#0A0E1A",
        card: "#131A2B",
        cyan: { DEFAULT: "#00E5FF" },
        purple: { DEFAULT: "#7C3AED" },
        ink: "#F5F7FA",
        muted: "#94A3B8",
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
        display: ["Poppins", "system-ui", "sans-serif"],
      },
      backgroundImage: {
        "gradient-brand": "linear-gradient(135deg, #00E5FF 0%, #7C3AED 100%)",
      },
      keyframes: {
        float: {
          "0%,100%": { transform: "translateY(0px)" },
          "50%": { transform: "translateY(-18px)" },
        },
        glow: {
          "0%,100%": { boxShadow: "0 0 20px rgba(0,229,255,0.4)" },
          "50%": { boxShadow: "0 0 40px rgba(0,229,255,0.8)" },
        },
      },
      animation: {
        float: "float 3s ease-in-out infinite",
        glow: "glow 2.5s ease-in-out infinite",
      },
    },
  },
  plugins: [],
};
export default config;
EOF

cat > postcss.config.mjs << 'EOF'
export default { plugins: { tailwindcss: {}, autoprefixer: {} } };
EOF

cat > .gitignore << 'EOF'
node_modules
.next
.env
.env.local
public/uploads/*
!public/uploads/.gitkeep
*.log
.DS_Store
EOF

# ---------- 5. FILE .env (tự sinh secret) ----------
echo "🔐 Tạo .env với secret ngẫu nhiên..."

SECRET=$(openssl rand -base64 32)

cat > .env << EOF
DATABASE_URL="postgresql://${DB_USER}:${DB_PASS}@localhost:5432/${DB_NAME}?schema=public"
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="${SECRET}"
AWS_REGION="ap-southeast-1"
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AWS_S3_BUCKET=""
EOF

cp .env .env.example
sed -i "s|NEXTAUTH_SECRET=.*|NEXTAUTH_SECRET=\"doi-thanh-chuoi-random-dai-32-ky-tu-tro-len\"|" .env.example

# ---------- 6. PRISMA SCHEMA ----------
echo "🗄 Tạo Prisma schema..."

cat > prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  username  String   @unique
  password  String
  createdAt DateTime @default(now())
}

model Category {
  id        String    @id @default(cuid())
  name      String    @unique
  slug      String    @unique
  products  Product[]
  createdAt DateTime  @default(now())
}

model Product {
  id         String    @id @default(cuid())
  name       String
  slug       String    @unique
  shortDesc  String?
  longDesc   String?
  price      Int
  oldPrice   Int?
  stock      Int       @default(0)
  isActive   Boolean   @default(true)
  categoryId String?
  category   Category? @relation(fields: [categoryId], references: [id])
  images     Image[]
  createdAt  DateTime  @default(now())
  updatedAt  DateTime  @updatedAt

  @@index([categoryId])
}

model Image {
  id        String   @id @default(cuid())
  url       String
  isMain    Boolean  @default(false)
  order     Int      @default(0)
  productId String
  product   Product  @relation(fields: [productId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())

  @@index([productId])
}
EOF

# ---------- 7. PRISMA SEED ----------
cat > prisma/seed.ts << 'EOF'
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
EOF

# ---------- 8. LIB ----------
echo "🧰 Tạo lib files..."

cat > src/lib/prisma.ts << 'EOF'
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };
export const prisma = globalForPrisma.prisma ?? new PrismaClient();
if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
EOF

cat > src/lib/slug.ts << 'EOF'
export function slugify(str: string): string {
  return str
    .toLowerCase()
    .normalize("NFD").replace(/[\u0300-\u036f]/g, "")
    .replace(/đ/g, "d").replace(/Đ/g, "D")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}
EOF

cat > src/lib/auth.ts << 'EOF'
import type { NextAuthOptions } from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";
import bcrypt from "bcryptjs";
import { prisma } from "./prisma";

export const authOptions: NextAuthOptions = {
  session: { strategy: "jwt" },
  pages: { signIn: "/login" },
  providers: [
    CredentialsProvider({
      name: "credentials",
      credentials: {
        username: { label: "Username", type: "text" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        if (!credentials?.username || !credentials?.password) return null;
        const user = await prisma.user.findUnique({
          where: { username: credentials.username },
        });
        if (!user) return null;
        const ok = await bcrypt.compare(credentials.password, user.password);
        if (!ok) return null;
        return { id: user.id, name: user.username };
      },
    }),
  ],
};
EOF

cat > src/lib/upload.ts << 'EOF'
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { writeFile, mkdir } from "fs/promises";
import path from "path";
import { randomUUID } from "crypto";

const useS3 = !!process.env.AWS_S3_BUCKET;

const s3 = useS3
  ? new S3Client({
      region: process.env.AWS_REGION!,
      credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
      },
    })
  : null;

export async function uploadFile(file: File): Promise<string> {
  const ext = file.name.split(".").pop() || "jpg";
  const key = `${randomUUID()}.${ext}`;
  const buffer = Buffer.from(await file.arrayBuffer());

  if (useS3 && s3) {
    await s3.send(
      new PutObjectCommand({
        Bucket: process.env.AWS_S3_BUCKET!,
        Key: key,
        Body: buffer,
        ContentType: file.type,
        ACL: "public-read",
      })
    );
    return `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;
  }

  const dir = path.join(process.cwd(), "public", "uploads");
  await mkdir(dir, { recursive: true });
  await writeFile(path.join(dir, key), buffer);
  return `/uploads/${key}`;
}
EOF

# ---------- 9. TYPES ----------
cat > src/types/index.ts << 'EOF'
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
EOF

# ---------- 10. MIDDLEWARE ----------
cat > src/middleware.ts << 'EOF'
import { withAuth } from "next-auth/middleware";

export default withAuth({
  pages: { signIn: "/login" },
});

export const config = { matcher: ["/admin/:path*"] };
EOF

# ---------- HOÀN TẤT ----------
echo ""
echo "════════════════════════════════════════════════"
echo "  ✅ PHẦN 1/3 HOÀN TẤT!"
echo "════════════════════════════════════════════════"
echo ""
echo "📊 Đã tạo:"
echo "   • Node.js: $(node -v)"
echo "   • PostgreSQL: OK"
echo "   • Database: $DB_NAME"
echo "   • $(find . -type f -not -path './node_modules/*' -not -path './.next/*' | wc -l) file"
echo ""
echo "🔐 Tài khoản DB: $DB_USER / $DB_PASS"
echo "🔐 Sẽ đăng nhập admin bằng: admin / admin123"
echo ""
echo "👉 Bước tiếp theo:"
echo "   Reply 'tiếp 2' để nhận setup-part2.sh (14 components)"
echo ""
