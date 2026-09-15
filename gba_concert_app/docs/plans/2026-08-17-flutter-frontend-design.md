# 大湾区观演一站式平台 · 可交互 Flutter 前端设计文档

- 日期：2026-08-17
- 依据：PRD v0.2（管理型二级票务平台＋票酒套餐）+ 原型 `UX_大湾区观演平台_App原型_v6(3).html`
- 目标：可交互 Flutter **纯前端**（mock 数据），移动端为主，Web 仅本地调试预览

## 1. 决策基线（用户 2026-08-17 定调）

1. **范围** = C 端主链路 6 屏 + PRD A1–A11 关键补充屏。
2. **对齐** = 边做边按 PRD 附录C「原型对齐清单」修正，不照抄 v6 的 bug。
3. **技术** = Flutter 移动端布局为主（iOS/Android），Web 仅调试。
4. **数据** = mock 为主，**预留后端接口结构**（Repository 抽象层）。
5. **状态方案** = A · Provider + ChangeNotifier + Repository 接口。

## 2. 目标与非目标

### 目标
- 用户可走完：登录 → 首页 → 演出详情 → 套餐选择 → 出行人 → 下单确认 → 支付结果 → 下单完成 → 订单中心 → 订单详情 → 售后/现场应急。
- 三种票源库存（现票/担保/询价）与两类酒店库存（配额/申请）在 UI 上严格区分。
- 交互真实：选票档/人数、库存校验、房型加减、下单确认弹窗、状态流转均可点。

### 非目标（一期前端不做）
- 五大 AI 引擎、供应商工作台、运营后台（PRD 第 9/10 章，本次不做）。
- 真实支付、真实后端、账号体系持久化。
- 精确选座图、多币种、海外卡支付。

## 3. 页面清单（枚举全集）

### 主链路 6 屏（v6 已有）
| # | 屏 | 要点 |
|---|---|---|
| 1 | Home 首页 | 轮播、搜索、推荐套餐、热门/折扣/近期演出 |
| 2 | EventDetail 演出详情 | 多场次切换、票档、**预设套餐为主入口**、担保规则、最迟出票时间、退改说明 |
| 3 | PackageSelect 套餐选择 | 预设套餐列表 + 精选座位(③-C) + 自定义配置(③-B，降级次级) |
| 4 | Checkout 下单确认 | 场次/票档/数量/酒店/房型/日期/出行人 + 担保说明 + 30 分钟锁定提示 |
| 5 | OrderDone 下单完成 | **区分"资源确认中" vs "套餐已确认"** |
| 6 | OrderDetail 订单详情 | **票/酒店/交通独立履约状态**、凭证、联系人 |

### A1–A11 补充屏（新增）
| # | 屏 | PRD |
|---|---|---|
| 7 | Auth 登录 | A1 手机号+验证码 |
| 8 | TravelerForm 出行人证件 | A5 下单前填、证件脱敏 |
| 9 | PayResult 支付结果 | A7 资源确认中/套餐已确认 |
| 10 | OrderCenter 订单中心 | A8 九种状态筛选 |
| 11 | AfterSale 售后/现场应急 | A10 现场无法入场高优先级入口 |
| 12 | Messages 消息通知 | A11 |
| 13 | Profile 我的 | 出行人/证件/地址管理入口 |

弹层/子态：连坐库存提示（紧张/不足两态）、酒店详情弹层、房型加减、下单确认弹窗。

## 4. 架构（Provider + Repository）

```
lib/
  main.dart
  app.dart              # MaterialApp + 路由表 + MultiProvider
  theme/
    app_theme.dart      # 配色对齐 v6：主色#7CC200 / 浅绿底#E8F7D0 / 深绿字#3A7A00 / 文字#1A1A1A·#666·#999
  models/               # 纯数据类，对齐 PRD 第12章数据模型
    event.dart          # Artist / Event / PerformanceSession / Venue / TicketTier
    inventory.dart      # StockType(hard/committed/onRequest) 枚举 + 库存量
    package.dart        # PackageSKU / PackageItemAllocation
    hotel.dart          # Hotel / RoomType / HotelStockType(allotment/request)
    order.dart          # Order / OrderItem(ticket/hotel/transport) / 状态机枚举
    traveler.dart       # Traveler(证件脱敏) / Address
  repositories/
    catalog_repository.dart   # 抽象接口：演出/套餐/酒店查询
    order_repository.dart     # 抽象接口：下单/支付/订单查询/售后
    mock/
      mock_catalog_repository.dart
      mock_order_repository.dart
  state/
    auth_state.dart
    cart_state.dart     # 选中的套餐/票档/人数/房型/出行人/库存校验
    order_state.dart    # 订单列表与状态流转（mock 定时推进）
  screens/              # 13 屏，每屏一文件
  widgets/
    phone_frame.dart    # 移动端外壳（Web 调试时套手机边框）
    stock_badge.dart    # 现票/担保出票/资源确认中 三态徽章
    guarantee_card.dart # 担保规则卡
    status_timeline.dart# 订单履约时间线（票/酒店/交通独立）
    seat_warn_modal.dart# 连坐库存提示弹层（修复 v6 JS bug 版）
  mock/
    seed_data.dart      # 假数据：2-3 场演出、多套餐、酒店、示例订单
```

**数据流**：Screen → 读 Provider（state）→ state 调 Repository（抽象）→ MockRepository 返回 seed 数据。以后接后端只替换 `repositories/mock/*` 为真实 HTTP 实现，接口签名不变。

## 5. 关键业务规则（前端必须体现）

- **三种票源库存严格区分**：`hard`=现票（可显示"现票/已出票"），`committed`=担保出票（显示"担保出票"+预计出票时间，不显示现票/座位号），`onRequest`=询价（不可直接售，前端不作为可购态）。
- **酒店两类**：`allotment` 配额（付款即"已确认"）；`request` 申请（付款后显示 **"已付款·酒店确认中"**，不得提前显示"套餐已确认"）。
- **套餐** = 门票 + 酒店（交通可选加购）；预设套餐一口价为主 + 主票轻量加购。
- **库存不足禁止继续购买**（v6 的"仍然继续"按钮删除）；**站席不显示连座**。
- 担保范围/截止时间/退改/赔付在**支付前展示**。
- 赔付口径：现场无法入场 **500 元/票、单笔上限 2000 元**（售后页展示规则）。

## 6. PRD 附录C 对齐清单（边做边落）

- [ ] 预设套餐 → 详情主入口，自定义套餐降级为次级
- [ ] 现票/担保出票/酒店确认中 清晰标识（StockBadge）
- [ ] 移除站席"连座"表述
- [ ] 库存不足时禁止"仍然继续"
- [ ] 酒店加入住/退房日期、房间容量、入住人校验
- [ ] 支付成功页区分"资源确认中"/"套餐已确认"
- [ ] 订单详情票/酒店/交通独立状态
- [ ] 删除"付款后不可修改"与"修改订单"矛盾文案
- [ ] 连坐弹窗逻辑用 Flutter 重写（原 JS 语法错误自然消除）

## 7. 状态机（mock 落地，对齐 PRD 第11章）

- 总订单：`待付款 → 资源确认中 → 套餐已确认 → 出票中 → 已出票 → 待观演 → 已完成`；异常分支 `替代方案处理中 / 退款中 / 部分退款`。
- 票子项：`待锁定→已锁定→待供应商确认→待交票→已交票→已验证→已交付用户→已使用`。
- 酒店子项：配额 `已锁定→已确认→已出凭证→已入住`；申请 `待申请→确认中→已确认/确认失败→替换中/退款中`。
- mock 实现：`OrderState` 用定时器/手动按钮把示例订单从一个状态推进到下一个，便于演示流转。

## 8. 主题/视觉

对齐 v6：浅绿背景、白卡片、主色 `#7CC200`、标签浅绿底 `#E8F7D0` + 深绿字 `#3A7A00`、圆角卡片 + 轻阴影。移动端单列布局（不再横排多手机），Web 调试用 `PhoneFrame` 套 360×760 边框。

## 9. 构建顺序（分批交付，每批可预览）

1. **批次1 脚手架**：flutter create + theme + models + mock repository + seed data + 路由骨架。
2. **批次2 主链路**：Home → EventDetail → PackageSelect → Checkout → PayResult → OrderDone → OrderDetail。
3. **批次3 补充屏**：Auth / TravelerForm / OrderCenter / AfterSale / Messages / Profile。
4. **批次4 收尾**：连坐库存校验、酒店弹层与房型加减、对齐清单逐条核对、状态机流转演示。

## 10. 运行与预览约定

- 项目路径：`/Users/charliewu/Documents/香港票务酒店套餐平台/gba_concert_app`
- Web 调试跑 localhost（沿用 toefl_repro 打法：`flutter build web` / `flutter run -d chrome`；**不 kill 用户的 Chrome**，用户自行刷新）。
- 每批完成后本地预览截图自查 + 让用户在浏览器查看。
