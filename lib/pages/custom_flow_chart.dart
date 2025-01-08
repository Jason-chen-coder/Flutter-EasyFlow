import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_svg/svg.dart';
import 'package:highlight/languages/json.dart';
import 'package:star_menu/star_menu.dart';

import '../flow_chart/dashboard.dart';
import '../flow_chart/elements/flow_element.dart';
import '../flow_chart/flow_chart.dart';
import 'code_editor_theme.dart';

class CustomFlowChart extends StatefulWidget {
  static String name = 'CustomFlowChart';

  const CustomFlowChart({super.key});

  @override
  State<CustomFlowChart> createState() => _CustomFlowChartState();
}

class _CustomFlowChartState extends State<CustomFlowChart> {
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
    dashboard.addListener(_onDashboardJsonChanged);
  }

  void _onDashboardJsonChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    dashboard.removeListener(_onDashboardJsonChanged);
    dashboard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/svg/ic_return.svg',
                    matchTextDirection: true,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Transform(
                    transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/svg/ic_return.svg',
                      matchTextDirection: true,
                    ),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  constraints: BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                    maxWidth: 36,
                    maxHeight: 36,
                  ),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  icon: SvgPicture.asset(
                    'assets/svg/ic_md_save.svg',
                    matchTextDirection: true,
                    width: 20,
                    height: 20,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  constraints: BoxConstraints(
                    minWidth: 450,
                    maxWidth: 480,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return CodeTheme(
                        data: CodeThemeData(styles: editorDefaultTheme),
                        child: SingleChildScrollView(
                            child: CodeField(
                          enabled: false,
                          wrap: true,
                          controller: CodeController(
                            text: dashboard.toPrettyJsonString,
                            language: json,
                          ),
                          minLines: 1,
                        )),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        constraints: BoxConstraints.expand(),
                        child: FlowChart(
                            dashboard: dashboard,
                            onPlusNodePressed: (context, position,
                                sourceElement, destElement) {
                              _displayPlusElementMenu(
                                  context, position, sourceElement);
                            },
                            onGoupPlusPressed: (context, position, element) {
                              _displayGroupPlusElementMenu(
                                  context, position, element);
                            },
                            onGroupColumnPlusNodePressed:
                                (context, position, sourceElement) {
                              _displayGroupColumnPlusNodeMenu(
                                  context, position, sourceElement);
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
                        left: 15,
                        bottom: 15,
                        child: Column(
                          children: [
                            // 清空
                            Container(
                              width: 36,
                              height: 36,
                              margin: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 1),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Color(0xFFffffff),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: () {
                                  dashboard.removeAllElements();
                                  _initStartElements();
                                },
                                child: Icon(
                                  Icons.cleaning_services_outlined,
                                  color: const Color(0xFF8D8C8D),
                                  size: 20,
                                ),
                              ),
                            ),
                            // 放大
                            Container(
                              width: 36,
                              height: 36,
                              margin: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 1),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Color(0xFFffffff),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: () {
                                  dashboard.setZoomFactor(
                                      1.5 * dashboard.zoomFactor);
                                },
                                child: const Icon(
                                  Icons.add,
                                  color: Color(0xFF8D8C8D),
                                  size: 20,
                                ),
                              ),
                            ),
                            // 缩小
                            Container(
                              width: 36,
                              height: 36,
                              margin: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 1),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Color(0xFFffffff),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: () {
                                  dashboard.setZoomFactor(
                                      dashboard.zoomFactor / 1.5);
                                },
                                child: const Icon(
                                  Icons.remove,
                                  color: Color(0xFF8D8C8D),
                                  size: 20,
                                ),
                              ),
                            ),
                            // 定位至中心
                            Container(
                              width: 36,
                              height: 36,
                              margin: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 1),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Color(0xFFffffff),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: dashboard.setFullView,
                                child: const Icon(
                                  Icons.fullscreen,
                                  color: Color(0xFF8D8C8D),
                                  size: 20,
                                ),
                              ),
                            ),
                            // 锁定
                            Container(
                              width: 36,
                              height: 36,
                              margin: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 1),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Color(0xFFffffff),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: () {
                                  dashboard.triggerllElementDraggable();
                                  setState(() {
                                    allElementsDraggable =
                                        dashboard.allElementsDraggable;
                                  });
                                },
                                child: Icon(
                                  dashboard.allElementsDraggable
                                      ? Icons.lock
                                      : Icons.lock_open,
                                  color: const Color(0xFF8D8C8D),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
              final flowElement = FlowElement(
                position: dashboard.getNextElementPosition(sourceElement),
                text: 'Delay',
                subTitleText: "wait for 12 minutes",
                taskType: TaskType.delay,
                kind: ElementKind.task,
                handlers: [
                  Handler.bottomCenter,
                  Handler.topCenter,
                ],
                parentId:
                    sourceElement.parentId != '' ? sourceElement.parentId : "",
              );
              if (sourceElement.parentId != '') {
                dashboard.addElementByGroupColumnPlus(
                    sourceElement, flowElement);
              } else {
                dashboard.addElementByPlus(sourceElement, flowElement);
              }
            },
          ),
          ActionChip(
            label: const Text('Add Timer Out'),
            onPressed: () {
              final flowElement = FlowElement(
                position: dashboard.getNextElementPosition(sourceElement),
                text: 'Timer Out',
                subTitleText: "just 2 minutes",
                taskType: TaskType.timeout,
                kind: ElementKind.task,
                handlers: [
                  Handler.topCenter,
                  Handler.bottomCenter,
                ],
                parentId:
                    sourceElement.parentId != '' ? sourceElement.parentId : "",
              );
              if (sourceElement.parentId != '') {
                dashboard.addElementByGroupColumnPlus(
                    sourceElement, flowElement);
              } else {
                dashboard.addElementByPlus(sourceElement, flowElement);
              }
            },
          ),
          ActionChip(
            label: const Text('Add Grab'),
            onPressed: () {
              final flowElement = FlowElement(
                position: dashboard.getNextElementPosition(sourceElement),
                text: 'Grab Samples',
                subTitleText: "grab 2 PCR samples",
                taskType: TaskType.grab,
                kind: ElementKind.task,
                parentId:
                    sourceElement.parentId != '' ? sourceElement.parentId : "",
                handlers: [
                  Handler.topCenter,
                  Handler.bottomCenter,
                ],
              );
              if (sourceElement.parentId != '') {
                dashboard.addElementByGroupColumnPlus(
                    sourceElement, flowElement);
              } else {
                dashboard.addElementByPlus(sourceElement, flowElement);
              }
            },
          ),
          sourceElement.parentId != ''
              ? SizedBox()
              : ActionChip(
                  label: Text('Add Group'),
                  onPressed: () {
                    _addGroupNode(position, sourceElement);
                  },
                ),
        ],
      ),
    );
  }

  void _displayGroupColumnPlusNodeMenu(
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
            backgroundColor: Colors.red,
            label: const Text('Add Delay'),
            onPressed: () {
              dashboard.addElementByGroupColumnBottomPlus(
                  sourceElement,
                  FlowElement(
                    position: dashboard.getNextElementPosition(sourceElement),
                    text: 'Delay',
                    subTitleText: "wait for 12 minutes",
                    parentId: sourceElement.parentId,
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
            backgroundColor: Colors.red,
            label: const Text('Add Timer Out'),
            onPressed: () {
              dashboard.addElementByGroupColumnBottomPlus(
                  sourceElement,
                  FlowElement(
                    position: dashboard.getNextElementPosition(sourceElement),
                    text: 'Timer Out',
                    subTitleText: "just 2 minutes",
                    taskType: TaskType.timeout,
                    parentId: sourceElement.parentId,
                    kind: ElementKind.task,
                    handlers: [
                      Handler.topCenter,
                      Handler.bottomCenter,
                    ],
                  ));
            },
          ),
          ActionChip(
            backgroundColor: Colors.red,
            label: const Text('Add Grab'),
            onPressed: () {
              dashboard.addElementByGroupColumnBottomPlus(
                  sourceElement,
                  FlowElement(
                    position: dashboard.getNextElementPosition(sourceElement),
                    text: 'Grab Samples',
                    subTitleText: "grab 2 PCR samples",
                    taskType: TaskType.grab,
                    kind: ElementKind.task,
                    parentId: sourceElement.parentId,
                    handlers: [
                      Handler.topCenter,
                      Handler.bottomCenter,
                    ],
                  ));
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
            backgroundColor: Color(0xff6cd7a3),
            label: const Text('Add Delay'),
            onPressed: () {
              dashboard.addElementByGroupRightPlus(
                  sourceElement,
                  FlowElement(
                      parentId: sourceElement.id,
                      text: 'Delay',
                      subTitleText: "wait for 12 minutes",
                      taskType: TaskType.delay,
                      kind: ElementKind.task,
                      isDraggable: true,
                      handlers: [Handler.bottomCenter]));
            },
          ),
          ActionChip(
            backgroundColor: Color(0xff6cd7a3),
            label: const Text('Add Timer Out'),
            onPressed: () {
              dashboard.addElementByGroupRightPlus(
                  sourceElement,
                  FlowElement(
                      parentId: sourceElement.id,
                      text: 'Timer Out',
                      subTitleText: "just 2 minutes",
                      taskType: TaskType.timeout,
                      kind: ElementKind.task,
                      isDraggable: true,
                      handlers: [Handler.bottomCenter]));
            },
          ),
          ActionChip(
            backgroundColor: Color(0xff6cd7a3),
            label: const Text('Add Grab'),
            onPressed: () {
              dashboard.addElementByGroupRightPlus(
                  sourceElement,
                  FlowElement(
                      parentId: sourceElement.id,
                      text: 'Grab Samples',
                      subTitleText: "grab 2 PCR samples",
                      taskType: TaskType.grab,
                      kind: ElementKind.task,
                      isDraggable: true,
                      handlers: [Handler.bottomCenter]));
            },
          ),
        ],
      ),
    );
  }

  void _addGroupNode(Offset position, FlowElement sourceElement) {
    final groupElement = FlowElement(
      size: defaultGoupElementSize,
      position: dashboard.getNextElementPosition(sourceElement,
          targetElementSize: defaultGoupElementSize),
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
    final startDx = (dashboard.dashboardSize.width / 2) + dashboard.position.dx;
    final startDy =
        (dashboard.dashboardSize.height / 8) + dashboard.position.dy;
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

    final endElement = FlowElement(
      position: dashboard.getNextElementPosition(startElement),
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
  }
}
