import PasswordForm from "@/components/PasswordForm";
import SettingsForm from "@/components/SettingsForm";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";

export default async function AdminSettings() {
  const session = await getServerSession(authOptions);
  return (
    <div>
      <h1 className="font-display text-3xl font-bold mb-6">⚙️ Cài đặt hệ thống</h1>
      
      <div className="card p-6 mb-8 max-w-4xl bg-gradient-to-r from-cyan/10 to-purple/10 border-cyan/20">
        <p className="text-muted text-sm mb-1">Đang đăng nhập với tài khoản quản trị</p>
        <p className="font-display text-xl font-semibold text-white">👤 {session?.user?.name}</p>
      </div>

      {/* Form cấu hình giao diện */}
      <div className="mb-12">
        <SettingsForm />
      </div>

      {/* Form đổi mật khẩu */}
      <div>
        <PasswordForm />
      </div>
    </div>
  );
}
