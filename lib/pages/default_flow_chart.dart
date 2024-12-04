import 'package:flutter/cupertino.dart';
import './element_settings_menu.dart';
import './platforms/hooks_mobile.dart'
if (dart.library.js) './platforms/hooks_web.dart';
import './text_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_flow/flutter_flow_chart/flutter_flow_chart.dart';
import 'package:star_menu/star_menu.dart';

class DefaultFlowChart extends StatefulWidget {
  static String name = 'DefaultFlowChart';

  const DefaultFlowChart({super.key}); // 直接定义静态 name 属性
  @override
  State<DefaultFlowChart> createState() => _DefaultFlowChartState();
}

class _DefaultFlowChartState extends State<DefaultFlowChart> {
  Dashboard dashboard = Dashboard();

  /// Notifier for the tension slider
  final segmentedTension = ValueNotifier<double>(1);

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
              // 新增连接线的回调
              onNewConnection: (p1, p2) {
                debugPrint('new connection11111');
              },
              // 单击画布时的回调
              onDashboardTapped: (context, position) {
                debugPrint('Dashboard tapped $position');
                _displayDashboardMenu(context, position);
              },
              // 手势放大缩小的回调
              onScaleUpdate: (newScale) {
                debugPrint('Scale updated. new scale: $newScale');
              },
              // 右键点击画布时的回调
              onDashboardSecondaryTapped: (context, position) {
                debugPrint('Dashboard right clicked $position');
                _displayDashboardMenu(context, position);
              },
              // 长按画布时的回调
              onDashboardLongTapped: (context, position) {
                debugPrint('Dashboard long tapped $position');
              },
              // 右键长按画布时的回调
              onDashboardSecondaryLongTapped: (context, position) {
                debugPrint(
                  'Dashboard long tapped with mouse right click $position',
                );
              },
              // 长按元素时的回调
              onElementLongPressed: (context, position, element) {
                debugPrint('Element with "${element.text}" text '
                    'long pressed');
              },
              // 右键长按元素时的回调
              onElementSecondaryLongTapped: (context, position, element) {
                debugPrint('Element with "${element.text}" text '
                    'long tapped with mouse right click');
              },
              // 单击元素时的回调
              onElementPressed: (context, position, element) {
                debugPrint(
                    'onElementPressed with "${element.text}" text pressed');
                _displayElementMenu(context, position, element);
              },
              // 右键单击元素时的回调
              onElementSecondaryTapped: (context, position, element) {
                debugPrint(
                    'onElementSecondaryTapped with "${element
                        .text}" text pressed');
                _displayElementMenu(context, position, element);
              },
              // 点击锚点的回调
              onHandlerPressed: (context, position, handler, element) {
                debugPrint('handler pressed: position $position '
                    'handler $handler" of element $element');
                _displayHandlerMenu(position, handler, element);
              },
              // 长按锚点的回调
              onHandlerLongPressed: (context, position, handler, element) {
                debugPrint('handler long pressed: position $position '
                    'handler $handler" of element $element');
              },
              // 右键长按锚点的回调
              onPivotSecondaryPressed: (context, pivot) {
                dashboard.removeDissection(pivot);
              },
            ),
          ),
          Positioned(
              right: 50,
              bottom: 50,
              child:Column(
                children: [
                  // 放大
                  ElevatedButton(
                    onPressed: () {
                      dashboard.setZoomFactor(1.5 * dashboard.zoomFactor);
                    },
                    child: const Icon(Icons.zoom_in),
                  ),
                  // 缩小
                  ElevatedButton(
                    onPressed: () {
                      dashboard.setZoomFactor(dashboard.zoomFactor / 1.5);
                    },
                    child: const Icon(Icons.zoom_out),
                  ),
                  ElevatedButton(
                    onPressed: dashboard.recenter,
                    child: const Icon(Icons.center_focus_strong),
                  )
                ]
              )
          )
          // 定位至画布中心
        ],
      ),
    );
  }

  //*********************
  //* POPUP MENUS
  //*********************

  /// Display a drop down menu when tapping on a handler
  /// 点击锚点时显示下拉菜单
  void _displayHandlerMenu(Offset position,
      Handler handler,
      FlowElement element,) {
    StarMenuOverlay.displayStarMenu(
      context,
      StarMenu(
        params: StarMenuParameters(
          shape: MenuShape.linear,
          openDurationMs: 60,
          linearShapeParams: const LinearShapeParams(
            angle: 270,
            space: 10,
            alignment: LinearAlignment.left,
          ),
          onHoverScale: 1.1,
          useTouchAsCenter: true,
          centerOffset: position -
              Offset(
                dashboard.dashboardSize.width / 2,
                dashboard.dashboardSize.height / 2,
              ),
        ),
        onItemTapped: (index, controller) {
          if (index != 2) {
            controller.closeMenu!();
          }
        },
        items: [
          ActionChip(
            label: const Icon(Icons.delete),
            onPressed: () =>
                dashboard.removeElementConnection(element, handler),
          ),
          ActionChip(
            label: const Icon(Icons.control_point),
            onPressed: () {
              dashboard.dissectElementConnection(element, handler);
            },
          ),
          ValueListenableBuilder<double>(
            valueListenable: segmentedTension,
            builder: (_, tension, __) {
              return Wrap(
                children: [
                  ActionChip(
                    label: const Text('segmented'),
                    onPressed: () {
                      dashboard.setArrowStyleByHandler(
                        element,
                        handler,
                        ArrowStyle.segmented,
                        tension: tension,
                      );
                    },
                  ),
                  SizedBox(
                    width: 200,
                    child: Slider(
                      value: tension,
                      max: 3,
                      onChanged: (v) {
                        segmentedTension.value = v;
                        dashboard.setArrowStyleByHandler(
                          element,
                          handler,
                          ArrowStyle.segmented,
                          tension: v,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          ActionChip(
            label: const Text('curved'),
            onPressed: () {
              dashboard.setArrowStyleByHandler(
                element,
                handler,
                ArrowStyle.curve,
              );
            },
          ),
          ActionChip(
            label: const Text('rectangular'),
            onPressed: () {
              dashboard.setArrowStyleByHandler(
                element,
                handler,
                ArrowStyle.rectangular,
              );
            },
          ),
        ],
        parentContext: context,
      ),
    );
  }

  /// Display a drop down menu when tapping on an element
  /// 点击元素时显示下拉菜单
  void _displayElementMenu(BuildContext context,
      Offset position,
      FlowElement element,) {
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
          onHoverScale: 1.1,
          centerOffset: position - const Offset(50, 0),
          boundaryBackground: BoundaryBackground(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme
                  .of(context)
                  .cardColor,
              boxShadow: kElevationToShadow[6],
            ),
          ),
        ),
        onItemTapped: (index, controller) {
          if (!(index == 6 || index == 2)) {
            controller.closeMenu!();
          }
        },
        items: [
          Text(
            element.text,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          InkWell(
            onTap: () => dashboard.removeElement(element),
            child: const Text('Delete'),
          ),
          TextMenu(element: element),
          InkWell(
            onTap: () {
              dashboard.removeElementConnections(element);
            },
            child: const Text('Remove all connections'),
          ),
          // InkWell(
          //   onTap: () {
          //     dashboard.setElementDraggable(element, !element.isDraggable);
          //   },
          //   child:
          //       Text('Toggle Draggable (${element.isDraggable ? '✔' : '✘'})'),
          // ),
          InkWell(
            onTap: () {
              dashboard.setElementConnectable(element, !element.isConnectable);
            },
            child: Text(
              'Toggle Connectable (${element.isConnectable ? '✔' : '✘'})',
            ),
          ),
          InkWell(
            onTap: () {
              dashboard.setElementResizable(element, !element.isResizable);
            },
            child:
            Text('Toggle Resizable (${element.isResizable ? '✔' : '✘'})'),
          ),
          ElementSettingsMenu(
            element: element,
          ),
        ],
        parentContext: context,
      ),
    );
  }

  /// Display a menu for the dashboard
  /// 画布的菜单
  void _displayDashboardMenu(BuildContext context, Offset position) {
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
          centerOffset: position -
              Offset(
                dashboard.dashboardSize.width / 2,
                dashboard.dashboardSize.height / 2,
              ),
        ),
        onItemTapped: (index, controller) => controller.closeMenu!(),
        parentContext: context,
        items: [
          ActionChip(
            label: const Text('Add diamond'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(80, 80),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  kind: ElementKind.diamond,
                  handlers: [
                    Handler.bottomCenter,
                    Handler.topCenter,
                    Handler.leftCenter,
                    Handler.rightCenter,
                  ],
                ),
              );
            },
          ),
          ActionChip(
            label: const Text('Add rect'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(100, 50),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  // ignore: avoid_redundant_argument_values
                  kind: ElementKind.rectangle,
                  handlers: [
                    Handler.bottomCenter,
                    Handler.topCenter,
                    Handler.leftCenter,
                    Handler.rightCenter,
                  ],
                ),
              );
            },
          ),
          ActionChip(
            label:
            const Text('Add rect (draggable, resizable, not connectable)'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(100, 50),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  // ignore: avoid_redundant_argument_values
                  kind: ElementKind.rectangle,
                )
                  ..isDraggable = true
                  ..isResizable = true
                  ..isConnectable = false,
              );
            },
          ),
          ActionChip(
            label: const Text('Add oval'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(100, 50),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  kind: ElementKind.oval,
                  handlers: [
                    Handler.bottomCenter,
                    Handler.topCenter,
                    Handler.leftCenter,
                    Handler.rightCenter,
                  ],
                ),
              );
            },
          ),
          ActionChip(
            label: const Text('Add parallelogram'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(100, 50),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  kind: ElementKind.parallelogram,
                  handlers: [
                    Handler.bottomCenter,
                    Handler.topCenter,
                  ],
                ),
              );
            },
          ),
          ActionChip(
            label: const Text('Add hexagon'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(150, 100),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  kind: ElementKind.hexagon,
                  handlers: [
                    Handler.bottomCenter,
                    Handler.leftCenter,
                    Handler.rightCenter,
                    Handler.topCenter,
                  ],
                ),
              );
            },
          ),
          ActionChip(
            label: const Text('Add storage'),
            onPressed: () {
              dashboard.addElement(
                FlowElement(
                  position: position,
                  size: const Size(100, 150),
                  text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  kind: ElementKind.storage,
                  handlers: [
                    Handler.bottomCenter,
                    Handler.leftCenter,
                    Handler.rightCenter,
                  ],
                ),
              );
            },
          ),
          ActionChip(
            label: const Text('Add image'),
            onPressed: () async {
              final bytes = await pickImageBytes();
              if (bytes == null) return;

              dashboard.addElement(
                FlowElement(
                  position: position,
                  // size: const Size(200, 200),
                  // text: '${dashboard.elements.length}',
                  handlerSize: 25,
                  kind: ElementKind.image,
                  handlers: [
                    Handler.topCenter,
                    Handler.bottomCenter,
                    Handler.leftCenter,
                    Handler.rightCenter,
                  ],
                  data: Image
                      .memory(bytes)
                      .image,
                )
                  ..isResizable = true,
              );
            },
          ),
          ActionChip(
            label: const Text('Remove all'),
            onPressed: () {
              dashboard.removeAllElements();
            },
          ),
          ActionChip(
            label: const Text('SAVE dashboard'),
            onPressed: () => saveDashboard(dashboard),
          ),
          ActionChip(
            label: const Text('LOAD dashboard'),
            onPressed: () => loadDashboard(dashboard),
          ),
        ],
      ),
    );
  }
}
