(function(){
  'use strict';

  const PSA = window.PSA = window.PSA || {};
  const ST = PSA.ST = PSA.ST || {};
  const LS = window.localStorage;
  const LANG_KEY = 'soulinpsy_lang';
  const DEFAULT_LANG = 'ru';

  const $ = (s, r=document)=>r.querySelector(s);
  const $$= (s, r=document)=>Array.from(r.querySelectorAll(s));

  function toast(msg, ms=2600){
    let el = $('.toast');
    if(!el){
      el = document.createElement('div');
      el.className = 'toast';
      document.body.appendChild(el);
    }
    el.textContent = msg;
    el.classList.add('show');
    setTimeout(()=>el.classList.remove('show'), ms);
  }

  const fetchText = (url)=>fetch(url,{cache:'no-store'}).then(r=>{ if(!r.ok) throw new Error('HTTP '+r.status); return r.text(); });
  const fetchJSON = (url)=>fetch(url,{cache:'no-store'}).then(r=>{ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); });

  async function loadConfig(){
    try{
      ST.cfg = await fetchJSON('/assets/js/site.config.json');
      return ST.cfg;
    }catch(e){
      ST.cfg = { project:{name:'SoulInPsyAbstract', languages:['ru','en'], default_lang:'ru'}, texts:{ hero_phrases:'/assets/texts/hero_phrases.json' } };
      return ST.cfg;
    }
  }

  ST.i18n = ST.i18n || {
    'nav.home':{ru:'Главная',en:'Home'},
    'nav.gallery':{ru:'Галерея',en:'Gallery'},
    'nav.nft':{ru:'NFT',en:'NFT'},
    'nav.manifest':{ru:'Манифест',en:'Manifest'},
    'nav.poems':{ru:'Стихи',en:'Poems'},
    'nav.songs':{ru:'Песни',en:'Songs'},
    'nav.faq':{ru:'FAQ',en:'FAQ'},
    'nav.contacts':{ru:'Контакты',en:'Contacts'},
    'nav.ai':{ru:'AI',en:'AI'},
    'cta.buy':{ru:'Купить',en:'Buy'},
  };

  function getLang(){
    const v = LS.getItem(LANG_KEY);
    if(v==='ru' || v==='en') return v;
    const n = (navigator.language||'ru').toLowerCase();
    return n.startsWith('ru') ? 'ru' : 'en';
  }

  function setLang(l){
    ST.lang = (l==='ru'||l==='en') ? l : DEFAULT_LANG;
    LS.setItem(LANG_KEY, ST.lang);
    document.documentElement.setAttribute('data-lang', ST.lang);

    const btn = $('#lang-toggle');
    if(btn) btn.textContent = ST.lang.toUpperCase();

    $$('[data-i18n]').forEach(el=>{
      const key = el.getAttribute('data-i18n');
      const pack = ST.i18n[key];
      if(pack && pack[ST.lang]) el.textContent = pack[ST.lang];
    });

    $$('section[data-lang]').forEach(s=>{
      s.classList.toggle('show', s.getAttribute('data-lang')===ST.lang);
    });
  }

  function bindLangToggle(){
    const btn = $('#lang-toggle');
    if(!btn) return;
    btn.addEventListener('click', ()=>{
      setLang(ST.lang === 'ru' ? 'en' : 'ru');
      toast(ST.lang==='ru'?'Язык: Русский':'Language: English');
      Rotator.restart();
    });
  }

  function highlightNav(){
    const file = (location.pathname.split('/').pop() || 'index.html').toLowerCase();
    $$('.nav a').forEach(a=>{
      const href = (a.getAttribute('href')||'').toLowerCase();
      a.classList.toggle('active', href===file);
    });
  }

  // NAV GUARD: если ссылка ведёт на отсутствующую страницу из списка, блокируем.
  const PAGES = ['index.html','gallery.html','nft.html','manifest.html','poems.html','songs.html','faq.html','contacts.html','ai.html'];
  function bindNavGuard(){
    document.addEventListener('click',(e)=>{
      const a = e.target.closest('a');
      if(!a) return;
      const href = a.getAttribute('href')||'';
      if(!href.endsWith('.html')) return;
      if(!PAGES.includes(href)){
        e.preventDefault();
        console.warn('Blocked missing page:', href);
        toast('Link disabled (missing page): '+href);
      }
    });
  }

  const Rotator = (() => {
    let timer=null, idx=0;
    const period=6000;
    const rootId='hero-rotator';

    async function ensure(){
      if(ST.heroPhrases) return ST.heroPhrases;
      const src = ST.cfg?.texts?.hero_phrases || '/assets/texts/hero_phrases.json';
      try{
        const data = await fetchJSON(src);
        ST.heroPhrases = Array.isArray(data)?data:[];
      }catch{
        ST.heroPhrases = [{ru:'Честность важнее идеальности.',en:'Honesty over perfection.'}];
      }
      return ST.heroPhrases;
    }

    function render(text){
      const card = document.createElement('div');
      card.className='hero-card';
      card.innerHTML = `<div class="hero-card__row"><span class="hero-card__bullet"></span><div class="hero-card__text">${text}</div></div>`;
      return card;
    }

    async function start(){
      const root = document.getElementById(rootId);
      if(!root) return;
      const list = await ensure();
      if(!list.length) return;
      clearInterval(timer);
      idx=0;
      step(list, root);
      timer=setInterval(()=>step(list,root), period);
    }

    function step(list, root){
      const item = list[idx % list.length] || {};
      const text = item[ST.lang] || '';
      idx++;
      root.innerHTML='';
      root.appendChild(render(text));
    }

    function restart(){ clearInterval(timer); start(); }
    return { start, restart };
  })();

  function escapeHTML(s){ return s.replace(/[&<>"']/g,(m)=>({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[m])); }

  async function renderTextPage(){
    const page = (location.pathname.split('/').pop() || 'index.html').toLowerCase();
    if(page==='manifest.html'){
      const root = $('#manifest-article'); if(!root) return;
      const txt = await fetchText('/assets/texts/manifest.txt');
      root.innerHTML = `<pre>${escapeHTML(txt)}</pre>`;
    }
    if(page==='poems.html'){
      const root = $('#poems-article'); if(!root) return;
      const txt = await fetchText('/assets/texts/poems.txt');
      root.innerHTML = `<pre>${escapeHTML(txt)}</pre>`;
    }
    if(page==='songs.html'){
      const root = $('#songs-root'); if(!root) return;
      const html = await fetchText('/assets/texts/songs.html');
      root.innerHTML = html;
      setLang(ST.lang); // чтобы секции переключились
    }
  }

  async function buildGallery(){
    const root = $('#gallery-grid'); if(!root) return;
    const count = ST.cfg?.assets?.gallery?.count || 94;
    const pattern = ST.cfg?.assets?.gallery?.pattern || '/assets/img/%02d.jpg';
    const priceByIndex = (i)=> i<=20?400 : i<=40?600 : i<=70?800 : 1000;

    const items=[];
    for(let i=1;i<=count;i++){
      const src = pattern.replace('%02d', String(i).padStart(2,'0'));
      items.push({id:i, src, price:priceByIndex(i)});
    }

    root.innerHTML = items.map(it=>`
      <article class="art-card" data-id="${it.id}">
        <img loading="lazy" src="${it.src}" alt="Artwork #${it.id}" onerror="this.style.opacity=.25; this.alt='Missing image ${it.id}'">
        <div class="buybar">
          <div class="price">$${it.price}</div>
          <button class="btn btn-buy" data-buy="${it.id}">${ST.lang==='ru'?'Купить':'Buy'}</button>
        </div>
      </article>
    `).join('');

    root.addEventListener('click',(e)=>{
      const btn = e.target.closest('[data-buy]');
      if(!btn) return;
      const id = +btn.getAttribute('data-buy');
      const it = items.find(x=>x.id===id);
      if(it) openBuyModal(it);
    });
  }

  async function buildNFT(){
    const root = $('#nft-list'); if(!root) return;
    const links = ST.cfg?.nft?.links || [];
    if(!links.length){
      root.innerHTML = `<p class="p">${ST.lang==='ru'?'Ссылки NFT пока не добавлены.':'NFT links not added yet.'}</p>`;
      return;
    }
    root.innerHTML = links.map(h=>`<p><a target="_blank" rel="noopener" href="${h}">${h}</a></p>`).join('');
  }

  function ensureModalRoot(){
    let r = $('#buy-modal-root');
    if(!r){ r=document.createElement('div'); r.id='buy-modal-root'; document.body.appendChild(r); }
    return r;
  }

  function openBuyModal(item){
    const cfg = ST.cfg || {};
    const pp = cfg.payments?.paypal_me || '';
    const eth = cfg.payments?.eth || cfg.payments?.eth_address || '';
    const ncp = cfg.payments?.ncp_by_price || cfg.payments?.ncp_by_price || cfg.payments?.paypal_fast_ncp || {};
    const shipNcp = cfg.payments?.shipping_ncp || cfg.payments?.shipping_ncp || {};
    const excl = cfg.payments?.exclusive_usd || 200;

    const root = ensureModalRoot();
    root.innerHTML = `
      <div class="modal show" role="dialog" aria-modal="true">
        <div class="dialog">
          <div class="head">
            <strong>${ST.lang==='ru'?'Покупка':'Buy'} #${item.id}</strong>
            <button class="btn" data-x>×</button>
          </div>
          <div class="body">
            <div class="opts">
              <div class="opt">
                <div class="row"><div>${ST.lang==='ru'?'База':'Base'}</div><div>$${item.price}</div></div>
                <div class="hint">${ST.lang==='ru'?'Оригинал.':'Original.'}</div>
              </div>
              <div class="opt">
                <label class="row">
                  <span>${ST.lang==='ru'?'Exclusive +':'Exclusive +'} $${excl}</span>
                  <input type="checkbox" id="excl">
                </label>
                <div class="hint">${ST.lang==='ru'?'Коммерческое использование (1 кейс).':'Single commercial use.'}</div>
              </div>
              <div class="opt">
                <label class="row">
                  <span>${ST.lang==='ru'?'Доставка':'Shipping'}</span>
                  <select id="shipSel" class="btn">
                    <option value="">${ST.lang==='ru'?'Стандарт':'Standard'}</option>
                    <option value="ship150">$150</option>
                    <option value="ship200">$200</option>
                    <option value="ship300">$300</option>
                  </select>
                </label>
                <div class="hint">${ST.lang==='ru'?'Трекинг. Экспресс по запросу.':'Tracked. Express on request.'}</div>
              </div>
            </div>
            <div class="total">${ST.lang==='ru'?'Итого':'Total'}: <span id="total"></span></div>
            <div class="p" style="margin-top:10px">
              ${pp ? `<a class="btn" target="_blank" rel="noopener" href="${pp}">PayPal.me</a>`:''}
              ${eth ? `<button class="btn" data-copy-eth>${ST.lang==='ru'?'Копировать ETH':'Copy ETH'}</button>`:''}
              ${ncp[String(item.price)] ? `<button class="btn" data-paypal-fast>${ST.lang==='ru'?'PayPal Fast':'PayPal Fast'}</button>`:''}
            </div>
            <div class="hint" id="payhint"></div>
          </div>
        </div>
      </div>
    `;

    const modal = $('.modal', root);
    const totalEl = $('#total', root);
    const exclEl = $('#excl', root);
    const shipEl = $('#shipSel', root);
    const hint = $('#payhint', root);

    const calc = ()=>{
      const base = item.price;
      const ex = exclEl.checked ? excl : 0;
      const shipKey = shipEl.value;
      const ship = shipKey==='ship150'?150 : shipKey==='ship200'?200 : shipKey==='ship300'?300 : 0;
      totalEl.textContent = '$' + (base + ex + ship);
      return {base, ex, ship, shipKey};
    };
    calc();

    root.addEventListener('change', (e)=>{
      if(e.target.id==='excl' || e.target.id==='shipSel') calc();
    });

    root.addEventListener('click',(e)=>{
      const x = e.target.closest('[data-x]');
      if(x){ modal.remove(); return; }

      const c = e.target.closest('[data-copy-eth]');
      if(c && eth){
        navigator.clipboard?.writeText(eth).then(()=>toast('ETH copied')).catch(()=>toast('Copy failed'));
      }

      const fast = e.target.closest('[data-paypal-fast]');
      if(fast){
        const st = calc();
        const code = ncp[String(item.price)] || '';
        const shipCode = st.shipKey ? (shipNcp[st.shipKey]||'') : '';
        hint.textContent = (ST.lang==='ru'
          ? `PayPal Fast коды: цена ${code}${shipCode?`, доставка ${shipCode}`:''}`
          : `PayPal Fast codes: price ${code}${shipCode?`, shipping ${shipCode}`:''}`);
      }
    });
  }

  function injectTawk(){
    const t = ST.cfg?.chat?.tawk;
    if(!t || !t.embed_script) return;
    const s = document.createElement('script');
    s.async=true; s.src=t.embed_script; s.charset='UTF-8'; s.setAttribute('crossorigin','*');
    document.head.appendChild(s);
  }

  async function boot(){
    await loadConfig();
    ST.lang = getLang();
    setLang(ST.lang);

    bindLangToggle();
    bindNavGuard();
    highlightNav();

    Rotator.start();
    renderTextPage();
    buildGallery();
    buildNFT();

    injectTawk();
  }

  document.addEventListener('DOMContentLoaded', boot);
})();
