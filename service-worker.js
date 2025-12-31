const CACHE_NAME = 'sipa-cache-v1';
const CORE = [
  '/', '/index.html','/gallery.html','/nft.html','/manifest.html','/poems.html','/songs.html','/faq.html','/contacts.html','/ai.html',
  '/assets/css/main.css','/assets/js/core.js','/assets/js/site.config.json','/assets/texts/hero_phrases.json','/manifest.webmanifest'
];

self.addEventListener('install', (event)=>{
  event.waitUntil(caches.open(CACHE_NAME).then(c=>c.addAll(CORE)).then(()=>self.skipWaiting()));
});

self.addEventListener('activate', (event)=>{
  event.waitUntil(
    caches.keys().then(keys=>Promise.all(keys.filter(k=>k!==CACHE_NAME).map(k=>caches.delete(k))))
      .then(()=>self.clients.claim())
  );
});

self.addEventListener('fetch', (event)=>{
  const req = event.request;
  const url = new URL(req.url);
  if(req.method !== 'GET' || url.origin !== location.origin) return;

  const isHTML = req.headers.get('accept')?.includes('text/html');
  if(isHTML){
    event.respondWith(
      fetch(req).then(res=>{
        const copy = res.clone();
        caches.open(CACHE_NAME).then(c=>c.put(req, copy));
        return res;
      }).catch(()=>caches.match(req).then(r=>r||caches.match('/index.html')))
    );
    return;
  }

  event.respondWith(
    caches.match(req).then(cached => cached || fetch(req).then(res=>{
      const copy = res.clone();
      caches.open(CACHE_NAME).then(c=>c.put(req, copy));
      return res;
    }))
  );
});
