"use client"

import { useEffect, useRef } from "react"

export default function Home() {
  const initialized = useRef(false)

  useEffect(() => {
    if (initialized.current) return
    initialized.current = true

    fetch("/site.html")
      .then((res) => res.text())
      .then((html) => {
        // Extract content between <head> and </head>
        const headMatch = html.match(/<head[^>]*>([\s\S]*?)<\/head>/i)
        const bodyMatch = html.match(/<body[^>]*>([\s\S]*?)<\/body>/i)

        if (headMatch) {
          const headContent = headMatch[1]

          // Extract stylesheet links and add them
          const linkRegex = /<link[^>]+rel=["']stylesheet["'][^>]*>/gi
          let linkMatch
          while ((linkMatch = linkRegex.exec(headContent)) !== null) {
            const hrefMatch = linkMatch[0].match(/href=["']([^"']+)["']/)
            if (hrefMatch) {
              const link = document.createElement("link")
              link.rel = "stylesheet"
              link.href = hrefMatch[1]
              const crossOriginMatch = linkMatch[0].match(/crossorigin=["']([^"']+)["']/)
              if (crossOriginMatch) link.crossOrigin = crossOriginMatch[1]
              document.head.appendChild(link)
            }
          }

          // Extract and add style blocks
          const styleRegex = /<style[^>]*>([\s\S]*?)<\/style>/gi
          let styleMatch
          while ((styleMatch = styleRegex.exec(headContent)) !== null) {
            const style = document.createElement("style")
            style.textContent = styleMatch[1]
            document.head.appendChild(style)
          }

          // Extract and add ld+json scripts
          const ldJsonRegex = /<script\s+type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi
          let ldMatch
          while ((ldMatch = ldJsonRegex.exec(headContent)) !== null) {
            const s = document.createElement("script")
            s.type = "application/ld+json"
            s.textContent = ldMatch[1]
            document.head.appendChild(s)
          }
        }

        if (bodyMatch) {
          // Separate body HTML from scripts
          const bodyContent = bodyMatch[1]
          
          // Extract scripts from body
          const scriptParts: { src?: string; content?: string }[] = []
          const scriptRegex = /<script[^>]*>([\s\S]*?)<\/script>/gi
          let sMatch
          while ((sMatch = scriptRegex.exec(bodyContent)) !== null) {
            const srcMatch = sMatch[0].match(/src=["']([^"']+)["']/)
            if (srcMatch) {
              scriptParts.push({ src: srcMatch[1] })
            } else if (sMatch[1].trim()) {
              scriptParts.push({ content: sMatch[1] })
            }
          }

          // Remove scripts from HTML to inject just the markup
          const bodyHtml = bodyContent.replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "")

          // Inject body HTML
          const container = document.getElementById("site-root")
          if (container) {
            container.innerHTML = bodyHtml
          }

          // Execute scripts after DOM is ready
          setTimeout(() => {
            scriptParts.forEach((part) => {
              const s = document.createElement("script")
              if (part.src) {
                s.src = part.src
                s.async = false
              } else if (part.content) {
                s.textContent = part.content
              }
              document.body.appendChild(s)
            })
          }, 100)
        }
      })
  }, [])

  return <div id="site-root" />
}
