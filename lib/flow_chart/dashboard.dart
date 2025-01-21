// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import './flow_chart_library.dart';
import './ui/draw_arrow.dart';
import './ui/segment_handler.dart';

/// 组节点内子节点的间距
const double groupElementSpacing = 20;

/// 节点间默认距离
const int defaultNodeDistance = 50;

class GroupLayoutData {
  final String id;
  final List<List<FlowElement>> columnsLayoutData;
  final List<List<FlowElement>> rowsLayoutData;
  GroupLayoutData(
      {required this.id,
      required this.columnsLayoutData,
      required this.rowsLayoutData});
}

class RectangleBounds {
  final double width;
  final double height;
  final double maxX;
  final double minX;
  final double minY;
  final double maxY;
  final Size size;
  final Offset center;
  RectangleBounds(
      {required this.width,
      required this.height,
      required this.maxX,
      required this.minX,
      required this.minY,
      required this.maxY,
      required this.center,
      required this.size});

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
        _allGroupsLayoutData = {},
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

  Map<String, GroupLayoutData> _allGroupsLayoutData = {};
  Map<String, GroupLayoutData> get allGroupsLayoutData => _allGroupsLayoutData;

  String selectedElement = '';

  Offset _dashboardPosition;

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
  bool _allElementsDraggable = true;

  get allElementsDraggable => _allElementsDraggable;

  double _oldScaleUpdateDelta = 0;
  get oldScaleUpdateDelta => _oldScaleUpdateDelta;

  setOldScaleUpdateDelta(double value) {
    _oldScaleUpdateDelta = value;
  }

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
    _allElementsDraggable = !_allElementsDraggable;
    for (var element in elements) {
      element.isDraggable = _allElementsDraggable;
    }
    if (_allElementsDraggable) notifyListeners();
  }

  void setAllElementsDraggable(bool val) {
    _allElementsDraggable = val;
    for (var element in elements) {
      element.isDraggable = val;
    }
    notifyListeners();
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

  void setSelectedElement(String elementId) {
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
        element.position.dx +
            ((element.size.width + (element.handlerSize)) *
                    (1 - gridBackgroundParams.scale)) /
                2,
        element.position.dy);

    element.setScale(1, gridBackgroundParams.scale);

    elements.insert(position ?? elements.length, element);
    updateAllGroupsLayoutData();
    if (notify) {
      notifyListeners();
    }
  }

  void updateAllGroupsLayoutData() {
    Future.microtask(() {
      elements
          .where((element) => element.taskType == TaskType.group)
          .map((groupElement) {
        final childElements = elements
            .where((element) => element.parentId == groupElement.id)
            .toList();
        final groupLayoutData = GroupLayoutData(
          id: groupElement.id,
          columnsLayoutData: getGroupColumnLayoutData(groupElement.id),
          rowsLayoutData: getGroupRowLayoutData(childElements, groupElement.id),
        );
        _allGroupsLayoutData[groupElement.id] = groupLayoutData;
      }).toList();
      notifyListeners();
    });
  }

  // TODO : 优化缩放
  void setFullView() {
    if (elements.isEmpty) {
      return;
    }
    // 计算所有元素的包围区域
    RectangleBounds boundingBoxSize = calculateBoundingBox(elements);
    // 屏幕中心点
    final center = Offset(dashboardSize.width / 2, dashboardSize.height / 2) +
        _dashboardPosition;
    gridBackgroundParams.offset = center;
    // 区域偏移
    final currentDeviation = boundingBoxSize.center - center;
    double newZoomFactor = calculateScale(boundingBoxSize.size, dashboardSize) +
        _oldScaleUpdateDelta;
    for (final element in elements) {
      element.position -= currentDeviation;
      for (final next in element.next) {
        for (final pivot in next.pivots) {
          pivot.pivot -= currentDeviation;
        }
      }
    }
    // 开始放大/缩小
    setZoomFactor(newZoomFactor, focalPoint: center);
    setOldScaleUpdateDelta(zoomFactor - 1);
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
      double elementTop = element.position.dy - paddingOffset;
      double elementRight =
          element.position.dx + element.size.width + paddingOffset;
      double elementBottom =
          element.position.dy + element.size.height + paddingOffset;

      // 更新边界值
      minX = min(minX, elementLeft);
      minY = min(minY, elementTop);
      maxX = max(maxX, elementRight);
      maxY = max(maxY, elementBottom);
    }
    double width = maxX - minX + (handleSize * 2);
    double height = maxY - minY + (handleSize * 2);
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
    final sourceElementIndex = elements.indexOf(sourceElement);
    // 新增节点
    addElement(orderElement, position: sourceElementIndex + 1);
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
      final orderElementBottomHandlerPos =
          orderElement.getHandlerPosition(Alignment.bottomCenter);
      final sourceEleBottomHandlerPos =
          sourceElement.getHandlerPosition(Alignment.bottomCenter);
      final elementsDistant =
          orderElementBottomHandlerPos.dy - sourceEleBottomHandlerPos.dy;
      final orderElementIndex = elements.indexOf(orderElement);
      for (int i = 0; i < elements.length; i++) {
        final element = elements[i];
        String elementGroupId =
            element.taskType != TaskType.group ? element.parentId : "";
        int elementGroupIndex = elementGroupId == ''
            ? -1
            : elements
                .indexOf(elements.firstWhere((el) => el.id == elementGroupId));
        if (i > orderElementIndex &&
            (elementGroupId == ''
                ? true
                : elementGroupIndex > orderElementIndex)) {
          element.position = Offset(
            element.position.dx,
            element.position.dy + elementsDistant,
          );
        }
      }
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
      // 选中当前节点
      setSelectedElement(orderElement.id);
    }
  }

  // 通过组内 节点之间的 + 号新增
  void addElementByGroupColumnPlus(
      FlowElement sourceElement, FlowElement orderElement) {
    final groupElement = elements.firstWhere(
      (element) => element.id == sourceElement.parentId,
    );
    // 新增节点
    addElement(orderElement);
    final lastRowNum = groupElement.rowsElementIds.length;

    final sourceElementColumnIndex = groupElement.colsElementIds
        .indexWhere((elementIds) => elementIds.contains(sourceElement.id));
    final sourceElementRowIndex = groupElement.rowsElementIds
        .indexWhere((elementIds) => elementIds.contains(sourceElement.id));
    final columnNum = groupElement.colsElementIds.length;
    for (int i = 0; i < columnNum; i++) {
      if (i == sourceElementColumnIndex) {
        groupElement.colsElementIds[i]
            .insert(sourceElementRowIndex + 1, orderElement.id);
      } else {
        groupElement.colsElementIds[i].add("");
      }
    }
    groupElement.colsElementIds =
        cleanLastEmptyItems(groupElement.colsElementIds);
    groupElement.rowsElementIds = transpose(groupElement.colsElementIds);

    // 选中当前节点
    setSelectedElement(orderElement.id);

    List<ConnectionParams> nextElementsConnectionParams = sourceElement.next;
    List<String> bottomOfSourceElementIds = getDestElementIds(sourceElement);

    List<String> removedConnectDestElementIds = [];
    if (nextElementsConnectionParams.isNotEmpty) {
      // // 移除当前节点下现有的所有连接并记录其目标节点id
      for (var params in nextElementsConnectionParams.toList()) {
        removeConnectionByElements(
          sourceElement,
          findElementById(params.destElementId) as FlowElement,
          notify: false,
        );
        removedConnectDestElementIds.add(params.destElementId);
      }
      final orderElementBottomHandlerPos =
          orderElement.getHandlerPosition(Alignment.bottomCenter);
      final sourceEleBottomHandlerPos =
          sourceElement.getHandlerPosition(Alignment.bottomCenter);
      final addHeight =
          orderElementBottomHandlerPos.dy - sourceEleBottomHandlerPos.dy;

      ///  调整当前组当前节点所在的列后续节点的垂直位置
      final sourceDy = sourceElement.position.dy;
      for (int i = 0; i < bottomOfSourceElementIds.length; i++) {
        final destElement = findElementById(bottomOfSourceElementIds[i])!;
        if ((destElement.position.dy > sourceDy.toDouble())) {
          destElement.changePosition(Offset(
              destElement.position.dx, destElement.position.dy + addHeight));
        }
      }

      ///  更新组节点大小
      final diffElementRows = groupElement.rowsElementIds.length - lastRowNum;
      final newGroupElementSize = Size(groupElement.size.width,
          groupElement.size.height + addHeight * diffElementRows);
      final diffHeight = newGroupElementSize.height - groupElement.size.height;

      /// 预留判断：
      ///  判断source的所在的列最后一个元素是否是整个组内的最后一行，最后一行才需要更新组节点大小
      ///  找到source所在列的最后一个元素
      // FlowElement? sourceColumnLastElement =
      //     findElementById(bottomOfSourceElementIds.last);
      // bool elementIsLastRow = sourceColumnLastElement == null
      //     ? false
      //     : checkElementIsLastRow(sourceColumnLastElement, groupRowLayoutData);
      // if (elementIsLastRow) {
      groupElement.size = newGroupElementSize;
      // }

      for (int i = 0; i < elements.length; i++) {
        if (elements[i].position.dy >= orderElement.position.dy &&
            elements[i].parentId != groupElement.id) {
          elements[i].position = Offset(
            elements[i].position.dx,
            elements[i].position.dy + diffHeight,
          );
        }
      }

      ///连接新节点
      addNextById(
        sourceElement,
        orderElement.id,
        DrawingArrow.instance.params.copyWith(
          style: ArrowStyle.rectangular,
          startArrowPosition: Alignment.bottomCenter,
          endArrowPosition: Alignment.topCenter,
        ),
      );
      // // 恢复之前移除的连接，将orderElement连接到destElementId节点
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
      notifyListeners();
    }
  }

  // 获取sourceElement连线下面的所有节点Id
  List<String> getDestElementIds(FlowElement sourceElement) {
    List<String> destElementIds = [];
    for (int i = 0; i < sourceElement.next.length; i++) {
      final destElementId = sourceElement.next[i].destElementId;
      destElementIds.add(destElementId);
      final destElement = findElementById(destElementId);
      if (destElement != null) {
        final nextDestElementIds = getDestElementIds(destElement);
        destElementIds.addAll(nextDestElementIds);
      }
    }
    return destElementIds;
  }

//  判断element是否是组内的最后一列
  bool checkElementIsLastColumn(FlowElement element) {
    return false;
  }

// 判断element是否在组内的某一列
  bool checkElementIsInColumn(double elementDx, double targetDx,
      List<List<FlowElement>> groupColumnLayoutData) {
    for (int i = 0; i < groupColumnLayoutData.length; i++) {
      final columnDx = groupColumnLayoutData[i].first.position.dx;
      if (targetDx == columnDx && elementDx == targetDx) {
        return true;
      }
    }
    return false;
  }

// 判断element是否在组内的某一行
  bool checkElementIsInRow() {
    return false;
  }

  // 通过组内每一列底部节点下的+号新增
  void addElementByGroupColumnBottomPlus(
      FlowElement sourceElement, FlowElement orderElement) {
    final groupElement = elements.firstWhere(
      (element) => element.id == sourceElement.parentId,
    );

    /// 新增节点(节点先进画布，获取真实宽高)
    addElement(orderElement);
    // 通过sourceElementId找到他在groupElement.colsElementIds所在列
    final lastRowNum = groupElement.rowsElementIds.length;

    final sourceElementColumnIndex = groupElement.colsElementIds
        .indexWhere((elementIds) => elementIds.contains(sourceElement.id));
    final sourceElementRowIndex = groupElement.rowsElementIds
        .indexWhere((elementIds) => elementIds.contains(sourceElement.id));
    final columnNum = groupElement.colsElementIds.length;
    for (int i = 0; i < columnNum; i++) {
      if (i == sourceElementColumnIndex) {
        groupElement.colsElementIds[i]
            .insert(sourceElementRowIndex + 1, orderElement.id);
      } else {
        groupElement.colsElementIds[i].add("");
      }
    }

    groupElement.colsElementIds =
        cleanLastEmptyItems(groupElement.colsElementIds);
    groupElement.rowsElementIds = transpose(groupElement.colsElementIds);

    ///连接新节点
    addNextById(
      sourceElement,
      orderElement.id,
      DrawingArrow.instance.params.copyWith(
        style: ArrowStyle.rectangular,
        startArrowPosition: Alignment.bottomCenter,
        endArrowPosition: Alignment.topCenter,
      ),
    );
    setSelectedElement(orderElement.id);

    final diffElementRows = groupElement.rowsElementIds.length - lastRowNum;

    ///  更新组节点大小
    final orderElementBottomHandlerPos =
        orderElement.getHandlerPosition(Alignment.bottomCenter);
    final sourceEleBottomHandlerPos =
        sourceElement.getHandlerPosition(Alignment.bottomCenter);
    final addHeight =
        orderElementBottomHandlerPos.dy - sourceEleBottomHandlerPos.dy;

    final newGroupElementSize = Size(groupElement.size.width,
        groupElement.size.height + addHeight * diffElementRows);
    final diffHeight = newGroupElementSize.height - groupElement.size.height;
    groupElement.size = newGroupElementSize;

    ///  组外的节点向下移动
    for (int i = 0; i < elements.length; i++) {
      if (elements[i].position.dy >= orderElement.position.dy &&
          elements[i].parentId != groupElement.id) {
        elements[i].position = Offset(
          elements[i].position.dx,
          elements[i].position.dy + diffHeight,
        );
      }
    }
    notifyListeners();
  }

  /// 从组节点右侧添加新节点
  void addElementByGroupRightPlus(
      FlowElement groupElement, FlowElement orderElement) {
    /// 计算group的padding
    final currentGroupElementSpacing = groupElementSpacing * zoomFactor;

    /// 找到属于groupElement的所有子Element
    List<FlowElement> lastChildElements =
        elements.where((ele) => ele.parentId == groupElement.id).toList();

    /// 新增节点(节点先进画布，获取真实宽高)
    addElement(orderElement);
    groupElement.rowsElementIds = List.from(groupElement
        .rowsElementIds); // 第一行的最后一个元素为orderElement.id，其他行的最后一个元素是""
    if (groupElement.rowsElementIds.isNotEmpty) {
      for (int i = 0; i < groupElement.rowsElementIds.length; i++) {
        if (i == 0) {
          groupElement.rowsElementIds[i].add(orderElement.id);
        } else {
          groupElement.rowsElementIds[i].add("");
        }
      }
    } else {
      groupElement.rowsElementIds.add([orderElement.id]); // 新增节点在第一行
    }
    groupElement.rowsElementIds =
        cleanLastEmptyItems(groupElement.rowsElementIds);
    groupElement.colsElementIds = transpose(groupElement.rowsElementIds);

    setSelectedElement(orderElement.id);
    final offsetWidth = (orderElement.size.width + currentGroupElementSpacing);

    final groupStartPosition = Offset(
        groupElement.position.dx + currentGroupElementSpacing,
        groupElement.position.dy + currentGroupElementSpacing);
    if (lastChildElements.isNotEmpty) {
      ///  更新组节点大宽度
      final groupElementSize = Size(
          groupElement.size.width +
              orderElement.size.width +
              currentGroupElementSpacing,
          groupElement.size.height);
      groupElement.size = groupElementSize;

      ///   更新组节点位置
      groupElement.position = Offset(
          groupElement.position.dx - offsetWidth / 2, groupElement.position.dy);

      ///   获取最右一列的坐标，并更新节点坐标
      final elementDx = findElementById(groupElement.rowsElementIds
                  .first[groupElement.rowsElementIds.first.length - 2])!
              .position
              .dx +
          (orderElement.size.width + currentGroupElementSpacing);
      orderElement.changePosition(Offset(elementDx, groupStartPosition.dy));
      List<FlowElement> childElements =
          elements.where((el) => el.parentId == groupElement.id).toList();
      for (FlowElement element in childElements) {
        element.changePosition(
            Offset(element.position.dx - offsetWidth / 2, element.position.dy));
      }
    } else {
      //更新组节点高度
      final addHeight = (defaultNodeDistance + defaultHandlerSize) * zoomFactor;
      final newGroupElementSize = Size(groupElement.size.width,
          addHeight + defaultElementSize.height + elementPadding * 2);
      final diffHeight = newGroupElementSize.height - groupElement.size.height;
      groupElement.size = newGroupElementSize;
      // 更新节点坐标
      orderElement.changePosition(groupStartPosition);

      ///  组外下面的节点重新排列
      for (int i = 0; i < elements.length; i++) {
        if (elements[i].position.dy >= orderElement.position.dy &&
            elements[i].parentId != groupElement.id) {
          elements[i].position = Offset(
            elements[i].position.dx,
            elements[i].position.dy + diffHeight,
          );
        }
      }
    }
    notifyListeners();
  }

// 获取行布局数据
  List<List<FlowElement>> getGroupRowLayoutData(
      List<FlowElement> childElements, String groupId) {
    FlowElement? groupElement = findElementById(groupId);
    List<List<FlowElement>> groupRowLayoutData = [];
    if (groupElement != null) {
      for (var rowElementIds in groupElement.rowsElementIds) {
        List<FlowElement> rowElements = [];
        for (var elementId in rowElementIds) {
          if (elementId != "") {
            FlowElement element = findElementById(elementId)!;
            rowElements.add(element);
          }
        }
        groupRowLayoutData.add(rowElements);
      }
    }
    return groupRowLayoutData;
  }

// 获取列布局数据
  List<List<FlowElement>> getGroupColumnLayoutData(String groupId) {
    FlowElement? groupElement = findElementById(groupId);
    List<List<FlowElement>> groupColumnLayoutData = [];
    if (groupElement != null) {
      for (var columnElementIds in groupElement.colsElementIds) {
        List<FlowElement> columnElements = [];
        for (var elementId in columnElementIds) {
          if (elementId != "") {
            FlowElement element = findElementById(elementId)!;
            columnElements.add(element);
          }
        }
        groupColumnLayoutData.add(columnElements);
      }
    }
    return groupColumnLayoutData;
  }

  Offset getNextElementPosition(FlowElement sourceElement,
      {Size targetElementSize = defaultElementSize}) {
    final newElementDx =
        sourceElement.getHandlerPosition(Alignment.bottomCenter).dx;
    final diffDisatnce =
        ((targetElementSize.height * zoomFactor) - sourceElement.size.height) /
            2;
    final handlerSizeScaled = sourceElement.handlerSize / zoomFactor;
    final adjustedNodeDistance = defaultNodeDistance * 2 * zoomFactor;
    // final totalHandlerHeight = handlerSizeScaled * 2;
    // final newElementDy = sourceElement.position.dy +
    //     totalHandlerHeight +
    //     diffDisatnce +
    //     sourceElement.size.height +
    //     adjustedNodeDistance;
    final newElementDy =
        sourceElement.getHandlerPosition(Alignment.bottomCenter).dy +
            handlerSizeScaled * 1.5 +
            (diffDisatnce > 0 ? diffDisatnce.abs() : 0) +
            adjustedNodeDistance;
    return Offset(newElementDx, newElementDy);
  }

  void updateGroupSubElementLayout(FlowElement groupElement) {
    print("updateGroupSubElementLayout====>");
    final currentGroupElementSpacing = groupElementSpacing * zoomFactor;
    List<FlowElement> subElements =
        elements.where((ele) => ele.parentId == groupElement.id).toList();
    for (var i = 0; i < subElements.length; i++) {
      final element = subElements[i];
      final elementDx = groupElement.position.dx +
          currentGroupElementSpacing +
          i * (element.size.width + currentGroupElementSpacing);
      final elementDy = groupElement.position.dy + elementPadding * zoomFactor;
      element.changePosition(Offset(elementDx, elementDy));
    }
  }

  //更新被删除节点所在列后面的所有节点视图
  void updateLayOutAfterDelElementInGroup(
      FlowElement deletedElement,
      FlowElement? sourceElement,
      List<FlowElement> bottomOfRemovedElements,
      double decreaseHeight) {
    final delEleBottomHandlerPos =
        deletedElement.getHandlerPosition(Alignment.bottomCenter);
    final sourceEleBottomHandlerPos =
        sourceElement?.getHandlerPosition(Alignment.bottomCenter) ??
            Offset.zero;
    // 被删除元素和源元素之间的垂直距离
    final elementsDistant =
        delEleBottomHandlerPos.dy - sourceEleBottomHandlerPos.dy;
    // 调整被删除节点所在列后面的所有节点垂直位置
    for (FlowElement element in bottomOfRemovedElements) {
      element.changePosition(Offset(
          element.position.dx,
          element.position.dy -
              (sourceElement == null ? decreaseHeight : elementsDistant)));
    }

    //  被删除节点的连接点
    // 抓到被删除节点的下一个节点
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
      if (sourceElement != null) {
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

  FlowElement? findSourceElementByDestElement(FlowElement destElement) {
    var sourceElement;
    for (final element in elements) {
      for (final conn in element.next) {
        if (conn.destElementId == destElement.id) {
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

  void moveAllElements(Offset offset) {
    for (var i = 0; i < elements.length; i++) {
      elements[i].position += offset;
      for (final conn in elements[i].next) {
        for (final pivot in conn.pivots) {
          pivot.pivot += offset;
        }
      }
    }
  }

  /// 移除所有节点
  void removeAllElements({bool notify = true}) {
    elements.clear();
    updateAllGroupsLayoutData();
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

  /// 根据现有数据重新加载面板
  void dashBoardReload() {
    final mapData = toMap();
    elements.clear();
    // _dashboardPosition = Offset.zero;
    // dashboardSize = Size.zero;
    loadDashboardData(mapData);
    // 通知监听器更新
    // notifyListeners();
    updateAllGroupsLayoutData();
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
      if (element.id == id) {
        removedElement = element;
        sourceElement = findSrcElementByDestElement(element);
        return true;
      } else {
        return false;
      }
    });
    // 删除组节点需要删除所有其子节点
    if (removedElement.taskType == TaskType.group) {
      elements.removeWhere((element) => element.parentId == removedElement.id);
    }
    // 移除当前节点所有的连接
    for (final e in elements) {
      e.next.removeWhere((handlerParams) {
        return id.contains(handlerParams.destElementId);
      });
    }
    // 如果有后续节点的布局需要更新
    if (removedElement.next.isNotEmpty) {
      // 更新布局
      updateLayOutAfterDelElement(removedElement, sourceElement);
    }
    updateAllGroupsLayoutData();
    if (notify) notifyListeners();
  }

  /// 在组内通过 节点[id] 移除节点
  void removeElementInGroupByElementId(String removedElementId,
      {bool notify = true}) {
    FlowElement removedElement = findElementById(removedElementId)!;
    FlowElement? sourceElement = findSrcElementByDestElement(removedElement);
    double decreaseHeight = 0;
    double decreaseWidth = 0;
    final currentGroupElementSpacing = groupElementSpacing * zoomFactor;
    FlowElement? removedEleNextEle = removedElement.next.isNotEmpty
        ? findElementById(removedElement.next.first.destElementId)
        : null;
    List<FlowElement> lastChildElements = elements
        .where((ele) => ele.parentId == removedElement.parentId)
        .toList();
    final groupElement = findElementById(removedElement.parentId)!;
    final removedElementColumnIndex = groupElement.colsElementIds
        .indexWhere((elementIds) => elementIds.contains(removedElementId));
    final removedElementRowIndex = groupElement.rowsElementIds
        .indexWhere((elementIds) => elementIds.contains(removedElementId));
    final lastColsLength = groupElement.colsElementIds.length;
    final lastRowsLength = groupElement.rowsElementIds.length;
    if (removedElementColumnIndex != -1 && removedElementRowIndex != -1) {
      groupElement.colsElementIds[removedElementColumnIndex]
          [removedElementRowIndex] = "";
      groupElement.colsElementIds =
          cleanLastEmptyItems(groupElement.colsElementIds);
      groupElement.rowsElementIds[removedElementRowIndex]
          [removedElementColumnIndex] = "";
      groupElement.rowsElementIds =
          cleanLastEmptyItems(groupElement.rowsElementIds);
    }
    final colsLength = groupElement.colsElementIds.length;
    final rowsLength = groupElement.rowsElementIds.length;
    if (sourceElement == null) {
      //删除的是组内的第一行的节点
      if (removedEleNextEle != null) {
        //删除的节点下面有其他节点
        final removedEleBottomHandlerPos =
            removedElement.getHandlerPosition(Alignment.bottomCenter);
        final removedNextEleBottomHandlerPos =
            removedEleNextEle.getHandlerPosition(Alignment.bottomCenter);
        decreaseHeight =
            removedNextEleBottomHandlerPos.dy - removedEleBottomHandlerPos.dy;
      } else {
        //删除的节点下面没有其他节点，删除后组直接少一列
        if (lastChildElements.length > 1) {
          decreaseWidth =
              removedElement.size.width + currentGroupElementSpacing;
        }
      }
    }
    final lastGroupColumnLayoutData =
        getGroupColumnLayoutData(removedElement.parentId);

    // 移除当前节点
    elements.removeWhere((element) {
      if (element.id == removedElementId) {
        return true;
      } else {
        return false;
      }
    });

    // 移除当前节点所有的连接
    for (final e in elements) {
      e.next.removeWhere((handlerParams) {
        return removedElementId.contains(handlerParams.destElementId);
      });
    }

    List<FlowElement> bottomOfRemovedElements = [];
    for (List<FlowElement> columnElements in lastGroupColumnLayoutData) {
      if (columnElements.first.position.dx == removedElement.position.dx) {
        bottomOfRemovedElements = columnElements.where((ele) {
          return double.parse(ele.position.dy.toStringAsFixed(4)) >
              double.parse(removedElement.position.dy.toStringAsFixed(4));
        }).toList();
        break;
      }
    }
    updateLayOutAfterDelElementInGroup(
        removedElement, sourceElement, bottomOfRemovedElements, decreaseHeight);

    List<FlowElement> childElements = elements
        .where((ele) => ele.parentId == removedElement.parentId)
        .toList();
    final diffElementRows = rowsLength - lastRowsLength;
    final diffElementCols = colsLength - lastColsLength;
    if (diffElementCols < 0) {
      decreaseWidth = removedElement.size.width + currentGroupElementSpacing;
    }
    if (sourceElement != null) {
      final sourceElementBottomHandlerPos =
          sourceElement.getHandlerPosition(Alignment.bottomCenter);
      final removedEleBottomHandlerPos =
          removedElement.getHandlerPosition(Alignment.bottomCenter);
      decreaseHeight =
          removedEleBottomHandlerPos.dy - sourceElementBottomHandlerPos.dy;
    }

    (defaultNodeDistance * 2 + defaultHandlerSize * 2) * zoomFactor;

    /// 判断是否需要更新组节点的大小
    /// 关于高度：如果删除的节点导致行数变少了，需要更新组节点的高度
    final newGroupElementSize = Size(groupElement.size.width - decreaseWidth,
        groupElement.size.height + decreaseHeight * diffElementRows);

    ///关于宽度：如果删除的节点导致列数变少了，需要更新组节点的宽度
    groupElement.size = newGroupElementSize;
    if (decreaseWidth != 0) {
      //  更新组节点位置
      groupElement.position = Offset(
          groupElement.position.dx + decreaseWidth / 2,
          groupElement.position.dy);
      //  子节点dx小于 removedElement.dx都向右移动,反正向左移动
      for (FlowElement element in childElements) {
        final leftElement =
            element.position.dx - removedElement.position.dx < 0;
        element.changePosition(Offset(
            element.position.dx + ((leftElement ? 1 : -1) * decreaseWidth / 2),
            element.position.dy));
      }
    }
    // 如果行数减少了则追加调整组外后续节点的垂直位置
    if (diffElementRows < 0) {
      for (var element in elements) {
        if (element.position.dy > removedElement.position.dy - decreaseHeight &&
            element.parentId != groupElement.id &&
            removedElement.parentId != element.id) {
          element.position = Offset(
            element.position.dx,
            element.position.dy + decreaseHeight * diffElementRows,
          );
        }
      }
    }
    updateAllGroupsLayoutData();
    if (notify) notifyListeners();
  }

  updateLayOutAfterDelElement(
      FlowElement deletedElement, FlowElement? sourceElement) {
    final delEleBottomHandlerPos =
        deletedElement.getHandlerPosition(Alignment.bottomCenter);
    final sourceEleBottomHandlerPos =
        sourceElement?.getHandlerPosition(Alignment.bottomCenter) ??
            Offset.zero;
    // 被删除元素和源元素之间的垂直距离
    final elementsDistant =
        delEleBottomHandlerPos.dy - sourceEleBottomHandlerPos.dy;
    // 调整所有后续节点的垂直位置(将被删除的元素下方的所有元素向上移动)
    for (var element in elements) {
      if (element.position.dy >=
          deletedElement.position.dy - defaultNodeDistance * zoomFactor) {
        element.position = Offset(
          element.position.dx,
          element.position.dy - elementsDistant,
        );
      }
    }
    //  被删除节点的连接点
    // 抓到被删除节点的下一个节点
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
      if (sourceElement != null) {
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
    updateAllGroupsLayoutData();
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
    if (factor < minimumZoomFactor) {
      factor = minimumZoomFactor;
    }
    if (factor > maximumZoomFactor) {
      factor = maximumZoomFactor;
    }
    focalPoint ??= Offset(dashboardSize.width / 2, dashboardSize.height / 2) +
        _dashboardPosition;

    for (final element in elements) {
      element
        ..position = (element.position - focalPoint) /
                gridBackgroundParams.scale *
                factor +
            focalPoint
        ..setScale(gridBackgroundParams.scale, factor);

      /// 折线点的缩放
      for (final conn in element.next) {
        for (final pivot in conn.pivots) {
          pivot.setScale(gridBackgroundParams.scale, focalPoint, factor);
        }
      }
    }

    /// 更新背景网格尺寸
    gridBackgroundParams.setScale(factor, focalPoint);

    notifyListeners();
  }

  /// shorthand to get the current zoom factor
  double get zoomFactor {
    return gridBackgroundParams.scale;
  }

  // 图表组件的位置以计算拖放元素的偏移量
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

  /// 获取格式化后的json数据
  get toPrettyJsonString =>
      const JsonEncoder.withIndent('  ').convert(json.decode(toJson()));

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

  void loadDashboardDataByLocal() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/FlowChart.json');
    final source = json.decode(jsonString) as Map<String, dynamic>;
    loadDashboardData(source);
  }

  /// clear the dashboard and load the new one from [source] json
  void loadDashboardData(Map<String, dynamic> source) {
    elements.clear();

    gridBackgroundParams = GridBackgroundParams.fromMap(
      source['gridBackgroundParams'] as Map<String, dynamic>,
    );
    blockDefaultZoomGestures = source['blockDefaultZoomGestures'] as bool;
    minimumZoomFactor = (source['minimumZoomFactor'] ?? 0.25) as double;
    maximumZoomFactor = (source['maximumZoomFactor'] ?? 1.8) as double;
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
    updateAllGroupsLayoutData();
    setFullView();
  }

  // 矩阵转置
  List<List<T>> transpose<T>(List<List<T>> matrix) {
    if (matrix.isEmpty || matrix[0].isEmpty) return [];

    int rowCount = matrix.length;
    int colCount = matrix[0].length;

    // 创建一个新的二维数组
    List<List<T>> result = List.generate(
      colCount,
      (_) => List<T>.filled(rowCount, matrix[0][0], growable: true),
    );

    // 填充转置后的数组
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < colCount; j++) {
        result[j][i] = matrix[i][j];
      }
    }

    return result;
  }

  List<List<String>> cleanLastEmptyItems(List<List<String>> matrix) {
    if (matrix.isEmpty) return matrix;

    // 如果所有子数组的最后一项都为空字符串，则移除最后一项
    if (matrix.every((row) => row.isNotEmpty && row.last.isEmpty)) {
      return matrix.map((row) => row.sublist(0, row.length - 1)).toList();
    }

    // 否则，过滤掉空子数组并返回原始数组
    return matrix
        .where((row) => row.where((item) => item != "").isNotEmpty)
        .toList();
  }
}
