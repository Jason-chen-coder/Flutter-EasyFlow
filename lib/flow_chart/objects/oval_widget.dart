import 'package:flutter/material.dart';
import '../elements/flow_element.dart';
import './element_text_widget.dart';

/// A kind of element
class OvalWidget extends StatelessWidget {
  ///
  const OvalWidget({
    required this.element,
    super.key,
  });

  ///
  final FlowElement element;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: element.size,
            painter: _OvalPainter(
              element: element,
            ),
          ),
          ElementTextWidget(element: element),
        ],
      ),
    );
  }
}

class _OvalPainter extends CustomPainter {
  _OvalPainter({
    required this.element,
  });
  final FlowElement element;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();

    paint
      ..style = PaintingStyle.fill
      ..color = element.backgroundColor;

    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    if (element.elevation > 0.01) {
      canvas.drawShadow(
        path.shift(Offset(element.elevation, element.elevation)),
        Colors.black,
        element.elevation,
        true,
      );
    }
    canvas.drawPath(path, paint);

    paint
      ..strokeWidth = element.borderThickness
      ..color = element.borderColor
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
