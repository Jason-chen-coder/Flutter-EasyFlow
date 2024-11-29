import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../dashboard.dart';
import '../elements/flow_element.dart';
import './element_text_widget.dart';

/// A kind of element
class GroupWidget extends StatelessWidget {
  ///
  const GroupWidget({
    required this.dashboard,
    required this.element,
    super.key,
  });

  ///
  final FlowElement element;
  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    bool isSelected = dashboard.selectedElement == element.id;
    double toolbarIconWrapperSize = 30;
    double toolbarIconSize = 23;

    toolbarIconWrapperSize  = toolbarIconWrapperSize * element.zoom;
    toolbarIconSize  = toolbarIconSize * element.zoom;

    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 边框和阴影
          Container(
            decoration: BoxDecoration(
              border:isSelected ? Border.all(color:Color(0xFF31DA9F), width: 1.0):null,
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
         ),
          //  删除和编辑按钮
          isSelected ? Positioned(
            top: -10  * element.zoom,
            right: 10  * element.zoom,
            child: Row(
              children: [
                Container(
                  width: toolbarIconWrapperSize,
                  height: toolbarIconWrapperSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4f5158),
                    borderRadius: BorderRadius.circular(toolbarIconWrapperSize/2),
                  ),
                  child: Icon(Icons.edit, color: Colors.white, size: toolbarIconSize),
                ),
                SizedBox(width: 8 * element.zoom,),
                InkWell(
                    onTap: () {
                      dashboard.removeElementById(element.id);
                    },
                    child: Container(
                      width: toolbarIconWrapperSize,
                      height: toolbarIconWrapperSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4f5158),
                        borderRadius: BorderRadius.circular(toolbarIconWrapperSize/2),
                      ),
                      child: Icon(Icons.delete, color: Colors.white, size: toolbarIconSize),
                    )
                )
              ],
            ),
          ):SizedBox(),
        ],
      ),
    );
  }
}
