
;(() => {
  const mount = document.getElementById('gallery');
  if (!mount) return;

  // config for gallery
  const FREE = new Set([6,8,9,10,12,13,15,19,30,33,34,38,44,53,56,58,61,66,67,69,70,71,73,74,75,77,78,79,89,90,93]);
  const DRAFT = new Set([68,94,64,63,52,51,50,28,26]);
  const SOLD = new Set(); // computed dynamically if needed

  function priceFor(i){
    // tiers cycle 400/600/800/1000 for demo
    const tiers = [400,600,800,1000];
    return tiers[(i-1) % tiers.length];
  }

  const grid = document.createElement('div');
  grid.className = 'grid-arts';

  for (let i=1;i<=94;i++){
    const card = document.createElement('article');
    card.className = 'art';
    const img = document.createElement('img');
    img.src = `/assets/img/${String(i).padStart(2,'0')}.jpg`;
    img.alt = `Art #${i}`;
    img.onerror = () => { img.style.objectFit = 'contain'; img.alt = 'image placeholder'; };
    const meta = document.createElement('div');
    meta.className = 'meta';

    const badge = document.createElement('span');
    badge.className = 'badge';
    if (DRAFT.has(i)) badge.textContent = 'DRAFT';
    else if (FREE.has(i)) badge.textContent = 'FREE';
    else badge.textContent = 'FOR SALE';

    const p = document.createElement('div');
    p.className = 'muted';
    p.textContent = window.__LANG === 'en'
      ? 'Ink liner. One of a kind. Aquamarine mood.'
      : 'Лайнер. Уникальный оригинал. Аквамариновое настроение.';

    const buy = document.createElement('div');
    buy.className = 'buybar';
    const btn = document.createElement('a');
    btn.className = 'btn';
    const price = priceFor(i);
    btn.textContent = (window.__LANG === 'en' ? 'Buy ' : 'Купить ') + `$${price}`;
    btn.href = '#';
    btn.addEventListener('click', (e) => { e.preventDefault(); openBuy(i, price); });
    buy.appendChild(btn);

    meta.appendChild(badge);
    meta.appendChild(p);
    meta.appendChild(buy);

    card.appendChild(img);
    card.appendChild(meta);
    grid.appendChild(card);
  }
  mount.appendChild(grid);

  // minimal buy modal shim
  window.openBuy = function(idx, basePrice){
    const exclusive = confirm((window.__LANG==='en'?'Add exclusive rights +$200?':'Добавить эксклюзивные права +$200?'));
    const shipping = prompt(window.__LANG==='en'?'Shipping (150/200/300):':'Доставка (150/200/300):','150');
    const total = basePrice + (exclusive?200:0) + (parseInt(shipping||'0',10)||0);
    alert((window.__LANG==='en'?'Total: $':'Итого: $') + total + '\n' + (window.__LANG==='en'?'PayPal link will open now.':'Сейчас откроется ссылка PayPal.'));
    // open PayPal.me fast link with amount
    window.open('https://paypal.me/SoulInPsyAbstract/' + total, '_blank');
  };
})();
