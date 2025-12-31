// /assets/js/data-bridge.js — NCP коды по цене
(function(){
  if(!window.__DATA__||!__DATA__.ART) return;
  const MAP = (window.__PAYCFG__ && __PAYCFG__.NCP) || {};
  __DATA__.ART = __DATA__.ART.map(a=>{
    const uid = MAP[a.price_usd];
    if(uid) a.ncp = "https://www.paypal.com/ncp/payment/"+uid;
    return a;
  });
})();