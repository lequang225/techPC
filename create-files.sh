#!/bin/bash
set -e
cd "$(dirname "$0")"

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

echo "📄 Tạo file trống..."

# ---- CONFIG (7 file) ----
touch package.json
touch tsconfig.json
touch next.config.mjs
touch tailwind.config.ts
touch postcss.config.mjs
touch .env.example
touch .gitignore

# ---- PRISMA (2 file) ----
touch prisma/schema.prisma
touch prisma/seed.ts

# ---- LIB (4 file) ----
touch src/lib/prisma.ts
touch src/lib/slug.ts
touch src/lib/auth.ts
touch src/lib/upload.ts

# ---- TYPES (1 file) ----
touch src/types/index.ts

# ---- MIDDLEWARE (1 file) ----
touch src/middleware.ts

# ---- COMPONENTS (14 file) ----
touch src/components/Particles.tsx
touch src/components/ScrollProgress.tsx
touch src/components/Navbar.tsx
touch src/components/Footer.tsx
touch src/components/Hero.tsx
touch src/components/AnimatedCounter.tsx
touch src/components/ProductCard.tsx
touch src/components/ImageGallery.tsx
touch src/components/Toast.tsx
touch src/components/ImageUploader.tsx
touch src/components/ProductForm.tsx
touch src/components/CategoryManager.tsx
touch src/components/PasswordForm.tsx
touch src/components/StructuredData.tsx

# ---- API (7 file) ----
touch 'src/app/api/auth/[...nextauth]/route.ts'
touch src/app/api/upload/route.ts
touch src/app/api/products/route.ts
touch 'src/app/api/products/[id]/route.ts'
touch src/app/api/categories/route.ts
touch 'src/app/api/categories/[id]/route.ts'
touch src/app/api/admin/password/route.ts

# ---- PAGES (18 file) ----
touch src/app/globals.css
touch src/app/layout.tsx
touch src/app/page.tsx
touch src/app/not-found.tsx
touch src/app/robots.ts
touch src/app/sitemap.ts
touch src/app/products/page.tsx
touch 'src/app/products/[slug]/page.tsx'
touch src/app/login/page.tsx
touch src/app/login/layout.tsx
touch src/app/admin/layout.tsx
touch src/app/admin/page.tsx
touch src/app/admin/products/page.tsx
touch src/app/admin/products/DeleteButton.tsx
touch src/app/admin/products/new/page.tsx
touch 'src/app/admin/products/[id]/edit/page.tsx'
touch src/app/admin/categories/page.tsx
touch src/app/admin/settings/page.tsx

touch public/uploads/.gitkeep

echo ""
echo "✅ Đã tạo $(find . -type f -not -path './node_modules/*' | wc -l) file trống"
echo ""
echo "👉 Tiếp theo: mở từng file và paste code"
