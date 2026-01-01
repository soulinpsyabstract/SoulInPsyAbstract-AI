
fetch('assets/data/songs.json').then(r=>r.json()).then(d=>{
  const s=document.getElementById('songs');
  d.forEach(i=>s.innerHTML+=`<li>${i.title}</li>`);
});
