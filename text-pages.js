
;(() => {
  function loadInto(id, url){
    const el = document.getElementById(id);
    if (!el) return;
    fetch(url).then(r => r.text()).then(t => el.innerHTML = t.replace(/\n/g,'<br>')).catch(()=>{
      el.textContent = '';
    });
  }
  loadInto('manifest-text', '/assets/texts/manifest.txt');
  loadInto('poems-text', '/assets/texts/poems.txt');
  loadInto('songs-html', '/assets/texts/songs.html');
})();
