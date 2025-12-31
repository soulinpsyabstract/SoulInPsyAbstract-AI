
;(() => {
  const wrap = document.getElementById('rotator');
  if (!wrap) return;
  // Fetch phrases
  fetch('/assets/texts/hero_phrases.json').then(r=>r.json()).then(data => {
    const lang = window.__LANG || 'ru';
    const arr = (data[lang] || []).slice();
    if (!arr.length) return;
    let idx = 0;
    const cards = 6;
    function render(){
      wrap.innerHTML = '';
      for (let i=0;i<cards;i++){
        const line = document.createElement('div');
        line.className = 'r-line';
        line.textContent = arr[(idx + i) % arr.length];
        wrap.appendChild(line);
      }
      idx = (idx + cards) % arr.length;
    }
    render();
    setInterval(render, 6000);
  }).catch(()=>{});
})();
