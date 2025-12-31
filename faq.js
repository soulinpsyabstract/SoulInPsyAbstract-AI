
;(() => {
  const mount = document.getElementById('faq-mini');
  if (!mount) return;
  fetch('/config.js').then(r=>r.json()).then(cfg => {
    const data = (cfg.faq_mini && cfg.faq_mini[window.__LANG||'ru']) || [];
    const frag = document.createDocumentFragment();
    data.slice(0,8).forEach(item => {
      const d = document.createElement('details');
      const s = document.createElement('summary'); s.textContent = item.q;
      const p = document.createElement('p'); p.textContent = item.a;
      d.appendChild(s); d.appendChild(p);
      frag.appendChild(d);
    });
    mount.appendChild(frag);
  }).catch(()=>{});
})();
