import type { Metadata } from "next";
import "./globals.css";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import ScrollProgress from "@/components/ScrollProgress";
import Particles from "@/components/Particles";
import { prisma } from "@/lib/prisma";

const SITE_URL = process.env.NEXTAUTH_URL || "http://localhost:3000";
const SITE_NAME = "TechPC";
const SITE_DESC = "Máy vi tính cao cấp — PC Gaming, Đồ họa, Văn phòng. Bảo hành 36 tháng, giao hàng 2h toàn quốc.";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: { default: `${SITE_NAME} — Máy vi tính cao cấp`, template: `%s | ${SITE_NAME}` },
  description: SITE_DESC,
  keywords: ["máy vi tính", "PC gaming", "PC đồ họa", "PC văn phòng", "build PC", "TechPC"],
  authors: [{ name: SITE_NAME }],
  openGraph: {
    type: "website", locale: "vi_VN", url: SITE_URL, siteName: SITE_NAME,
    title: `${SITE_NAME} — Máy vi tính cao cấp`, description: SITE_DESC,
    images: [{ url: "/og-image.jpg", width: 1200, height: 630, alt: SITE_NAME }],
  },
  twitter: { card: "summary_large_image", title: `${SITE_NAME} — Máy vi tính cao cấp`, description: SITE_DESC, images: ["/og-image.jpg"] },
  robots: { index: true, follow: true },
  alternates: { canonical: SITE_URL },
};

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  let settings = await prisma.setting.findUnique({ where: { id: "global" } });
  if (!settings) {
    settings = await prisma.setting.create({ data: { id: "global" } });
  }

  return (
    <html lang="vi">
      <body>
        <Particles />
        <ScrollProgress />
        <Navbar />
        <main className="min-h-screen">{children}</main>
        <Footer address={settings.footerAddress} phone={settings.footerPhone} email={settings.footerEmail} />
      </body>
    </html>
  );
}
