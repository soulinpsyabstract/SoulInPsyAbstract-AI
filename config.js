{
  "version": "1.0",
  "project": {
    "name": "Soul in PsyAbstract",
    "owner": "Marina Saponenko",
    "canonical": "https://soulinpsyabstract.42web.io/",
    "languages": ["ru", "en"],
    "default_lang": "ru",
    "routing": "spa-hash",
    "content_mode": "verbatim"
  },
  "paths": {
    "html": "/htdocs",
    "css": "/assets/css",
    "js": "/assets/js",
    "img": "/assets/img",
    "fonts": "/assets/fonts",
    "audio": "/assets/audio",
    "texts": "/assets/texts"
  },
  "design": {
    "theme_tokens": {
      "bg": "#050709",
      "card": "#0d1015",
      "line": "#1b2230",
      "txt": "#c7ecff",
      "muted": "#9fd3df",
      "muter": "#6f91a0",
      "neon": "#00f0ff",
      "accent": "#18a4b9",
      "accent2": "#7ef3ff",
      "ok": "#52ffa8",
      "warn": "#ffc857",
      "err": "#ff5e7a"
    },
    "radii": { "base": 16, "lg": 22 },
    "shadows": {
      "s1": "0 10px 30px rgba(0,0,0,.35)",
      "s2": "0 12px 40px rgba(0,0,0,.45)",
      "glow": "0 0 12px rgba(0,240,255,.35), 0 0 24px rgba(0,240,255,.15)"
    },
    "fonts_stack": {
      "base": "system-ui, -apple-system, Segoe UI, Roboto, Inter, \"Marck Script\", \"Caveat\", sans-serif",
      "display": "\"Pacifico\",\"Caveat\",system-ui,Arial,sans-serif",
      "script": "\"Marck Script\",\"Caveat\",system-ui,Arial,sans-serif"
    },
    "neon_waves": true,
    "accent_animation": "soft-glow",
    "menu_layout": "single-row-wrap",
    "prefers_reduced_motion": true
  },
  "seo": {
    "title": "Soul in PsyAbstract — Marina | messy sketch · hearts · spirals · neon · acrylic",
    "description": {
      "ru": "Честность души в линиях хаоса. Сердца и спирали. Оригиналы, принты, on-chain (NFT), заказы.",
      "en": "Soul honesty in lines of chaos. Hearts & spirals. Originals, prints, on-chain (NFT), commissions."
    },
    "keywords_en": "soul in psyabstract, abstract line art, hearts and spirals, neon acrylic, Marina Saponenko, original drawings, buy abstract art, Rarible NFT",
    "og": { "image": "/assets/img/og_cover.jpg", "type": "website" },
    "meta": { "theme_color": "#0b0d10" },
    "json_ld": {
      "website": {
        "enabled": true,
        "name": "Soul in PsyAbstract",
        "url": "https://soulinpsyabstract.42web.io/",
        "potentialAction": [
          {
            "@type": "SearchAction",
            "target": "https://soulinpsyabstract.42web.io/?q={search_term_string}",
            "query-input": "required name=search_term_string"
          }
        ]
      }
    }
  },
  "pwa": {
    "manifest": "/manifest.webmanifest",
    "service_worker": "/service-worker.js",
    "theme_color": "#0b0d10",
    "scope": "/",
    "start_url": "/htdocs/index.html",
    "icons": [
      { "src": "/assets/img/icon-192.png", "sizes": "192x192", "type": "image/png" },
      { "src": "/assets/img/icon-512.png", "sizes": "512x512", "type": "image/png" }
    ]
  },
  "service_worker": {
    "cache_name": "psyabstract-v7",
    "core_assets": [
      "/htdocs/index.html",
      "/assets/css/main.css",
      "/assets/css/fonts.css",
      "/assets/img/icon-192.png",
      "/assets/img/icon-512.png",
      "/assets/img/og_cover.jpg",
      "/assets/js/app.js",
      "/assets/js/i18n.js",
      "/assets/js/rotator.js",
      "/assets/js/data.js"
    ],
    "strategies": { "html": "network-first", "assets": "cache-first" },
    "fallback_html": "/htdocs/index.html",
    "register_script": "/assets/js/pwa.js"
  },
  "assets": {
    "favicon": "/assets/img/favicon.png",
    "og_image": "/assets/img/og_cover.jpg",
    "gallery": { "count": 94, "pattern": "/assets/img/%02d.jpg" },
    "qr": {
      "instagram": "/assets/img/qr_instagram.jpg",
      "telegram_group": "/assets/img/qr_telegram_group.jpg",
      "whatsapp": "/assets/img/qr_whatsapp.jpg",
      "threads": "/assets/img/qr_threads.jpg",
      "tiktok": "/assets/img/qr_tiktok.jpg",
      "zora": "/assets/img/qr_zora.jpg"
    },
        "fonts": [
      { "file": "/assets/fonts/Caveat-VariableFont_wght.ttf", "family": "Caveat", "weight": "100 900", "preload": true },
      { "file": "/assets/fonts/Pacifico-Regular.ttf", "family": "Pacifico", "weight": "400", "preload": true },
      { "file": "/assets/fonts/MarckScript-Regular.ttf", "family": "Marck Script", "weight": "400", "preload": true }
    ]
  },
  "texts": {
    "about": "/assets/texts/about.txt",
    "manifest": "/assets/texts/manifest.txt",
    "poems": "/assets/texts/poems.txt",
    "songs": "/assets/texts/songs.html",
    "hero_phrases": "/assets/texts/hero_phrases.json"
  },
  "i18n": {
    "storage_key": "soulinpsy_lang",
    "default": "ru",
    "nav": {
      "ru": { "home": "Главная", "gallery": "Галерея", "nft": "NFT", "manifest": "Манифест", "poems": "Стихи", "songs": "Песни", "faq": "FAQ", "contacts": "Контакты" },
      "en": { "home": "Home", "gallery": "Gallery", "nft": "NFT", "manifest": "Manifest", "poems": "Poems", "songs": "Songs", "faq": "FAQ", "contacts": "Contacts" }
    },
    "meta_titles": {
      "ru": {
        "index": "Soul in PsyAbstract — Marina | messy sketch · hearts · spirals · neon · acrylic",
        "gallery": "Галерея — Soul in PsyAbstract",
        "nft": "NFT — Soul in PsyAbstract",
        "manifest": "Манифест — Soul in PsyAbstract",
        "poems": "Стихи — Soul in PsyAbstract",
        "songs": "Песни — Soul in PsyAbstract",
        "faq": "FAQ — Soul in PsyAbstract",
        "contacts": "Контакты — Soul in PsyAbstract"
      },
      "en": {
        "index": "Soul in PsyAbstract — Marina | messy sketch · hearts · spirals · neon · acrylic",
        "gallery": "Gallery — Soul in PsyAbstract",
        "nft": "NFT — Soul in PsyAbstract",
        "manifest": "Manifest — Soul in PsyAbstract",
        "poems": "Poems — Soul in PsyAbstract",
        "songs": "Songs — Soul in PsyAbstract",
        "faq": "FAQ — Soul in PsyAbstract",
        "contacts": "Contacts — Soul in PsyAbstract"
      }
    }
  },
  "hero_rotator": {
    "source": "/assets/texts/hero_phrases.json",
    "cards_per_cycle": 6,
    "locale_mode": "only-current",
    "card_style": {
      "weight": 800,
      "font_family": "\"Marck Script\",\"Caveat\",system-ui,Arial,sans-serif",
      "bullet_glow": true
    },
    "animation": { "enter_ms": 420, "hold_ms": 4600, "leave_ms": 420, "total_ms": 6000, "easing": "ease-in-out" },
    "a11y": { "aria_live": "polite" }
  },
  "gallery": {
    "hide_titles": true,
    "missing_ids": [92, 86, 85, 80, 65, 62, 54, 32],
    "free_ids": [6, 8, 9, 10, 12, 13, 15, 19, 30, 33, 34, 38, 44, 53, 56, 58, 61, 66, 67, 69, 70, 71, 73, 74, 75, 77, 78, 79, 89, 90, 93],
    "draft_ids": [68, 94, 64, 63, 52, 51, 50, 28, 26],
    "duplicate_groups": [
      [76, 79],
      [73, 72],
      [60, 59],
      [48, 47, 77],
      [46, 44],
      [49, 42],
      [40, 39, 25],
      [31, 30, 2],
      [23, 44, 17],
      [35, 15],
      [14, 20],
      [13, 11],
      [6, 7],
      [4, 3],
      [1, 8]
    ],
    "sold_policy": "others_sold",
    "pricing": { "tiers_usd": [400, 600, 800, 1000], "increase_every_sales": 4, "increase_amount": 200 },
    "ui": { "grid_breakpoints": [4, 3, 2, 1], "show_buy_bar": true, "badges": { "free": "FREE", "sold": "SOLD", "draft": "DRAFT" } }
  },
  "payments": {
    "eth": "0x2a7fFb7B3174fcA16CD2476a55E39f9Ea2d04073",
    "paypal_me": "https://paypal.me/SoulInPsyAbstract?locale.x=en_US&country.x=IL",
    "ncp_by_price": {
      "400": "TU5S4WBATKB5Y",
      "600": "4G9HRSR622B3E",
      "800": "C35VA4EUKNR7Q",
      "1000": "DWXVT5MTH3NG8",
      "1200": "S625M8XK4LUQ6",
      "1400": "7NE2M3WHBNSZU",
      "1600": "3D8S966C9SAGS",
      "1800": "UEY7U4UTWHYAU",
      "2000": "YY2J3K4ADFQLG"
    },
    "shipping_ncp": { "ship150": "WN5SEBVTCPV2J", "ship200": "X3FPSE4E3Z2PE", "ship300": "VYBZADUBRHC4L" },
    "exclusive_usd": 200,
    "ui": { "show_eth_copy": true, "show_paypal_fast": true, "show_paypal_me": true }
  },
  "nft": {
    "source": "rarible_only",
    "links_source": "/assets/js/data.js",
    "links": [
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046501",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046499",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046497",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046496",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046494",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046493",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046492",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046491",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046490",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046487",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046481",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046480",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046479",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046469",
      "https://og.rarible.com/token/0xc9154424b823b10579895ccbe442d41b9abd96ed:19223264877338955498166477182825409596884630599573943600177382871287898046465",
      "https://og.rarible.com/token/polygon/0x35f8aee672cde8e5fd09c93d2bfe4ff5a9cf0756:19223264877338955498166477182825409596884630599573943600177382871287898046476",
      "https://og.rarible.com/token/polygon/0x35f8aee672cde8e5fd09c93d2bfe4ff5a9cf0756:19223264877338955498166477182825409596884630599573943600177382871287898046475",
      "https://og.rarible.com/token/polygon/0x35f8aee672cde8e5fd09c93d2bfe4ff5a9cf0756:19223264877338955498166477182825409596884630599573943600177382871287898046474",
      "https://og.rarible.com/token/polygon/0x35f8aee672cde8e5fd09c93d2bfe4ff5a9cf0756:19223264877338955498166477182825409596884630599573943600177382871287898046472",
      "https://og.rarible.com/token/polygon/0x35f8aee672cde8e5fd09c93d2bfe4ff5a9cf0756:19223264877338955498166477182825409596884630599573943600177382871287898046471",
      "https://og.rarible.com/token/polygon/0x35f8aee672cde8e5fd09c93d2bfe4ff5a9cf0756:19223264877338955498166477182825409596884630599573943600177382871287898046470"
    ]
  },
  "audio": {
    "playlist_name": "Voice 70–94",
    "folder": "/assets/audio",
    "format_pattern": "AUD-20251010-WA00%02d.mp3",
    "range": { "from": 70, "to": 94 }
  },
  "social": {
    "instagram": "https://www.instagram.com/soul.in.psyabstract",
    "telegram": "https://t.me/messycketch",
    "rarible": "https://og.rarible.com/soulinpsyabstract",
    "zora": "https://zora.co/@soulinpsyabstract",
    "tiktok": "https://www.tiktok.com/@soul.in.psyabstract",
    "threads": "https://www.threads.net/@soul.in.psyabstract",
    "email": "mailto:soulinpsyabstract@gmail.com",
    "whatsapp": "https://wa.me/972525074743"
  },
  "chat": {
    "tawk": {
      "property_id": "68d8492a9c33dd1951ed7462",
      "property_url": "https://soulinpsyabstract.42web.io",
      "embed_script": "https://embed.tawk.to/68d8492a9c33dd1951ed7462/1j66drjvf"
    }
  },
  "pages": [
    { "file": "/htdocs/index.html", "lang": ["ru", "en"], "features": ["hero_rotator", "neon_waves", "tawk_embed", "pwa_register", "fouc_guard"] },
    { "file": "/htdocs/gallery.html", "lang": ["ru", "en"], "features": ["buy_modal", "inventory", "neon_waves"] },
    { "file": "/htdocs/nft.html", "lang": ["ru", "en"], "features": ["nft_links"] },
    { "file": "/htdocs/manifest.html", "lang": ["ru", "en"], "features": ["verbatim_text"] },
    { "file": "/htdocs/poems.html", "lang": ["ru", "en"], "features": ["verbatim_text"] },
    { "file": "/htdocs/songs.html", "lang": ["ru", "en"], "features": ["verbatim_text"] },
    { "file": "/htdocs/faq.html", "lang": ["ru", "en"], "features": ["faq_mini"] },
    { "file": "/htdocs/contacts.html", "lang": ["ru", "en"], "features": ["qr_links", "tawk_embed"] }
  ],
  "faq_mini": {
    "ru": [
      { "q": "Оплата", "a": "PayPal Fast, PayPal.me, ETH. Эксклюзив +200 к базе. Доставка оплачивается отдельно." },
      { "q": "Доставка", "a": "Миром. Трекинг. Экспресс по запросу." },
      { "q": "Оригинал", "a": "Все работы рисуются линером. Оригиналы — уникальны." },
      { "q": "NFT", "a": "Только Rarible. Ссылки — на странице NFT." },
      { "q": "Право", "a": "Exclusive даёт единственное коммерческое использование." },
      { "q": "Размер", "a": "Обычно A5–A4, другие по запросу." },
      { "q": "Цвет", "a": "Неон/аква настроение. Мягче вживую." },
      { "q": "Возврат", "a": "Если посылка потерялась — верну или перешлю." },
      { "q": "Комиссия", "a": "Принимаю заказы на сердца и спирали по историям клиентов." },
      { "q": "Гарантия", "a": "Надёжная упаковка и помощь при проблемах с доставкой." },
      { "q": "Связь", "a": "Быстрее всего — WhatsApp или Telegram." },
      { "q": "Сроки", "a": "Обычно 7–14 дней до отправки." }
    ],
    "en": [
      { "q": "Payment", "a": "PayPal Fast, PayPal.me, ETH. Exclusive +200 USD. Shipping paid separately." },
      { "q": "Shipping", "a": "Worldwide, tracked, express on request." },
      { "q": "Original", "a": "Drawn in ink liner. Originals are one of a kind." },
      { "q": "NFT", "a": "Rarible only. Links on NFT page." },
      { "q": "Rights", "a": "Exclusive = single commercial use." },
      { "q": "Size", "a": "Usually A5–A4, others on request." },
      { "q": "Color", "a": "Neon/aqua mood. Softer in person." },
      { "q": "Returns", "a": "If lost, refund or reship." },
      { "q": "Commission", "a": "Custom hearts & spirals based on stories." },
      { "q": "Guarantee", "a": "Safe packaging, full support." },
      { "q": "Contact", "a": "Fastest: WhatsApp or Telegram." },
      { "q": "Lead time", "a": "Usually 7–14 days to dispatch." }
    ]
  },
  "build": {
    "sitemap": "/sitemap.xml",
    "robots": "/robots.txt",
    "features": ["hero_rotator", "neon_waves", "fouc_guard", "tawk_embed", "pwa_register"],
    "force_html_dir": "/htdocs",
    "lastmod_strategy": "file-mtime-or-today",
    "gzip_html": false
  },
  "sitemap": {
    "base_url": "https://soulinpsyabstract.42web.io",
    "entries": [
      { "loc": "/htdocs/index.html", "priority": 1.0 },
      { "loc": "/htdocs/gallery.html", "priority": 0.9 },
      { "loc": "/htdocs/nft.html", "priority": 0.8 },
      { "loc": "/htdocs/manifest.html", "priority": 0.7 },
      { "loc": "/htdocs/poems.html", "priority": 0.6 },
      { "loc": "/htdocs/songs.html", "priority": 0.6 },
      { "loc": "/htdocs/faq.html", "priority": 0.6 },
      { "loc": "/htdocs/contacts.html", "priority": 0.5 }
    ]
  },
  "robots": {
    "content": "User-agent: *\nAllow: /\nDisallow: /assets/\nSitemap: https://soulinpsyabstract.42web.io/sitemap.xml\n"
  },
  "server": {
    "htaccess_needed": true,
    "htaccess": "AddDefaultCharset utf-8\n<IfModule mod_deflate.c>\n  AddOutputFilterByType DEFLATE text/html text/css application/javascript application/json image/svg+xml\n</IfModule>\n<IfModule mod_expires.c>\n  ExpiresActive On\n  ExpiresByType text/css \"access plus 30 days\"\n  ExpiresByType application/javascript \"access plus 30 days\"\n  ExpiresByType image/png \"access plus 30 days\"\n  ExpiresByType image/jpeg \"access plus 30 days\"\n  ExpiresByType image/svg+xml \"access plus 30 days\"\n  ExpiresByType font/ttf \"access plus 30 days\"\n</IfModule>\nAddType application/manifest+json .webmanifest\nAddType font/ttf .ttf\n"
  },
  "checks": {
    "html_dir_exists": true,
    "css_files": ["/assets/css/main.css", "/assets/css/fonts.css"],
    "js_files": [
      "/assets/js/app.js",
      "/assets/js/i18n.js",
      "/assets/js/rotator.js",
      "/assets/js/data.js",
      "/assets/js/pwa.js",
      "/assets/js/gallery.js",
      "/assets/js/inventory.js",
      "/assets/js/buy-modal.js",
      "/assets/js/buy-hook.js",
      "/assets/js/pay-config.js",
      "/assets/js/pay-shim.js",
      "/assets/js/text-pages.js",
      "/assets/js/faq.js",
      "/assets/js/nft.js",
      "/assets/js/tawk.js"
    ],
    "text_files": [
      "/assets/texts/about.txt",
      "/assets/texts/manifest.txt",
      "/assets/texts/poems.txt",
      "/assets/texts/songs.html",
      "/assets/texts/hero_phrases.json"
    ],
    "images_required": {
      "gallery_range": { "from": 1, "to": 94, "pad": 2, "ext": ".jpg" },
      "icons": ["/assets/img/icon-192.png", "/assets/img/icon-512.png", "/assets/img/og_cover.jpg", "/assets/img/favicon.png"]
    },
    "qrs_optional": [
      "/assets/img/qr_instagram.jpg",
      "/assets/img/qr_telegram_group.jpg",
      "/assets/img/qr_whatsapp.jpg",
      "/assets/img/qr_threads.jpg",
      "/assets/img/qr_tiktok.jpg",
      "/assets/img/qr_zora.jpg"
    ]
  },
  "accessibility": {
    "lang_toggle_has_label": true,
    "aria_live_rotator": "polite",
    "focus_outline_preserved": true,
    "reduced_motion_supported": true
  },
  "notes": [
    "Все страницы лежат в /htdocs; каноникалы на них указывают.",
    "Service Worker fallback обязательно на /htdocs/index.html.",
    "При правке CSS/JS увеличивай service_worker.cache_name.",
    "Ротатор показывает только текущую локаль (RU или EN).",
    "Галерея ожидает /assets/img/%02d.jpg: 01.jpg … 94.jpg.",
    "Песни/Стихи вставляются вербатим из файлов в /assets/texts."
  ]
}
