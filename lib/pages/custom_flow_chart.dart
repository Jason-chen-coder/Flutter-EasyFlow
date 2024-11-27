import 'package:diagram_flow/flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter/material.dart';

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
  _CustomFlowChartState(){
     dashboard = Dashboard();
     allElementsDraggable = dashboard.allElementsDraggable;
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
              // onScaleUpdate: (newScale) {
              //   debugPrint('Scale updated. new scale: $newScale');
              // },
                // 单击元素时的回调
                onElementPressed: (context, position, element) {
                  debugPrint(
                      'onElementPressed with "${element.id}" text pressed');
                  dashboard.setSelectedElement(element.id);
                }
            ),
          ),
          Positioned(
              left: 50,
              bottom: 50,
              child: Column(children: [
                // 添加start节点
                Container(
                  width: 36,
                  height: 36,
                  margin: EdgeInsets.symmetric(vertical: 2,horizontal: 1),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Color(0xFFffffff),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: () {
                      final statDx = dashboard.dashboardSize.width / 2;
                      final startElement  =  FlowElement(
                        position: Offset(statDx,
                            dashboard.dashboardSize.height/8),
                        text: 'Trigger',
                        subTitleText: '实验人员手动触发',
                        taskType:TaskType.trigger,
                        kind: ElementKind.task,
                        isDraggable: true,
                        handlers: [
                          Handler.bottomCenter,
                          // Handler.topCenter,
                          // Handler.leftCenter,
                          // Handler.rightCenter,
                        ],
                      );
                      final plusElement = FlowElement(
                        size: Size(36, 36),
                        elevation:0 ,
                        iconSize: 20,
                        text: 'plus',
                        position: Offset(statDx,
                            dashboard.dashboardSize.height/8 + (dashboard.defaultNodeDistance *dashboard.zoomFactor)),
                        taskType:TaskType.plus,
                        kind: ElementKind.plus,
                        isDraggable: true,
                        handlers: [
                          Handler.bottomCenter,
                          Handler.topCenter,
                        ],
                      );
                      dashboard.addElement(
                        startElement,
                      );
                      // 添加plus节点
                      dashboard.addElement(
                        plusElement
                      );
                    //  连线
                      dashboard.addNextById(
                        startElement,
                        plusElement.id,
                        DrawingArrow.instance.params.copyWith(
                          style: ArrowStyle.rectangular,
                          startArrowPosition: Alignment.bottomCenter,
                          endArrowPosition: Alignment.topCenter,
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.task,
                      color: Color(0xFF8D8C8D),
                      size: 20,
                    ),
                  ),
                ),

                // 添加end节点
                Container(
                  width: 36,
                  height: 36,
                  margin: EdgeInsets.symmetric(vertical: 2,horizontal: 1),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Color(0xFFffffff),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: () {
                      dashboard.addElement(
                        FlowElement(
                          position: Offset(dashboard.dashboardSize.width / 2,
                              dashboard.dashboardSize.height/1.5),
                          text: 'End Process',
                          subTitleText: 'end of workflows',
                          taskType:TaskType.end,
                          kind: ElementKind.task,
                          isDraggable: true,
                          handlers: [
                            // Handler.bottomCenter,
                            Handler.topCenter,
                            // Handler.leftCenter,
                            // Handler.rightCenter,
                          ],
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.pin_end,
                      color: Color(0xFF8D8C8D),
                      size: 20,
                    ),
                  ),
                ),
                // 放大
                Container(
                    width: 36,
                    height: 36,
                    margin: EdgeInsets.symmetric(vertical: 2,horizontal: 1),
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
                    margin: EdgeInsets.symmetric(vertical: 2,horizontal: 1),
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
                    margin: EdgeInsets.symmetric(vertical: 2,horizontal: 1),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Color(0xFFffffff),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: dashboard.recenter,
                      child: const Icon(Icons.fullscreen,
                          color: Color(0xFF8D8C8D), size: 20),
                    )),
                // 锁定
                Container(
                    width: 36,
                    height: 36,
                    margin: EdgeInsets.symmetric(vertical: 2,horizontal: 1),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Color(0xFFffffff),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: (){
                        dashboard.triggerllElementDraggable();
                        setState(() {
                          allElementsDraggable = dashboard.allElementsDraggable;
                        });
                      },
                      child: Icon(dashboard.allElementsDraggable ?Icons.lock: Icons.lock_open,
                          color: const Color(0xFF8D8C8D), size: 20),
                    ))
              ]))
          // 定位至画布中心
        ],
      ),
    );
  }
}
