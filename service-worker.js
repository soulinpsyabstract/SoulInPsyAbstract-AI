
const CACHE = "sipa-cache-v1";
const CORE = [
  "index.html","gallery.html","nft.html","manifest.html","poems.html","songs.html","faq.html","contacts.html","ai.html",
  "assets/css/main.css","assets/js/app.js",
  "assets/data/gallery.json","assets/data/manifest.json","assets/data/poems.json","assets/data/songs.json",
  "assets/data/faq.json","assets/data/contacts.json","assets/data/nft.json","assets/data/ai_canon.json","assets/data/hero_phrases.json"
];
self.addEventListener("install",(e)=>{
  e.waitUntil(caches.open(CACHE).then(c=>c.addAll(CORE)).then(()=>self.skipWaiting()));
});
self.addEventListener("activate",(e)=>{
  e.waitUntil(self.clients.claim());
});
self.addEventListener("fetch",(e)=>{
  const req = e.request;
  const url = new URL(req.url);
  if(url.origin !== location.origin) return;
  e.respondWith(
    caches.match(req).then(cached=>{
      return cached || fetch(req).then(res=>{
        const copy = res.clone();
        if(req.method==="GET" && res.ok){
          caches.open(CACHE).then(c=>c.put(req, copy)).catch(()=>{});
        }
        return res;
      }).catch(()=>cached);
    })
  );
});
