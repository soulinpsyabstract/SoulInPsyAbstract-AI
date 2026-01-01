const C='sipa-v1';
const ASSETS=[
  '/', '/index.html','/gallery.html','/nft.html','/manifest.html','/poems.html','/songs.html','/faq.html','/contacts.html',
  '/assets/css/main.css','/assets/css/fonts.css',
  '/assets/js/app.js','/assets/js/hero6.js','/assets/js/data.js','/assets/js/data-bridge.js','/assets/js/meta.js','/assets/js/titles.js','/assets/js/texts.js',
  '/assets/js/pay-config.js','/assets/js/pay-shim.js','/assets/js/buy-hook.js','/assets/js/buy-modal.js','/assets/js/sections.js','/assets/js/player.js',
  '/assets/texts/hero_phrases.json','/assets/texts/about.txt','/assets/texts/songs.html'
];
self.addEventListener('install',e=>{e.waitUntil(caches.open(C).then(c=>c.addAll(ASSETS)).then(()=>self.skipWaiting()))});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k!==C).map(k=>caches.delete(k)))) )});
self.addEventListener('fetch',e=>{e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request)))});
