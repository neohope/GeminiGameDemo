# Neo Game Suite

这是使用 Flutter 重写的经典桌面游戏合集，支持 Windows、macOS、Linux、Android、iOS 和 Web 平台。

## 包含游戏

1. **五子棋** - 经典的连珠游戏，支持人人对战和人机对战
2. **中国象棋** - 中国传统棋类游戏
3. **围棋** - 古老的策略棋类游戏
4. **国际象棋** - 世界流行的棋类游戏
5. **数独** - 经典的数字逻辑谜题

## 功能特点

- **跨平台支持** - 支持桌面端、移动端和Web端
- **响应式设计** - 自适应不同屏幕尺寸
- **游戏存档** - 支持保存和加载游戏进度
- **悔棋功能** - 支持撤销之前的走法
- **游戏模式** - 人人对战和人机对战（部分游戏）
- **完整的游戏逻辑** - 所有游戏都有完整的规则实现

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── core/                        # 核心模块
│   ├── constants/               # 常量定义
│   ├── routing/                 # 路由配置
│   ├── storage/                 # 本地存储
│   └── utils/                   # 工具类
├── features/                    # 功能模块
│   ├── home/                    # 首页
│   └── games/                   # 游戏模块
│       ├── gomoku/              # 五子棋
│       ├── chinese_chess/       # 中国象棋
│       ├── go/                  # 围棋
│       ├── chess/               # 国际象棋
│       └── sudoku/              # 数独
└── shared/                      # 共享模块
    ├── widgets/                 # 通用组件
    └── services/                # 通用服务
```

## 技术栈

- **Flutter** - 跨平台UI框架
- **Riverpod** - 状态管理
- **Go Router** - 路由管理
- **Shared Preferences** - 本地存储
- **Equatable** - 值比较

## 快速开始

1. 确保已安装 Flutter SDK
2. 克隆项目到本地
3. 进入项目目录，运行 `flutter pub get` 安装依赖
4. 运行 `flutter run` 启动应用

## 平台支持

- Windows: `flutter run -d windows`
- macOS: `flutter run -d macos`
- Linux: `flutter run -d linux`
- Android: `flutter run -d android`
- iOS: `flutter run -d ios`
- Web: `flutter run -d chrome`

## 游戏说明

### 五子棋
- 黑方先行
- 连成五子即可获胜
- 支持悔棋、保存、加载

### 中国象棋
- 红方先行
- 各棋子按规则移动和吃子
- 支持悔棋、保存、加载

### 围棋
- 黑方先行
- 轮流落子，围地吃子
- 支持停着（pass）

### 国际象棋
- 白方先行
- 各棋子按规则移动和吃子
- 支持悔棋、保存、加载

### 数独
- 自动生成合法谜题
- 支持求解功能
- 冲突格子高亮显示

## 许可证

本项目仅供学习和参考使用。
