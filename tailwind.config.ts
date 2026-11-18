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
