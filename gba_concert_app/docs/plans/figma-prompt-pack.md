# Figma AI (Make / First Draft) Prompt Pack
## 大湾区观演一站式平台 · 暗色电影票务风

用法：先把 **§0 主风格系统 Prompt** 作为全局风格基线（每次生成都带上，或在 Make 项目里作为 project context）；再对每一页把「§0 + 该页 prompt」拼接后喂给 Figma AI。这样保证 13 页视觉统一、又各自带对业务上下文。

---

## §0 主风格系统 Prompt（每页都带）

```
You are designing a high-end mobile app (iOS, 393×852pt) for a premium cross-border
concert-going service platform: mainland-China fans travel to Hong Kong to watch concerts,
buying a bundled package = concert ticket + HK hotel (+ optional cross-border transport).
Brand positioning: trustworthy, premium, full-service — NOT a cheap ticket reseller.

VISUAL LANGUAGE (apply to every screen):
- Theme: dark, cinematic. Base background #0A0A0B (near-black). Cards #161618 / #1C1C1E.
- Accent: warm gold / amber (#E8B65A → #C9962F gradient) for primary buttons, highlights,
  price, and key CTAs. Use sparingly for a luxe feel.
- Hero media: full-bleed concert/artist poster imagery with a bottom-to-top black gradient
  scrim so white text stays legible over the image.
- Typography: bold / italic display type for hero titles and big numbers (e.g. dates,
  ticket counts, prices); clean sans-serif (SF Pro style) for body. High contrast white text.
- Glassmorphism: frosted-glass floating bottom nav bar, segmented controls, and floating
  circular buttons (backdrop blur, subtle border, translucent dark fill).
- Pill-shaped controls: tabs and primary buttons are fully-rounded capsules.
- Ticket-stub metaphor for any voucher/credential card: perforated edge + dashed divider +
  barcode/QR, like a real concert ticket.
- Generous spacing, rounded 20–24px card corners, soft shadows, premium restraint.
- Language: Simplified Chinese UI copy (labels in 中文), currency CNY ¥.

Reference mood: Adverse casino app (dark + amber), F1 movie ticket app (cinematic poster +
glass), KALAN "35 Tickets" (bold display type + ticket-stub cards).
```

---

## §1 Home 首页

```
Screen: Home / discovery for the concert-package app.
Content blocks top→bottom:
- Top bar: small logo left, notification bell + user avatar right.
- Search field (pill, frosted): placeholder "搜索艺人、演出、场馆".
- Auto-rotating hero carousel: full-bleed concert poster cards with black bottom scrim;
  overlay = artist name (bold display), venue + date, an amber "担保出票" pill badge, and
  from-price "¥1,880 起". 3 dots indicator.
- Section "推荐套餐": horizontal scroll of package cards (poster thumb + concert name +
  "含门票+酒店" + amber price).
- Section tabs (pill segmented): 热门 / 折扣 / 近期演出; below a vertical list of event rows
  (poster thumb left, name + date + venue + lowest package price + a small stock badge).
- Floating frosted bottom nav (5 items): 首页 / 发现 / 搜索 / 消息 / 我的, center item highlighted amber.
Chinese UI copy, CNY. Keep it cinematic and premium.
```

## §2 EventDetail 演出详情

```
Screen: Event / concert detail.
- Full-bleed artist/concert poster hero with black gradient scrim; back button (frosted circle)
  and share button top corners. Over the image: concert title (bold display), artist, venue.
- Multi-session selector: horizontal pill row of dates (e.g. 12/06 12/07 12/08), one selected amber.
- Info row: venue, city, doors/最迟出票时间, a "担保出票" trust badge.
- PRIMARY entry = "票酒套餐" section: prominent package cards (this is the main CTA, not raw tickets).
  Each package card: poster thumb, "门票 + 酒店 2 晚", room type, from-price, stock badge
  (现票 green / 担保出票 amber). A big amber pill button "查看套餐".
- Secondary/collapsed: 票档说明 (tiers with view/座席), 担保与退改规则 (expandable), 购票须知.
- IMPORTANT: seated tiers may show "系统尽力安排相邻座位"; standing tiers must NOT show any
  "连座/adjacent seats" wording. Do not show exact seat numbers for 担保出票 stock.
Chinese UI copy, CNY, dark cinematic.
```

## §3 PackageSelect 套餐选择

```
Screen: Package selection & configuration.
- Header: concert name + selected session date.
- Preset packages list (PRIMARY): rich cards — poster, "套餐A · 门票内场 + 尖沙咀酒店2晚",
  included items as icon rows (🎫门票档位 / 🏨酒店房型 / 🚄可选加购交通), total price in amber,
  stock badge, "一口价" tag. Selectable (selected card = amber border + glow).
- Ticket tier picker: pill options (内场企位 / A区看台 / B区看台) with per-tier stock hint.
- Quantity/pax stepper. IMPORTANT: if stock < requested qty, DISABLE purchase and show a
  clear inline warning "库存不足，无法购买 N 张" — do NOT offer a "仍然继续" button.
- Hotel block: room type options (双人房/大床房/家庭房) with capacity "可住2人", check-in/out
  dates, "每房含早" note, and a room-count stepper that validates total capacity ≥ pax.
- Secondary entry (de-emphasized, smaller): "自定义套餐配置" for advanced users.
- Sticky bottom bar: total price (amber) + "立即下单" pill button.
Chinese UI copy, CNY, dark cinematic, ticket-stub accents.
```

## §4 Checkout 下单确认

```
Screen: Order confirmation before payment.
- Summary card: concert, session, tier, qty, hotel + room type + check-in/out dates + pax.
- Stock/status chips: 现票/担保出票 for ticket, 配额(付款即确认) or 申请(需酒店确认) for hotel.
- Travelers section: list of travelers with masked ID (e.g. 证件 3****9), "编辑/添加出行人".
- Guarantee & refund block (MUST show BEFORE payment): 担保范围, 最迟出票时间, 退改规则,
  现场无法入场赔付 (¥500/票, 单笔上限 ¥2000). Currency clearly CNY.
- Price breakdown: 门票 / 酒店 / 加购 / 优惠, then total in big amber number.
- A "30 分钟内完成支付，超时自动释放库存" countdown hint.
- Agreement checkbox: "我已阅读并同意服务协议与退改规则".
- Sticky bottom: total + amber "去支付" pill.
- IMPORTANT: do NOT show contradictory copy like "付款后不可修改" next to a "修改订单" action.
Chinese UI copy, CNY, dark cinematic.
```

## §5 PayResult 支付结果与资源确认

```
Screen: Payment result + resource confirmation state.
- Top: success checkmark (amber) + "支付成功" + order number.
- CRITICAL state distinction — show one of two states clearly, never mix:
  (a) "资源确认中" — when hotel is 申请库存 or ticket is 担保出票: amber/neutral status with
      "预计 2 小时内反馈" and per-resource sub-status; do NOT say "套餐已确认".
  (b) "套餐已确认" — only when ALL resources (票 + 酒店) confirmed: green success state.
- Resource checklist rows: 门票 (担保出票·最迟出票时间 T-1 18:00) / 酒店 (已付款·酒店确认中 或 已确认).
- Buttons: "查看订单" (amber pill) + "返回首页".
Chinese UI copy, CNY, dark cinematic.
```

## §6 OrderDone 下单完成

```
Screen: Order completed / booking summary landing after confirmation.
- Ticket-stub hero card (perforated edge, dashed divider, subtle barcode): concert name,
  session date, venue, seat tier, qty; amber accent line.
- Resource status summary: 门票状态 / 酒店状态 / 交通状态 as separate rows with independent
  status chips (do not collapse into one overall label).
- Next-steps hints: 出票提醒 / 酒店确认反馈时间 / 现场取票或电子票说明.
- Buttons: "查看订单详情" + "分享给同行朋友".
Chinese UI copy, CNY, dark cinematic, strong ticket-stub styling.
```

## §7 OrderDetail 订单详情

```
Screen: Order detail with INDEPENDENT fulfillment tracks.
- Order header: order no., concert, total paid (amber).
- THREE independent status timelines (must be visually separate, each with its own state):
  1) 门票: 待锁定→已锁定→待供应商确认→待交票→已交票→已验证→已交付→已使用 (show current node).
  2) 酒店: 配额=已锁定→已确认→已出凭证→已入住; 申请=待申请→确认中→已确认/失败→替换中.
  3) 交通(可选): if not purchased show "未购买".
- Credential area: image ticket / QR / 官方转赠链接 / 纸质票物流 / 香港现场取票 — with a
  ticket-stub voucher card showing QR + order last-4 + a faint security watermark.
- Contacts: 出行人 list, 客服入口.
- Bottom actions: "申请售后" + prominent red "现场无法入场" emergency entry.
Chinese UI copy, CNY, dark cinematic.
```

---

## §8 Auth 登录 (A1)

```
Screen: Phone + SMS code login (A1).
- Dark cinematic bg with subtle concert imagery / gradient.
- Brand lockup + tagline "港澳观演 · 票酒一站式".
- Phone input (pill, frosted) with +86 prefix; SMS code input + "获取验证码" (amber, with
  60s countdown state); rate-limit / error state design.
- Agreement checkbox: 用户协议 + 隐私政策 links.
- Amber pill "登录 / 注册". Note: no WeChat login in phase 1.
Chinese UI copy, dark cinematic.
```

## §9 TravelerForm 出行人与证件 (A5)

```
Screen: Traveler & ID form (A5), shown before payment.
- List of saved travelers (masked ID) + "添加出行人".
- Form fields: 中文姓名, 拼音姓名, 证件类型 (身份证/港澳通行证/护照), 证件号码, 有效期,
  出生日期(如需), 手机号. Show a note: 仅在票务/酒店/交通履约需要时收集, 用途与保存期限.
- ID number masked on display (证件 3****9). One booker can add multiple travelers.
- Amber pill "保存并继续".
Chinese UI copy, dark cinematic.
```

## §10 OrderCenter 订单中心 (A8)

```
Screen: Order center list (A8).
- Top pill segmented filter across 9 states: 待付款 / 资源确认中 / 套餐已确认 / 出票中 /
  已出票 / 待观演 / 已完成 / 售后中 / 已退款关闭.
- Order cards: poster thumb, concert + session, total (amber), and a compact multi-track
  status (票/酒店 chips). Ticket-stub styling accents.
- Empty state design for a filter with no orders.
Chinese UI copy, CNY, dark cinematic.
```

## §11 AfterSale 售后 / 现场应急 (A10)

```
Screen: After-sales + on-site emergency (A10).
- TWO clearly separated entries:
  (a) 普通售后: select order sub-item (票/酒店/交通), 原因, 说明, 上传凭证; view 申请状态,
      处理意见, 退款金额.
  (b) 现场无法入场 (HIGH PRIORITY): a bold red emergency panel at top with 客服电话 and a
      "立即上报" button; fields for 检票口/时间/证据; explains 500元/票、单笔上限2000元 赔付规则.
- Refund vs compensation shown separately. Important actions need 二次确认.
Chinese UI copy, CNY, dark cinematic, emergency section in red.
```

## §12 Messages 消息通知 (A11)

```
Screen: Notifications (A11).
- Grouped list: 支付结果 / 酒店确认或失败 / 票商交票预警与出票 / 物流或现场取票 /
  替代方案待确认 / 售后与退款结果 / 演出前提醒.
- Each row: icon, title, one-line summary, timestamp, unread dot (amber).
- "替代方案待确认" rows have inline 接受/拒绝 quick actions.
Chinese UI copy, dark cinematic.
```

## §13 Profile 我的

```
Screen: Profile / account hub.
- Header: avatar, nickname, phone (masked), a subtle cinematic banner.
- Quick entries grid: 我的订单 / 出行人与证件 / 收货地址 / 消息 / 客服 / 设置.
- 出行人与证件 and 收货地址 manage lists (edit/delete, check in-progress orders on delete).
- Logout at bottom.
Chinese UI copy, dark cinematic.
```
