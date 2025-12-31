// /assets/js/hero6.js — ротатор фраз, 6 строк / каждые 6 секунд
(function(){
  const pull = async () => {
    try{
      if(window.__HERO_PHRASES__) return window.__HERO_PHRASES__;
      const r = await fetch('assets/texts/hero_phrases.json', { cache: 'no-store' });
      const j = await r.json();
      window.__HERO_PHRASES__ = j;
      return j;
    }catch(e){
      return { ru: [], en: [] };
    }
  };

  function currentLang(){
    return (localStorage.getItem('soulinpsy_lang')||'ru').toLowerCase()==='en' ? 'en' : 'ru';
  }

  function pick(arr){
    if(!arr || !arr.length) return '';
    return arr[Math.floor(Math.random()*arr.length)] || '';
  }

  function tick(dict){
    const host = document.querySelector('.hero .lang-content.active .rot6');
    if(!host) return;
    const lines = [...host.querySelectorAll('li')];
    const L = dict[currentLang()] || [];
    lines.forEach(li => { li.textContent = pick(L); });
  }

  pull().then(dict => {
    const doTick = () => tick(dict);
    doTick();
    setInterval(doTick, 6000);
    window.addEventListener('sipa:lang', () => setTimeout(doTick, 30));
  });
})();
