import 'dart:convert';

import 'package:flutter/material.dart';

import '../dashboard.dart';
import '../elements/flow_element.dart';
import './segment_handler.dart';

/// Arrow style enumeration
enum ArrowStyle {
  /// A curved arrow which points nicely to each handlers
  curve,

  /// A segmented line where pivot points can be added and curvature between
  /// them can be adjusted with a tension.
  segmented,

  /// A rectangular shaped line.
  rectangular,
}

/// Arrow parameters used by [DrawArrow] widget
class ArrowParams extends ChangeNotifier {
  ///
  ArrowParams({
    this.thickness = 2,
    this.headRadius = 3,
    double tailLength = 25.0,
    this.color = const Color(0xFF999999),
    this.style,
    this.tension = 1.0,
    this.plusNodeSize = 36,
    this.startArrowPosition = Alignment.centerRight,
    this.endArrowPosition = Alignment.centerLeft,
  }) : _tailLength = tailLength;

  ///
  factory ArrowParams.fromMap(Map<String, dynamic> map) {
    return ArrowParams(
      thickness: map['thickness'].toDouble(),
      headRadius: (map['headRadius'] ?? 4.0).toDouble(),
      plusNodeSize: (map['plusNodeSize'] ?? 16.0).toDouble(),
      tailLength: (map['tailLength'] ?? 25.0).toDouble(),
      color: Color(map['color'] as int),
      style: ArrowStyle.values[map['style'] as int? ?? 0],
      tension: (map['tension'] ?? 1).toDouble(),
      startArrowPosition: Alignment(
        map['startArrowPositionX'].toDouble(),
        map['startArrowPositionY'].toDouble(),
      ),
      endArrowPosition: Alignment(
        map['endArrowPositionX'].toDouble(),
        map['endArrowPositionY'].toDouble(),
      ),
    );
  }

  ///
  factory ArrowParams.fromJson(String source) =>
      ArrowParams.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Arrow thickness.
  double thickness;

  /// The radius of arrow tip.
  double headRadius;

  double plusNodeSize;

  /// Arrow color.
  final Color color;

  /// The start position alignment.
  final Alignment startArrowPosition;

  /// The end position alignment.
  final Alignment endArrowPosition;

  /// The tail length of the arrow.
  double _tailLength;

  /// The style of the arrow.
  ArrowStyle? style;

  /// The curve tension for pivot points when using [ArrowStyle.segmented].
  /// 0 means no curve on segments.
  double tension;

  ///
  ArrowParams copyWith({
    double? thickness,
    Color? color,
    ArrowStyle? style,
    double? tension,
    Alignment? startArrowPosition,
    Alignment? endArrowPosition,
  }) {
    return ArrowParams(
      thickness: thickness ?? this.thickness,
      color: color ?? this.color,
      style: style ?? this.style,
      tension: tension ?? this.tension,
      startArrowPosition: startArrowPosition ?? this.startArrowPosition,
      endArrowPosition: endArrowPosition ?? this.endArrowPosition,
    );
  }

  ///
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'thickness': thickness,
      'headRadius': headRadius,
      'plusNodeSize': plusNodeSize,
      'tailLength': _tailLength,
      'color': color.value,
      'style': style?.index,
      'tension': tension,
      'startArrowPositionX': startArrowPosition.x,
      'startArrowPositionY': startArrowPosition.y,
      'endArrowPositionX': endArrowPosition.x,
      'endArrowPositionY': endArrowPosition.y,
    };
  }

  ///
  String toJson() => json.encode(toMap());

  ///
  void setScale(double scale) {
    thickness = thickness * scale;
    headRadius = headRadius * scale;
    plusNodeSize = plusNodeSize * scale;
    _tailLength = _tailLength * scale;
    notifyListeners();
  }

  ///
  double get tailLength => _tailLength;
}

/// Notifier to update arrows position, starting/ending points and params
class DrawingArrow extends ChangeNotifier {
  DrawingArrow._();

  /// Singleton instance of this.
  static final instance = DrawingArrow._();

  /// Arrow parameters.
  ArrowParams params = ArrowParams();

  /// Sets the parameters.
  void setParams(ArrowParams params) {
    this.params = params;
    notifyListeners();
  }

  /// Starting arrow offset.
  Offset from = Offset.zero;

  ///
  void setFrom(Offset from) {
    this.from = from;
    notifyListeners();
  }

  /// Ending arrow offset.
  Offset to = Offset.zero;

  ///
  void setTo(Offset to) {
    this.to = to;
    notifyListeners();
  }

  ///
  bool isZero() {
    return from == Offset.zero && to == Offset.zero;
  }

  ///
  void reset() {
    params = ArrowParams();
    from = Offset.zero;
    to = Offset.zero;
    notifyListeners();
  }
}

/// Draw arrow from [srcElement] to [destElement]
/// using [arrowParams] parameters
class DrawArrow extends StatefulWidget {
  ///
  DrawArrow({
    required this.srcElement,
    required this.destElement,
    required this.dashboard,
    required List<Pivot> pivots,
    super.key,
    ArrowParams? arrowParams,
  })  : arrowParams = arrowParams ?? ArrowParams(),
        pivots = PivotsNotifier(pivots);

  ///
  final Dashboard dashboard;

  ///
  final ArrowParams arrowParams;

  ///
  final FlowElement srcElement;

  ///
  final FlowElement destElement;

  ///
  final PivotsNotifier pivots;

  @override
  State<DrawArrow> createState() => _DrawArrowState();
}

class _DrawArrowState extends State<DrawArrow> {
  @override
  void initState() {
    super.initState();
    widget.srcElement.addListener(_elementChanged);
    widget.destElement.addListener(_elementChanged);
    widget.pivots.addListener(_elementChanged);
  }

  @override
  void dispose() {
    widget.srcElement.removeListener(_elementChanged);
    widget.destElement.removeListener(_elementChanged);
    widget.pivots.removeListener(_elementChanged);
    super.dispose();
  }

  void _elementChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var from = Offset.zero;
    var to = Offset.zero;

    from = Offset(
      widget.srcElement.position.dx -
          (widget.dashboard.position.dx) +
          widget.srcElement.handlerSize / 2.0 +
          (widget.srcElement.size.width *
              ((widget.arrowParams.startArrowPosition.x + 1) / 2)),
      widget.srcElement.position.dy -
          (widget.dashboard.position.dy) +
          widget.srcElement.handlerSize / 2.0 +
          (widget.srcElement.size.height *
              ((widget.arrowParams.startArrowPosition.y + 1) / 2)),
    );
    to = Offset(
      widget.destElement.position.dx -
          (widget.dashboard.position.dx) +
          widget.destElement.handlerSize / 2.0 +
          (widget.destElement.size.width *
              ((widget.arrowParams.endArrowPosition.x + 1) / 2)),
      widget.destElement.position.dy -
          (widget.dashboard.position.dy) +
          widget.destElement.handlerSize / 2.0 +
          (widget.destElement.size.height *
              ((widget.arrowParams.endArrowPosition.y + 1) / 2)),
    );

    return RepaintBoundary(
      child: Builder(
        builder: (context) {
          return CustomPaint(
            painter: ArrowPainter(
              params: widget.arrowParams,
              from: from,
              to: to,
              pivots: widget.pivots.value,
            ),
            child: SizedBox(),
          );
        },
      ),
    );
  }
}

/// Paint the arrow connection taking in count the
/// [ArrowParams.startArrowPosition] and
/// [ArrowParams.endArrowPosition] alignment.
class ArrowPainter extends CustomPainter {
  ///
  ArrowPainter({
    required this.params,
    required this.from,
    required this.to,
    List<Pivot>? pivots,
    FlowElement? srcElement,
    FlowElement? destElement,
  })  : pivots = pivots ?? [],
        srcElement = srcElement ?? FlowElement(),
        destElement = destElement ?? FlowElement();

  ///
  final ArrowParams params;

  ///
  final Offset from;

  ///
  final Offset to;

  ///
  final Path path = Path();

  ///
  final List<List<Offset>> lines = [];

  ///
  final List<Pivot> pivots;

  late FlowElement srcElement;
  late FlowElement destElement;

  @override
  bool? hitTest(Offset position) {
    // 返回 false 以确保事件可以传递到 child
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Define common paint styles
    final commonPaint = Paint()
      ..strokeWidth = params.thickness
      ..color = const Color(0xFF4f5158);

    // Draw connection line based on style
    _drawConnectionLine(canvas, commonPaint);

    // Draw anchor points if needed
    _drawAnchorPoints(canvas, commonPaint);
  }

  void _drawConnectionLine(Canvas canvas, Paint paint) {
    // Draw line based on style
    switch (params.style) {
      case ArrowStyle.curve:
        drawCurve(canvas, paint);
      case ArrowStyle.segmented:
        drawLine();
      case ArrowStyle.rectangular:
        drawRectangularLine(canvas, paint);
      case null:
        // Handle null case if needed
        break;
    }

    // Draw the path
    paint
      ..color = params.color
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  void _drawAnchorPoints(Canvas canvas, Paint fillPaint) {
    // Draw source anchor point
    if (srcElement.taskType != TaskType.plus) {
      _drawAnchorPoint(canvas, from);
    }

    // Draw destination anchor point
    if (destElement.taskType != TaskType.plus) {
      _drawAnchorPoint(canvas, to);
    }
  }

  void _drawAnchorPoint(Canvas canvas, Offset position) {
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = params.headRadius * 4
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..strokeWidth = params.thickness
      ..color = const Color(0xFF4f5158);
    canvas.drawCircle(position, params.headRadius, borderPaint);
    canvas.drawCircle(position, params.headRadius, fillPaint);
  }

  // 绘制连线之间的加号
  // if (params.style != ArrowStyle.curve) {
  //   drawPlusNode(canvas, paint);
  // }
  // void drawPlusNode(Canvas canvas, Paint paint) {
  //   final paint = Paint()
  //     ..strokeWidth = params.thickness // 设置画笔的宽度
  //     ..color = Colors.white; // 设置颜色
  //
  //   var pivot1 = Offset(from.dx, from.dy);
  //   if (params.startArrowPosition.y == 1) {
  //     pivot1 = Offset(from.dx, (from.dy + to.dy) / 2);
  //   } else if (params.startArrowPosition.y == -1) {
  //     pivot1 = Offset(from.dx, from.dy - params.tailLength);
  //   }
  //
  //   final pivot2 = Offset(to.dx, pivot1.dy);
  //   // plus 的点
  //   final pivotPlus = Offset((pivot1.dx + pivot2.dx) / 2, pivot1.dy);
  //
  //   // 边长
  //   final double sideLength = params.headRadius * 12.0 ;
  //
  //   // 左上角坐标
  //   final Rect squareRect = Rect.fromCenter(
  //     center: pivotPlus, // 中心点
  //     width: sideLength, // 宽
  //     height: sideLength, // 高
  //   );
  //
  //   // 创建带圆角的矩形
  //   final rrect = RRect.fromRectAndRadius(squareRect, Radius.circular(5));
  //
  //   canvas.drawRRect(rrect, paint); // 绘制正方形
  //
  //   // 绘制 + 号
  //   final plusPaint = Paint()
  //   ..color = const Color(0xFF6CD7A3)
  //   ..strokeWidth = 2.0
  //   ..style = PaintingStyle.stroke;
  //
  //   final double plusSize = 20;
  //
  //   // 水平线
  //   canvas.drawLine(
  //   Offset(pivotPlus.dx - plusSize / 2, pivotPlus.dy), // 起点
  //   Offset(pivotPlus.dx + plusSize / 2, pivotPlus.dy), // 终点
  //   plusPaint,
  //   );
  //
  //   // 垂直线
  //   canvas.drawLine(
  //   Offset(pivotPlus.dx, pivotPlus.dy - plusSize / 2), // 起点
  //   Offset(pivotPlus.dx, pivotPlus.dy + plusSize / 2), // 终点
  //   plusPaint,
  //   );
  // }

  /// Draw a segmented line with a tension between points.
  void drawLine() {
    final points = [from];
    for (final pivot in pivots) {
      points.add(pivot.pivot);
    }
    points.add(to);

    path.moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = (i > 0) ? points[i - 1] : points[0];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = (i != points.length - 2) ? points[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6 * params.tension;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6 * params.tension;

      final cp2x = p2.dx - (p3.dx - p1.dx) / 6 * params.tension;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6 * params.tension;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }
  }

  /// Draw a rectangular line
  void drawRectangularLine(Canvas canvas, Paint paint) {
    // calculating offsetted pivot

    // var startVerticalOffset = 5.0;
    // var endVerticalOffset  = 5.0;
    // if(srcElement.taskType == TaskType.plus || from.dy<=to.dy){
    //   startVerticalOffset = 0;
    // }
    // if(destElement.taskType == TaskType.plus || to.dy<=from.dy){
    //   endVerticalOffset = 0;
    // }
    var pivot1 = Offset(from.dx, from.dy);
    if (params.startArrowPosition.y == 1) {
      pivot1 = Offset(from.dx, (from.dy + to.dy) / 2);
    } else if (params.startArrowPosition.y == -1) {
      pivot1 = Offset(from.dx, from.dy - params.tailLength);
    }

    final pivot2 = Offset(to.dx, pivot1.dy);

    // 绘制路径
    path
      ..moveTo(from.dx, from.dy + 0)
      ..lineTo(pivot1.dx, pivot1.dy)
      ..lineTo(pivot2.dx, pivot2.dy)
      ..lineTo(to.dx, to.dy - 0);

    lines.addAll([
      [from, pivot2],
      [pivot2, to],
    ]);
  }

  /// Draws a curve starting/ending the handler linearly from the center
  /// of the element.
  void drawCurve(Canvas canvas, Paint paint) {
    var distance = 0.0;

    var dx = 0.0;
    var dy = 0.0;

    final p0 = Offset(from.dx, from.dy);
    final p4 = Offset(to.dx, to.dy);
    distance = (p4 - p0).distance / 3;

    // checks for the arrow direction
    if (params.startArrowPosition.x > 0) {
      dx = distance;
    } else if (params.startArrowPosition.x < 0) {
      dx = -distance;
    }
    if (params.startArrowPosition.y > 0) {
      dy = distance;
    } else if (params.startArrowPosition.y < 0) {
      dy = -distance;
    }
    final p1 = Offset(from.dx + dx, from.dy + dy);
    dx = 0;
    dy = 0;

    // checks for the arrow direction
    if (params.endArrowPosition.x > 0) {
      dx = distance;
    } else if (params.endArrowPosition.x < 0) {
      dx = -distance;
    }
    if (params.endArrowPosition.y > 0) {
      dy = distance;
    } else if (params.endArrowPosition.y < 0) {
      dy = -distance;
    }
    final p3 = params.endArrowPosition == Alignment.center
        ? Offset(to.dx, to.dy)
        : Offset(to.dx + dx, to.dy + dy);
    final p2 = Offset(
      p1.dx + (p3.dx - p1.dx) / 2,
      p1.dy + (p3.dy - p1.dy) / 2,
    );

    path
      ..moveTo(p0.dx, p0.dy)
      ..conicTo(p1.dx, p1.dy, p2.dx, p2.dy, 1)
      ..conicTo(p3.dx, p3.dy, p4.dx, p4.dy, 1);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) {
    return true;
  }
}

/// Notifier for pivot points.
class PivotsNotifier extends ValueNotifier<List<Pivot>> {
  ///
  PivotsNotifier(super.value) {
    for (final pivot in value) {
      pivot.addListener(notifyListeners);
    }
  }

  /// Add a pivot point.
  void add(Pivot pivot) {
    value.add(pivot);
    pivot.addListener(notifyListeners);
    notifyListeners();
  }

  /// Remove a pivot point.
  void remove(Pivot pivot) {
    value.remove(pivot);
    pivot.removeListener(notifyListeners);
    notifyListeners();
  }

  /// Insert a pivot point.
  void insert(int index, Pivot pivot) {
    value.insert(index, pivot);
    pivot.addListener(notifyListeners);
    notifyListeners();
  }

  /// Remove a pivot point by its index.
  void removeAt(int index) {
    value.removeAt(index).removeListener(notifyListeners);
    notifyListeners();
  }
}
