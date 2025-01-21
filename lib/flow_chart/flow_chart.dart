import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easy_flow/flow_chart/ui/draw_group_column_plus.dart';
import 'package:flutter_easy_flow/flow_chart/ui/draw_plus.dart';
import 'package:flutter_easy_flow/flow_chart/ui/element_widget.dart';

import './dashboard.dart';
import './elements/flow_element.dart';
import './ui/draw_arrow.dart';
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
  bool scaling = false;
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
          final translation = object.getTransformTo(null).getTranslation();
          final size = object.semanticBounds.size;
          final position = Offset(translation.x, translation.y);

          widget.dashboard.setDashboardSize(size);
          widget.dashboard.setDashboardPosition(position);
        }
      }
    });

    // disabling default browser context menu on web
    if (kIsWeb) BrowserContextMenu.disableContextMenu();

    final gridKey = GlobalKey();
    var tapDownPos = Offset.zero;
    var secondaryTapDownPos = Offset.zero;

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
                    }
                    // 拖动画布
                    /// 设置网格相对位置
                    // widget.dashboard.setDashboardPosition(
                    //   widget.dashboard.position + details.focalPointDelta,
                    // );

                    /// 设置节点的位置
                    widget.dashboard.moveAllElements(details.focalPointDelta);

                    widget.dashboard.gridBackgroundParams.offset =
                        details.focalPointDelta;
                    setState(() {
                      scaling = true;
                    });
                  },
                  onScaleEnd: (details) {
                    widget.dashboard.setOldScaleUpdateDelta(
                        widget.dashboard.zoomFactor - 1);
                    setState(() {
                      scaling = false;
                    });
                  },
                  child: GridBackground(
                    key: gridKey,
                    params: widget.dashboard.gridBackgroundParams,
                  ),
                ),
              ),
              for (int i = 0; i < widget.dashboard.elements.length; i++)
                // 绘制 elements
                ElementWidget(
                  key: UniqueKey(),
                  dashboard: widget.dashboard,
                  element: widget.dashboard.elements[i],
                  onElementPressed: (context, position) {
                    if (widget.onElementPressed != null) {
                      widget.onElementPressed!(
                        context,
                        position,
                        widget.dashboard.elements[i],
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
                        widget.dashboard.elements[i],
                      );
                    }
                  },
                  onElementSecondaryTapped: widget.onElementSecondaryTapped ==
                          null
                      ? null
                      : (context, position) => widget.onElementSecondaryTapped!(
                            context,
                            position,
                            widget.dashboard.elements[i],
                          ),
                  onElementLongPressed: widget.onElementLongPressed == null
                      ? null
                      : (context, position) => widget.onElementLongPressed!(
                            context,
                            position,
                            widget.dashboard.elements[i],
                          ),
                  onElementSecondaryLongTapped:
                      widget.onElementSecondaryLongTapped == null
                          ? null
                          : (context, position) =>
                              widget.onElementSecondaryLongTapped!(
                                context,
                                position,
                                widget.dashboard.elements[i],
                              ),
                  onHandlerPressed: widget.onHandlerPressed == null
                      ? null
                      : (context, position, handler, element) =>
                          widget.onHandlerPressed!(
                              context, position, handler, element),
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
              // 合并遍历
              for (int i = 0; i < widget.dashboard.elements.length; i++) ...[
                for (int n = 0;
                    n < widget.dashboard.elements[i].next.length;
                    n++) ...[
                  // 绘制连线
                  DrawArrow(
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
                    scaling: scaling,
                  ),
                  // 绘制连线之间的加号
                  if (!scaling)
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
                                widget.dashboard.elements[
                                    widget.dashboard.findElementIndexById(
                                  widget.dashboard.elements[i].next[n]
                                      .destElementId,
                                )]);
                          }
                        }),
                ],
              ],
              // 绘制组节点每一列最下面的加号
              if (!scaling)
                for (var groupLayoutData
                    in widget.dashboard.allGroupsLayoutData.values)
                  for (var columnElements in groupLayoutData.columnsLayoutData)
                    DrawGroupColumnPlus(
                        dashboard: widget.dashboard,
                        key: UniqueKey(),
                        srcElement: columnElements.last,
                        onGroupColumnPlusNodePressed: (context, position) {
                          if (widget.onGroupColumnPlusNodePressed != null) {
                            widget.onGroupColumnPlusNodePressed!(
                                context, position, columnElements.last);
                          }
                        }),
              // 绘制用户正在连接时的预览线
              DrawingArrowWidget(
                  style: widget.dashboard.defaultArrowStyle,
                  dashboard: widget.dashboard),
            ],
          )),
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
