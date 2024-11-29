import 'dart:async';

import 'package:diagram_flow/flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter/material.dart';
import 'package:star_menu/star_menu.dart';

import '../flutter_flow_chart/ui/draw_arrow.dart';

class CustomFlowChart extends StatefulWidget {
  static String name = 'CustomFlowChart';

  const CustomFlowChart({super.key});

  @override
  State<CustomFlowChart> createState() => _CustomFlowChartState();
}

class _CustomFlowChartState extends State<CustomFlowChart> {
  // Map<String,dynamic> _flowData = FlowData();
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
                onPlusNodePressed:(context, position, sourceElement,destElement) {
                  _displayPlusElementMenu(context, position, sourceElement,destElement);
                },
                onScaleUpdate: (newScale) {},
                onDashboardLongTapped: (context, position) {
                  debugPrint('onDashboardLongTapped position: $position');
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
                  if (element.taskType == TaskType.plus) {
                    // _displayPlusElementMenu(context, position, element);
                  } else {
                    dashboard.setSelectedElement(element.id);
                  }
                }),
          ),
          Positioned(
              left: 50,
              bottom: 50,
              child: Column(children: [
                // 添加start节点
                // Container(
                //   width: 36,
                //   height: 36,
                //   margin: EdgeInsets.symmetric(vertical: 2,horizontal: 1),
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       padding: EdgeInsets.zero,
                //       backgroundColor: Color(0xFFffffff),
                //       shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(5)),
                //     ),
                //     onPressed: () {
                //       _initStartElements();
                //     },
                //     child: const Icon(
                //       Icons.task,
                //       color: Color(0xFF8D8C8D),
                //       size: 20,
                //     ),
                //   ),
                // ),
                // 添加end节点
                // Container(
                //   width: 36,
                //   height: 36,
                //   margin: EdgeInsets.symmetric(vertical: 2,horizontal: 1),
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       padding: EdgeInsets.zero,
                //       backgroundColor: Color(0xFFffffff),
                //       shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(5)),
                //     ),
                //     onPressed: () {
                //       dashboard.addElement(
                //         FlowElement(
                //           position: Offset(dashboard.dashboardSize.width / 2,
                //               dashboard.dashboardSize.height/1.5),
                //           text: 'End Process',
                //           subTitleText: 'end of workflows',
                //           taskType:TaskType.end,
                //           kind: ElementKind.task,
                //           isDraggable: true,
                //           handlers: [
                //             // Handler.bottomCenter,
                //             Handler.topCenter,
                //             // Handler.leftCenter,
                //             // Handler.rightCenter,
                //           ],
                //         ),
                //       );
                //     },
                //     child: const Icon(
                //       Icons.pin_end,
                //       color: Color(0xFF8D8C8D),
                //       size: 20,
                //     ),
                //   ),
                // ),
                // 添加组节点
                // Container(
                //   width: 36,
                //   height: 36,
                //   margin: EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       padding: EdgeInsets.zero,
                //       backgroundColor: Color(0xFFffffff),
                //       shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(5)),
                //     ),
                //     onPressed: () {
                //       final statDx = dashboard.dashboardSize.width / 2;
                //       final groupElement = FlowElement(
                //         size: Size(600, 100),
                //         position:
                //             Offset(statDx, dashboard.dashboardSize.height / 2),
                //         text: 'Group',
                //         taskType: TaskType.group,
                //         kind: ElementKind.group,
                //         isDraggable: true,
                //         handlers: [
                //           Handler.bottomCenter,
                //           Handler.topCenter,
                //           // Handler.leftCenter,
                //           // Handler.rightCenter,
                //         ],
                //       );
                //       dashboard.addElement(
                //         groupElement,
                //       );
                //     },
                //     child: const Icon(
                //       Icons.grid_on,
                //       color: Color(0xFF8D8C8D),
                //       size: 20,
                //     ),
                //   ),
                // ),
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
              ]))
          // 定位至画布中心
        ],
      ),
    );
  }

  void _displayPlusElementMenu(
    BuildContext context,
    Offset position,
    FlowElement sourceElement,
    FlowElement destElement,
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
                    position: Offset(position.dx, position.dy + dashboard.defaultNodeDistance * dashboard.zoomFactor),
                    text: 'Delay',
                    subTitleText: "wait for 12 minutes",
                    taskType: TaskType.delay,
                    kind: ElementKind.task,
                    handlers: [
                      Handler.bottomCenter,
                      Handler.topCenter,
                      Handler.leftCenter,
                      Handler.rightCenter,
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
                    position: Offset(position.dx, position.dy + dashboard.defaultNodeDistance * dashboard.zoomFactor),
                    text: 'Timer Out',
                    subTitleText: "just 2 minutes",
                    taskType: TaskType.timeout,
                    kind: ElementKind.task,
                    handlers: [
                      Handler.topCenter,
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
                    position: Offset(position.dx, position.dy + dashboard.defaultNodeDistance * dashboard.zoomFactor),
                    text: 'Grab Samples',
                    subTitleText: "grab 2 PCR samples",
                    taskType: TaskType.grab,
                    kind: ElementKind.task,
                    handlers: [
                      Handler.topCenter,
                    ],
                  ));
            },
          ),
          ActionChip(
            label: const Text('Add Group'),
            onPressed: () {
              final groupElement = FlowElement(
                size: Size(600, 100),
                position: Offset(position.dx, position.dy + dashboard.defaultNodeDistance * dashboard.zoomFactor),
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
            },
          ),
        ],
      ),
    );
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
    final endElementDx =
        startElement.getHandlerPosition(Alignment.bottomCenter).dx;
    final endElementDy =
        startElement.position.dy + ((startElement.handlerSize)*2 +startElement.size.height + startElement.handlerSize)+
            (dashboard.defaultNodeDistance*2* dashboard.zoomFactor ) ;
    final endElement = FlowElement(
              position: Offset(endElementDx, endElementDy),
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
    dashboard.addElementConnection(startElement, endElement);

    // dashboard.addElementByPlus(
    //     startElement,
    //     endElement);

    // final statDx = dashboard.dashboardSize.width / 2;
    //
    // final startElement = FlowElement(
    //   position: Offset(statDx, dashboard.dashboardSize.height / 8),
    //   text: 'Trigger',
    //   subTitleText: '实验人员手动触发',
    //   taskType: TaskType.trigger,
    //   kind: ElementKind.task,
    //   isDraggable: true,
    //   handlers: [
    //     Handler.bottomCenter,
    //   ],
    // );
    //   添加
    // final plusElementDx =
    //     startElement.getHandlerPosition(Alignment.bottomCenter).dx;
    // final plusElementDy =
    //     startElement.getHandlerPosition(Alignment.bottomCenter).dy +
    //         (dashboard.defaultNodeDistance * dashboard.zoomFactor);
    // final plusElement = FlowElement(
    //   size: Size(36, 36),
    //   elevation: 0,
    //   iconSize: 20,
    //   text: 'plus',
    //   position: Offset(plusElementDx, plusElementDy),
    //   taskType: TaskType.plus,
    //   kind: ElementKind.plus,
    //   isDraggable: true,
    //   handlers: [
    //     Handler.bottomCenter,
    //     Handler.topCenter,
    //   ],
    // );
    // dashboard.addElement(
    //   startElement,
    // );
    // 添加plus节点
    // dashboard.addElement(plusElement);
    //  连线
    // dashboard.addNextById(
    //   startElement,
    //   plusElement.id,
    //   DrawingArrow.instance.params.copyWith(
    //     style: ArrowStyle.rectangular,
    //     startArrowPosition: Alignment.bottomCenter,
    //     endArrowPosition: Alignment.topCenter,
    //   ),
    // );
    //   添加
    // final newElementDx =
    //     plusElement.getHandlerPosition(Alignment.bottomCenter).dx;
    // final newElementDy =
    //     plusElement.getHandlerPosition(Alignment.bottomCenter).dy +
    //         (dashboard.defaultNodeDistance * dashboard.zoomFactor);
    // dashboard.addElementByPlus(
    //     plusElement,
    //     FlowElement(
    //       position: Offset(newElementDx, newElementDy),
    //       text: 'End Process',
    //       subTitleText: "end of workflows",
    //       taskType: TaskType.end,
    //       kind: ElementKind.task,
    //       handlers: [
    //         Handler.topCenter,
    //       ],
    //     ));
  }
}
