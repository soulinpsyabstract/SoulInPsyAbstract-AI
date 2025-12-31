// /assets/js/sections.js — рендер галереи (Buy/NFT/Sold)
(function(){
  const box = document.getElementById('gallery');
  if(!box) return;
  function card(a){
    const sold = (a.sold || (window.isSold && isSold(a.code)));
    return `
    <article class="tile">
      <img src="assets/img/${a.file}" alt="${a.title_ru||a.title_en}">
      <h3 class="lang-content active" data-lang="ru">${a.title_ru}</h3>
      <h3 class="lang-content" data-lang="en">${a.title_en}</h3>
      <p class="muted">USD ${a.price_usd}${a.nft?' • NFT':''}${sold?' • SOLD':''}</p>
      <div style="display:flex;gap:8px;flex-wrap:wrap">
        ${sold?'<span class="btn muted">Sold</span>':`<button class="btn primary" data-buy data-id="${a.code}" data-price="${a.price_usd}">Buy</button>`}
        ${a.nft?`<a class="btn" href="${a.nft}" target="_blank" rel="noopener">NFT</a>`:`<a class="btn" href="https://og.rarible.com/soulinpsyabstract" target="_blank" rel="noopener">NFT Profile</a>`}
      </div>
    </article>`;
  }
  function render(){ box.innerHTML = (window.__DATA__&&__DATA__.ART||[]).map(card).join(''); window.initBuyHook&&initBuyHook(); }
  document.addEventListener('DOMContentLoaded', render);
})();