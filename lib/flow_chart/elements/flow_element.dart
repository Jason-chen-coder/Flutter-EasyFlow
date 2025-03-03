// ignore_for_file: avoid_positional_boolean_parameters, avoid_dynamic_calls

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../dashboard.dart';
import 'connection_params.dart';


enum TaskType { none, trigger, delay, timeout, grab, end, plus, group }

// 扩展枚举，添加字符串映射
extension TaskTypeExtension on TaskType {
  String get toStringValue {
    switch (this) {
      case TaskType.none:
        return "none";
      case TaskType.trigger:
        return "trigger";
      case TaskType.delay:
        return "delay";
      case TaskType.timeout:
        return "timeout";
      case TaskType.grab:
        return "grab";
      case TaskType.plus:
        return "plus";
      case TaskType.group:
        return "group";
      case TaskType.end:
        return "end";
    }
  }
}

/// Kinf od element
enum ElementKind {
  ///
  rectangle,

  ///
  diamond,

  ///
  storage,

  ///
  oval,

  ///
  parallelogram,

  ///
  hexagon,

  ///
  image,

  ///
  task,

  plus,

  group,
}

/// Handler supported by elements
enum Handler {
  ///
  topCenter,

  ///
  bottomCenter,

  ///
  rightCenter,

  ///
  leftCenter;

  /// Convert to [Alignment]
  Alignment toAlignment() {
    switch (this) {
      case Handler.topCenter:
        return Alignment.topCenter;
      case Handler.bottomCenter:
        return Alignment.bottomCenter;
      case Handler.rightCenter:
        return Alignment.centerRight;
      case Handler.leftCenter:
        return Alignment.centerLeft;
    }
  }
}

/// Class to store [FlowElement]s and notify its changes
class FlowElement extends ChangeNotifier {
  ///
  FlowElement({
    Offset position = Offset.zero,
    this.size = defaultElementSize,
    this.text = '',
    this.subTitleText = '',
    this.textColor = Colors.black,
    this.fontFamily,
    this.textSize = 14,
    this.subTextColor = const Color(0xFF8D8C8D),
    this.subTitleTextSize = 10,
    this.iconSize = 40,
    this.parentId = "",
    this.textIsBold = false,
    this.kind = ElementKind.rectangle,
    this.handlers = const [
      Handler.topCenter,
      Handler.bottomCenter,
      Handler.rightCenter,
      Handler.leftCenter,
    ],
    this.rowsElementIds = const [],
    this.colsElementIds = const [],
    this.handlerSize = defaultHandlerSize,
    this.backgroundColor = Colors.white,
    this.borderRadius = 10,
    this.taskType = TaskType.none,
    this.borderColor = Colors.blue,
    this.borderThickness = 3,
    this.elevation = 2,
    this.data,
    this.isDraggable = true,
    this.isResizable = false,
    this.isConnectable = true,
    this.isDeletable = false,
    List<ConnectionParams>? next,
  })  : next = next ?? [],
        id = const Uuid().v4(),
        isEditingText = false,
        zoom = 1,
        newScaleFactor = 1,
        // fixing offset issue under extreme scaling
        position = position -
            Offset(
              size.width / 2 + handlerSize / 2,
              size.height / 2 + handlerSize / 2,
            );

  ///
  factory FlowElement.fromMap(Map<String, dynamic> map) {
    final e = FlowElement(
      size: Size(map['size.width'].toDouble(), map['size.height'].toDouble()),
      text: map['text'] as String,
      textColor: Color(map['textColor'] as int),
      subTitleText: map['subTitleText'] as String,
      fontFamily: map['fontFamily'] as String?,
      textSize: map['textSize'].toDouble(),
      subTitleTextSize: map['subTitleTextSize'].toDouble(),
      iconSize: map['iconSize'].toDouble(),
      parentId: map['parentId'] as String,
      textIsBold: map['textIsBold'] as bool,
      kind: ElementKind.values[map['kind'] as int],
      handlers: List<Handler>.from(
        (map['handlers'] as List<dynamic>).map<Handler>(
          (x) => Handler.values[x as int],
        ),
      ),
      rowsElementIds: (map['rowsElementIds'] as List<dynamic>?)
              ?.map((row) =>
                  (row as List<dynamic>).map((id) => id.toString()).toList())
              .toList() ??
          [],
      colsElementIds: (map['colsElementIds'] as List<dynamic>?)
              ?.map((col) =>
                  (col as List<dynamic>).map((id) => id.toString()).toList())
              .toList() ??
          [],
      handlerSize: map['handlerSize'].toDouble(),
      backgroundColor: Color(map['backgroundColor'] as int),
      borderRadius: map['borderRadius'].toDouble(),
      taskType: TaskType.values[map['taskType'] as int],
      borderColor: Color(map['borderColor'] as int),
      borderThickness: map['borderThickness'].toDouble(),
      elevation: map['elevation'].toDouble(),
      next: (map['next'] as List).isNotEmpty
          ? List<ConnectionParams>.from(
              (map['next'] as List<dynamic>).map<dynamic>(
                (x) => ConnectionParams.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      isDraggable: map['isDraggable'] as bool? ?? true,
      isResizable: map['isResizable'] as bool? ?? false,
      isConnectable: map['isConnectable'] as bool? ?? true,
      isDeletable: map['isDeletable'] as bool? ?? false,
    )
      ..setId(map['id'] as String)
      ..position = Offset(
        map['positionDx'].toDouble(),
        map['positionDy'].toDouble(),
      )
      ..serializedData = map['data'] as String?;
    return e;
  }

  ///
  factory FlowElement.fromJson(String source) =>
      FlowElement.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Unique id set when adding a [FlowElement] with [Dashboard.addElement()]
  String id;

  /// The position of the [FlowElement]
  Offset position;

  /// The size of the [FlowElement]
  Size size;

  /// Element text
  String text;

  /// Text color
  Color textColor;

  /// Text font family
  String? fontFamily;

  /// Text size
  double textSize;

  String subTitleText;

  double subTitleTextSize;

  Color subTextColor;

  double iconSize;

  // 所属父级元素的ID,默认为空(整个画布)
  String parentId;

  /// Makes text bold if true
  bool textIsBold;

  /// Element shape
  ElementKind kind;

  /// Connection handlers
  List<Handler> handlers;

  // 节点内所有行的元素ID
  List<List<String>> rowsElementIds = [];

  // 节点内所有列的元素ID
  List<List<String>> colsElementIds = [];

  /// The size of element handlers
  double handlerSize;

  /// Background color of the element
  Color backgroundColor;

  /// Border color of the element
  Color borderColor;

  double borderRadius;

  TaskType taskType;

  /// Border thickness of the element
  double borderThickness;

  /// Shadow elevation
  double elevation;

  /// List of connections from this element
  List<ConnectionParams> next;

  /// Whether this element can be dragged around
  bool isDraggable;

  /// Whether this element can be resized
  bool isResizable;

  /// Whether this element can be deleted quickly by clicking on the trash icon
  bool isDeletable;

  /// Whether this element can be connected to others
  bool isConnectable;

  /// Whether the text of this element is being edited with a form field
  bool isEditingText;

  double zoom;

  double newScaleFactor;

  /// Kind-specific data
  final dynamic data;

  /// Kind-specific data to load/save
  String? serializedData;

  @override
  String toString() {
    return 'FlowElement{kind: $kind, text: $text}';
  }

  /// Get the handler center of this handler for the given alignment.
  Offset getHandlerPosition(Alignment alignment) {
    // The zero position coordinate is the top-left of this element.
    final ret = Offset(
      position.dx + (size.width * ((alignment.x + 1) / 2)) + handlerSize / 2,
      position.dy + (size.height * ((alignment.y + 1) / 2) + handlerSize / 2),
    );
    return ret;
  }

  /// Sets a new scale
  void setScale(double currentZoom, double factor) {
    zoom = currentZoom == 1 ? factor : currentZoom; // 更新当前的缩放级别
    newScaleFactor = factor / currentZoom; // 计算新的缩放因子
    size = size * newScaleFactor; // 调整尺寸
    handlerSize = handlerSize * newScaleFactor;
    textSize = textSize * newScaleFactor;
    subTitleTextSize = subTitleTextSize * newScaleFactor;
    iconSize = iconSize * newScaleFactor;

    // if(currentZoom != 1 && factor != 1) {
    // 处理线和锚点
    for (final element in next) {
      element.arrowParams.setScale(newScaleFactor);
    }
    // }
    notifyListeners();
  }

  /// Used internally to set an unique Uuid to this element
  void setId(String id) {
    this.id = id;
  }

  /// Set text
  void setText(String text) {
    this.text = text;
    notifyListeners();
  }

  /// Set text color
  void setTextColor(Color color) {
    textColor = color;
    notifyListeners();
  }

  void setSubTitleText(String text) {
    subTitleText = text;
    notifyListeners();
  }

  void setSubTextColor(Color color) {
    subTextColor = color;
    notifyListeners();
  }

  /// Set text font family
  void setFontFamily(String? fontFamily) {
    this.fontFamily = fontFamily;
    notifyListeners();
  }

  /// Set text size
  void setTextSize(double size) {
    textSize = size;
    notifyListeners();
  }

  void setSubTitleTextSize(double size) {
    subTitleTextSize = size;
    notifyListeners();
  }

  void setIconSize(double size) {
    iconSize = size;
    notifyListeners();
  }

  void setParentId(String id) {
    parentId = id;
    notifyListeners();
  }

  /// Set text bold
  void setTextIsBold(bool isBold) {
    textIsBold = isBold;
    notifyListeners();
  }

  /// Set background color
  void setBackgroundColor(Color color) {
    backgroundColor = color;
    notifyListeners();
  }

  /// Set border color
  void setBorderColor(Color color) {
    borderColor = color;
    notifyListeners();
  }

  /// Set border thickness
  void setBorderThickness(double thickness) {
    borderThickness = thickness;
    notifyListeners();
  }

  /// Set elevation
  void setElevation(double elevation) {
    this.elevation = elevation;
    notifyListeners();
  }

  /// 修改节点坐标
  void changePosition(Offset newPosition,
      {FlowElement? element, Dashboard? dashboard, Offset? delta}) {
    position = newPosition;
    if (element != null && dashboard != null && delta != null) {
      if (element.taskType == TaskType.group) {
        moveGroupWidthSubElements(dashboard, element, delta);
      }
    }
    notifyListeners();
  }

  /// 移动组节点时要带上子节点
  void moveGroupWidthSubElements(
      Dashboard dashboard, FlowElement groupElement, Offset deltaPosition) {
    List<FlowElement> subElements = dashboard.elements
        .where((ele) => ele.parentId == groupElement.id)
        .toList();
    for (var element in subElements) {
      element.changePosition(element.position + deltaPosition);
    }
  }

  /// Change element size
  void changeSize(Size newSize) {
    double zoomWidthVal = newSize.width / size.width;
    double zoomHeightVal = newSize.height / size.height;
    iconSize = iconSize * zoomWidthVal;
    textSize = textSize * zoomHeightVal;
    subTitleTextSize = subTitleTextSize * zoomHeightVal;
    size = newSize;
    if (size.width < 40) size = Size(40, size.height);
    if (size.height < 40) size = Size(size.width, 40);
    notifyListeners();
  }

  @override
  bool operator ==(covariant FlowElement other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode {
    return position.hashCode ^
        size.hashCode ^
        text.hashCode ^
        textColor.hashCode ^
        fontFamily.hashCode ^
        textSize.hashCode ^
        subTextColor.hashCode ^
        subTitleText.hashCode ^
        subTitleTextSize.hashCode ^
        textIsBold.hashCode ^
        id.hashCode ^
        kind.hashCode ^
        handlers.hashCode ^
        handlerSize.hashCode ^
        backgroundColor.hashCode ^
        borderColor.hashCode ^
        borderRadius.hashCode ^
        taskType.hashCode ^
        borderThickness.hashCode ^
        elevation.hashCode ^
        next.hashCode ^
        isResizable.hashCode ^
        isConnectable.hashCode ^
        rowsElementIds.hashCode ^
        colsElementIds.hashCode ^
        isDeletable.hashCode;
  }

  ///
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'positionDx': position.dx,
      'positionDy': position.dy,
      'size.width': size.width,
      'size.height': size.height,
      'text': text,
      'textColor': textColor.value,
      'fontFamily': fontFamily,
      'textSize': textSize,
      'subTitleText': subTitleText,
      'subTextColor': subTextColor.value,
      'subTitleTextSize': subTitleTextSize,
      'iconSize': iconSize,
      'parentId': parentId,
      'textIsBold': textIsBold,
      'id': id,
      'kind': kind.index,
      'handlers': handlers.map((x) => x.index).toList(),
      'handlerSize': handlerSize,
      'backgroundColor': backgroundColor.value,
      'borderRadius': borderRadius,
      'rowsElementIds': rowsElementIds,
      'colsElementIds': colsElementIds,
      'taskType': taskType.index,
      'borderColor': borderColor.value,
      'borderThickness': borderThickness,
      'elevation': elevation,
      'data': serializedData,
      'next': next.map((x) => x.toMap()).toList(),
      'isDraggable': isDraggable,
      'isResizable': isResizable,
      'isConnectable': isConnectable,
      'isDeletable': isDeletable,
    };
  }

  ///
  String toJson() => json.encode(toMap());
}
