# 穩飛 SureTix · 大湾区观演一站式平台(Flutter 前端 Demo)

演唱会门票 + 香港酒店打包的一站式观演平台。主打**担保出票**信任叙事,面向年轻观演人群。

本仓库是**可交互的 Flutter Web 前端 Demo**(mock 数据,预留后端接口),供设计团队参考现有实现继续优化 UI/UX。

## 目录结构

- `gba_concert_app/` — Flutter 主工程(所有页面代码)
- `PRD_大湾区观演一站式服务平台_v0.2.md` / `.docx` — 产品需求文档

## 本地运行

```bash
cd gba_concert_app
flutter pub get
flutter run -d chrome            # 或
flutter build web --no-tree-shake-icons   # 构建后用 http.server 起 build/web
```

Flutter 3.44.x。桌面预览会以 390 宽的手机框居中显示(`_PhoneShell`)。

## 设计现状(供优化参考)

- **主题**:暗色(#0A0A0B)+ 玫红主强调色(#E5477B),翡冷翠绿(#2FBE8F)做信任/确认信号,暖橙(#FF8A5A)做紧迫点睛。全站色板集中在 `lib/theme/app_theme.dart` 的 `AppColors`(token 命名沿用 `amber*`,只是色值为玫红)。
- **字体**:标题 Noto Serif SC(斜体),正文 Noto Sans SC(google_fonts)。
- **组件**:`lib/widgets/common.dart`(PressableScale/Glass/AppBackButton/PosterBox 等)。
- **导航**:`MainShell`(首页/套餐/订单/我的 4 tab)+ CupertinoPageRoute 统一右滑转场。

## 已实现页面(21+ 屏)

- 核心购票链路:首页 → 演出详情 → 套餐组装器(选票/选方案/附加)→ 确认订单(含支付倒计时锁票)→ 支付成功/电子票根 → 订单中心/详情
- 合规捆绑:门票 + (酒店套餐 OR 观演礼包)二选一
- 账户/信任:登录、onboarding、穩飛保障、评价墙+成交流水、出行人证件、收货地址
- 辅助:搜索、消息通知、优惠券钱包、我的收藏、在线客服、帮助中心、设置、协议、退款售后、现场应急

## 换配色方向

`lib/theme/app_theme.dart` 里 `static const int scheme` 可切换:
- `scheme = 2`(当前)玫红主 + 翡冷翠确认(潮流优先)
- `scheme = 1` 翡冷翠主 + 玫红点睛(信任优先)

> 说明:图片为 Unsplash 占位,上线前需替换为真实艺人/演出图。
