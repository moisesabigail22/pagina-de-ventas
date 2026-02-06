import type { Metadata, Viewport } from "next"
import "./globals.css"

export const metadata: Metadata = {
  title: "Epic Gold Shop | Comprar Oro WoW - Vender Oro WoW - Cuentas Premium",
  description:
    "Tienda #1 para comprar oro World of Warcraft, Turtle WoW, Albion Online. Vende tu oro seguro, entrega inmediata 24/7. Cuentas verificadas, precios competitivos.",
  keywords: "comprar oro wow, vender oro wow, oro world of warcraft, turtle wow gold, albion online silver, cuentas wow",
  openGraph: {
    title: "Epic Gold Shop | Compra y Vende Oro WoW Seguro",
    description: "Marketplace especializado en oro World of Warcraft. Compra y vende con seguridad, entrega inmediata, soporte 24/7 en Discord.",
    images: ["https://i.imgur.com/ynvAS9B.png"],
    url: "https://epicgoldshop.com/",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Epic Gold Shop | Compra Oro WoW",
    description: "Compra y vende oro World of Warcraft seguro. Entrega inmediata, precios competitivos.",
    images: ["https://i.imgur.com/ynvAS9B.png"],
  },
  icons: {
    icon: "https://i.imgur.com/ynvAS9B.png",
  },
}

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 5,
  userScalable: true,
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="es">
      <body style={{ margin: 0, padding: 0 }}>{children}</body>
    </html>
  )
}
