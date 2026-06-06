# 婚礼策划预订 App

新人婚礼筹备 App：婚宴酒店比价、四大金刚预约、预算表、宾客座位、任务清单、当天流程、合同 Mock、灵感案例库。

## 技术栈

| 层 | 技术 |
|---|---|
| 前端 | Flutter 3.22+、Riverpod、go_router、dio、table_calendar、fl_chart |
| 后端 Mock | Express + better-sqlite3，端口 **3022** |

## 测试账号

| 手机号 | 密码 | 说明 |
|--------|------|------|
| 13800000001 | 123456 | 新娘账号（已绑定演示婚礼） |
| 13800000002 | 123456 | 新郎账号（同一 weddingId 共享数据） |

演示绑定码：`DEMO01`（伴侣可通过「绑定」加入同一婚礼）

## 快速开始

### 1. 启动 Mock 后端

```bash
cd backend
npm install
npm run dev
```

服务地址：`http://localhost:3022`

### 2. Web 调试 Flutter

```bash
cd mobile
flutter pub get
flutter run -d chrome --web-port=5192 --dart-define=API_BASE=http://localhost:3022
```

## 路由（24 页）

| 路由 | 页面 |
|------|------|
| `/splash` | 启动 |
| `/login` | 登录 |
| `/wedding/create` | 创建/绑定婚礼 |
| `/home` | 筹备首页（Tab） |
| `/wedding/date` | 婚期选择 |
| `/budget` | 预算总览（Tab） |
| `/budget/items` | 预算明细 |
| `/budget/add` | 添加支出 |
| `/venues` | 酒店列表 |
| `/venue/:id` | 酒店详情 |
| `/venue/:id/inquiry` | 询价 |
| `/vendors` | 供应商 Tab 四类 |
| `/vendor/:id` | 供应商详情 |
| `/booking/create` | 预约档期 |
| `/bookings` | 我的预约 |
| `/guests` | 宾客名单（Tab） |
| `/guest/create` | 添加宾客 |
| `/seating` | 座位图 |
| `/tasks` | 任务清单 |
| `/timeline` | 当天流程 |
| `/inspirations` | 灵感案例 |
| `/contracts` | 合同 Mock |
| `/messages` | 消息 |
| `/settings` | 设置 |

**底部导航**：首页 | 预算 | 供应商 | 宾客

## 业务规则（Mock）

- **双人协作**：同一 `weddingId` 数据共享，创建婚礼后生成绑定码
- **婚期锁定**：改期扣 Mock 定金 ¥5000
- **预算**：已付 + 待付 = 总支出，超支标红
- **座位**：桌位总容量须 ≥ 有效宾客数
- **档期**：同一供应商同一日期不可重复预约

## 测试

```bash
# 后端 API 测试（桌位校验、预算汇总、档期冲突）
cd backend && npm test

# Flutter 单元测试
cd mobile && flutter test
```

Seed 数据：12 酒店、32 供应商（四类各 8 家）、演示婚礼 80 名宾客。

## Web 兼容说明

- 不使用 camera、地图 SDK、电子签章 SDK
- 案例图与合同使用 URL Mock
- 酒店距离为城区 Mock 数值
