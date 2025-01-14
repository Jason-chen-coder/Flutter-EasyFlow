import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easy_flow/flow_chart/ui/draw_group_column_plus.dart';
import 'package:flutter_easy_flow/flow_chart/ui/element_widget.dart';

import './dashboard.dart';
import './elements/flow_element.dart';
import './ui/draw_arrow.dart';
import './ui/draw_plus.dart';
import './ui/grid_background.dart';
import './ui/segment_handler.dart';

/// Main flow chart Widget.
/// It displays the background grid, all the elements and connection lines
class FlowChart extends StatefulWidget {
  ///
  const FlowChart({
    required this.dashboard,
    super.key,
    this.onElementPressed,
    this.onGoupPlusPressed,
    this.onGroupColumnPlusNodePressed,
    this.onPlusNodePressed,
    this.onElementSecondaryTapped,
    this.onElementLongPressed,
    this.onElementSecondaryLongTapped,
    this.onDashboardTapped,
    this.onDashboardSecondaryTapped,
    this.onDashboardLongTapped,
    this.onDashboardSecondaryLongTapped,
    this.onHandlerPressed,
    this.onHandlerSecondaryTapped,
    this.onHandlerLongPressed,
    this.onHandlerSecondaryLongTapped,
    this.onPivotPressed,
    this.onPivotSecondaryPressed,
    this.onScaleUpdate,
    this.onNewConnection,
    this.onElementOptionsPressed,
  });

  /// callback for tap on dashboard
  final void Function(BuildContext context, Offset position)? onDashboardTapped;

  /// callback for long tap on dashboard
  final void Function(BuildContext context, Offset position)?
      onDashboardLongTapped;

  /// callback for mouse right click on dashboard
  final void Function(BuildContext context, Offset postision)?
      onDashboardSecondaryTapped;

  /// callback for mouse right click long press on dashboard
  final void Function(BuildContext context, Offset position)?
      onDashboardSecondaryLongTapped;

  /// callback for element pressed
  final void Function(
    BuildContext context,
    Offset position,
    FlowElement element,
  )? onElementPressed;

  /// callback for element options pressed
  final void Function(
    BuildContext context,
    FlowElement element,
  )? onElementOptionsPressed;

  // 点击组节点的plus
  final void Function(
    BuildContext context,
    Offset position,
    FlowElement element,
  )? onGoupPlusPressed;

  final void Function(
    BuildContext context,
    Offset position,
    FlowElement sourceElement,
    FlowElement destElement,
  )? onPlusNodePressed;

  final void Function(
    BuildContext context,
    Offset position,
    FlowElement destElement,
  )? onGroupColumnPlusNodePressed;

  /// callback for mouse right click event on an element
  final void Function(
    BuildContext context,
    Offset position,
    FlowElement element,
  )? onElementSecondaryTapped;

  /// callback for element long pressed
  final void Function(
    BuildContext context,
    Offset position,
    FlowElement element,
  )? onElementLongPressed;

  /// callback for right click long press event on an element
  final void Function(
    BuildContext context,
    Offset position,
    FlowElement element,
  )? onElementSecondaryLongTapped;

  /// callback for onclick event of pivot
  final void Function(BuildContext context, Pivot pivot)? onPivotPressed;

  /// callback for secondary press event of pivot
  final void Function(BuildContext context, Pivot pivot)?
      onPivotSecondaryPressed;

  /// callback for handler pressed
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerPressed;

  /// callback for handler right click event
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerSecondaryTapped;

  /// callback for handler right click long press event
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerSecondaryLongTapped;

  /// callback for handler long pressed
  final void Function(
    BuildContext context,
    Offset position,
    Handler handler,
    FlowElement element,
  )? onHandlerLongPressed;

  /// callback when adding a new connection
  final ConnectionListener? onNewConnection;

  /// main dashboard to use
  final Dashboard dashboard;

  /// Trigger for the scale change
  final void Function(double scale)? onScaleUpdate;

  @override
  State<FlowChart> createState() => _FlowChartState();
}

class _FlowChartState extends State<FlowChart> {
  @override
  void initState() {
    super.initState();
    widget.dashboard.addListener(_elementChanged);
    if (widget.onScaleUpdate != null) {
      widget.dashboard.gridBackgroundParams.addOnScaleUpdateListener(
        widget.onScaleUpdate!,
      );
    }
    if (widget.onNewConnection != null) {
      widget.dashboard.addConnectionListener(widget.onNewConnection!);
    }
  }

  @override
  void dispose() {
    widget.dashboard.removeListener(_elementChanged);
    if (widget.onScaleUpdate != null) {
      widget.dashboard.gridBackgroundParams.removeOnScaleUpdateListener(
        widget.onScaleUpdate!,
      );
    }
    super.dispose();
  }

  void _elementChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    /// get dashboard position after first frame is drawn
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        final object = context.findRenderObject() as RenderBox?;
        if (object != null) {
          // 获取 RenderBox 对象的平移变换，即其相对于屏幕的位置
          final translation = object.getTransformTo(null).getTranslation();
          final size = object.semanticBounds.size;
          final position = Offset(translation.x, translation.y);
          widget.dashboard.setDashboardSize(size);

          if (widget.dashboard.position.dx != position.dx) {
            // 当缩放过大时也会出发，暂时取消
            // var offsetDx = position.dx - widget.dashboard.position.dx;
            // if (offsetDx.abs() >= 0) {
            //   var moveElementOffset = Offset(offsetDx / 2, 0);
            //   widget.dashboard.moveAllElements(moveElementOffset);
            // }
            widget.dashboard.setDashboardPosition(position);
            setState(() {});
          }
        }
      }
    });

    // disabling default browser context menu on web
    if (kIsWeb) BrowserContextMenu.disableContextMenu();

    final gridKey = GlobalKey();
    var tapDownPos = Offset.zero;
    var secondaryTapDownPos = Offset.zero;

    List<DrawGroupColumnPlus> drawGroupLayoutPlusElement() {
      print("drawGroupLayoutPlusElement-======>");
      final dashboardElements = widget.dashboard.elements;
      List<DrawGroupColumnPlus> drawGroupColumnPlus = [];

      for (int i = 0; i < dashboardElements.length; i++) {
        final _element = widget.dashboard.elements[i];
        if (_element.taskType == TaskType.group) {
          final childElements =
              dashboardElements.where((el) => el.parentId == _element.id);
          if (childElements.isNotEmpty) {
            final groupColumnLayoutData = widget.dashboard
                .getGroupColumnLayoutData(childElements.toList());
            // 获取每一列的最后一个元素
            for (var columnElements in groupColumnLayoutData) {
              drawGroupColumnPlus.add(DrawGroupColumnPlus(
                  dashboard: widget.dashboard,
                  key: UniqueKey(),
                  srcElement: columnElements.last,
                  onGroupColumnPlusNodePressed: (context, position) {
                    if (widget.onGroupColumnPlusNodePressed != null) {
                      widget.onGroupColumnPlusNodePressed!(
                          context, position, columnElements.last);
                    }
                  }));
            }
          }
        }
      }

      return drawGroupColumnPlus;
    }

    return ClipRect(
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 绘制背景网格
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (details) {
                  tapDownPos = details.localPosition;
                },
                onSecondaryTapDown: (details) {
                  secondaryTapDownPos = details.localPosition;
                },
                onTap: widget.onDashboardTapped == null
                    ? null
                    : () => widget.onDashboardTapped!(
                          gridKey.currentContext!,
                          tapDownPos,
                        ),
                onLongPress: widget.onDashboardLongTapped == null
                    ? null
                    : () => widget.onDashboardLongTapped!(
                          gridKey.currentContext!,
                          tapDownPos,
                        ),
                onSecondaryTap: () {
                  widget.onDashboardSecondaryTapped?.call(
                    gridKey.currentContext!,
                    secondaryTapDownPos,
                  );
                },
                onSecondaryLongPress: () {
                  widget.onDashboardSecondaryLongTapped?.call(
                    gridKey.currentContext!,
                    secondaryTapDownPos,
                  );
                },
                onScaleUpdate: (details) {
                  // 缩放画布
                  if (details.scale != 1) {
                    final factor =
                        details.scale + widget.dashboard.oldScaleUpdateDelta;
                    widget.dashboard.setZoomFactor(
                      factor,
                      focalPoint: details.focalPoint,
                    );
                    widget.dashboard.setDashboardScaling(true);
                  }
                  // 拖动画布
                  /// 设置网格相对位置
                  widget.dashboard.setDashboardPosition(
                    widget.dashboard.position + details.focalPointDelta,
                  );

                  /// 设置节点的位置
                  widget.dashboard
                      .moveAllElements(details.focalPointDelta, notify: false);
                  widget.dashboard.gridBackgroundParams.offset =
                      details.focalPointDelta;
                  setState(() {});
                },
                onScaleEnd: (details) {
                  widget.dashboard
                      .setOldScaleUpdateDelta(widget.dashboard.zoomFactor - 1);
                  widget.dashboard.setDashboardScaling(false);
                },
                child: GridBackground(
                  key: gridKey,
                  params: widget.dashboard.gridBackgroundParams,
                ),
              ),
            ),
            // TODO: 优化渲染逻辑：不需要重新遍历那么多次
            // 绘制 elements
            for (int i = 0; i < widget.dashboard.elements.length; i++)
              ElementWidget(
                key: UniqueKey(),
                dashboard: widget.dashboard,
                element: widget.dashboard.elements.elementAt(i),
                onElementPressed: (context, position) {
                  if (widget.onElementPressed != null) {
                    widget.onElementPressed!(
                      context,
                      position,
                      widget.dashboard.elements.elementAt(i),
                    );
                  }
                },
                onElementOptionsPressed: (context, element) {
                  if (widget.onElementOptionsPressed != null) {
                    widget.onElementOptionsPressed!(
                      context,
                      element,
                    );
                  }
                },
                onGoupPlusPressed: (context, position) {
                  if (widget.onGoupPlusPressed != null) {
                    widget.onGoupPlusPressed!(
                      context,
                      position,
                      widget.dashboard.elements.elementAt(i),
                    );
                  }
                },
                onElementSecondaryTapped: widget.onElementSecondaryTapped ==
                        null
                    ? null
                    : (context, position) => widget.onElementSecondaryTapped!(
                          context,
                          position,
                          widget.dashboard.elements.elementAt(i),
                        ),
                onElementLongPressed: widget.onElementLongPressed == null
                    ? null
                    : (context, position) => widget.onElementLongPressed!(
                          context,
                          position,
                          widget.dashboard.elements.elementAt(i),
                        ),
                onElementSecondaryLongTapped:
                    widget.onElementSecondaryLongTapped == null
                        ? null
                        : (context, position) =>
                            widget.onElementSecondaryLongTapped!(
                              context,
                              position,
                              widget.dashboard.elements.elementAt(i),
                            ),
                onHandlerPressed: widget.onHandlerPressed == null
                    ? null
                    : (context, position, handler, element) => widget
                        .onHandlerPressed!(context, position, handler, element),
                onHandlerSecondaryTapped:
                    widget.onHandlerSecondaryTapped == null
                        ? null
                        : (context, position, handler, element) =>
                            widget.onHandlerSecondaryTapped!(
                              context,
                              position,
                              handler,
                              element,
                            ),
                onHandlerLongPressed: widget.onHandlerLongPressed == null
                    ? null
                    : (context, position, handler, element) =>
                        widget.onHandlerLongPressed!(
                          context,
                          position,
                          handler,
                          element,
                        ),
                onHandlerSecondaryLongTapped:
                    widget.onHandlerSecondaryLongTapped == null
                        ? null
                        : (context, position, handler, element) =>
                            widget.onHandlerSecondaryLongTapped!(
                              context,
                              position,
                              handler,
                              element,
                            ),
              ),
            // 绘制连线
            for (int i = 0; i < widget.dashboard.elements.length; i++)
              for (int n = 0; n < widget.dashboard.elements[i].next.length; n++)
                DrawArrow(
                  dashboard: widget.dashboard,
                  arrowParams: widget.dashboard.elements[i].next[n].arrowParams,
                  pivots: widget.dashboard.elements[i].next[n].pivots,
                  key: UniqueKey(),
                  srcElement: widget.dashboard.elements[i],
                  destElement: widget
                      .dashboard.elements[widget.dashboard.findElementIndexById(
                    widget.dashboard.elements[i].next[n].destElementId,
                  )],
                ),
            // 绘制连线之间的加号
            for (int i = 0; i < widget.dashboard.elements.length; i++)
              for (int n = 0; n < widget.dashboard.elements[i].next.length; n++)
                DrawPlus(
                    dashboard: widget.dashboard,
                    arrowParams:
                        widget.dashboard.elements[i].next[n].arrowParams,
                    pivots: widget.dashboard.elements[i].next[n].pivots,
                    key: UniqueKey(),
                    srcElement: widget.dashboard.elements[i],
                    destElement: widget.dashboard
                        .elements[widget.dashboard.findElementIndexById(
                      widget.dashboard.elements[i].next[n].destElementId,
                    )],
                    onPlusNodePressed: (context, position) {
                      if (widget.onPlusNodePressed != null) {
                        widget.onPlusNodePressed!(
                            context,
                            position,
                            widget.dashboard.elements[i],
                            widget.dashboard
                                .elements[widget.dashboard.findElementIndexById(
                              widget
                                  .dashboard.elements[i].next[n].destElementId,
                            )]);
                      }
                    }),
            ...drawGroupLayoutPlusElement(),
            // 绘制线段中转的点
            for (int i = 0; i < widget.dashboard.elements.length; i++)
              for (int n = 0; n < widget.dashboard.elements[i].next.length; n++)
                if (widget.dashboard.elements[i].next[n].arrowParams.style ==
                    ArrowStyle.segmented)
                  for (int j = 0;
                      j < widget.dashboard.elements[i].next[n].pivots.length;
                      j++)
                    SegmentHandler(
                      key: UniqueKey(),
                      pivot: widget.dashboard.elements[i].next[n].pivots[j],
                      dashboard: widget.dashboard,
                      onPivotPressed: widget.onPivotPressed,
                      onPivotSecondaryPressed: widget.onPivotSecondaryPressed,
                    ),
            // 绘制用户正在连接时的预览线
            DrawingArrowWidget(
                style: widget.dashboard.defaultArrowStyle,
                dashboard: widget.dashboard),
          ],
        ),
      ),
    );
  }
}

/// Widget to draw interactive connection when the user tap on handlers
class DrawingArrowWidget extends StatefulWidget {
  ///
  const DrawingArrowWidget(
      {required this.style, required this.dashboard, super.key});

  ///
  final ArrowStyle style;
  final Dashboard dashboard;

  @override
  State<DrawingArrowWidget> createState() => _DrawingArrowWidgetState();
}

class _DrawingArrowWidgetState extends State<DrawingArrowWidget> {
  @override
  void initState() {
    super.initState();
    DrawingArrow.instance.addListener(_arrowChanged);
  }

  @override
  void dispose() {
    DrawingArrow.instance.removeListener(_arrowChanged);
    super.dispose();
  }

  void _arrowChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final params = DrawingArrow.instance.params;
    if (DrawingArrow.instance.isZero()) return const SizedBox.shrink();
    return CustomPaint(
      painter: ArrowPainter(
        params: params,
        from: DrawingArrow.instance.from,
        to: DrawingArrow.instance.to,
      ),
    );
  }
}
