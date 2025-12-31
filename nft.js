
;(() => {
  const mount = document.getElementById('nft-list');
  if (!mount) return;
  fetch('/config.js').then(r=>r.json()).then(cfg => {
    const links = (cfg.nft && cfg.nft.links) || [];
    const grid = document.createElement('div');
    grid.className = 'nft-grid';
    links.forEach(href => {
      const a = document.createElement('a');
      a.className = 'btn';
      a.href = href; a.target = '_blank'; a.rel = 'noopener';
      a.textContent = (window.__LANG==='en'?'Open':'Открыть');
      const card = document.createElement('article');
      card.className = 'nft-card';
      const b = document.createElement('span'); b.className='nft-badge'; b.textContent = href.includes('/polygon/')?'Rarible (Polygon)':'Rarible';
      const h3e = document.createElement('h3'); h3e.setAttribute('data-lang','en'); h3e.className='show'; h3e.textContent='NFT Link';
      const h3r = document.createElement('h3'); h3r.setAttribute('data-lang','ru'); h3r.textContent='Ссылка на NFT';
      const pe = document.createElement('p'); pe.className='muted'; pe.setAttribute('data-lang','en'); pe.textContent='Opens in new tab.';
      const pr = document.createElement('p'); pr.className='muted'; pr.setAttribute('data-lang','ru'); pr.textContent='Откроется в новой вкладке.';
      card.appendChild(b); card.appendChild(h3e); card.appendChild(h3r); card.appendChild(pe); card.appendChild(pr); card.appendChild(a);
      grid.appendChild(card);
    });
    mount.appendChild(grid);
  }).catch(()=>{});
})();
