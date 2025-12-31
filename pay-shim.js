// /assets/js/pay-shim.js — localStorage пометка sold
(function(){
  window.markSold = function(code){
    try{ localStorage.setItem('sipa_sold_'+code,'1'); }catch(e){}
  };
  window.isSold = function(code){
    try{ return localStorage.getItem('sipa_sold_'+code)==='1'; }catch(e){ return false; }
  };
})();