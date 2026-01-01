(function(){
  const ids=['rot1','rot2','rot3','rot4','rot5','rot6'];
  const pull = async () => {
    try{
      if(window.__HERO_PHRASES__) return window.__HERO_PHRASES__;
      const r = await fetch('assets/texts/hero_phrases.json'); return await r.json();
    }catch(e){return {ru:[],en:[]}}
  };
  function pick(arr){return arr[Math.floor(Math.random()*arr.length)]||''}
  function currentLang(){return (localStorage.getItem('soulinpsy_lang')||'ru').toLowerCase()==='en'?'en':'ru'}
  pull().then(dict=>{
    window.__HERO_PHRASES__ = dict;
    const tick=()=>{
      const L = dict[currentLang()]||[];
      ids.forEach(id=>{ const el=document.getElementById(id); if(el) el.textContent=pick(L); });
    };
    tick(); setInterval(tick,6000);
    document.addEventListener('click',e=>{
      if(e.target.id==='lang-en'||e.target.id==='lang-ru') setTimeout(tick,50);
    });
  });
})();