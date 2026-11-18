import Hero from "@/components/Hero";
import ProductCard from "@/components/ProductCard";
import AnimatedCounter from "@/components/AnimatedCounter";
import StructuredData from "@/components/StructuredData";
import { prisma } from "@/lib/prisma";

export const dynamic = "force-dynamic";

export default async function Home() {
  const products = await prisma.product.findMany({
    where: { isActive: true },
    include: { images: { orderBy: { order: "asc" } }, category: true },
    take: 8,
    orderBy: { createdAt: "desc" },
  });

  const settings = await prisma.setting.findUnique({ where: { id: "global" } });

  const orgSchema = {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: "TechPC",
    url: process.env.NEXTAUTH_URL || "http://localhost:3000",
    contactPoint: { "@type": "ContactPoint", telephone: settings?.footerPhone || "", contactType: "customer service", areaServed: "VN" },
  };

  const stats = [
    { label: "Sản phẩm", value: products.length + 500 },
    { label: "Khách hàng", value: 1200 },
    { label: "Đánh giá 5★", value: 490 },
    { label: "Hỗ trợ 24/7", value: 24 },
  ];

  return (
    <>
      <StructuredData data={orgSchema} />
      
      <Hero 
        title={settings?.bannerTitle || "Build PC mơ ước của bạn"}
        subtitle={settings?.bannerSubtitle || ""}
        images={settings?.bannerImages || []}
        buttonText={settings?.bannerButton || "Xem sản phẩm"}
      />

      <section className="max-w-7xl mx-auto px-6 py-16 grid grid-cols-2 md:grid-cols-4 gap-6">
        {stats.map((s) => (
          <div key={s.label} className="card p-6 text-center">
            <p className="font-display text-3xl font-bold gradient-text"><AnimatedCounter to={s.value} /></p>
            <p className="text-muted text-sm mt-1">{s.label}</p>
          </div>
        ))}
      </section>

      <section className="max-w-7xl mx-auto px-6 py-16">
        <h2 className="font-display text-3xl md:text-4xl font-bold text-center mb-12">
          <span className="gradient-text">Sản phẩm nổi bật</span>
        </h2>
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          {products.map((p, i) => <ProductCard key={p.id} product={p} index={i} />)}
        </div>
      </section>

      <section id="why" className="max-w-7xl mx-auto px-6 py-16 grid md:grid-cols-3 gap-6">
        {[
          { icon: "🛡️", title: "Bảo hành 36 tháng", desc: "Cam kết chính hãng" },
          { icon: "🚚", title: "Giao hàng 2h", desc: "Toàn quốc, miễn phí nội thành" },
          { icon: "💳", title: "Trả góp 0%", desc: "Duyệt nhanh, thủ tục đơn giản" },
        ].map((f) => (
          <div key={f.title} className="card p-8 text-center card-hover">
            <div className="text-4xl mb-3">{f.icon}</div>
            <h3 className="font-display font-semibold text-lg">{f.title}</h3>
            <p className="text-muted text-sm mt-2">{f.desc}</p>
          </div>
        ))}
      </section>
    </>
  );
}
