const G1='linear-gradient(160deg,#4a3a1e,#1a1206 70%)',G2='linear-gradient(160deg,#5e2a3a,#301018 70%)',G3='linear-gradient(160deg,#2a4a5e,#102630 70%)',G4='linear-gradient(160deg,#3a2a5e,#1a1030 70%)',G5='linear-gradient(160deg,#2a5e3a,#10301a 70%)';
const scrim='linear-gradient(to top,rgba(0,0,0,.92) 8%,rgba(0,0,0,.35) 45%,rgba(0,0,0,0) 75%)';
const SB='<div class="sb"><div>9:41</div><div>📶 🔋95</div></div>';
function frame(label,inner){return `<div class="col"><div class="tag">${label}</div><div class="phone"><div class="screen">${SB}${inner}</div></div></div>`;}

// ── ① HOME (info-dense) ───────────────────────────────────
const HOME=`
<div style="display:flex;align-items:center;gap:8px;padding:6px 22px 12px">
  <div style="width:24px;height:24px;border-radius:7px;background:linear-gradient(135deg,#E8B65A,#C9962F)"></div>
  <b style="font-size:16px">湾区看演</b><div style="flex:1"></div>🔔
  <div style="width:28px;height:28px;border-radius:50%;background:#2a2a2d;margin-left:12px"></div>
</div>
<div style="padding:0 22px 14px"><div class="glass" style="border-radius:22px;padding:14px 16px;color:#9a9a9e;font-size:14px">🔍 搜艺人 / 演出 —— 想看谁，直接搜</div></div>

<!-- 2 ★ TRUST NUMBER BAR (clickable) -->
<div style="margin:0 22px 16px;border-radius:16px;padding:14px 16px;background:linear-gradient(150deg,rgba(232,182,90,.16),rgba(232,182,90,.03));border:1px solid rgba(232,182,90,.3);display:flex;align-items:center">
  <div style="flex:1;display:flex;justify-content:space-around;text-align:center">
    <div><div style="font-size:18px;font-weight:800;color:#E8B65A">128,000+</div><div style="font-size:10px;color:#c9b98a">担保出票</div></div>
    <div style="width:1px;background:rgba(232,182,90,.25)"></div>
    <div><div style="font-size:18px;font-weight:800;color:#E8B65A">42</div><div style="font-size:10px;color:#c9b98a">服务场次</div></div>
    <div style="width:1px;background:rgba(232,182,90,.25)"></div>
    <div><div style="font-size:18px;font-weight:800;color:#E8B65A">0</div><div style="font-size:10px;color:#c9b98a">违约</div></div>
  </div>
  <div style="color:#E8B65A;font-size:18px;margin-left:8px">›</div>
</div>

<!-- 3 dual entry pills -->
<div style="display:flex;gap:10px;padding:0 22px 20px">
  <div style="flex:1;border-radius:16px;padding:12px 14px;display:flex;align-items:center;gap:10px;background:linear-gradient(150deg,rgba(232,182,90,.18),rgba(232,182,90,.04));border:1px solid rgba(232,182,90,.35)">
    <span style="font-size:20px">🎫</span><div><div style="font-size:14px;font-weight:800">担保有票</div><div style="font-size:10px;color:#c9b98a;margin-top:2px">热门·秒罄补票</div></div>
  </div>
  <div style="flex:1;border-radius:16px;padding:12px 14px;display:flex;align-items:center;gap:10px;background:linear-gradient(150deg,rgba(255,120,90,.16),rgba(255,120,90,.03));border:1px solid rgba(255,120,90,.35)">
    <span style="font-size:20px">✨</span><div><div style="font-size:14px;font-weight:800">甄选特惠</div><div style="font-size:10px;color:#e0a58a;margin-top:2px">早鸟·尾票捡漏</div></div>
  </div>
</div>

<!-- 4 本周最抢手 (horizontal, replaces big hero) -->
<div style="display:flex;justify-content:space-between;align-items:baseline;padding:0 22px 12px"><b style="font-size:16px">🔥 本周最抢手</b><span style="font-size:11px;color:#8A8A8E">查看全部 ›</span></div>
<div style="display:flex;gap:12px;overflow-x:auto;padding:0 22px 22px;scrollbar-width:none">
  ${[[G1,'薛之谦 天外来物','09/13 香港体育馆','¥1,880'],[G2,'周杰伦 CARNIVAL','10/05 启德主场馆','¥2,980'],[G4,'邓紫棋 G.E.M.','08/30 香港体育馆','¥2,180']].map(([g,n,d,p])=>`
  <div style="flex:0 0 200px;border-radius:18px;overflow:hidden;position:relative;background:${g};height:250px">
    <div style="position:absolute;inset:0;background:${scrim}"></div>
    <div style="position:absolute;top:12px;left:12px" class="pill badge-guar" style2>✓ 担保出票</div>
    <div style="position:absolute;left:14px;right:14px;bottom:14px">
      <div style="font-size:18px;font-weight:800;font-style:italic;line-height:1.1">${n}</div>
      <div style="font-size:11px;color:#cfcfcf;margin:6px 0">${d}</div>
      <div style="display:flex;justify-content:space-between;align-items:center;margin-top:6px">
        <span style="font-size:15px;color:#E8B65A;font-weight:800">${p}<span style="font-size:10px;color:#9a9a9e;font-weight:500"> 起</span></span>
        <span class="pill" style="background:linear-gradient(135deg,#E8B65A,#C9962F);color:#1a1200;font-size:11px;padding:6px 14px">抢票</span>
      </div>
    </div>
  </div>`).join('')}
</div>

<!-- 5 近期演出 list + filter -->
<div style="display:flex;gap:8px;padding:0 22px 14px">
  <span class="pill" style="background:linear-gradient(135deg,#E8B65A,#C9962F);color:#1a1200">近期</span>
  <span class="pill glass">本周</span><span class="pill glass">粤语</span><span class="pill glass">全部</span>
</div>
${[[G3,'林俊杰 JJ20 世界巡演','09/14 · 亚洲博览馆','¥2,480','badge-hard','现票'],[G5,'五月天 好好好想见到你','09/21 · 启德主场馆','¥3,280','badge-guar','担保出票'],[G2,'陈奕迅 FEAR不惧','09/28 · 红磡体育馆','¥2,680','badge-deal','特惠 ¥2,180']].map(([g,n,d,p,bc,bt])=>`
<div style="display:flex;gap:12px;padding:10px 22px;align-items:center">
  <div style="flex:0 0 58px;background:${g};height:70px;border-radius:12px"></div>
  <div style="flex:1"><div style="font-size:14px;font-weight:700">${n}</div><div style="font-size:11px;color:#8A8A8E;margin:3px 0 6px">${d}</div><span class="pill ${bc}" style="font-size:9px;padding:3px 9px">${bt}</span></div>
  <div style="text-align:right"><div style="font-size:15px;color:#E8B65A;font-weight:800">${p}</div><div style="font-size:9px;color:#8A8A8E">起</div></div>
</div>`).join('')}
<div style="height:90px"></div>

<div class="glass" style="position:absolute;left:16px;right:16px;bottom:14px;border-radius:26px;display:flex;justify-content:space-around;padding:12px 0;font-size:11px;color:#8A8A8E">
  <div style="color:#E8B65A;text-align:center">🏠<br>首页</div>
  <div style="text-align:center">🧭<br>发现</div>
  <div style="width:44px;height:44px;border-radius:50%;background:linear-gradient(135deg,#E8B65A,#C9962F);display:flex;align-items:center;justify-content:center;font-size:19px;margin-top:-20px">🎟</div>
  <div style="text-align:center">💬<br>消息</div>
  <div style="text-align:center">👤<br>我的</div>
</div>`;

// ── ② 甄选特惠列表页 ──────────────────────────────────────
const DEAL=`
<div style="display:flex;align-items:center;gap:14px;padding:8px 22px 8px"><span style="font-size:20px">‹</span><b style="font-size:18px">✨ 甄选特惠</b></div>
<div style="padding:0 22px 16px;font-size:12px;color:#8A8A8E">早鸟预售 · 冷门场次 · 尾票捡漏，品质不打折</div>
<!-- sort tabs -->
<div style="display:flex;gap:8px;padding:0 22px 16px">
  <span class="pill" style="background:linear-gradient(135deg,#E8B65A,#C9962F);color:#1a1200">折扣最大</span>
  <span class="pill glass">临近开场</span><span class="pill glass">低价优先</span>
</div>
${[[G2,'陈奕迅 FEAR不惧','09/28 · 红磡','¥2,680','¥2,180','省¥500','尾票捡漏'],[G3,'林忆莲 呼吸','10/12 · 会展中心','¥1,880','¥1,380','省¥500','早鸟预售'],[G5,'李荣浩 年少有为','10/19 · 亚博','¥1,680','¥1,280','省¥400','冷门场次'],[G4,'方大同 声名大噪','11/02 · 麦花臣','¥1,480','¥1,080','省¥400','早鸟预售']].map(([g,n,d,op,np,save,why])=>`
<div style="margin:0 22px 12px;background:#161618;border-radius:18px;border:1px solid #232326;overflow:hidden;display:flex">
  <div style="flex:0 0 96px;background:${g}"></div>
  <div style="flex:1;padding:12px 14px">
    <div style="display:flex;justify-content:space-between;align-items:start">
      <div style="font-size:14px;font-weight:700">${n}</div>
      <span class="badge-deal pill" style="font-size:9px;padding:3px 8px">${why}</span>
    </div>
    <div style="font-size:11px;color:#8A8A8E;margin:5px 0 10px">${d} · 含门票+酒店</div>
    <div style="display:flex;align-items:baseline;gap:8px">
      <span style="font-size:18px;color:#FF8A5A;font-weight:800">${np}</span>
      <span style="font-size:11px;color:#6a6a6e;text-decoration:line-through">${op}</span>
      <span style="font-size:10px;color:#FF8A5A;font-weight:700;margin-left:auto">${save}</span>
    </div>
  </div>
</div>`).join('')}
<div style="padding:6px 24px 20px;font-size:10px;color:#6a6a6e;text-align:center">特惠场次同样享受担保出票与验票保真 · 品质不打折</div>`;

// ── ③ 信任 · 验真详情页 ───────────────────────────────────
const TRUST=`
<div style="display:flex;align-items:center;gap:14px;padding:8px 22px 16px"><span style="font-size:20px">‹</span><b style="font-size:18px">🛡 为什么更靠谱</b></div>
<!-- big numbers -->
<div style="display:flex;gap:10px;padding:0 22px 18px">
  ${[['128,000+','累计担保出票'],['42','服务场次'],['0','履约违约']].map(([n,l])=>`
  <div style="flex:1;background:linear-gradient(150deg,rgba(232,182,90,.14),rgba(232,182,90,.02));border:1px solid rgba(232,182,90,.28);border-radius:16px;padding:16px 8px;text-align:center">
    <div style="font-size:22px;font-weight:800;color:#E8B65A">${n}</div><div style="font-size:10px;color:#c9b98a;margin-top:4px">${l}</div>
  </div>`).join('')}
</div>
<!-- mechanism cards -->
${[['🎫','担保出票','热门秒罄场次，我们承诺在最迟出票时间前交票；到点未出，优先补同档或免费升档，仍无法解决全额退款。'],['🔍','验票保真','每张票经平台核验来源与票权后交付，杜绝假票、重复二维码、挂失票。'],['🏨','一价全含','门票+香港酒店+可选跨境交通打包，一次下单，不用多平台反复比价下单。'],['📍','现场兜底','现场无法入场即时上报，客服最高优先级补票；仍无法入场按 ¥500/票（单笔上限 ¥2,000）赔付。']].map(([i,t,d])=>`
<div style="margin:0 22px 12px;background:#161618;border:1px solid #232326;border-radius:16px;padding:16px">
  <div style="display:flex;align-items:center;gap:10px;margin-bottom:8px"><span style="font-size:20px">${i}</span><b style="font-size:15px">${t}</b></div>
  <div style="font-size:12px;color:#9a9a9e;line-height:1.7">${d}</div>
</div>`).join('')}
<!-- user proof -->
<div style="padding:6px 22px 10px;font-size:14px;font-weight:700">真实用户反馈</div>
${[['@薛之谦粉丝','红馆内场，出票很准时，验票秒过，比自己找黄牛安心太多。'],['@Eason歌迷','酒店离场馆走路10分钟，一价全含省事，客服全程盯着出票。']].map(([u,c])=>`
<div style="margin:0 22px 10px;background:#131315;border:1px solid #232326;border-radius:14px;padding:14px 16px">
  <div style="font-size:12px;color:#E8B65A;font-weight:700;margin-bottom:6px">${u}</div>
  <div style="font-size:12px;color:#c9c9cd;line-height:1.6">${c}</div>
</div>`).join('')}
<div style="padding:8px 24px 20px;font-size:10px;color:#6a6a6e;text-align:center">※ 数据示意，上线前以真实履约统计为准</div>`;

document.getElementById('root').innerHTML=frame('① 首页 · 信息优先',HOME)+frame('② 甄选特惠列表',DEAL)+frame('③ 信任·验真详情',TRUST);
