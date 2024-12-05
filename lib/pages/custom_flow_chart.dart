import 'dart:async';

import 'package:flutter_easy_flow/flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter/material.dart';
import 'package:star_menu/star_menu.dart';

class CustomFlowChart extends StatefulWidget {
  static String name = 'CustomFlowChart';

  const CustomFlowChart({super.key});

  @override
  State<CustomFlowChart> createState() => _CustomFlowChartState();
}

class _CustomFlowChartState extends State<CustomFlowChart> {
  /// Notifier for the tension slider
  final segmentedTension = ValueNotifier<double>(1);
  late final Dashboard dashboard;
  late bool allElementsDraggable;
  int selectedIndex = 0;
  Offset currentPosition = Offset(0, 0);
  _CustomFlowChartState() {
    dashboard = Dashboard();
    allElementsDraggable = dashboard.allElementsDraggable;
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 0), () {
      _initStartElements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints.expand(),
            child: FlowChart(
                dashboard: dashboard,
                onPlusNodePressed:
                    (context, position, sourceElement, destElement) {
                      _displayPlusElementMenu(context, position, sourceElement);
                },
                onGoupPlusPressed: (context, position, element) {
                  _displayGroupPlusElementMenu(context, position, element);
                },
                onScaleUpdate: (newScale) {},
                onDashboardLongTapped: (context, position) {
                  final flowElement = FlowElement(
                    size: Size(36, 36),
                    elevation: 0,
                    iconSize: 20,
                    text: 'plus',
                    position: Offset(0, 0),
                    taskType: TaskType.plus,
                    kind: ElementKind.plus,
                    isDraggable: true,
                    handlers: [
                      Handler.bottomCenter,
                      Handler.topCenter,
                    ],
                  );
                  dashboard.addElement(flowElement);
                },
                // 单击元素时的回调
                onElementPressed: (context, position, element) {
                  dashboard.setSelectedElement(element.id);
                }),
          ),
          Positioned(
              left: 50,
              bottom: 50,
              child: Column(children: [
                // 清空
                Container(
                    width: 36,
                    height: 36,
                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Color(0xFFffffff),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: () {
                        dashboard.removeAllElements();
                        _initStartElements();
                      },
                      child: Icon(
                          Icons.cleaning_services_outlined,
                          color: const Color(0xFF8D8C8D),
                          size: 20),
                    )),
                // 放大
                Container(
                    width: 36,
                    height: 36,
                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Color(0xFFffffff),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: () {
                        dashboard.setZoomFactor(1.5 * dashboard.zoomFactor);
                      },
                      child: const Icon(Icons.add,
                          color: Color(0xFF8D8C8D), size: 20),
                    )),
                // 缩小
                Container(
                    width: 36,
                    height: 36,
                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Color(0xFFffffff),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: () {
                        dashboard.setZoomFactor(dashboard.zoomFactor / 1.5);
                      },
                      child: const Icon(Icons.remove,
                          color: Color(0xFF8D8C8D), size: 20),
                    )),
                // 定位至中心
                Container(
                    width: 36,
                    height: 36,
                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Color(0xFFffffff),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: dashboard.setFullView,
                      child: const Icon(Icons.fullscreen,
                          color: Color(0xFF8D8C8D), size: 20),
                    )),
                // 锁定
                Container(
                    width: 36,
                    height: 36,
                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Color(0xFFffffff),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: () {
                        dashboard.triggerllElementDraggable();
                        setState(() {
                          allElementsDraggable = dashboard.allElementsDraggable;
                        });
                      },
                      child: Icon(
                          dashboard.allElementsDraggable
                              ? Icons.lock
                              : Icons.lock_open,
                          color: const Color(0xFF8D8C8D),
                          size: 20),
                    ))
              ])),
        ],
      ),
    );
  }

  void _displayPlusElementMenu(
    BuildContext context,
    Offset position,
    FlowElement sourceElement,
  ) {
    StarMenuOverlay.displayStarMenu(
      context,
      StarMenu(
        params: StarMenuParameters(
          shape: MenuShape.linear,
          openDurationMs: 60,
          linearShapeParams: const LinearShapeParams(
            angle: 270,
            alignment: LinearAlignment.left,
            space: 10,
          ),
          // calculate the offset from the dashboard center
          centerOffset: position - const Offset(-50, 90),
        ),
        onItemTapped: (index, controller) => controller.closeMenu!(),
        parentContext: context,
        items: [
          ActionChip(
            label: const Text('Add Delay'),
            onPressed: () {

              dashboard.addElementByPlus(
                  sourceElement,
                  FlowElement(
                    position: dashboard.getNextElementPosition(sourceElement),
                    text: 'Delay',
                    subTitleText: "wait for 12 minutes",
                    taskType: TaskType.delay,
                    kind: ElementKind.task,
                    handlers: [
                      Handler.bottomCenter,
                      Handler.topCenter,
                    ],
                  ));
            },
          ),
          ActionChip(
            label: const Text('Add Timer Out'),
            onPressed: () {
              dashboard.addElementByPlus(
                  sourceElement,
                  FlowElement(
                    position:dashboard.getNextElementPosition(sourceElement),
                    text: 'Timer Out',
                    subTitleText: "just 2 minutes",
                    taskType: TaskType.timeout,
                    kind: ElementKind.task,
                    handlers: [
                      Handler.topCenter,
                      Handler.bottomCenter,
                    ],
                  ));
            },
          ),
          ActionChip(
            label: const Text('Add Grab'),
            onPressed: () {
              dashboard.addElementByPlus(
                  sourceElement,
                  FlowElement(
                    position:dashboard.getNextElementPosition(sourceElement),
                    text: 'Grab Samples',
                    subTitleText: "grab 2 PCR samples",
                    taskType: TaskType.grab,
                    kind: ElementKind.task,
                    handlers: [
                      Handler.topCenter,
                      Handler.bottomCenter,
                    ],
                  ));
            },
          ),
          ActionChip(
            label: const Text('Add Group'),
            onPressed: () {
              _addGroupNode(position, sourceElement);
            },
          ),
        ],
      ),
    );
  }

  void _displayGroupPlusElementMenu(
    BuildContext context,
    Offset position,
    FlowElement sourceElement,
  ) {
    StarMenuOverlay.displayStarMenu(
      context,
      StarMenu(
        params: StarMenuParameters(
          shape: MenuShape.linear,
          openDurationMs: 60,
          linearShapeParams: const LinearShapeParams(
            angle: 270,
            alignment: LinearAlignment.left,
            space: 10,
          ),
          // calculate the offset from the dashboard center
          centerOffset: position - const Offset(-50, 90),
        ),
        onItemTapped: (index, controller) => controller.closeMenu!(),
        parentContext: context,
        items: [
          ActionChip(
            label: const Text('Add Delay'),
            onPressed: () {
              dashboard.addElementByGroupPlus(
                  sourceElement,
                  FlowElement(
                      parentId: sourceElement.id,
                      text: 'Delay',
                      subTitleText: "wait for 12 minutes",
                      taskType: TaskType.delay,
                      kind: ElementKind.task,
                      isDraggable: true,
                      handlers: []));
            },
          ),
          ActionChip(
            label: const Text('Add Timer Out'),
            onPressed: () {
              dashboard.addElementByGroupPlus(
                  sourceElement,
                  FlowElement(
                      parentId: sourceElement.id,
                      text: 'Timer Out',
                      subTitleText: "just 2 minutes",
                      taskType: TaskType.timeout,
                      kind: ElementKind.task,
                      isDraggable: true,
                      handlers: []));
            },
          ),
          ActionChip(
            label: const Text('Add Grab'),
            onPressed: () {
              dashboard.addElementByGroupPlus(
                  sourceElement,
                  FlowElement(
                      parentId: sourceElement.id,
                      text: 'Grab Samples',
                      subTitleText: "grab 2 PCR samples",
                      taskType: TaskType.grab,
                      kind: ElementKind.task,
                      isDraggable: true,
                      handlers: []));
            },
          ),
        ],
      ),
    );
  }

  void _addGroupNode(Offset position, FlowElement sourceElement) {
    final groupElement = FlowElement(
      size: Size(400, 80),
      position: dashboard.getNextElementPosition(sourceElement),
      text: 'Group',
      taskType: TaskType.group,
      kind: ElementKind.group,
      isDraggable: true,
      handlers: [
        Handler.bottomCenter,
        Handler.topCenter,
      ],
    );

    dashboard.addElementByPlus(sourceElement, groupElement);
  }

  void _initStartElements() {
    final startDx = dashboard.dashboardSize.width / 2;
    final startDy = dashboard.dashboardSize.height / 8;
    final startElement = FlowElement(
      position: Offset(startDx, startDy),
      text: 'Trigger',
      subTitleText: '实验人员手动触发',
      taskType: TaskType.trigger,
      kind: ElementKind.task,
      isDraggable: true,
      handlers: [
        Handler.bottomCenter,
      ],
    );
    dashboard.addElement(
      startElement,
    );
    final groupElement = FlowElement(
      position:dashboard.getNextElementPosition(startElement),
      text: 'Group',
      size: Size(400, 80),
      iconSize: 36,
      taskType: TaskType.group,
      kind: ElementKind.group,
      handlers: [
        Handler.topCenter,
        Handler.bottomCenter,
      ],
    );
    dashboard.addElement(
      groupElement,
    );
    dashboard.addElementConnection(startElement, groupElement);

    final endElement = FlowElement(
      position:dashboard.getNextElementPosition(groupElement),
      text: 'End Process',
      subTitleText: "end of workflows",
      taskType: TaskType.end,
      kind: ElementKind.task,
      handlers: [
        Handler.topCenter,
      ],
    );
    dashboard.addElement(
      endElement,
    );
    dashboard.addElementConnection(groupElement, endElement);
  }
}
