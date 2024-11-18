import 'package:flutter/cupertino.dart';
import './element_settings_menu.dart';
import './platforms/hooks_mobile.dart'
if (dart.library.js) 'package:example/platforms/hooks_web.dart';
import './text_menu.dart';
import 'package:flutter/material.dart';
import 'package:diagram_flow/packages/flutter_flow_chart/flutter_flow_chart.dart';
import 'package:star_menu/star_menu.dart';

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
  Dashboard dashboard = Dashboard();

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
}
