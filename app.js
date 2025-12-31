
;(function(){
  const y = document.getElementById('y');
  if (y) y.textContent = new Date().getFullYear();
  // Language restore
  const key = 'soulinpsy_lang';
  const saved = localStorage.getItem(key) || 'ru';
  window.__LANG = saved;
  function applyLang(lang){
    window.__LANG = lang;
    localStorage.setItem(key, lang);
    document.querySelectorAll('[data-lang]').forEach(el => {
      el.classList.toggle('show', el.getAttribute('data-lang') === lang);
    });
    document.documentElement.setAttribute('lang', lang);
  }
  applyLang(saved);
  const btnEN = document.getElementById('lang-en');
  const btnRU = document.getElementById('lang-ru');
  if (btnEN) btnEN.addEventListener('click', () => applyLang('en'));
  if (btnRU) btnRU.addEventListener('click', () => applyLang('ru'));

  // PWA register
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/service-worker.js').catch(()=>{});
  }
})();
