import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Taskora — Micro Job Marketplace",
  description: "A transparent marketplace for small online tasks."
};

export default function RootLayout({
  children
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="bn">
      <body>{children}</body>
    </html>
  );
  }
