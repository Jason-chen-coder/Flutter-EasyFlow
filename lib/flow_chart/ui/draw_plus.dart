import 'package:flutter/material.dart';

import '../dashboard.dart';
import '../elements/flow_element.dart';
import './segment_handler.dart';
import 'draw_arrow.dart';

class DrawPlus extends StatefulWidget {
  ///
  DrawPlus({
    required this.srcElement,
    required this.destElement,
    required List<Pivot> pivots,
    this.onPlusNodePressed,
    super.key,
    ArrowParams? arrowParams,
    required this.dashboard,
  })  : arrowParams = arrowParams ?? ArrowParams(),
        pivots = PivotsNotifier(pivots);

  ///
  final Dashboard dashboard;

  ///
  final ArrowParams arrowParams;

  ///
  final FlowElement srcElement;

  ///
  final FlowElement destElement;

  ///
  final PivotsNotifier pivots;

  final void Function(BuildContext context, Offset position)? onPlusNodePressed;

  @override
  State<DrawPlus> createState() => _DrawArrowState();
}

class _DrawArrowState extends State<DrawPlus> {
  @override
  void initState() {
    super.initState();
    widget.srcElement.addListener(_elementChanged);
    widget.destElement.addListener(_elementChanged);
    widget.pivots.addListener(_elementChanged);
  }

  @override
  void dispose() {
    widget.srcElement.removeListener(_elementChanged);
    widget.destElement.removeListener(_elementChanged);
    widget.pivots.removeListener(_elementChanged);
    super.dispose();
  }

  void _elementChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var from = Offset.zero;
    var to = Offset.zero;

    from = Offset(
      widget.srcElement.position.dx -
          (widget.dashboard.position.dx) +
          widget.srcElement.handlerSize / 2.0 +
          (widget.srcElement.size.width *
              ((widget.arrowParams.startArrowPosition.x + 1) / 2)),
      widget.srcElement.position.dy -
          (widget.dashboard.position.dy) +
          widget.srcElement.handlerSize / 2.0 +
          (widget.srcElement.size.height *
              ((widget.arrowParams.startArrowPosition.y + 1) / 2)),
    );
    to = Offset(
      widget.destElement.position.dx -
          (widget.dashboard.position.dx) +
          widget.destElement.handlerSize / 2.0 +
          (widget.destElement.size.width *
              ((widget.arrowParams.endArrowPosition.x + 1) / 2)),
      widget.destElement.position.dy -
          (widget.dashboard.position.dy) +
          widget.destElement.handlerSize / 2.0 +
          (widget.destElement.size.height *
              ((widget.arrowParams.endArrowPosition.y + 1) / 2)),
    );
    double plusNodeSize = widget.arrowParams.plusNodeSize;
    var pivotPlus = Offset(from.dx + ((to.dx - from.dx - plusNodeSize) / 2),
        from.dy + ((to.dy - from.dy - plusNodeSize) / 2));
    double textSize = (0.56 * plusNodeSize);

    return Transform.translate(
      offset: pivotPlus,
      child: SizedBox(
        width: plusNodeSize,
        height: plusNodeSize,
        child: GestureDetector(
          onTap: () {
            widget.onPlusNodePressed?.call(
                context,
                Offset(pivotPlus.dx + plusNodeSize / 2,
                    pivotPlus.dy + plusNodeSize / 2));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(widget.destElement.borderRadius),
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

/// Paint the arrow connection taking in count the
/// [ArrowParams.startArrowPosition] and
/// [ArrowParams.endArrowPosition] alignment.

/// Notifier for pivot points.
class PivotsNotifier extends ValueNotifier<List<Pivot>> {
  ///
  PivotsNotifier(super.value) {
    for (final pivot in value) {
      pivot.addListener(notifyListeners);
    }
  }

  /// Add a pivot point.
  void add(Pivot pivot) {
    value.add(pivot);
    pivot.addListener(notifyListeners);
    notifyListeners();
  }

  /// Remove a pivot point.
  void remove(Pivot pivot) {
    value.remove(pivot);
    pivot.removeListener(notifyListeners);
    notifyListeners();
  }

  /// Insert a pivot point.
  void insert(int index, Pivot pivot) {
    value.insert(index, pivot);
    pivot.addListener(notifyListeners);
    notifyListeners();
  }

  /// Remove a pivot point by its index.
  void removeAt(int index) {
    value.removeAt(index).removeListener(notifyListeners);
    notifyListeners();
  }
}
