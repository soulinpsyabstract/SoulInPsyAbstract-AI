
(async function(){
  const $ = (sel)=>document.querySelector(sel);
  const $$ = (sel)=>Array.from(document.querySelectorAll(sel));
  const store = {
    get(k, d){ try{ return localStorage.getItem(k) ?? d; }catch(e){ return d; } },
    set(k, v){ try{ localStorage.setItem(k, v); }catch(e){} }
  };

  const state = {
    lang: (store.get("sipa_lang","ru") || "ru").toLowerCase(),
    kid: store.get("sipa_kid","0")==="1",
    phrases:null,
    data:{}
  };

  function t(en, ru){ return state.lang==="en" ? en : ru; }

  async function loadJSON(path){
    const res = await fetch(path, {cache:"no-store"});
    if(!res.ok) throw new Error("Failed to load "+path);
    return res.json();
  }

  async function boot(){
    // load common data
    state.phrases = await loadJSON("assets/data/hero_phrases.json");

    const page = document.body.getAttribute("data-page") || "index";
    // wire buttons
    const langBtn = $("#lang-toggle");
    if(langBtn){
      langBtn.textContent = state.lang.toUpperCase();
      langBtn.addEventListener("click", ()=>{
        state.lang = (state.lang==="ru") ? "en" : "ru";
        store.set("sipa_lang", state.lang);
        location.reload();
      });
    }
    const kidBtn = $("#kid-toggle");
    if(kidBtn){
      kidBtn.textContent = state.kid ? t("Kid: ON","Ребёнок: ON") : t("Kid: OFF","Ребёнок: OFF");
      kidBtn.addEventListener("click", ()=>{
        state.kid = !state.kid;
        store.set("sipa_kid", state.kid ? "1":"0");
        location.reload();
      });
    }

    heroRotator();

    // page render
    if(page==="gallery") await renderGallery();
    if(page==="nft") await renderNFT();
    if(page==="songs") await renderSongs();
    if(page==="poems") await renderText("poems");
    if(page==="manifest") await renderText("manifest");
    if(page==="faq") await renderFAQ();
  if(page==="kid") await renderKid();
    if(page==="contacts") await renderContacts();
    if(page==="ai") await renderAI();
  }

  function heroRotator(){
    const el = $("#hero-rotator");
    if(!el) return;

    const list = state.kid
      ? (state.lang==="en" ? state.phrases.kid_en : state.phrases.kid_ru)
      : (state.lang==="en" ? state.phrases.en : state.phrases.ru);

    let i = 0;
    const tick = ()=>{
      el.textContent = list[i % list.length];
      i++;
    };
    tick();
    setInterval(tick, 3600);
  }

  async function renderGallery(){
    const wrap = $("#gallery-grid");
    if(!wrap) return;
    const data = await loadJSON("assets/data/gallery.json");
    wrap.innerHTML = "";
    data.items.forEach(it=>{
      const card = document.createElement("div");
      card.className="art";
      card.innerHTML = `
        <img loading="lazy" src="${it.img}" alt="${escapeHtml(state.lang==="en"?it.title_en:it.title_ru)}">
        <div class="meta">
          <div class="title">${escapeHtml(state.lang==="en"?it.title_en:it.title_ru)}</div>
          <div class="k">${escapeHtml(it.serial)} · ${escapeHtml(it.year)} · ${it.uv ? "UV" : ""}</div>
        </div>`;
      wrap.appendChild(card);
    });
    $("#gallery-count").textContent = String(data.items.length);
  }

  async function renderNFT(){
    const wrap = $("#nft-list");
    if(!wrap) return;
    const data = await loadJSON("assets/data/nft.json");
    wrap.innerHTML = "";
    data.collections.forEach(c=>{
      const row = document.createElement("div");
      row.className="row";
      const url = (c.url||"").trim();
      row.innerHTML = `
        <div>
          <div class="title">${escapeHtml(c.name)}</div>
          <div class="small">${escapeHtml(state.lang==="en" ? (c.note_en||"") : (c.note_ru||""))}</div>
        </div>
        <div class="right">${url ? `<a href="${url}" target="_blank" rel="noopener">open</a>` : t("missing link","нет ссылки")}</div>`;
      wrap.appendChild(row);
    });
  }

  async function renderSongs(){
    const wrap = $("#songs-root");
    if(!wrap) return;
    const data = await loadJSON("assets/data/songs.json");
    wrap.innerHTML = "";
    data.items.forEach(s=>{
      const row = document.createElement("div");
      row.className="row";
      const url = (s.url||"").trim();
      row.innerHTML = `
        <div>
          <div class="title">${escapeHtml(state.lang==="en"?s.title_en:s.title_ru)}</div>
          <div class="small">${escapeHtml(state.lang==="en"? (s.note_en||"") : (s.note_ru||""))}</div>
          ${url ? `<audio controls preload="none" src="${url}" style="width:100%;margin-top:10px"></audio>` : ``}
        </div>
        <div class="right">${url ? "audio" : t("no audio yet","аудио пока нет")}</div>`;
      wrap.appendChild(row);
    });
  }

  async function renderText(kind){
    const el = $("#text-article");
    if(!el) return;
    const data = await loadJSON(`assets/data/${kind}.json`);
    const txt = state.lang==="en" ? (data.text_en||"") : (data.text_ru||"");
    el.textContent = txt || t("Text not added yet.","Текст ещё не добавлен.");
  }

  async function renderFAQ(){
    const wrap = $("#faq-list");
    if(!wrap) return;
    const data = await loadJSON("assets/data/faq.json");
    wrap.innerHTML = "";
    data.items.forEach(it=>{
      const row=document.createElement("div");
      row.className="card";
      row.innerHTML = `
        <div class="title">${escapeHtml(state.lang==="en"?it.q_en:it.q_ru)}</div>
        <div class="small" style="margin-top:8px">${escapeHtml(state.lang==="en"?it.a_en:it.a_ru)}</div>`;
      wrap.appendChild(row);
    });
  }

async function renderKid(){
  const root = qs("#kid-root");
  if(!root) return;
  const data = await loadJSON("assets/data/kid.json", { sections: [] });
  const lang = state.lang || "en";
  const title = lang==="ru" ? (data.title_ru || "Ребёнок") : (data.title_en || "Kid");
  const intro = lang==="ru" ? (data.intro_ru || "") : (data.intro_en || "");
  root.innerHTML = `
    <section class="card">
      <h2 class="h2">${escapeHTML(title)}</h2>
      ${intro ? `<p class="muted">${escapeHTML(intro)}</p>` : ""}
    </section>
  `;

  (data.sections||[]).forEach(sec=>{
    const h = lang==="ru" ? (sec.h_ru||sec.h_en||"") : (sec.h_en||sec.h_ru||"");
    const p = lang==="ru" ? (sec.p_ru||sec.p_en||"") : (sec.p_en||sec.p_ru||"");
    const items = (lang==="ru" ? (sec.items_ru||sec.items_en||[]) : (sec.items_en||sec.items_ru||[])) || [];
    const el = document.createElement("section");
    el.className = "card";
    el.innerHTML = `
      ${h ? `<h3 class="h3">${escapeHTML(h)}</h3>` : ""}
      ${p ? `<p>${escapeHTML(p)}</p>` : ""}
      ${items.length ? `<ul class="list">${items.map(x=>`<li>${escapeHTML(String(x))}</li>`).join("")}</ul>` : ""}
    `;
    root.appendChild(el);
  });
}

  async function renderContacts(){
    const wrap=$("#contacts-root");
    if(!wrap) return;
    const c = await loadJSON("assets/data/contacts.json");
    wrap.innerHTML = `
      <div class="list">
        <div class="row"><div class="title">Email</div><div class="right">${escapeHtml(c.email||"")}</div></div>
        <div class="row"><div class="title">Instagram</div><div class="right">${escapeHtml(c.instagram||"")}</div></div>
        <div class="row"><div class="title">Linktree</div><div class="right">${escapeHtml(c.linktree||"")}</div></div>
      </div>`;
  }

  async function renderAI(){
    const canonBox=$("#canon-box");
    const patchesBox=$("#patches-box");
    if(!canonBox || !patchesBox) return;

    const a = await loadJSON("assets/data/ai_canon.json");
    canonBox.innerHTML = `
      <ul>
        <li>${escapeHtml(a.core)}</li>
        <li>${escapeHtml(a.disclosure)}</li>
        <li>${escapeHtml(a.payton)}</li>
      </ul>
      <div class="small">${escapeHtml(state.lang==="en"?a.note_en:a.note_ru)}</div>
      <div class="small" style="margin-top:10px">
        <a href="assets/ai-canon/CORE_CANON.json" target="_blank" rel="noopener">CORE_CANON.json</a> ·
        <a href="assets/ai-canon/PATCHES/v1.1.9_PATCH01_DORMANT_STATE_GOVERNANTE_ZEROTOLERANT_AI.json" target="_blank" rel="noopener">PATCH01</a>
      </div>
    `;

    // render patch list from file if exists
    try{
      const core = await loadJSON("assets/ai-canon/CORE_CANON.json");
      const patch = await loadJSON("assets/ai-canon/PATCHES/v1.1.9_PATCH01_DORMANT_STATE_GOVERNANTE_ZEROTOLERANT_AI.json");
      const items = [];
      if(core && core.active_patches) items.push(...core.active_patches);
      if(patch && patch.patch_name) items.unshift(patch.patch_name);
      patchesBox.innerHTML = `<ul>${items.map(x=>`<li>${escapeHtml(String(x))}</li>`).join("")}</ul>`;
    }catch(e){
      patchesBox.innerHTML = `<div class="small">${escapeHtml(t("Patches file not found.","Файл патчей не найден."))}</div>`;
    }
  }

  function escapeHtml(str){
    return String(str).replace(/[&<>"']/g, s=>({ "&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;" }[s]));
  }

  document.addEventListener("DOMContentLoaded", ()=>{
    boot().catch(err=>{
      console.error(err);
      const box=$("#fatal");
      if(box) box.textContent = "ERROR: "+err.message;
    });
  });
})();