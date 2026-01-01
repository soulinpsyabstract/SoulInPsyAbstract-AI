// /assets/js/player.js — мини-плеер без библиотек
function initPlayer(hostId, list){
  const host=document.getElementById(hostId); if(!host) return;
  let i=0, a=new Audio(); a.preload='metadata';
  host.innerHTML = `
    <div class="card">
      <div id="t">${list[0]?.title||''}</div>
      <div style="display:flex;gap:8px;margin:8px 0">
        <button class="btn" id="prev">Prev</button>
        <button class="btn" id="play">Play</button>
        <button class="btn" id="next">Next</button>
      </div>
      <div id="time" class="muted">0:00</div>
    </div>`;
  function load(idx){ i=(idx+list.length)%list.length; a.src=list[i].url; document.getElementById('t').textContent=list[i].title; }
  function toggle(){ if(a.paused){ a.play().catch(()=>{}); play.textContent='Pause'; } else { a.pause(); play.textContent='Play'; } }
  const prev=host.querySelector('#prev'), next=host.querySelector('#next'), play=host.querySelector('#play');
  prev.onclick=()=>{ load(i-1); a.play().catch(()=>{}); play.textContent='Pause'; };
  next.onclick=()=>{ load(i+1); a.play().catch(()=>{}); play.textContent='Pause'; };
  play.onclick=toggle; a.ontimeupdate=()=>{ time.textContent = `${Math.floor(a.currentTime/60)}:${String(Math.floor(a.currentTime%60)).padStart(2,'0')}`; };
  a.onended=()=>next.onclick();
  load(0);
}