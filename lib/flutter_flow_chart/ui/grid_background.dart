import 'package:flutter/material.dart';

/// 网格参数
class GridBackgroundParams extends ChangeNotifier {
  /// [gridSquare] 表示当缩放比例为1时网格单元的原始大小
  GridBackgroundParams({
    double gridSquare = 20.0,
    this.secondarySquareStep = 5,
    // 画布背景颜色
    this.backgroundColor =  const Color(0xFFf8f8f8),
    this.gridColor = const Color(0xFFABABAB),
    void Function(double scale)? onScaleUpdate,
  }) : rawGridSquareSize = gridSquare {
    if (onScaleUpdate != null) {
      _onScaleUpdateListeners.add(onScaleUpdate);
    }
  }

  ///
  factory GridBackgroundParams.fromMap(Map<String, dynamic> map) {
    final params = GridBackgroundParams(
      gridSquare: map['gridSquare'] as double? ?? 20.0,
      secondarySquareStep: map['secondarySquareStep'] as int? ?? 5,
      backgroundColor: Color(map['backgroundColor'] as int? ?? 0xFFFFFFFF),
      gridColor: Color(map['gridColor'] as int? ?? 0xFFABABAB),
    )
      ..scale = map['scale'] as double? ?? 1.0
      .._offset = Offset(
        map['offset.dx'] as double? ?? 0.0,
        map['offset.dy'] as double? ?? 0.0,
      );

    return params;
  }

  /// 未缩放时的网格单元大小
  /// 即当缩放比例为1时的网格单元大小
  final double rawGridSquareSize;

  /// 每多少个垂直或水平线绘制标记线
  final int secondarySquareStep;

  /// 网格背景颜色
  final Color backgroundColor;

  /// 网格线条颜色
  final Color gridColor;

  /// 偏移量，用于移动网格
  Offset _offset = Offset.zero;

  /// 网格的缩放比例
  double scale = 1;

  /// 添加缩放监听器
  void addOnScaleUpdateListener(void Function(double scale) listener) {
      print("=addOnScaleUpdateListener===========>");
      _onScaleUpdateListeners.add(listener);
  }

  /// 移除缩放监听器
  void removeOnScaleUpdateListener(void Function(double scale) listener) {
    _onScaleUpdateListeners.remove(listener);
  }

  final List<void Function(double scale)> _onScaleUpdateListeners = [];

  /// 设置偏移量
  set offset(Offset delta) {
    _offset += delta;
    notifyListeners();
  }

  /// 设置缩放比例
  void setScale(double factor, Offset focalPoint) {
    _offset = Offset(
      focalPoint.dx * (1 - factor),
      focalPoint.dy * (1 - factor),
    );
    scale = factor;

    for (final listener in _onScaleUpdateListeners) {
      listener(scale);
    }
    notifyListeners();
  }

  /// 获取缩放后的网格单元大小
  double get gridSquare => rawGridSquareSize * scale;

  /// 获取偏移量
  Offset get offset => _offset;

  /// 将参数转换为Map
  Map<String, dynamic> toMap() {
    return {
      'offset.dx': _offset.dx,
      'offset.dy': _offset.dy,
      'scale': scale,
      'gridSquare': rawGridSquareSize,
      'secondarySquareStep': secondarySquareStep,
      'backgroundColor': backgroundColor.value,
      'gridColor': gridColor.value,
    };
  }
}

/// 使用CustomPainter绘制带有给定参数的网格
class GridBackground extends StatelessWidget {
  GridBackground({
    super.key,
    GridBackgroundParams? params,
  }) : params = params ?? GridBackgroundParams();
  final GridBackgroundParams params;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: params,
      builder: (context, _) {
        return RepaintBoundary(
          child: CustomPaint(
            painter: _GridBackgroundPainter(
              params: params,
              dx: params.offset.dx,
              dy: params.offset.dy,
            ),
          ),
        );
      },
    );
  }
}
class _GridBackgroundPainter extends CustomPainter {
  _GridBackgroundPainter({
    required this.params,
    required this.dx,
    required this.dy,
  });

  final GridBackgroundParams params;
  final double dx;
  final double dy;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Background
    paint.color = params.backgroundColor;
    canvas.drawRect(
      Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
      paint,
    );

    // Grid points
    paint.color = params.gridColor;
    paint.style = PaintingStyle.fill;

    // Calculate the starting points for x and y
    final startX = dx % (params.gridSquare * params.secondarySquareStep);
    final startY = dy % (params.gridSquare * params.secondarySquareStep);

    // Calculate the number of lines to draw outside the visible area
    const extraLines = 4;

    // Draw points at grid intersections
    for (var x = startX - extraLines * params.gridSquare;
    x < size.width + extraLines * params.gridSquare;
    x += params.gridSquare) {
      for (var y = startY - extraLines * params.gridSquare;
      y < size.height + extraLines * params.gridSquare;
      y += params.gridSquare) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridBackgroundPainter oldDelegate) {
    debugPrint('shouldRepaint ${oldDelegate.dx} $dx ${oldDelegate.dy} $dy');
    return oldDelegate.dx != dx || oldDelegate.dy != dy;
  }
}
