
fetch('assets/data/gallery.json').then(r=>r.json()).then(d=>{
  const g=document.getElementById('gallery');
  if(g) d.forEach(i=>g.innerHTML+=`<p>${i.title}</p>`);
});
fetch('assets/data/nfts.json').then(r=>r.json()).then(d=>{
  const n=document.getElementById('nfts');
  if(n) d.forEach(i=>n.innerHTML+=`<li><a href="${i.url}">${i.name}</a></li>`);
});
