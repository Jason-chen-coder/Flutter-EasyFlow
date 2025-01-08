import 'package:flutter/material.dart';

import '../dashboard.dart';
import '../elements/flow_element.dart';
import 'draw_arrow.dart';

class DrawGroupColumnPlus extends StatefulWidget {
  ///
  DrawGroupColumnPlus({
    required this.srcElement,
    this.onGroupColumnPlusNodePressed,
    super.key,
    ArrowParams? arrowParams,
    required this.dashboard,
  }) : arrowParams = arrowParams ?? ArrowParams();

  ///
  final Dashboard dashboard;

  ///
  final ArrowParams arrowParams;

  ///
  final FlowElement srcElement;

  final void Function(BuildContext context, Offset position)?
      onGroupColumnPlusNodePressed;

  @override
  State<DrawGroupColumnPlus> createState() => _DrawArrowState();
}

class _DrawArrowState extends State<DrawGroupColumnPlus> {
  @override
  void initState() {
    super.initState();
    widget.srcElement.addListener(_elementChanged);
  }

  @override
  void dispose() {
    widget.srcElement.removeListener(_elementChanged);
    super.dispose();
  }

  void _elementChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = widget.srcElement.iconSize;
    double nodeSize = iconSize * 0.6;
    var pivotPlus = Offset(
        widget.srcElement.getHandlerPosition(Alignment.bottomCenter).dx -
            (widget.dashboard.position.dx) -
            nodeSize / 2,
        widget.srcElement.getHandlerPosition(Alignment.bottomCenter).dy -
            (widget.dashboard.position.dy) +
            defaultNodeDistance / 2 * widget.dashboard.zoomFactor);
    double textSize = (0.8 * nodeSize);

    return Transform.translate(
      offset: pivotPlus,
      child: SizedBox(
        width: nodeSize,
        height: nodeSize,
        child: GestureDetector(
          onTap: () {
            widget.onGroupColumnPlusNodePressed?.call(
                context,
                Offset(
                    pivotPlus.dx + nodeSize / 2, pivotPlus.dy + nodeSize / 2));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xfff6f6f6),
              borderRadius: BorderRadius.all(
                Radius.circular(widget.srcElement.borderRadius),
              ),
            ),
            child:
                // Text("${pivotPlus.dy}"),
                Icon(
              Icons.add,
              color: const Color(0xFF31DA9F),
              size: textSize,
            ),
          ),
        ),
      ),
    );
  }
}
