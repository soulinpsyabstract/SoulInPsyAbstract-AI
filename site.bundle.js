/* ==========================================================================
   /assets/js/site.bundle.js
   Soul in PsyAbstract — единая боевая сборка
   Модули: конфиг, i18n, язык, ротатор, тексты, галерея, NFT, покупки,
           PWA, Tawk, мелкие утилиты.
   Никаких import — всё в одном файле, неймспейс window.PSA
   ========================================================================== */
(function(){
  'use strict';

  /* --------------------------- БАЗА / Неймспейс --------------------------- */
  const PSA = window.PSA = window.PSA || {};
  const ST = PSA.ST = {};                    // глобальное состояние
  const LS = window.localStorage;
  const LANG_KEY = 'soulinpsy_lang';         // как в YAML
  const DEFAULT_LANG = 'ru';
  const TEXT_PATHS = {
    about:   '/assets/texts/about.txt',
    manifest:'/assets/texts/manifest.txt',
    poems:   '/assets/texts/poems.txt',
    songs:   '/assets/texts/songs.html',
    hero:    '/assets/texts/hero_phrases.json'
  };

  /* ------------------------------- УТИЛИТЫ -------------------------------- */
  const $  = (sel, root=document) => root.querySelector(sel);
  const $$ = (sel, root=document) => Array.from(root.querySelectorAll(sel));
  const sleep = ms => new Promise(r => setTimeout(r, ms));
  const b64  = s => window.btoa(unescape(encodeURIComponent(s)));
  const safeJSON = (s, f=[]) => { try{ return JSON.parse(s) } catch{ return f } };
  const q = new URLSearchParams(location.search);

  // анти-кеш
  const fetchText = (url) => fetch(url, { cache:'no-store' }).then(r => {
    if(!r.ok) throw new Error('HTTP '+r.status+' @ '+url);
    return r.text();
  });
  const fetchJSON = (url) => fetch(url, { cache:'no-store' }).then(r => {
    if(!r.ok) throw new Error('HTTP '+r.status+' @ '+url);
    return r.json();
  });

  // мини-тост
  function toast(msg, timeout=3200){
    let el = $('.toast');
    if(!el){
      el = document.createElement('div');
      el.className = 'toast';
      document.body.appendChild(el);
    }
    el.textContent = msg;
    el.classList.add('show');
    setTimeout(()=> el.classList.remove('show'), timeout);
  }

  /* ------------------------------ КОНФИГ --------------------------------- */
  // 1) пытаемся взять site.config.json (готовый JSON от твоего YAML)
  // 2) если его нет, используем встроенные значения из твоего site_build_full.yaml
  async function loadConfig(){
    try{
      const cfg = await fetchJSON('/assets/js/site.config.json');
      ST.cfg = cfg;
      return cfg;
    }catch(e){
      // запасной борт со значениями, которые ты прислал (без сокращений)
      const fallback = {
        project:{
          name:"Soul in PsyAbstract",
          owner:"Marina Saponenko",
          canonical:"https://soulinpsyabstract.42web.io/",
          languages:["ru","en"],
          default_lang:"ru",
          routing:"spa-hash",
          content_mode:"verbatim"
        },
        seo:{
          title:"Soul in PsyAbstract — Marina | messy sketch · hearts · spirals · neon · acrylic",
          description:{
            ru:"Честность души в линиях хаоса. Сердца и спирали. Оригиналы, принты, on-chain (NFT), заказы.",
            en:"Soul honesty in lines of chaos. Hearts & spirals. Originals, prints, on-chain (NFT), commissions."
          },
          keywords_en:"soul in psyabstract, abstract line art, hearts and spirals, neon acrylic, Marina Saponenko, original drawings, buy abstract art, Rarible NFT"
        },
        pwa:{
          manifest:"/manifest.webmanifest",
          service_worker:"/service-worker.js",
          theme_color:"#0b0d10"
        },
        paths:{
          html:"/htdocs", css:"/assets/css", js:"/assets/js",
          img:"/assets/img", fonts:"/assets/fonts", audio:"/assets/audio", texts:"/assets/texts"
        },
        design:{
          theme_tokens:{ bg:"#050709", card:"#0d1015", line:"#1b2230", txt:"#c7ecff", neon:"#00f0ff", accent:"#18a4b9" },
          neon_waves:true, menu_two_lines:true, accent_animation:"soft-glow"
        },
        assets:{
          gallery:{ count:94, pattern:"/assets/img/%02d.jpg" },
          favicon:"/assets/img/favicon.png",
          og_image:"/assets/img/og_cover.jpg",
          qr:{
            instagram:"/assets/img/qr_instagram.jpg",
            telegram_group:"/assets/img/qr_telegram_group.jpg",
            whatsapp:"/assets/img/qr_whatsapp.jpg",
            threads:"/assets/img/qr_threads.jpg",
            tiktok:"/assets/img/qr_tiktok.jpg",
            zora:"/assets/img/qr_zora.jpg"
          },
          fonts:[
            { file:"/assets/fonts/Caveat-VariableFont_wght.ttf", family:"Caveat", weight:"100 900", preload:true },
            { file:"/assets/fonts/Pacifico-Regular.ttf", family:"Pacifico", weight:"400", preload:true },
            { file:"/assets/fonts/MarckScript-Regular.ttf", family:"Marck Script", weight:"400", preload:true }
          ]
        },
        texts:{
          about: TEXT_PATHS.about,
          manifest: TEXT_PATHS.manifest,
          poems: TEXT_PATHS.poems,
          songs: TEXT_PATHS.songs,
          hero_phrases: TEXT_PATHS.hero
        },
        payments:{
          eth:"0x2a7fFb7B3174fcA16CD2476a55E39f9Ea2d04073",
          paypal_me:"https://paypal.me/SoulInPsyAbstract?locale.x=en_US&country.x=IL",
          ncp_by_price:{
            "400":"TU5S4WBATKB5Y","600":"4G9HRSR622B3E","800":"C35VA4EUKNR7Q","1000":"DWXVT5MTH3NG8",
            "1200":"S625M8XK4LUQ6","1400":"7NE2M3WHBNSZU","1600":"3D8S966C9SAGS",
            "1800":"UEY7U4UTWHYAU","2000":"YY2J3K4ADFQLG"
          },
          shipping_ncp:{ ship150:"WN5SEBVTCPV2J", ship200:"X3FPSE4E3Z2PE", ship300:"VYBZADUBRHC4L" },
          exclusive_usd:200,
          price_ladder:{
            rule:"1–20: $400, 21–40: $600, 41–70: $800, 71–94: $1000",
            increase_every_sales:4,
            increase_amount:200
          }
        },
        social:{
          instagram:"https://www.instagram.com/soul.in.psyabstract",
          telegram:"https://t.me/messycketch",
          rarible:"https://og.rarible.com/soulinpsyabstract",
          zora:"https://zora.co/@soulinpsyabstract",
          tiktok:"https://www.tiktok.com/@soulinpsyabstract",
          threads:"https://www.threads.net/@soul.in.psyabstract",
          email:"mailto:soulinpsyabstract@gmail.com",
          whatsapp:"https://wa.me/972525074743"
        },
        chat:{
          tawk:{
            property_id:"68d8492a9c33dd1951ed7462",
            embed_script:"https://embed.tawk.to/68d8492a9c33dd1951ed7462/1j66drjvf"
          }
        },
        nft:{
          source:"rarible_only",
          links_source:"/assets/js/data.js"
        },
        gallery_logic:{
          hide_titles:true,
          missing_ids:[92,86,85,80,65,62,54,32],
          free_ids:[6,8,9,10,12,13,15,19,30,33,34,38,44,53,56,58,61,66,67,69,70,71,73,74,75,77,78,79,89,90,93],
          draft_ids:[68,94,64,63,52,51,50,28,26],
          duplicate_groups:[
            [76,79],[73,72],[60,59],[48,47,77],[46,44],[49,42],[40,39,25],[31,30,2],[23,44,17],[35,15],[14,20],[13,11],[6,7],[4,3],[1,8]
          ],
          sold_policy:"others_sold"
        },
        audio:{ playlist:"Voice 70–94", folder:"/assets/audio", format:"AUD-20251010-WA00%02d.mp3" },
        build:{
          pages:["index.html","gallery.html","nft.html","manifest.html","poems.html","songs.html","faq.html","contacts.html"],
          sitemap:"/sitemap.xml", robots:"/robots.txt", lang_storage_key:"soulinpsy_lang",
          features:["hero_rotator","neon_waves","tawk_embed","pwa_register"]
        }
      };
      ST.cfg = fallback;
      console.warn('[CFG] site.config.json не найден, работаем на встроенном наборе.');
      return fallback;
    }
  }

  /* ------------------------------ ЯЗЫК / I18N ----------------------------- */
  function getLang(){
    const fromLS = LS.getItem(LANG_KEY);
    if(fromLS) return fromLS;
    return (navigator.language || 'ru').startsWith('ru') ? 'ru' : 'en';
  }
  function setLang(l){
    ST.lang = (l==='ru'||l==='en') ? l : DEFAULT_LANG;
    LS.setItem(LANG_KEY, ST.lang);
    document.documentElement.setAttribute('data-lang', ST.lang);
    const btn = $('#lang-toggle');
    if(btn) btn.textContent = ST.lang.toUpperCase();
    // простая замена data-i18n по словарю
    if(ST.i18n){
      $$('[data-i18n]').forEach(el=>{
        const key = el.getAttribute('data-i18n');
        const pack = ST.i18n[key];
        if(pack && pack[ST.lang]) el.textContent = pack[ST.lang];
      });
    }
    // переключаем RU/EN секции на текстовых страницах
    $$('section[data-lang]').forEach(s=>{
      s.classList.toggle('show', s.getAttribute('data-lang')===ST.lang);
    });
  }

  // базовый словарик (можно расширять)
  ST.i18n = {
    'nav.home': {ru:'Главная', en:'Home'},
    'nav.gallery': {ru:'Галерея', en:'Gallery'},
    'nav.nft': {ru:'NFT', en:'NFT'},
    'nav.manifest': {ru:'Манифест', en:'Manifest'},
    'nav.poems': {ru:'Стихи', en:'Poems'},
    'nav.songs': {ru:'Песни', en:'Songs'},
    'nav.faq': {ru:'FAQ', en:'FAQ'},
    'nav.contacts': {ru:'Контакты', en:'Contacts'},
    'cta.view_gallery': {ru:'Смотреть галерею', en:'View gallery'},
    'cta.view_nft': {ru:'Смотреть NFT', en:'View NFT'},
    'contacts.h1': {ru:'Контакты', en:'Contacts'},
    'faq.h1': {ru:'FAQ', en:'FAQ'},
    'manifest.h1': {ru:'Манифест', en:'Manifest'},
    'poems.h1': {ru:'Стихи', en:'Poems'},
    'songs.h1': {ru:'Песни', en:'Songs'}
  };

  function bindLangToggle(){
    const btn = $('#lang-toggle');
    if(!btn) return;
    btn.addEventListener('click', ()=>{
      setLang(ST.lang === 'ru' ? 'en' : 'ru');
      toast(ST.lang==='ru' ? 'Язык: Русский' : 'Language: English');
      // перезапустить ротатор, чтобы показать нужный язык
      Rotator.restart();
    });
  }

  /* ----------------------------- РОТАТОР HERO ----------------------------- */
  // Берем из /assets/texts/hero_phrases.json список [{en:"...",ru:"..."}]
  const Rotator = (() => {
    let timer = null;
    let idx = 0;
    const period = 6000;
    const rootId = 'hero-rotator';

    async function ensureData(){
      if(ST.heroPhrases) return ST.heroPhrases;
      try{
        const data = await fetchJSON(TEXT_PATHS.hero);
        ST.heroPhrases = Array.isArray(data) ? data : [];
        return ST.heroPhrases;
      }catch(e){
        ST.heroPhrases = [
          {en:"Come fill the soul", ru:"Приди и наполни душу"},
          {en:"Dream can come true", ru:"Мечта может стать явью"},
          {en:"Touch the silence", ru:"Коснись тишины"},
          {en:"Hearts in motion", ru:"Сердца в движении"},
          {en:"Flow of honesty", ru:"Поток честности"},
          {en:"Love in every line", ru:"Любовь в каждой линии"},
        ];
        return ST.heroPhrases;
      }
    }

    function renderCard(text){
      const card = document.createElement('div');
      card.className = 'hero-card entering';
      card.innerHTML = `
        <div class="hero-card__row">
          <span class="hero-card__bullet"></span>
          <div class="hero-card__text">${text}</div>
        </div>
      `;
      return card;
    }

    function step(list, root){
      const lang = ST.lang || DEFAULT_LANG;
      const item = list[idx % list.length] || {};
      const text = (item && item[lang]) ? item[lang] : '';
      idx++;

      // старую карточку плавно убираем
      const prev = root.firstElementChild;
      if(prev){
        prev.classList.add('leaving');
        setTimeout(()=> prev.remove(), 420);
      }

      const el = renderCard(text);
      root.prepend(el);
      requestAnimationFrame(()=> el.classList.remove('entering'));
    }

    async function start(){
      const root = document.getElementById(rootId);
      if(!root) return;
      const list = await ensureData();
      if(!list.length) return;
      clearInterval(timer);
      idx = 0;
      step(list, root);
      timer = setInterval(()=> step(list, root), period);
    }

    function restart(){ clearInterval(timer); start(); }

    return { start, restart };
  })();

  /* --------------------------- ТЕКСТОВЫЕ СТРАНИЦЫ ------------------------- */
  async function renderVerbatimText(pageId){
    // manifest.html => #manifest-article
    // poems.html    => #poems-article
    // songs.html    => #songs-root
    let target, src;
    if(pageId==='manifest'){
      target = $('#manifest-article');
      src = ST.cfg?.texts?.manifest || TEXT_PATHS.manifest;
    }else if(pageId==='poems'){
      target = $('#poems-article');
      src = ST.cfg?.texts?.poems || TEXT_PATHS.poems;
    }else if(pageId==='songs'){
      target = $('#songs-root');
      src = ST.cfg?.texts?.songs || TEXT_PATHS.songs;
    }else{
      return;
    }
    if(!target) return;

    try{
      const isHTML = src.endsWith('.html');
      const txt = await fetchText(src);
      target.innerHTML = isHTML
        ? txt
        : `<section data-lang="ru" class="show"><pre>${escapeHTML(txt)}</pre></section>`; // poems/manifest у тебя часто plain
      // при смене языка секции уже переключаются селектором [data-lang]
    }catch(e){
      target.innerHTML = `<pre>Не удалось загрузить текст: ${e.message}</pre>`;
    }
  }
  function escapeHTML(s){ return s.replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }

  /* ------------------------------- ГАЛЕРЕЯ -------------------------------- */
  // Ожидается контейнер #gallery-grid
  async function buildGallery(){
    const root = $('#gallery-grid');
    if(!root) return;

    const cfg = ST.cfg || {};
    const count = cfg.assets?.gallery?.count || 94;
    const pattern = cfg.assets?.gallery?.pattern || '/assets/img/%02d.jpg';
    const free = new Set(cfg.gallery_logic?.free_ids || []);
    const draft = new Set(cfg.gallery_logic?.draft_ids || []);
    const missing = new Set(cfg.gallery_logic?.missing_ids || []);
    const hideTitles = !!cfg.gallery_logic?.hide_titles;

    const priceByIndex = (i) => {
      // Прайс-лестница как в YAML: 1–20:400, 21–40:600, 41–70:800, 71–94:1000
      if(i<=20) return 400;
      if(i<=40) return 600;
      if(i<=70) return 800;
      return 1000;
    };

    const items = [];
    for(let i=1;i<=count;i++){
      if(missing.has(i)) continue;
      const src = pattern.replace('%02d', String(i).padStart(2,'0'));
      const price = priceByIndex(i);
      const isFree = free.has(i);
      const isDraft = draft.has(i);
      items.push({ id:i, src, price, isFree, isDraft });
    }

    root.classList.add('grid-gallery');
    root.innerHTML = items.map(item=>{
      const badge = item.isDraft ? 'draft' : (item.isFree ? 'free' : '');
      const badgeText = item.isDraft ? (ST.lang==='ru'?'Драфт':'Draft') : (item.isFree ? (ST.lang==='ru'?'Свободна':'Available') : '');
      const priceStr = `$${item.price}`;
      return `
        <article class="art-card" data-id="${item.id}">
          <img loading="lazy" src="${item.src}" alt="Artwork #${item.id}">
          ${badge ? `<span class="badge ${badge}">${badgeText}</span>` : ''}
          <div class="buybar">
            <div class="price">${priceStr}${cfg.payments?.exclusive_usd ? ` <small>+${cfg.payments.exclusive_usd} exclusive</small>`:``}</div>
            <button class="btn btn-buy" data-buy="${item.id}">${ST.lang==='ru'?'Купить':'Buy'}</button>
          </div>
        </article>
      `;
    }).join('');

    root.addEventListener('click', (e)=>{
      const btn = e.target.closest('[data-buy]');
      if(!btn) return;
      const id = +btn.getAttribute('data-buy');
      const item = items.find(x=>x.id===id);
      if(item) openBuyModal(item);
    });
  }

  /* ----------------------------- NFT СТРАНИЦА ----------------------------- */
  // Ожидается контейнер #nft-list
  async function buildNFT(){
    const root = $('#nft-list');
    if(!root) return;
    let links = [];

    // 1) Если у тебя есть /assets/js/data.js, можно взять NFT оттуда:
    //    ожидаем window.PSA_DATA?.nftLinks = ["https://og.rarible.com/token/...", ...]
    // 2) Иначе берём из конфигурации (fallback).
    if(window.PSA_DATA && Array.isArray(window.PSA_DATA.nftLinks)){
      links = window.PSA_DATA.nftLinks.slice();
    }else if(Array.isArray(ST.cfg?.nft?.links)){
      links = ST.cfg.nft.links.slice();
    }else{
      // fallback из YAML может быть огромный; если нет — покажем подсказку
      root.innerHTML = `<p>${ST.lang==='ru'
        ? 'Ссылки на NFT не найдены. Добавь в window.PSA_DATA.nftLinks или в cfg.nft.links.'
        : 'NFT links not found. Provide window.PSA_DATA.nftLinks or cfg.nft.links.'}</p>`;
      return;
    }

    root.classList.add('grid-nft');
    root.innerHTML = links.map((href, i)=>`
      <article class="nft-card">
        <img loading="lazy" src="/assets/img/${String((i%94)+1).padStart(2,'0')}.jpg" alt="NFT #${i+1}">
        <div class="meta">
          <div>${ST.lang==='ru'?'On-chain ссылка':'On-chain link'}</div>
          <a class="btn btn nft" target="_blank" rel="noopener" href="${href}">
            ${ST.lang==='ru'?'Открыть на Rarible/Zora':'Open on Rarible/Zora'}
          </a>
        </div>
      </article>
    `).join('');
  }

  /* ------------------------------- ПОКУПКИ -------------------------------- */
  // Модалка покупки: NCP ключи по цене, PayPal.me, ETH
  function ensureModalRoot(){
    let root = $('#buy-modal-root');
    if(!root){
      root = document.createElement('div');
      root.id = 'buy-modal-root';
      document.body.appendChild(root);
    }
    return root;
  }

  function openBuyModal(item){
    const cfg = ST.cfg || {};
    const ncp = cfg.payments?.ncp_by_price || {};
    const eth = cfg.payments?.eth || '';
    const pp  = cfg.payments?.paypal_me || '';

    const code = ncp[String(item.price)] || '';
    const ship = cfg.payments?.shipping_ncp || {};

    const root = ensureModalRoot();
    root.innerHTML = `
      <div class="modal show" role="dialog" aria-modal="true">
        <div class="dialog">
          <div class="head">
            <strong>${ST.lang==='ru'?'Покупка работы':'Buy artwork'} #${item.id}</strong>
            <button class="x" data-x>×</button>
          </div>
          <div class="body">
            <div class="opts">
              <div class="opt">
                <div class="row"><div>${ST.lang==='ru'?'Базовая цена':'Base price'}</div><div>$${item.price}</div></div>
                <div class="hint">${ST.lang==='ru'?'Оригинал, без эксклюзива':'Original, no exclusive'}</div>
              </div>
              <div class="opt">
                <label class="row">
                  <span>${ST.lang==='ru'?'Exclusive + $':'Exclusive + $'}${cfg.payments?.exclusive_usd||200}</span>
                  <input type="checkbox" id="excl">
                </label>
                <div class="hint">${ST.lang==='ru'
                  ? 'Единственное коммерческое использование'
                  : 'Single commercial use'}</div>
              </div>
              <div class="opt">
                <label for="shipSel">${ST.lang==='ru'?'Доставка':'Shipping'}</label>
                <select id="shipSel">
                  <option value="">${ST.lang==='ru'?'Стандартная':'Standard'}</option>
                  <option value="ship150">$150</option>
                  <option value="ship200">$200</option>
                  <option value="ship300">$300</option>
                </select>
                <div class="hint">${ST.lang==='ru'?'Миром, трекинг, экспресс по запросу':'Worldwide, tracked, express on request'}</div>
              </div>
            </div>
            <div class="total">${ST.lang==='ru'?'Итого':'Total'}: <span id="total"></span></div>
          </div>
          <div class="foot">
            <div class="pay-notes">
              <div>${ST.lang==='ru'?'PayPal.me':''} ${pp ? `<a class="btn mail" href="${pp}" target="_blank" rel="noopener">PayPal.me</a>`:''}</div>
              <div>${ST.lang==='ru'?'ETH':'ETH'}: <code>${eth}</code> <button class="btn" data-copy-eth>${ST.la