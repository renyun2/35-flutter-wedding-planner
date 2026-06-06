# 项目 35：婚礼策划预订 App（Flutter）

> 本文件仅描述需求，不包含任何实现代码。UI 使用 Material 基础组件，不做美化。

## 一、项目简介
新人婚礼筹备 App：婚宴酒店比价、四大金刚（摄影/摄像/化妆/主持）预约、婚礼预算表、宾客名单座位、任务清单、婚礼当天流程表、供应商合同 Mock、灵感案例库。与酒店旅游（15）区分：聚焦婚礼筹备全流程。

## 二、技术栈

### 前端
- Flutter 3.22+、Riverpod + freezed、go_router、dio
- table_calendar（婚期、档期）
- fl_chart（预算饼图、支出进度）

### 后端 Mock
- Express + SQLite，端口 `3022`

### Web 兼容约束
- **禁止**：camera、地图 SDK、电子合同签章 SDK
- **替代**：案例图 URL；合同 PDF 链接；酒店距离=城区 Mock

## 三、后端 Mock API 设计

| 模块 | 路径 | 说明 |
|------|------|------|
| 认证 | `/api/auth/*` | 支持双人绑定 weddingId |
| 婚期 | PUT `/api/wedding/date` | |
| 预算 | CRUD `/api/budget/items` | 分类、已付/待付 |
| 酒店 | GET `/api/venues` | 桌数、价位筛选 |
| 酒店 | POST `/api/venue-inquiries` | 询价 |
| 供应商 | GET `/api/vendors` | 四大分类 |
| 供应商 | POST `/api/bookings` | 预约档期 |
| 宾客 | CRUD `/api/guests` | 桌号、RSVP |
| 座位 | PUT `/api/seating` | 桌位分配 JSON |
| 任务 | CRUD `/api/tasks` | 筹备 checklist |
| 流程 | CRUD `/api/timeline` | 当天分钟级 |
| 案例 | GET `/api/inspirations` | |
| 合同 | GET `/api/contracts` | URL Mock |
| 消息 | `/api/notifications` | |

**业务规则**：婚期锁定后改期扣 Mock 定金；桌位容量校验；预算超支标红。

## 四、页面清单（≥24 页）

| 序号 | 页面 | 路由 | 说明 |
|------|------|------|------|
| 1 | 启动 | `/splash` | |
| 2 | 登录 | `/login` | |
| 3 | 创建婚礼 | `/wedding/create` | 新人信息 |
| 4 | 筹备首页 | `/home` | 倒计时、任务摘要 |
| 5 | 婚期选择 | `/wedding/date` | calendar |
| 6 | 预算总览 | `/budget` | 饼图 |
| 7 | 预算明细 | `/budget/items` | |
| 8 | 添加支出 | `/budget/add` | |
| 9 | 酒店列表 | `/venues` | |
| 10 | 酒店详情 | `/venue/:id` | |
| 11 | 询价 | `/venue/:id/inquiry` | |
| 12 | 供应商 | `/vendors` | Tab 四类 |
| 13 | 供应商详情 | `/vendor/:id` | |
| 14 | 预约档期 | `/booking/create` | |
| 15 | 我的预约 | `/bookings` | |
| 16 | 宾客名单 | `/guests` | |
| 17 | 添加宾客 | `/guest/create` | |
| 18 | 座位图 | `/seating` | 桌位 Mock |
| 19 | 任务清单 | `/tasks` | |
| 20 | 当天流程 | `/timeline` | |
| 21 | 灵感案例 | `/inspirations` | |
| 22 | 合同 | `/contracts` | |
| 23 | 消息 | `/messages` | |
| 24 | 设置 | `/settings` | |

**底部导航**：首页 | 预算 | 供应商 | 宾客

## 五、核心功能需求
1. 双人协作：同一 weddingId 数据共享
2. 预算：已付+待付=总预算，环形进度
3. 座位：桌容量≥宾客数校验
4. 倒计时：婚期 D-day 首页展示

## 六、编译与调试
```bash
cd backend && npm run dev    # :3022
flutter run -d chrome --web-port=5192 --dart-define=API_BASE=http://localhost:3022
```

## 七、交付物
- seed：≥10 酒店、≥30 供应商、样例宾客 80 人
- 测试：桌位校验、预算汇总、档期冲突
- README

## 八、本次任务
**只列出需求和架构规划，不要写代码。**
