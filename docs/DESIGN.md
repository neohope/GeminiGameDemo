# Gemini Game Suite - Flutter 重写设计文档

## 1. 项目概述

### 1.1 项目背景
Gemini Game Suite 是一个经典桌面游戏合集，原项目使用 Electron + React 开发。本次重写使用 Flutter 框架，以实现更好的跨平台兼容性和性能。

### 1.2 支持平台
- **桌面端**: Windows, macOS, Linux
- **移动端**: iOS, Android
- **Web端**: 现代浏览器

### 1.3 包含游戏
1. 五子棋 (Gomoku)
2. 中国象棋 (Chinese Chess)
3. 围棋 (Go)
4. 国际象棋 (Chess)
5. 数独 (Sudoku)

---

## 2. 系统架构

### 2.1 整体架构

采用 Clean Architecture + Feature-First 结构：

```
lib/
├── main.dart                    # 应用入口
├── core/                        # 核心模块
│   ├── constants/               # 常量定义
│   │   ├── app_constants.dart
│   │   └── game_constants.dart
│   ├── routing/                 # 路由配置
│   │   └── app_router.dart
│   ├── storage/                 # 本地存储
│   │   ├── storage_service.dart
│   │   └── game_storage.dart
│   ├── theme/                   # 主题配置
│   │   └── app_theme.dart
│   └── utils/                   # 工具函数
│       ├── responsive_layout.dart
│       └── platform_utils.dart
├── features/                    # 功能模块
│   ├── home/                   # 首页
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── home_page.dart
│   │       └── widgets/
│   │           └── game_card.dart
│   ├── games/                   # 游戏模块
│   │   ├── gomoku/             # 五子棋
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── gomoku_board.dart
│   │   │   │   │   └── gomoku_piece.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── gomoku_logic.dart
│   │   │   │       └── gomoku_ai.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   └── gomoku_page.dart
│   │   │       ├── providers/
│   │   │       │   └── gomoku_provider.dart
│   │   │       └── widgets/
│   │   │           └── gomoku_board_widget.dart
│   │   ├── chinese_chess/      # 中国象棋
│   │   ├── go/                 # 围棋
│   │   ├── chess/              # 国际象棋
│   │   └── sudoku/             # 数独
│   └── ...
└── shared/                      # 共享模块
    ├── widgets/                # 通用组件
    │   ├── game_control_bar.dart
    │   └── responsive_scaffold.dart
    └── services/               # 通用服务
```

### 2.2 技术选型

| 功能 | 技术方案 | 说明 |
|------|----------|------|
| 状态管理 | flutter_riverpod | 跨平台性能好，代码简洁 |
| 路由管理 | go_router | 声明式路由，支持深度链接 |
| 本地存储 | shared_preferences + path_provider | 支持全平台 |
| 测试框架 | flutter_test + integration_test | 单元、Widget、集成测试 |
| 棋盘绘制 | CustomPainter | 高性能绘制 |
| 响应式框架 | 自定义 LayoutBuilder + Breakpoints | 灵活可控 |

---

## 3. 响应式设计

### 3.1 断点定义

```dart
enum ScreenSize {
  small,   // < 600  - 手机竖屏
  medium,  // 600-1200 - 平板/手机横屏
  large,   // > 1200 - 桌面端
}
```

### 3.2 棋盘自适应策略

每个棋盘使用 `LayoutBuilder` 动态计算尺寸：

```
可用空间 → 计算最大棋盘尺寸 → 根据棋盘尺寸计算格子大小 → 渲染
```

### 3.3 控制栏布局

- **小屏幕**: 垂直排列，滚动支持
- **大屏幕**: 水平排列

---

## 4. 游戏模块设计

### 4.1 通用游戏接口

```dart
abstract class GameState {
  GameMode get gameMode;  // hvh (人vs人), hva (人vsAI)
  List<Object?> get history;
  bool get isGameOver;
}

abstract class GamePage extends Widget {
  final String gameId;
  final String gameName;
}
```

### 4.2 数独 (Sudoku)

- 棋盘: 9x9 网格，3x3 宫格加粗
- 功能: 新游戏、重置、AI解题、错误高亮
- 生成器: 回溯法生成合法数独
- 解题器: 回溯法解题

### 4.3 五子棋 (Gomoku)

- 棋盘: 15x15 网格
- 功能: 人人对战、人机对战、悔棋、存档/读档、重置
- AI: Minimax 算法 + α-β 剪枝

### 4.4 中国象棋 (Chinese Chess)

- 棋盘: 9x10 网格 + 楚河汉界 + 九宫格
- 功能: 人人对战、人机对战、悔棋、存档/读档、重置
- AI: Minimax 算法 + 评估函数
- 规则: 将/帅、士/仕、象/相、马、車、炮、兵/卒

### 4.5 围棋 (Go)

- 棋盘: 19x19 网格 + 星位点
- 功能: 人人对战、人机对战、Pass、悔棋、数子、存档/读档
- 规则: 吃子、气、打劫、贴目 (6.5目)

### 4.6 国际象棋 (Chess)

- 棋盘: 8x8 交替色网格
- 功能: 人人对战、人机对战、悔棋、存档/读档
- AI: Minimax 算法
- 规则: 王、后、车、象、马、兵的移动规则

---

## 5. 数据持久化

### 5.1 存储结构

```json
{
  "game_saves": {
    "gomoku": { "timestamp": 1234567890, "state": "..." },
    "chinese_chess": { ... },
    ...
  }
}
```

### 5.2 序列化策略

每个游戏状态实现 `toJson()` 和 `fromJson()` 方法。

---

## 6. 测试策略

### 6.1 测试分层

| 测试类型 | 范围 | 目标 |
|---------|------|------|
| 单元测试 | 游戏逻辑、AI算法 | 验证规则正确性 |
| Widget测试 | UI组件 | 验证渲染和交互 |
| 集成测试 | 完整游戏流程 | 端到端验证 |

### 6.2 测试覆盖重点

- 游戏规则合法性验证
- 边界条件测试
- AI 逻辑测试
- 存档/读档功能
- 响应式布局适配

---

## 7. 实现计划

### 阶段一: 基础设施
- Flutter 项目初始化
- 项目架构搭建
- 路由配置
- 基础 Widget 组件
- 本地存储服务

### 阶段二: 基础游戏
- 数独 (逻辑简单，先验证流程)
- 五子棋 (规则简单，AI 完善)

### 阶段三: 棋盘游戏
- 国际象棋
- 中国象棋
- 围棋

### 阶段四: 完善与测试
- UI 美化
- 响应式优化
- 测试全覆盖
- 多平台验证

---

## 8. 新游戏扩展指南

添加新游戏步骤:

1. 在 `features/games/` 下创建新游戏模块
2. 实现游戏逻辑 (domain 层)
3. 实现棋盘 Widget (presentation 层)
4. 在 `home_page.dart` 中添加游戏卡片
5. 在 `app_router.dart` 中添加路由
6. 编写测试

---

## 9. 完成标准

每个模块完成的定义:

- ✅ 游戏核心功能完整可用
- ✅ 支持人人对战和人机对战 (如适用)
- ✅ 支持悔棋、重置、存档/读档
- ✅ 响应式布局适配各屏幕尺寸
- ✅ 单元测试覆盖核心逻辑
- ✅ Widget 测试覆盖主要交互
- ✅ 无 Mock 数据，全部真实功能实现
