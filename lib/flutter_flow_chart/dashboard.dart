// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:diagram_flow/flutter_flow_chart/ui/draw_arrow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:diagram_flow/flutter_flow_chart/flutter_flow_chart.dart';
import './ui/segment_handler.dart';
import 'package:uuid/uuid.dart';

final double groupElementSpacing = 20;

class RectangleBounds {
  final double width;
  final double height;
  final double maxX;
  final double minX;
  final double minY;
  final double maxY;
  final Size size;
  final Offset center;
  RectangleBounds({
    required this.width,
    required this.height,
    required this.maxX,
    required this.minX,
    required this.minY,
    required this.maxY,
    required this.center,
    required this.size
  });

  @override
  String toString() {
    return 'RectangleBounds(width: $width, height: $height, maxX: $maxX, minX: $minX, minY: $minY, maxY: $maxY,size:${size})';
  }
}
/// Listener definition for a new connection
typedef ConnectionListener = void Function(
  FlowElement srcElement,
  FlowElement destElement,
);

/// Class to store all the scene elements.
/// This also acts as the controller to the flow_chart widget
/// It notifies changes to [FlowChart]
class Dashboard extends ChangeNotifier {
  ///
  Dashboard({
    Offset? handlerFeedbackOffset,
    this.blockDefaultZoomGestures = false,
    this.minimumZoomFactor = 0.25,
    this.maximumZoomFactor = 1.8,
    this.defaultArrowStyle = ArrowStyle.rectangular,
  })  : elements = [],
        _dashboardPosition = Offset.zero,
        dashboardSize = Size.zero,
        gridBackgroundParams = GridBackgroundParams(
          // 画布背景点的颜色
          gridColor: const Color(0xFFABABAB),
          // 画布背景颜色
          backgroundColor: const Color(0xFFf8f8f8),
        ) {
    // This is a workaround to set the handlerFeedbackOffset
    // to improve the user experience on devices with touch screens
    // This will prevent the handler being covered by user's finger
    if (handlerFeedbackOffset != null) {
      this.handlerFeedbackOffset = handlerFeedbackOffset;
    } else {
      if (kIsWeb) {
        this.handlerFeedbackOffset = Offset.zero;
      } else {
        if (Platform.isIOS || Platform.isAndroid) {
          this.handlerFeedbackOffset = const Offset(0, -50);
        } else {
          this.handlerFeedbackOffset = Offset.zero;
        }
      }
    }
  }

  ///
  factory Dashboard.fromMap(Map<String, dynamic> map) {
    final d = Dashboard(
      defaultArrowStyle: ArrowStyle.values[map['arrowStyle'] as int? ?? 0],
    )
      ..elements = List<FlowElement>.from(
        (map['elements'] as List<dynamic>).map<FlowElement>(
          (x) => FlowElement.fromMap(x as Map<String, dynamic>),
        ),
      )
      ..dashboardSize = Size(
        map['dashboardSizeWidth'] as double? ?? 0,
        map['dashboardSizeHeight'] as double? ?? 0,
      );

    if (map['gridBackgroundParams'] != null) {
      d.gridBackgroundParams = GridBackgroundParams.fromMap(
        map['gridBackgroundParams'] as Map<String, dynamic>,
      );
    }
    d
      ..blockDefaultZoomGestures =
          (map['blockDefaultZoomGestures'] as bool? ?? false)
      ..minimumZoomFactor = map['minimumZoomFactor'] as double? ?? 0.25
      ..maximumZoomFactor = map['maximumZoomFactor'] as double? ?? 1.8;

    return d;
  }

  ///
  factory Dashboard.fromJson(String source) =>
      Dashboard.fromMap(json.decode(source) as Map<String, dynamic>);

  /// The current elements in the dashboard
  List<FlowElement> elements;

  String selectedElement = '';

  Offset _dashboardPosition;

  // 节点间默认距离
  int defaultNodeDistance = 65;

  /// Dashboard size
  Size dashboardSize;

  /// The default style for the new created arrow
  final ArrowStyle defaultArrowStyle;

  /// [handlerFeedbackOffset] sets an offset for the handler when user
  /// is dragging it.
  /// This can be used to prevent the handler being covered by user's
  /// finger on touch screens.
  late Offset handlerFeedbackOffset;

  /// Background parameters.
  GridBackgroundParams gridBackgroundParams;

  ///
  bool blockDefaultZoomGestures;

  /// minimum zoom factor allowed
  /// default is 0.25
  /// setting it to 1 will prevent zooming out
  /// setting it to 0 will remove the limit
  double minimumZoomFactor;
  double maximumZoomFactor;
  bool allElementsDraggable = true;

  final List<ConnectionListener> _connectionListeners = [];

  /// add listener called when a new connection is created
  void addConnectionListener(ConnectionListener listener) {
    _connectionListeners.add(listener);
  }

  /// remove connection listener
  void removeConnectionListener(ConnectionListener listener) {
    _connectionListeners.remove(listener);
  }

  /// set grid background parameters
  void setGridBackgroundParams(GridBackgroundParams params) {
    gridBackgroundParams = params;
    notifyListeners();
  }

  /// set the feedback offset to help on mobile device to see the
  /// end of arrow and not hiding behind the finger when moving it
  void setHandlerFeedbackOffset(Offset offset) {
    handlerFeedbackOffset = offset;
  }

  /// set [draggable] element property
  void setElementDraggable(
    FlowElement element,
    bool draggable, {
    bool notify = true,
  }) {
    element.isDraggable = draggable;
    if (notify) notifyListeners();
  }
  void triggerllElementDraggable() {
    allElementsDraggable = !allElementsDraggable;
    for (var element in elements) {
      element.isDraggable = allElementsDraggable;
    }
    if (allElementsDraggable) notifyListeners();
  }

  /// set [connectable] element property
  void setElementConnectable(
    FlowElement element,
    bool connectable, {
    bool notify = true,
  }) {
    element.isConnectable = connectable;
    if (notify) notifyListeners();
  }

  /// set [resizable] element property
  void setElementResizable(
    FlowElement element,
    bool resizable, {
    bool notify = true,
  }) {
    element.isResizable = resizable;
    if (notify) notifyListeners();
  }

  void setSelectedElement(String elementId){
    selectedElement = elementId;
    notifyListeners();
  }
  /// add a [FlowElement] to the dashboard
  void addElement(FlowElement element, {bool notify = true, int? position}) {
    if (element.id.isEmpty) {
      element.id = const Uuid().v4();
    }
    //放大或缩小会导致节点偏移
    element.position = Offset(
          element.position.dx + ((element.size.width+ (element.handlerSize)) * (1 - gridBackgroundParams.scale))/2,
          element.position.dy);

    element.setScale(1, gridBackgroundParams.scale);

    elements.insert(position ?? elements.length, element);
    if (notify) {
      notifyListeners();
    }
  }
  // TODO : 优化缩放
  void setFullView(){
    if(elements.length<1){
      return;
    }
    RectangleBounds boundingBoxSize =calculateBoundingBox(elements);
    print("boundingBoxSize.center====>${boundingBoxSize.center}");

    // 将所有元素移动至画布中心
    final center = Offset(dashboardSize.width / 2, dashboardSize.height / 2);
    final currentDeviation = boundingBoxSize.center - center;
    double newZoomFactor = calculateScale(boundingBoxSize.size, dashboardSize) +  zoomFactor - 1;

    setDashboardPosition(position  + currentDeviation);
    gridBackgroundParams.offset = center;
    for (final element in elements) {
      element.position -= currentDeviation;
      for (final next in element.next) {
        for (final pivot in next.pivots) {
          pivot.pivot -= currentDeviation;
        }
      }
    }
    // 开始放大/缩小
    setZoomFactor(newZoomFactor,focalPoint: center);
    notifyListeners();
  }

  RectangleBounds calculateBoundingBox(List<FlowElement> elements) {
    // 初始化边界的最小值和最大值
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    double paddingOffset = 50;
    double handleSize = 10;
    for (var element in elements) {
      // 获取节点的边界
      double elementLeft = element.position.dx - paddingOffset;
      double elementTop = element.position.dy  - paddingOffset;
      double elementRight = element.position.dx + element.size.width + paddingOffset;
      double elementBottom = element.position.dy + element.size.height + paddingOffset;

      // 更新边界值
      minX = min(minX, elementLeft);
      minY = min(minY, elementTop);
      maxX = max(maxX, elementRight);
      maxY = max(maxY, elementBottom);

    }
    double width = maxX - minX + (handleSize*2) ;
    double height = maxY - minY + (handleSize*2) ;
    return RectangleBounds(
      width: width,
      height: height,
      minX: minX,
      minY: minY,
      maxX: maxX,
      maxY: maxY,
      center: Offset(minX + (width) / 2, minY + (height) / 2),
      size: Size(maxX - minX, maxY - minY),
    );
  }

  double calculateScale(Size boundingBox, Size dashboardSize) {
    double boundingWidth = boundingBox.width;
    double boundingHeight = boundingBox.height;

    double scaleX = dashboardSize.width / boundingWidth;
    double scaleY = dashboardSize.height / boundingHeight;

    // 保持比例一致，选择较小的缩放值
    return scaleX < scaleY ? scaleX : scaleY;
  }

  void addElementByPlus(FlowElement sourceElement, FlowElement orderElement) {
    List<ConnectionParams> nextElementsConnectionParams = sourceElement.next;
    List<String> removedConnectDestElementIds = [];
    if (nextElementsConnectionParams.isNotEmpty) {
      // 移除当前节点下现有的所有连接并记录其目标节点id
      for (var params in nextElementsConnectionParams.toList()) {
        removeConnectionByElements(
          sourceElement,
          findElementById(params.destElementId) as FlowElement,
          notify: false,
        );
        removedConnectDestElementIds.add(params.destElementId);
      }
      // 调整所有后续节点的垂直位置
      for (var element in elements) {
        if (element.position.dy >= orderElement.position.dy - defaultNodeDistance * zoomFactor) {
          element.position = Offset(
            element.position.dx,
            element.position.dy + (orderElement.size.height + orderElement.handlerSize +  defaultNodeDistance ) * zoomFactor,
          );
        }
      }
      // 恢复之前移除的连接，将orderElement连接到destElementId节点
      for (final destElementId in removedConnectDestElementIds) {
        addNextById(
          orderElement,
          destElementId,
          DrawingArrow.instance.params.copyWith(
            style: ArrowStyle.rectangular,
            startArrowPosition: Alignment.bottomCenter,
            endArrowPosition: Alignment.topCenter,
          ),
        );
      }

      // 新增节点
      addElement(orderElement);
      // 连接新节点
      addNextById(
        sourceElement,
        orderElement.id,
        DrawingArrow.instance.params.copyWith(
          style: ArrowStyle.rectangular,
          startArrowPosition: Alignment.bottomCenter,
          endArrowPosition: Alignment.topCenter,
        ),
      );
      // 选中当前节点
      setSelectedElement(orderElement.id);
    }

    // 添加 orderElement 节点及其与 plus 节点的连接
    // _addElementWithConnection(plusElement, orderElement);

    // 如果是终止任务节点，直接返回
    // if (orderElement.taskType == TaskType.end) return;

    // setFullView();
  }

  // 组节点添加新节点
  void addElementByGroupPlus(FlowElement groupElement, FlowElement orderElement) {
    // 计算group的padding
    final currentGroupElementSpacing = groupElementSpacing*zoomFactor;
    // 找到属于groupElement的所有子Element
    List<FlowElement> subElements = elements.where((ele) => ele.parentId == groupElement.id).toList();
    if(subElements.isNotEmpty){
      final offsetWidth = (orderElement.size.width + currentGroupElementSpacing);
      // 更新组节点的宽度
      groupElement.size = Size(groupElement.size.width+offsetWidth, groupElement.size.height);
      // 更新组节点及其子节点的位置
      groupElement.position = Offset(groupElement.position.dx - offsetWidth/2, groupElement.position.dy);
      for(final element in subElements){
        element.changePosition(Offset(element.position.dx - offsetWidth/2, element.position.dy));
      }
    }
      // 新增节点
      final elementDx = groupElement.position.dx + currentGroupElementSpacing + subElements.length * (orderElement.size.width + currentGroupElementSpacing);
      final elementDy = groupElement.position.dy + (groupElement.size.height - orderElement.size.height)/2;
      orderElement.position = Offset(elementDx, elementDy);
      addElement(orderElement);
  }

  void addElementConnection(FlowElement fromElement, FlowElement toElement) {
    addNextById(
      fromElement,
      toElement.id,
      DrawingArrow.instance.params.copyWith(
        style: ArrowStyle.rectangular,
        startArrowPosition: Alignment.bottomCenter,
        endArrowPosition: Alignment.topCenter,
      ),
    );
  }

  FlowElement? findSourceElementByDestElement(FlowElement destElement){
    var sourceElement;
    for (final element in elements) {
      for (final conn in element.next) {
          if(conn.destElementId == destElement.id){
            sourceElement = element;
          }
      }
    }
    return sourceElement;
  }
  /// Enable editing mode for an element
  void setElementEditingText(
    FlowElement element,
    bool editing, {
    bool notify = true,
  }) {
    element.isEditingText = editing;
    if (notify) notifyListeners();
  }

  /// Set a new [style] to the arrow staring from [src] pointing to [dest].
  /// If [notify] is true the dasboard is refreshed.
  /// The [tension] parameter is used when [style] is [ArrowStyle.segmented] to
  /// set the curve strength on pivot points. 0 means no curve.
  void setArrowStyle(
    FlowElement src,
    FlowElement dest,
    ArrowStyle style, {
    bool notify = true,
    double tension = 1.0,
  }) {
    for (final conn in src.next) {
      if (conn.destElementId == dest.id) {
        conn.arrowParams.style = style;
        conn.arrowParams.tension = tension;
        break;
      }
    }
    if (notify) {
      notifyListeners();
    }
  }

  /// Set a new [style] to the arrow staring from the [handler] of [src]
  /// element.
  /// If [notify] is true the dasboard is refreshed.
  /// The [tension] parameter is used when [style] is [ArrowStyle.segmented] to
  /// set the curve strength on pivot points. 0 means no curve.
  void setArrowStyleByHandler(
    FlowElement src,
    Handler handler,
    ArrowStyle style, {
    bool notify = true,
    double tension = 1.0,
  }) {
    // find arrows that start from [src] inside [handler]
    for (final conn in src.next) {
      if (conn.arrowParams.startArrowPosition == handler.toAlignment()) {
        conn.arrowParams.tension = tension;
        conn.arrowParams.style = style;
      }
    }
    // find arrow that ends to this [src] inside [handler]
    for (final element in elements) {
      for (final conn in element.next) {
        if (conn.arrowParams.endArrowPosition == handler.toAlignment() &&
            conn.destElementId == src.id) {
          conn.arrowParams.tension = tension;
          conn.arrowParams.style = style;
        }
      }
    }

    if (notify) {
      notifyListeners();
    }
  }

  /// find the element by its [id]
  int findElementIndexById(String id) {
    return elements.indexWhere((element) => element.id == id);
  }

  /// find the element by its [id] for convenience
  /// return null if not found
  FlowElement? findElementById(String id) {
    try {
      return elements.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  /// find the connection from [srcElement] to [destElement]
  /// return null if not found.
  /// In case of multiple connections, first connection is returned.
  ConnectionParams? findConnectionByElements(
    FlowElement srcElement,
    FlowElement destElement,
  ) {
    try {
      return srcElement.next
          .firstWhere((element) => element.destElementId == destElement.id);
    } catch (e) {
      return null;
    }
  }

  /// find the source element of the [dest] element.
  FlowElement? findSrcElementByDestElement(FlowElement dest) {
    for (final element in elements) {
      for (final connection in element.next) {
        if (connection.destElementId == dest.id) {
          return element;
        }
      }
    }

    return null;
  }

  /// remove all elements
  void removeAllElements({bool notify = true}) {
    elements.clear();
    if (notify) notifyListeners();
  }

  /// remove the [handler] connection of [element]
  void removeElementConnection(
    FlowElement element,
    Handler handler, {
    bool notify = true,
  }) {
    Alignment alignment;
    switch (handler) {
      case Handler.topCenter:
        alignment = Alignment.topCenter;
      case Handler.bottomCenter:
        alignment = Alignment.bottomCenter;
      case Handler.leftCenter:
        alignment = Alignment.centerLeft;
      case Handler.rightCenter:
        alignment = Alignment.centerRight;
    }

    var isSrc = false;
    for (final connection in element.next) {
      if (connection.arrowParams.startArrowPosition == alignment) {
        isSrc = true;
        break;
      }
    }

    if (isSrc) {
      element.next.removeWhere(
        (handlerParam) =>
            handlerParam.arrowParams.startArrowPosition == alignment,
      );
    } else {
      final src = findSrcElementByDestElement(element);
      if (src != null) {
        src.next.removeWhere(
          (handlerParam) => handlerParam.destElementId == element.id,
        );
      }
    }

    if (notify) notifyListeners();
  }

  /// 解除一个元素连接
  /// [handler] 是当前处于连接状态的操作锚点
  /// [point] 是连接被解构的位置
  /// 如果 [point] 为 null，则会自动计算连接点
  void dissectElementConnection(
    FlowElement element,
    Handler handler, {
    Offset? point,
    bool notify = true,
  }) {
    Alignment alignment;
    switch (handler) {
      case Handler.topCenter:
        alignment = Alignment.topCenter;
      case Handler.bottomCenter:
        alignment = Alignment.bottomCenter;
      case Handler.leftCenter:
        alignment = Alignment.centerLeft;
      case Handler.rightCenter:
        alignment = Alignment.centerRight;
    }

    ConnectionParams? conn;

    var newPoint = Offset.zero;
    if (point == null) {
      try {
        // assuming element is the src
        conn = element.next.firstWhere(
          (handlerParam) =>
              handlerParam.arrowParams.startArrowPosition == alignment,
        );
        if (conn.arrowParams.style != ArrowStyle.segmented) return;

        final dest = findElementById(conn.destElementId);
        newPoint = (dest!
                    .getHandlerPosition(conn.arrowParams.endArrowPosition) +
                element
                    .getHandlerPosition(conn.arrowParams.startArrowPosition)) /
            2;
      } catch (e) {
        // apparently is not
        final src = findSrcElementByDestElement(element)!;
        conn = src.next.firstWhere(
          (handlerParam) => handlerParam.destElementId == element.id,
        );
        if (conn.arrowParams.style != ArrowStyle.segmented) return;

        newPoint = (element
                    .getHandlerPosition(conn.arrowParams.endArrowPosition) +
                src.getHandlerPosition(conn.arrowParams.startArrowPosition)) /
            2;
      }
    } else {
      newPoint = point;
    }

    conn?.dissect(newPoint);

    if (notify && conn != null) {
      notifyListeners();
    }
  }

  /// remove the dissection of the connection
  void removeDissection(Pivot pivot, {bool notify = true}) {
    for (final element in elements) {
      for (final connection in element.next) {
        connection.pivots.removeWhere((item) => item == pivot);
      }
    }
    if (notify) notifyListeners();
  }

  /// remove the connection from [srcElement] to [destElement]
  void removeConnectionByElements(
    FlowElement srcElement,
    FlowElement destElement, {
    bool notify = true,
  }) {
    srcElement.next.removeWhere(
      (handlerParam) => handlerParam.destElementId == destElement.id,
    );
    if (notify) notifyListeners();
  }

  /// 移除 [element] 节点的所有连接
  void removeElementConnections(FlowElement element, {bool notify = true}) {
    element.next.clear();
    if (notify) notifyListeners();
  }

  /// 通过 节点[id] 移除节点
  void removeElementById(String id, {bool notify = true}) {
    late FlowElement removedElement;
    late FlowElement? sourceElement;

    // remove the element
    elements.removeWhere((element) {
      if(element.id == id){
        removedElement = element;
        sourceElement = findSrcElementByDestElement(element);
        return true;
      }else{
        return false;
      }
    });
    // 删除组节点需要删除所有其子节点
    if(removedElement.taskType == TaskType.group){
      elements.removeWhere((element) => element.parentId == removedElement.id);
    }
    // 移除当前节点所有的连接
    for (final e in elements) {
      e.next.removeWhere((handlerParams) {
        return id.contains(handlerParams.destElementId);
      });
    }
    // 从组节点中移除,需要更新组节点的大小
    if(removedElement.parentId != ""){
      List<FlowElement> subElements = elements.where((ele) => ele.parentId == removedElement.parentId).toList();
      final groupElement = findElementById(removedElement.parentId);
      final currentGroupElementSpacing = groupElementSpacing*zoomFactor;

      if(subElements.isNotEmpty && groupElement !=null){
        final offsetWidth = (removedElement.size.width + currentGroupElementSpacing);

        final groupElementSize = Size(groupElement.size.width - removedElement.size.width - currentGroupElementSpacing,groupElement.size.height);
      //  更新组节点大小
        groupElement.size = groupElementSize;
      //   更新组节点位置
        groupElement.position = Offset(groupElement.position.dx+offsetWidth/2,groupElement.position.dy );
        //  子节点重新排列
        for (var i = 0; i < subElements.length; i++) {
          final element = subElements[i];
          final elementDx = groupElement.position.dx + currentGroupElementSpacing + i * (element.size.width + currentGroupElementSpacing);
          element.changePosition(Offset(elementDx,element.position.dy));
        }
      }
    }
    // 如果有后续节点的布局需要更新
    if(removedElement.next.isNotEmpty){
      // 更新布局
      updateLayOutAfterDelElement(removedElement,sourceElement);
    }

    if (notify) notifyListeners();
  }

  updateLayOutAfterDelElement(FlowElement deletedElement,FlowElement? sourceElement){
    // 调整所有后续节点的垂直位置(将被删除的元素一下的所有元素向上移动)
    for (var element in elements) {
      if (element.position.dy >= deletedElement.position.dy - defaultNodeDistance * zoomFactor) {
        element.position = Offset(
          element.position.dx,
          element.position.dy - (deletedElement.size.height + deletedElement.handlerSize +  defaultNodeDistance ) * zoomFactor,
        );
      }
    }
    //  被删除节点的连接点
    // 抓到被删除节点的上一个节点
    List<ConnectionParams> deletedElementConnectionParams = deletedElement.next;
    List<String> removedConnectDestElementIds = [];
    if (deletedElementConnectionParams.isNotEmpty) {
      // 被移除节点下所有连接的目标节点id
      for (var params in deletedElementConnectionParams.toList()) {
        removedConnectDestElementIds.add(params.destElementId);
      }
    }
    // 恢复之前移除的连接，将orderElement连接到destElementId节点
    for (final destElementId in removedConnectDestElementIds) {
      if(sourceElement != null){
        addNextById(
          sourceElement,
          destElementId,
          DrawingArrow.instance.params.copyWith(
            style: ArrowStyle.rectangular,
            startArrowPosition: Alignment.bottomCenter,
            endArrowPosition: Alignment.topCenter,
          ),
        );
      }
    }
  }
  /// remove element
  /// return true if it has been removed
  bool removeElement(FlowElement element, {bool notify = true}) {
    // remove the element
    var found = false;
    final elementId = element.id;
    elements.removeWhere((e) {
      if (e.id == element.id) found = true;
      return e.id == element.id;
    });

    // remove all connections to the element
    for (final e in elements) {
      e.next.removeWhere(
        (handlerParams) => handlerParams.destElementId == elementId,
      );
    }
    if (notify) notifyListeners();
    return found;
  }

  /// [factor] 需要是一个非负值。
  /// 默认值为 1.
  /// 提供大于 1 的值将按照给定的倍率放大仪表板，反之则缩小。
  /// 负值将被忽略
  /// zoomFactor 不会低于 [minimumZoomFactor] 不大于 [minimumZoomFactor]。
  /// [focalPoint] 是缩放的中心点，
  /// 默认为仪表板的中心位置。
  void setZoomFactor(double factor, {Offset? focalPoint}) {
    if (gridBackgroundParams.scale == factor) {
      return;
    }
    if(factor < minimumZoomFactor){
      factor = minimumZoomFactor;
    }
    if (factor > maximumZoomFactor) {
      factor = maximumZoomFactor;
    }
    focalPoint ??= Offset(dashboardSize.width / 2, dashboardSize.height / 2);

    for (final element in elements) {
      // applying new zoom
      element
        ..position = (element.position - focalPoint) /
                gridBackgroundParams.scale *
                factor +
            focalPoint
        ..setScale(gridBackgroundParams.scale, factor);
      // draw_arrow 添加 setScale方法
      for (final conn in element.next) {
        for (final pivot in conn.pivots) {
          pivot.setScale(gridBackgroundParams.scale, focalPoint, factor);
        }
      }
    }
    gridBackgroundParams.setScale(factor, focalPoint);

    notifyListeners();
  }

  /// shorthand to get the current zoom factor
  double get zoomFactor {
    return gridBackgroundParams.scale;
  }

  // 需要知道图表组件的位置以计算拖放元素的偏移量
  void setDashboardPosition(Offset position) {
    _dashboardPosition = position;
  }

  /// Get the position.
  Offset get position => _dashboardPosition;

  /// needed to know the diagram widget size
  void setDashboardSize(Size size) {
    dashboardSize = size;
  }

  /// 从 [sourceElement] 创建一个箭头连接到
  /// ID 为 [destId] 的元素。
  /// [arrowParams] 是箭头参数的定义。
  void addNextById(
    FlowElement sourceElement,
    String destId,
    ArrowParams arrowParams, {
    bool notify = true,
  }) {
    print("=-=======>addNextById-=====>arrowParams:${arrowParams.toMap()}");
    var found = 0;
    arrowParams.setScale(gridBackgroundParams.scale);
    for (var i = 0; i < elements.length; i++) {
      if (elements[i].id == destId) {
        // if the [id] already exist, remove it and add this new connection
        sourceElement.next
            .removeWhere((element) => element.destElementId == destId);
        final conn = ConnectionParams(
          destElementId: elements[i].id,
          arrowParams: arrowParams,
          pivots: [],
        );
        sourceElement.next.add(conn);
        for (final listener in _connectionListeners) {
          listener(sourceElement, elements[i]);
        }

        found++;
      }
    }

    if (found == 0) {
      debugPrint('Element with $destId id not found!');
      return;
    }
    if (notify) {
      notifyListeners();
    }
  }

  //******************************* */
  /// manage load/save using json
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'elements': elements.map((x) => x.toMap()).toList(),
      'dashboardSizeWidth': dashboardSize.width,
      'dashboardSizeHeight': dashboardSize.height,
      'gridBackgroundParams': gridBackgroundParams.toMap(),
      'blockDefaultZoomGestures': blockDefaultZoomGestures,
      'minimumZoomFactor': minimumZoomFactor,
      'arrowStyle': defaultArrowStyle.index,
    };
  }

  ///
  String toJson() => json.encode(toMap());

  ///
  String prettyJson() {
    final spaces = ' ' * 2;
    final encoder = JsonEncoder.withIndent(spaces);
    return encoder.convert(toMap());
  }

  /// recenter the dashboard
  void recenter() {
    final center = Offset(dashboardSize.width / 2, dashboardSize.height / 2);
    gridBackgroundParams.offset = center;
    if (elements.isNotEmpty) {
      final currentDeviation = elements.first.position - center;
      for (final element in elements) {
        element.position -= currentDeviation;
        for (final next in element.next) {
          for (final pivot in next.pivots) {
            pivot.pivot -= currentDeviation;
          }
        }
      }
    }
    notifyListeners();
  }

  /// save the dashboard into [completeFilePath]
  void saveDashboard(String completeFilePath) {
    File(completeFilePath).writeAsStringSync(prettyJson(), flush: true);
  }

  /// clear the dashboard and load the new one from file [completeFilePath]
  void loadDashboard(String completeFilePath) {
    final f = File(completeFilePath);
    if (f.existsSync()) {
      final source = json.decode(f.readAsStringSync()) as Map<String, dynamic>;
      loadDashboardData(source);
    }
  }

  /// clear the dashboard and load the new one from [source] json
  void loadDashboardData(Map<String, dynamic> source) {
    elements.clear();

    gridBackgroundParams = GridBackgroundParams.fromMap(
      source['gridBackgroundParams'] as Map<String, dynamic>,
    );
    blockDefaultZoomGestures = source['blockDefaultZoomGestures'] as bool;
    minimumZoomFactor = source['minimumZoomFactor'] as double;
    maximumZoomFactor = source['maximumZoomFactor'] as double;
    dashboardSize = Size(
      source['dashboardSizeWidth'] as double,
      source['dashboardSizeHeight'] as double,
    );

    final loadedElements = List<FlowElement>.from(
      (source['elements'] as List<dynamic>).map<FlowElement>(
        (x) => FlowElement.fromMap(x as Map<String, dynamic>),
      ),
    );
    elements
      ..clear()
      ..addAll(loadedElements);

    recenter();
  }
}
