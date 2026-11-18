type FooterProps = {
  address: string;
  phone: string;
  email: string;
};

export default function Footer({ address, phone, email }: FooterProps) {
  return (
    <footer className="border-t border-white/5 mt-24 py-10 text-center text-muted text-sm">
      <p className="font-display text-xl gradient-text font-extrabold mb-4">◆ TechPC</p>
      <p>{address}</p>
      <p className="mt-1">{phone} • {email}</p>
      <p className="mt-4 text-xs opacity-70">© {new Date().getFullYear()} TechPC. All rights reserved.</p>
    </footer>
  );
}
