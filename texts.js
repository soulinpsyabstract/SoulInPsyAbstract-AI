// /assets/js/texts.js — загрузка вербатим-текстов (about + songs)
(function(){
  async function getText(url){
    try{ const r=await fetch(url); return await r.text(); }catch(e){ return ''; }
  }
  function splitRUEN(raw){
    // формат: ===RU=== ... ===EN=== ...
    const m = raw.split('===EN===');
    if(m.length===1) return {ru:raw.trim(), en:raw.trim()};
    const ru = m[0].replace('===RU===','').trim();
    const en = m[1].trim();
    return {ru,en};
  }
  (async function(){
    const aboutRU=document.getElementById('about_ru');
    const aboutEN=document.getElementById('about_en');
    if(aboutRU||aboutEN){
      const t=await getText('assets/texts/about.txt');
      const p=splitRUEN(t);
      if(aboutRU) aboutRU.textContent=p.ru;
      if(aboutEN) aboutEN.textContent=p.en;
    }
    const songsRU=document.getElementById('songs_ru');
    const songsEN=document.getElementById('songs_en');
    if(songsRU||songsEN){
      const t=await getText('assets/texts/songs.html');
      const p=splitRUEN(t);
      if(songsRU) songsRU.innerHTML=p.ru;
      if(songsEN) songsEN.innerHTML=p.en;
    }
  })();
})();