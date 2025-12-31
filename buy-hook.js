// /assets/js/buy-hook.js — кнопка Buy
(function(){
  window.initBuyHook=function(){
    document.querySelectorAll('[data-buy]').forEach(btn=>{
      btn.addEventListener('click', ()=>{
        const code=btn.getAttribute('data-id');
        if(window.openBuy) return window.openBuy(code);
      });
    });
  };
})();