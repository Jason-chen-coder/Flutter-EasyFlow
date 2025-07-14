# Flutter-EasyFlow 使用示例 / Usage Examples

## 基本使用 / Basic Usage

### 1. 创建简单流程图 / Creating Simple Flow Chart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_easy_flow/flow_chart/flow_chart_library.dart';

class SimpleFlowChart extends StatefulWidget {
  @override
  _SimpleFlowChartState createState() => _SimpleFlowChartState();
}

class _SimpleFlowChartState extends State<SimpleFlowChart> {
  Dashboard dashboard = Dashboard();

  @override
  void initState() {
    super.initState();
    _createSampleFlow();
  }

  void _createSampleFlow() {
    // 添加开始节点
    final startElement = FlowElement(
      position: const Offset(100, 100),
      size: const Size(120, 80),
      text: '开始',
      kind: ElementKind.oval,
      backgroundColor: Colors.green.shade200,
    );
    dashboard.addElement(startElement);

    // 添加处理节点
    final processElement = FlowElement(
      position: const Offset(100, 220),
      size: const Size(120, 80),
      text: '处理数据',
      kind: ElementKind.rectangle,
      backgroundColor: Colors.blue.shade200,
    );
    dashboard.addElement(processElement);

    // 添加决策节点
    final decisionElement = FlowElement(
      position: const Offset(100, 340),
      size: const Size(120, 80),
      text: '是否成功?',
      kind: ElementKind.diamond,
      backgroundColor: Colors.orange.shade200,
    );
    dashboard.addElement(decisionElement);

    // 添加结束节点
    final endElement = FlowElement(
      position: const Offset(100, 460),
      size: const Size(120, 80),
      text: '结束',
      kind: ElementKind.oval,
      backgroundColor: Colors.red.shade200,
    );
    dashboard.addElement(endElement);

    // 创建连接
    startElement.next.add(processElement.id);
    processElement.next.add(decisionElement.id);
    decisionElement.next.add(endElement.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('简单流程图示例')),
      body: FlowChart(
        dashboard: dashboard,
        onDashboardTapped: (context, position) {
          _showAddNodeMenu(context, position);
        },
        onElementPressed: (context, element) {
          _showElementMenu(context, element);
        },
      ),
    );
  }

  void _showAddNodeMenu(BuildContext context, Offset position) {
    // 显示添加节点菜单的实现
  }

  void _showElementMenu(BuildContext context, FlowElement element) {
    // 显示元素菜单的实现
  }
}
```

### 2. 自定义节点样式 / Custom Node Styling

```dart
// 创建自定义样式的节点
final customElement = FlowElement(
  position: const Offset(200, 200),
  size: const Size(150, 100),
  text: '自定义节点',
  kind: ElementKind.rectangle,
  backgroundColor: Colors.purple.shade100,
  borderColor: Colors.purple,
  borderWidth: 2.0,
  textColor: Colors.purple.shade800,
  elevation: 4.0,
);

// 设置文字样式
customElement.textStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.purple.shade800,
);
```

### 3. 分组管理 / Group Management

```dart
// 创建分组
final group = FlowElement(
  position: const Offset(50, 50),
  size: const Size(300, 200),
  text: '工作流分组',
  kind: ElementKind.group,
  backgroundColor: Colors.grey.shade100,
  borderColor: Colors.grey,
);

// 添加子元素到分组
group.children = [element1.id, element2.id, element3.id];
dashboard.addElement(group);
```

### 4. JSON 数据操作 / JSON Data Operations

```dart
// 导出数据
String jsonData = dashboard.toJson();
print('流程图数据: $jsonData');

// 从 JSON 导入数据
try {
  dashboard.fromJson(jsonString);
  setState(() {}); // 刷新 UI
} catch (e) {
  print('导入失败: $e');
}

// 保存到本地文件
await _saveToFile(jsonData);

// 从文件加载
String? loadedData = await _loadFromFile();
if (loadedData != null) {
  dashboard.fromJson(loadedData);
}
```

### 5. 事件处理 / Event Handling

```dart
FlowChart(
  dashboard: dashboard,
  
  // 画布点击事件
  onDashboardTapped: (context, position) {
    print('画布被点击: $position');
    _showAddNodeDialog(context, position);
  },
  
  // 节点点击事件
  onElementPressed: (context, element) {
    print('节点被点击: ${element.text}');
    _showElementProperties(context, element);
  },
  
  // 节点长按事件
  onElementLongPressed: (context, element) {
    print('节点被长按: ${element.text}');
    _showElementContextMenu(context, element);
  },
  
  // 新连接创建事件
  onNewConnection: (sourceId, targetId) {
    print('新连接: $sourceId -> $targetId');
    _validateConnection(sourceId, targetId);
  },
  
  // 缩放事件
  onScaleUpdate: (scale) {
    print('缩放变化: $scale');
  },
)
```

### 6. 节点类型参考 / Node Types Reference

```dart
// 可用的节点类型
enum ElementKind {
  rectangle,    // 矩形 - 标准流程步骤
  diamond,      // 菱形 - 决策点
  oval,         // 椭圆 - 开始/结束
  hexagon,      // 六边形 - 准备/处理
  parallelogram, // 平行四边形 - 输入/输出
  storage,      // 存储 - 数据库/文件
  task,         // 任务 - 特殊任务
  image,        // 图片 - 自定义图像
  group,        // 分组 - 容器
}

// 使用示例
final elements = [
  FlowElement(kind: ElementKind.oval, text: '开始'),
  FlowElement(kind: ElementKind.rectangle, text: '处理'),
  FlowElement(kind: ElementKind.diamond, text: '判断'),
  FlowElement(kind: ElementKind.parallelogram, text: '输入'),
  FlowElement(kind: ElementKind.storage, text: '保存'),
  FlowElement(kind: ElementKind.hexagon, text: '准备'),
];
```

## 高级功能 / Advanced Features

### 1. 自定义连接样式 / Custom Connection Styling

```dart
// 设置连接参数
final connectionParams = ConnectionParams(
  color: Colors.blue,
  thickness: 2.0,
  style: ConnectionStyle.bezier, // 或 ConnectionStyle.straight
  arrowStyle: ArrowStyle.filled,
);
```

### 2. 实时数据绑定 / Real-time Data Binding

```dart
class DataBoundFlowChart extends StatefulWidget {
  @override
  _DataBoundFlowChartState createState() => _DataBoundFlowChartState();
}

class _DataBoundFlowChartState extends State<DataBoundFlowChart> {
  Dashboard dashboard = Dashboard();
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startRealTimeUpdate();
  }

  void _startRealTimeUpdate() {
    _updateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateFlowFromData();
    });
  }

  void _updateFlowFromData() {
    // 从外部数据源更新流程图
    setState(() {
      // 更新节点状态、颜色等
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
```

### 3. 导出功能 / Export Features

```dart
// 导出为图片
Future<void> _exportAsImage() async {
  final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary != null) {
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    
    // 保存图片
    await _saveImageToFile(bytes);
  }
}

// 导出为 PDF
Future<void> _exportAsPdf() async {
  final pdf = pw.Document();
  // 添加流程图到 PDF
  await _savePdfToFile(pdf);
}
```

## 最佳实践 / Best Practices

### 1. 性能优化 / Performance Optimization

```dart
// 大型流程图优化
class OptimizedFlowChart extends StatefulWidget {
  @override
  _OptimizedFlowChartState createState() => _OptimizedFlowChartState();
}

class _OptimizedFlowChartState extends State<OptimizedFlowChart> {
  // 使用分页或虚拟化
  bool _isLargeDataset = true;
  
  @override
  Widget build(BuildContext context) {
    return FlowChart(
      dashboard: dashboard,
      // 启用性能优化
      enableOptimization: _isLargeDataset,
      maxVisibleElements: 50, // 限制可见元素数量
    );
  }
}
```

### 2. 错误处理 / Error Handling

```dart
try {
  dashboard.addElement(newElement);
} on ElementException catch (e) {
  _showErrorDialog('添加元素失败: ${e.message}');
} on ValidationException catch (e) {
  _showWarningDialog('验证失败: ${e.message}');
} catch (e) {
  _showErrorDialog('未知错误: $e');
}
```

### 3. 状态管理 / State Management

```dart
// 使用 Provider 或其他状态管理
class FlowChartProvider extends ChangeNotifier {
  Dashboard _dashboard = Dashboard();
  
  Dashboard get dashboard => _dashboard;
  
  void addElement(FlowElement element) {
    _dashboard.addElement(element);
    notifyListeners();
  }
  
  void removeElement(String elementId) {
    _dashboard.removeElement(elementId);
    notifyListeners();
  }
}
```

## 故障排除 / Troubleshooting

### 常见问题 / Common Issues

1. **节点不显示**: 检查 `position` 和 `size` 是否合理
2. **连接线不显示**: 确保源节点和目标节点都存在
3. **性能问题**: 考虑启用优化选项或减少元素数量
4. **导入失败**: 验证 JSON 格式是否正确

### 调试技巧 / Debugging Tips

```dart
// 启用调试模式
FlowChart(
  dashboard: dashboard,
  debugMode: true, // 显示调试信息
  onDebugInfo: (info) {
    print('调试信息: $info');
  },
)
```

---

更多详细信息请参考 [API 文档](API_REFERENCE.md) 或查看 [示例代码](example/) 目录。