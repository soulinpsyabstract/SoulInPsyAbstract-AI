(function(){
  const LS="soulinpsy_lang";
  const $ = (s,p=document)=>p.querySelector(s);
  const $$= (s,p=document)=>[...p.querySelectorAll(s)];
  function setLang(l){
    localStorage.setItem(LS,l);
    $$('.langbtn').forEach(b=>b.classList.toggle('active',b.dataset.lang===l));
    $$('.lang-content').forEach(x=>x.classList.remove('active'));
    $$(`.lang-content[data-lang="${l}"]`).forEach(x=>x.classList.add('active'));
  }
  const saved=(localStorage.getItem(LS)||"ru").toLowerCase();
  setLang(saved==="en"?"en":"ru");
  document.addEventListener('click',e=>{
    const b=e.target.closest('.langbtn'); if(b){ setLang(b.dataset.lang); }
  });
  const y=document.getElementById('y'); if(y) y.textContent=(new Date()).getFullYear();
  document.documentElement.classList.add('js');
})();