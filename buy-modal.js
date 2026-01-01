// /assets/js/buy-modal.js — модалка с Exclusive +200
(function(){
  const $ = (s,p=document)=>p.querySelector(s);
  function fmt(n){return '$'+(n||0)}
  window.openBuy = function(code){
    const a = (window.__DATA__ && __DATA__.ART.find(x=>x.code===code)) || null;
    if(!a) return alert('Work not found');
    const ex = 200, base = a.price_usd||0;
    const eth = (window.__PAYCFG__&&__PAYCFG__.ETH_ADDRESS)||'';
    const html = `
    <div class="modal" onclick="this===event.target && this.remove()">
      <div class="box">
        <h3>${a.title_ru||a.title_en||a.code}</h3>
        <p>Base: ${fmt(base)} • Exclusive: ${fmt(base+ex)}</p>
        <div style="display:flex;gap:8px;flex-wrap:wrap">
          ${a.ncp?`<a class="btn" target="_blank" href="${a.ncp}">PayPal Fast</a>`:''}
          <a class="btn" target="_blank" href="https://og.rarible.com/soulinpsyabstract" rel="noopener">Rarible</a>
          <a class="btn" target="_blank" href="https://zora.co/@soulinpsyabstract" rel="noopener">Zora</a>
          ${a.nft?`<a class="btn" target="_blank" href="${a.nft}" rel="noopener">NFT Token</a>`:''}
          ${eth?`<button class="btn" id="copyeth">Copy ETH</button>`:''}
        </div>
        <div style="margin-top:10px"><button class="btn" onclick="this.closest('.modal').remove()">Close</button></div>
      </div>
    </div>`;
    document.body.insertAdjacentHTML('beforeend', html);
    const b = $('#copyeth'); 
    if(b){ 
      b.addEventListener('click', async ()=>{
        try{ await navigator.clipboard.writeText(eth); b.textContent='ETH copied'; }catch(e){}
      });
    }
  };
})();