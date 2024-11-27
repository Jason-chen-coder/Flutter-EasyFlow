import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../elements/flow_element.dart';
import './element_text_widget.dart';

/// A kind of element
class GroupWidget extends StatelessWidget {
  ///
  const GroupWidget({
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
          // 边框和阴影
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(element.borderRadius),
              color: element.backgroundColor,
              boxShadow: [
                if (element.elevation > 0.01)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // 阴影颜色和透明度
                    blurRadius: 10, // 模糊半径
                    spreadRadius: 0, // 扩散半径
                    offset: Offset(element.elevation, element.elevation), // 阴影偏移
                  ),
              ],
            ),
          ),
          // 图标和文字
         SizedBox(
           width: double.infinity,
           height: double.infinity,
           child: Icon(Icons.add, color: Color(0xFF31DA9F), size: element.iconSize),
         )
        ],
      ),
    );
  }
}
