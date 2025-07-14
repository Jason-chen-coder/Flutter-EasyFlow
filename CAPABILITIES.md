# Flutter-EasyFlow 功能指南 / Capabilities Guide

## 你可以做什么 / What Can You Do

Flutter-EasyFlow 是一个强大的流程图创建和管理工具，让你能够轻松构建复杂的流程图。以下是它的主要功能：

## 🎯 核心功能 / Core Features

### 1. 节点管理 / Node Management
- **添加节点 / Add Nodes**: 支持多种节点类型的创建
- **删除节点 / Delete Nodes**: 轻松移除不需要的节点
- **编辑节点 / Edit Nodes**: 修改节点属性、大小、颜色和文本内容
- **拖拽节点 / Drag Nodes**: 自由拖拽节点到画布任意位置

### 2. 节点类型 / Node Types
支持以下多种流程图节点类型：

#### 基础形状 / Basic Shapes
- **矩形 / Rectangle** (`rectangle_widget.dart`): 标准流程步骤
- **菱形 / Diamond** (`diamond_widget.dart`): 决策点
- **椭圆 / Oval** (`oval_widget.dart`): 开始/结束节点
- **六边形 / Hexagon** (`hexagon_widget.dart`): 特殊处理步骤

#### 专业图形 / Professional Shapes  
- **平行四边形 / Parallelogram** (`parallelogram_widget.dart`): 输入/输出操作
- **存储 / Storage** (`storage_widget.dart`): 数据存储
- **任务 / Task** (`task_widget.dart`): 任务节点
- **图片 / Image** (`image_widget.dart`): 支持图片节点

#### 特殊组件 / Special Components
- **加号 / Plus** (`plus_widget.dart`): 添加新节点的交互点
- **分组 / Group** (`group_widget.dart`): 节点分组管理

### 3. 连接和关系 / Connections & Relationships
- **创建连接 / Create Connections**: 在节点间建立连接线
- **连接参数 / Connection Parameters**: 自定义连接属性
- **箭头绘制 / Arrow Drawing**: 自动绘制连接箭头
- **连接处理 / Connection Handling**: 智能连接点管理

### 4. 画布交互 / Canvas Interaction
- **点击事件 / Click Events**: 
  - 单击画布添加节点
  - 右键菜单操作
  - 长按手势支持
- **缩放控制 / Scale Control**: 
  - 手势缩放画布
  - 实时缩放反馈
- **背景网格 / Grid Background**: 对齐辅助网格

### 5. 数据管理 / Data Management
- **实时数据渲染 / Real-time Data Rendering**: 
  - 基于数据自动渲染流程图
  - 动态更新节点状态
- **JSON 编辑器 / JSON Editor**:
  - 树形视图编辑
  - 文本模式编辑  
  - 实时预览数据结构
  - 搜索和过滤功能
- **数据导入导出 / Import/Export**:
  - JSON 格式数据导出
  - 本地文件导入

### 6. 用户界面功能 / UI Features
- **主题定制 / Theme Customization**:
  - 颜色选择器
  - 节点样式定制
  - 背景颜色设置
- **菜单系统 / Menu System**:
  - 星形菜单 (Star Menu)
  - 上下文菜单
  - 元素设置菜单
- **响应式设计 / Responsive Design**:
  - 支持多平台 (Web, Mobile, Desktop)
  - 自适应布局

## 🚀 高级功能 / Advanced Features

### 分组管理 / Group Management
- **创建分组 / Create Groups**: 将相关节点组织到一起
- **分组操作 / Group Operations**: 
  - 整体移动分组
  - 分组内节点管理
  - 分组样式设置

### 实时协作 / Real-time Collaboration
- **数据同步 / Data Sync**: 实时数据更新和同步
- **状态管理 / State Management**: 智能状态跟踪和恢复

### 平台兼容 / Platform Compatibility
- **Web 部署 / Web Deployment**: 
  - GitHub Pages 部署支持
  - 浏览器兼容
- **移动端 / Mobile**: 
  - Android/iOS 原生支持
  - 触摸手势优化
- **桌面端 / Desktop**:
  - Windows/macOS/Linux 支持
  - 键盘快捷键

## 📋 计划中的功能 / Planned Features

### 1. 可折叠分组节点 / Collapsible Group Nodes
- 支持分组节点的展开和折叠
- 更高效地管理复杂图表

### 2. 本地数据持久化 / Local Data Persistence  
- 本地保存画布数据
- 支持数据恢复，无缝继续工作

### 3. 动画 JSON 数据面板 / Animated JSON Data Panel
- 左侧可展开/折叠的动画面板
- 更好的数据管理体验

## 🛠️ 使用场景 / Use Cases

### 业务流程设计 / Business Process Design
- 工作流程图创建
- 业务逻辑可视化
- 决策树设计

### 软件开发 / Software Development
- 系统架构图
- 数据流图
- 用户界面流程

### 教育培训 / Education & Training
- 学习路径图
- 知识结构图
- 教学流程设计

### 项目管理 / Project Management
- 项目流程图
- 任务依赖关系
- 里程碑规划

## 🎮 如何开始 / Getting Started

### 基本操作 / Basic Operations
1. **添加节点**: 点击画布空白区域，选择节点类型
2. **连接节点**: 拖拽节点边缘的连接点到目标节点
3. **编辑属性**: 右键点击节点，打开设置菜单
4. **保存数据**: 使用 JSON 编辑器查看和导出数据

### 快捷操作 / Quick Actions
- **Ctrl/Cmd + 滚轮**: 缩放画布
- **拖拽**: 移动节点或画布
- **右键**: 打开上下文菜单
- **长按**: 多选操作

## 🔧 技术特性 / Technical Features

### 性能优化 / Performance Optimization
- 高效的渲染引擎
- 大型图表支持
- 流畅的动画效果

### 数据格式 / Data Format
- 标准 JSON 格式
- 易于集成和扩展
- 版本兼容性

### 扩展性 / Extensibility
- 插件化架构
- 自定义节点类型
- 主题扩展支持

---

**Flutter-EasyFlow** 让复杂的流程图创建变得简单直观。无论你是业务分析师、软件开发者还是项目经理，都能通过这个工具快速创建专业的流程图表。

立即开始探索 Flutter-EasyFlow 的强大功能吧！🚀