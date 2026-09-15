// ── shared bits ───────────────────────────────────────────
const SB = `<div class="sb"><div>9:41</div><div class="r">● ​📶 🔋95</div></div>`;
// gradient poster placeholder (no external images)
function poster(g, h=200){return `background:${g};height:${h}px`}
const G1='linear-gradient(160deg,#3a2a5e,#1a1030 70%)';
const G2='linear-gradient(160deg,#5e2a3a,#301018 70%)';
const G3='linear-gradient(160deg,#2a4a5e,#102630 70%)';
const G4='linear-gradient(160deg,#4a3a1e,#2a1e08 70%)';
function scrim(){return 'linear-gradient(to top,rgba(0,0,0,.92) 8%,rgba(0,0,0,.35) 45%,rgba(0,0,0,0) 75%)'}

function frame(label, inner){
  return `<div class="col"><div class="tag">${label}</div><div class="phone"><div class="screen">${SB}${inner}</div></div></div>`;
}

// ── ① HOME ────────────────────────────────────────────────
const HOME = `
<div style="display:flex;justify-content:space-between;align-items:center;padding:6px 22px 14px">
  <div style="display:flex;align-items:center;gap:8px">
    <div style="width:26px;height:26px;border-radius:8px;background:linear-gradient(135deg,#E8B65A,#C9962F)"></div>
    <b style="font-size:17px;letter-spacing:.5px">湾区看演</b>
  </div>
  <div style="display:flex;gap:14px;align-items:center;font-size:17px">🔔<div style="width:30px;height:30px;border-radius:50%;background:#2a2a2d;border:1px solid #3a3a3d"></div></div>
</div>
<div style="margin:0 22px 18px" class="glass" style2="">
  <div class="glass" style="border-radius:22px;padding:12px 16px;display:flex;align-items:center;gap:10px;color:#8A8A8E;font-size:13px">🔍 搜索艺人、演出、场馆</div>
</div>
<!-- hero -->
<div style="margin:0 22px 8px;border-radius:24px;overflow:hidden;position:relative;${poster(G1,220)}">
  <div style="position:absolute;inset:0;background:${scrim()}"></div>
  <div style="position:absolute;top:14px;left:14px" class="pill badge-guar">担保出票</div>
  <div style="position:absolute;left:18px;bottom:18px;right:18px">
    <div style="font-size:24px;font-weight:800;font-style:italic;letter-spacing:.5px">TWINS 演唱会</div>
    <div style="font-size:12px;color:#cfcfcf;margin-top:4px">香港红磡体育馆 · 12/06 周五 20:00</div>
    <div style="margin-top:8px;font-size:13px;color:#E8B65A;font-weight:700">¥1,880 <span style="color:#9a9a9e;font-weight:500">起 · 含门票+酒店</span></div>
  </div>
</div>
<div style="display:flex;gap:6px;justify-content:center;margin:10px 0 22px">
  <span style="width:18px;height:4px;border-radius:2px;background:#E8B65A"></span>
  <span style="width:4px;height:4px;border-radius:2px;background:#444"></span>
  <span style="width:4px;height:4px;border-radius:2px;background:#444"></span>
</div>
<!-- 推荐套餐 -->
<div style="display:flex;justify-content:space-between;align-items:baseline;padding:0 22px 12px">
  <b style="font-size:16px">推荐套餐</b><span style="font-size:11px;color:#8A8A8E">查看全部 ›</span>
</div>
<div style="display:flex;gap:12px;overflow-x:auto;padding:0 22px 20px;scrollbar-width:none">
  ${[[G2,'MIRROR 演唱会','¥2,180'],[G3,'张学友 60+','¥3,280'],[G4,'陈奕迅 FEAR','¥2,680']].map(([g,n,p])=>`
  <div style="flex:0 0 150px;background:#161618;border-radius:18px;overflow:hidden;border:1px solid #232326">
    <div style="${poster(g,96)}"></div>
    <div style="padding:10px 12px">
      <div style="font-size:13px;font-weight:700">${n}</div>
      <div style="font-size:10px;color:#8A8A8E;margin:4px 0 6px">含门票+酒店2晚</div>
      <div style="font-size:14px;color:#E8B65A;font-weight:800">${p}</div>
    </div>
  </div>`).join('')}
</div>
<!-- tabs + list -->
<div style="display:flex;gap:8px;padding:0 22px 14px">
  <span class="pill" style="background:linear-gradient(135deg,#E8B65A,#C9962F);color:#1a1200">热门</span>
  <span class="pill glass">折扣</span>
  <span class="pill glass">近期演出</span>
</div>
${[[G3,'MIRROR 演唱会','12/07 · 红磡体育馆','¥2,180','badge-guar','担保出票'],[G4,'林俊杰 JJ20','12/14 · 亚洲博览馆','¥2,480','badge-hard','现票'],[G2,'邓紫棋 I AM','12/20 · 启德主场馆','¥3,080','badge-guar','担保出票']].map(([g,n,d,p,bc,bt])=>`
<div style="display:flex;gap:12px;padding:10px 22px;align-items:center">
  <div style="flex:0 0 60px;${poster(g,72)};border-radius:12px"></div>
  <div style="flex:1">
    <div style="font-size:14px;font-weight:700">${n}</div>
    <div style="font-size:11px;color:#8A8A8E;margin:3px 0 6px">${d}</div>
    <span class="pill ${bc}" style="font-size:9px;padding:3px 10px">${bt}</span>
  </div>
  <div style="text-align:right"><div style="font-size:15px;color:#E8B65A;font-weight:800">${p}</div><div style="font-size:9px;color:#8A8A8E">起</div></div>
</div>`).join('')}
<div style="height:80px"></div>
<!-- bottom nav -->
<div class="glass" style="position:absolute;left:16px;right:16px;bottom:14px;border-radius:26px;display:flex;justify-content:space-around;align-items:center;padding:12px 0;font-size:11px;color:#8A8A8E">
  <div style="color:#E8B65A;text-align:center">🏠<div style="margin-top:2px">首页</div></div>
  <div style="text-align:center">🎫<div style="margin-top:2px">发现</div></div>
  <div style="width:44px;height:44px;border-radius:50%;background:linear-gradient(135deg,#E8B65A,#C9962F);display:flex;align-items:center;justify-content:center;font-size:20px;margin-top:-20px;box-shadow:0 6px 18px rgba(201,150,47,.5)">🔍</div>
  <div style="text-align:center">💬<div style="margin-top:2px">消息</div></div>
  <div style="text-align:center">👤<div style="margin-top:2px">我的</div></div>
</div>`;

// ── ② EVENT DETAIL ────────────────────────────────────────
const DETAIL = `
<!-- hero poster -->
<div style="position:relative;${poster(G1,340)};margin-top:-52px">
  <div style="position:absolute;inset:0;background:${scrim()}"></div>
  <div style="position:absolute;top:60px;left:18px;right:18px;display:flex;justify-content:space-between">
    <div class="glass" style="width:38px;height:38px;border-radius:50%;display:flex;align-items:center;justify-content:center">‹</div>
    <div class="glass" style="width:38px;height:38px;border-radius:50%;display:flex;align-items:center;justify-content:center">↗</div>
  </div>
  <div style="position:absolute;left:20px;bottom:20px;right:20px">
    <span class="pill badge-guar" style="font-size:10px">担保出票</span>
    <div style="font-size:30px;font-weight:800;font-style:italic;margin-top:10px;line-height:1.1">TWINS<br>LOL 世界巡演</div>
    <div style="font-size:13px;color:#cfcfcf;margin-top:8px">Twins · 香港红磡体育馆</div>
  </div>
</div>
<!-- session pills -->
<div style="display:flex;gap:8px;overflow-x:auto;padding:18px 20px 4px;scrollbar-width:none">
  ${[['12/06','周五',1],['12/07','周六',0],['12/08','周日',0]].map(([d,w,on])=>`
  <div class="${on?'':'glass'}" style="flex:0 0 auto;border-radius:16px;padding:10px 16px;text-align:center;${on?'background:linear-gradient(135deg,#E8B65A,#C9962F);color:#1a1200':''}">
    <div style="font-size:15px;font-weight:800">${d}</div><div style="font-size:10px;opacity:.8">${w}</div>
  </div>`).join('')}
</div>
<div style="display:flex;gap:16px;padding:16px 22px;font-size:12px;color:#9a9a9e">
  <div>📍 红磡体育馆</div><div>🕗 20:00 开演</div><div>🎫 最迟 T-1 出票</div>
</div>
<!-- PRIMARY: packages -->
<div style="padding:6px 22px 12px"><b style="font-size:17px">票酒套餐</b> <span style="font-size:11px;color:#8A8A8E">· 一价全含，省心之选</span></div>
${[['套餐A · 内场企位','尖沙咀凯悦 2 晚 · 大床房','¥2,680','badge-guar','担保出票'],['套餐B · A区看台','红磡海景酒店 2 晚 · 双床','¥2,180','badge-hard','现票']].map(([n,h,p,bc,bt])=>`
<div style="margin:0 22px 12px;background:#161618;border-radius:20px;border:1px solid #232326;overflow:hidden">
  <div style="display:flex;gap:12px;padding:14px">
    <div style="flex:0 0 64px;${poster(G4,80)};border-radius:12px"></div>
    <div style="flex:1">
      <div style="display:flex;justify-content:space-between;align-items:start">
        <div style="font-size:14px;font-weight:800">${n}</div>
        <span class="pill ${bc}" style="font-size:9px;padding:3px 9px">${bt}</span>
      </div>
      <div style="font-size:11px;color:#8A8A8E;margin:6px 0">🏨 ${h}</div>
      <div style="font-size:11px;color:#8A8A8E">🎫 门票 + 🏨 酒店 · 🚄 可加购交通</div>
    </div>
  </div>
  <div style="display:flex;justify-content:space-between;align-items:center;padding:12px 14px;border-top:1px solid #232326;background:#131315">
    <div><span style="font-size:18px;color:#E8B65A;font-weight:800">${p}</span> <span style="font-size:10px;color:#8A8A8E">一口价</span></div>
    <span class="pill" style="background:linear-gradient(135deg,#E8B65A,#C9962F);color:#1a1200;padding:9px 20px">查看套餐</span>
  </div>
</div>`).join('')}
<!-- secondary collapsibles -->
${['票档说明 · 内场企位 / A区 / B区看台','担保与退改规则','购票须知'].map(t=>`
<div style="margin:0 22px 10px;background:#141416;border:1px solid #232326;border-radius:14px;padding:14px 16px;display:flex;justify-content:space-between;color:#cfcfcf;font-size:13px">${t}<span style="color:#8A8A8E">›</span></div>`).join('')}
<div style="padding:2px 24px 16px;font-size:10px;color:#6a6a6e">※ 站席不支持连座；看台可"尽力安排相邻座位"，担保出票不显示具体座位号。</div>
<div style="height:20px"></div>`;

// ── ③ PACKAGE SELECT ──────────────────────────────────────
const PKG = `
<div style="display:flex;align-items:center;gap:14px;padding:8px 22px 16px">
  <span style="font-size:20px">‹</span><div><b style="font-size:16px">选择套餐</b><div style="font-size:11px;color:#8A8A8E">TWINS LOL · 12/06 周五</div></div>
</div>
<!-- selected preset package -->
<div style="margin:0 22px 14px;background:#161618;border-radius:20px;border:1.5px solid #E8B65A;box-shadow:0 0 22px rgba(232,182,90,.18);overflow:hidden">
  <div style="${poster(G1,120)};position:relative"><div style="position:absolute;inset:0;background:${scrim()}"></div>
    <div style="position:absolute;left:14px;bottom:12px;font-size:16px;font-weight:800;font-style:italic">套餐A · 内场企位 + 尖沙咀酒店</div>
    <div style="position:absolute;top:12px;right:12px" class="pill" style2="">✓</div>
  </div>
  <div style="padding:14px 16px">
    ${[['🎫','门票','内场企位 · 担保出票'],['🏨','酒店','尖沙咀凯悦 · 大床房 · 2晚含早'],['🚄','交通','可选加购 · 广深港高铁']].map(([i,k,v])=>`
    <div style="display:flex;gap:10px;padding:7px 0;font-size:13px;border-bottom:1px solid #202023"><span>${i}</span><b style="width:44px;color:#cfcfcf">${k}</b><span style="color:#9a9a9e">${v}</span></div>`).join('')}
    <div style="display:flex;justify-content:space-between;align-items:center;margin-top:12px">
      <span class="pill badge-guar" style="font-size:10px">一口价 · 担保出票</span>
      <div><span style="font-size:20px;color:#E8B65A;font-weight:800">¥2,680</span></div>
    </div>
  </div>
</div>
<!-- tier picker -->
<div style="padding:2px 22px 8px;font-size:13px;font-weight:700">票档</div>
<div style="display:flex;gap:8px;padding:0 22px 14px;flex-wrap:wrap">
  <span class="pill" style="background:linear-gradient(135deg,#E8B65A,#C9962F);color:#1a1200">内场企位 · 余3</span>
  <span class="pill glass">A区看台 · 余28</span>
  <span class="pill glass">B区看台 · 余45</span>
</div>
<!-- pax with stock guard -->
<div style="margin:0 22px 12px;background:#2a1618;border:1px solid #5a2a2e;border-radius:14px;padding:12px 14px">
  <div style="display:flex;justify-content:space-between;align-items:center;font-size:13px">
    <span>购买数量</span>
    <div style="display:flex;gap:14px;align-items:center"><span style="opacity:.4">－</span><b style="font-size:16px">4</b><span style="opacity:.4">＋</span></div>
  </div>
  <div style="font-size:11px;color:#FF6B6B;margin-top:8px">⚠ 内场企位仅余 3 张，无法购买 4 张。请减少数量或换其他票档。</div>
</div>
<!-- hotel block -->
<div style="padding:2px 22px 8px;font-size:13px;font-weight:700">酒店房型</div>
<div style="display:flex;gap:10px;padding:0 22px 10px">
  ${[['大床房','可住2人',1],['双床房','可住2人',0],['家庭房','可住3人',0]].map(([n,c,on])=>`
  <div class="${on?'':'glass'}" style="flex:1;border-radius:14px;padding:12px 8px;text-align:center;${on?'background:rgba(232,182,90,.12);border:1.5px solid #E8B65A':''}">
    <div style="font-size:13px;font-weight:700">${n}</div><div style="font-size:10px;color:#8A8A8E;margin-top:3px">${c}</div>
  </div>`).join('')}
</div>
<div style="display:flex;gap:10px;padding:0 22px 14px">
  <div class="glass" style="flex:1;border-radius:12px;padding:10px 12px;font-size:12px"><div style="color:#8A8A8E;font-size:10px">入住</div>12/06 周五</div>
  <div class="glass" style="flex:1;border-radius:12px;padding:10px 12px;font-size:12px"><div style="color:#8A8A8E;font-size:10px">退房</div>12/08 周日</div>
</div>
<div style="margin:0 22px 16px;font-size:12px;color:#8A8A8E">🛏 房间容量 2 人 ≥ 出行 2 人 ✓ · 每房含双早</div>
<div style="margin:0 22px 20px;font-size:12px;color:#9a9a9e;text-align:center;padding:12px;border:1px dashed #333;border-radius:12px">＋ 自定义套餐配置（进阶）</div>
<div style="height:70px"></div>
<!-- sticky bottom -->
<div class="glass" style="position:absolute;left:0;right:0;bottom:0;padding:14px 20px 22px;display:flex;justify-content:space-between;align-items:center;gap:14px">
  <div><div style="font-size:10px;color:#8A8A8E">合计</div><span style="font-size:22px;color:#E8B65A;font-weight:800">¥2,680</span></div>
  <button class="btn-amber" style="width:auto;padding:14px 42px">立即下单</button>
</div>`;

// ── ④ ORDER DETAIL (ticket-stub) ──────────────────────────
const ORDER = `
<div style="display:flex;align-items:center;gap:14px;padding:8px 22px 16px">
  <span style="font-size:20px">‹</span><div><b style="font-size:16px">订单详情</b><div style="font-size:11px;color:#8A8A8E">订单号 GBA20261206 · 已支付</div></div>
</div>
<!-- ticket stub -->
<div style="margin:0 22px 20px;position:relative">
  <div style="background:#17171a;border-radius:20px 20px 0 0;overflow:hidden">
    <div style="${poster(G1,130)};position:relative"><div style="position:absolute;inset:0;background:${scrim()}"></div>
      <div style="position:absolute;left:16px;bottom:12px"><div style="font-size:20px;font-weight:800;font-style:italic">TWINS LOL 世界巡演</div><div style="font-size:11px;color:#cfcfcf;margin-top:3px">香港红磡体育馆 · 12/06 20:00</div></div>
    </div>
    <div style="display:flex;padding:14px 18px;gap:8px">
      ${[['票档','内场企位'],['数量','2 张'],['取票','电子票']].map(([k,v])=>`<div style="flex:1"><div style="font-size:10px;color:#8A8A8E">${k}</div><div style="font-size:13px;font-weight:700;margin-top:3px">${v}</div></div>`).join('')}
    </div>
  </div>
  <!-- perforation -->
  <div style="height:0;border-top:2px dashed #333;position:relative;background:#17171a"></div>
  <div style="position:absolute;left:-10px;top:calc(130px + 62px);width:20px;height:20px;border-radius:50%;background:radial-gradient(circle at 50% -10%,#1a1a1d 0%,#0a0a0b 60%)"></div>
  <div style="position:absolute;right:-10px;top:calc(130px + 62px);width:20px;height:20px;border-radius:50%;background:radial-gradient(circle at 50% -10%,#1a1a1d 0%,#0a0a0b 60%)"></div>
  <div style="background:#17171a;border-radius:0 0 20px 20px;padding:16px 18px;text-align:center">
    <div style="height:52px;background:repeating-linear-gradient(90deg,#e8e8e8 0 2px,transparent 2px 5px);border-radius:6px;margin-bottom:8px"></div>
    <div style="font-size:10px;color:#8A8A8E;letter-spacing:2px">GBA · 2026 · 后四位 1206 · 请于现场出示</div>
  </div>
</div>
<!-- independent tracks -->
<div style="padding:0 22px 10px;font-size:14px;font-weight:700">履约状态</div>
${[['🎫 门票','已交付 · 电子票','#4EC38A','已验证 → 已交付用户'],['🏨 酒店','已付款 · 酒店确认中','#E8B65A','申请库存 · 预计2小时反馈'],['🚄 交通','未购买','#6a6a6e','—']].map(([k,s,c,sub])=>`
<div style="margin:0 22px 10px;background:#161618;border:1px solid #232326;border-radius:16px;padding:14px 16px;display:flex;justify-content:space-between;align-items:center">
  <div><div style="font-size:13px;font-weight:700">${k}</div><div style="font-size:10px;color:#8A8A8E;margin-top:4px">${sub}</div></div>
  <span style="font-size:12px;font-weight:700;color:${c}">${s}</span>
</div>`).join('')}
<div style="display:flex;gap:12px;padding:14px 22px 22px">
  <button class="glass" style="flex:1;border-radius:20px;padding:13px;color:#cfcfcf;font-size:13px;font-weight:600">申请售后</button>
  <button style="flex:1;border-radius:20px;padding:13px;background:rgba(255,77,77,.14);border:1px solid rgba(255,77,77,.5);color:#FF6B6B;font-size:13px;font-weight:700">现场无法入场</button>
</div>
<div style="height:20px"></div>`;

// ── mount ─────────────────────────────────────────────────
document.getElementById('root').innerHTML =
  frame('① 首页', HOME) +
  frame('② 演出详情', DETAIL) +
  frame('③ 套餐选择', PKG) +
  frame('④ 订单 · 票根', ORDER);
