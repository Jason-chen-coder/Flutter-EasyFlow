import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../dashboard.dart';
import '../elements/flow_element.dart';

/// A kind of element
class TaskWidget extends StatelessWidget {
  ///
  const TaskWidget({
    required this.dashboard,
    required this.element,
    required this.onElementOptionsPressed,
    super.key,
  });
  final Dashboard dashboard;

  ///
  final FlowElement element;

  final void Function(FlowElement element)? onElementOptionsPressed;

  @override
  Widget build(BuildContext context) {
    double toolbarIconWrapperSize = 20;
    double toolbarIconSize = 13;

    toolbarIconWrapperSize = toolbarIconWrapperSize * element.zoom;
    toolbarIconSize = toolbarIconSize * element.zoom;

    bool isSelected = dashboard.selectedElement == element.id;
    final titleTextStyle = TextStyle(
      color: element.textColor,
      fontSize: element.textSize,
    );
    final subtitleTextStyle = TextStyle(
      color: element.subTextColor,
      fontSize: element.subTitleTextSize,
    );
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 边框和阴影
          Container(
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: Color(0xFF31DA9F), width: 1.0)
                  : null,
              borderRadius: BorderRadius.circular(element.borderRadius),
              color: element.backgroundColor,
              boxShadow: [
                if (element.elevation > 0.01)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // 阴影颜色和透明度
                    blurRadius: 10, // 模糊半径
                    spreadRadius: 0, // 扩散半径
                    offset:
                        Offset(element.elevation, element.elevation), // 阴影偏移
                  ),
              ],
              // ),
            ),
          ),
          // 图标和文字
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 10 * element.zoom, vertical: 0),
            child: Row(children: [
              // 图标
              Container(
                margin: EdgeInsets.only(right: 10 * element.zoom),
                width: element.iconSize,
                height: element.iconSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Color(0xFFf7f7f7),
                  border: Border.all(
                    color: Color(0xFFF4F4F4),
                    width: 1,
                  ),
                ),
                child: Padding(
                    padding: EdgeInsets.all(4 * element.zoom),
                    child: SvgPicture.asset(
                      'assets/svg/ic_${TaskTypeExtension(element.taskType).toStringValue}.svg',
                      placeholderBuilder: (context) =>
                          const CircularProgressIndicator(),
                    )),
              ),
              // 文字
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      // "${element.position.dy}",
                      element.text,
                      style: titleTextStyle,
                    ),
                    SizedBox(height: 2 * element.zoom),
                    Text(
                      element.subTitleText,
                      style: subtitleTextStyle,
                    )
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(element.iconSize / 2),
                  onTap: () {
                    onElementOptionsPressed!(element);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(element.iconSize / 2),
                    ),
                    width: element.iconSize,
                    height: element.iconSize,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 * element.zoom),
                      child: SvgPicture.asset(
                        'assets/svg/ic_more.svg',
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          //  删除和编辑按钮
          (isSelected &&
                  element.taskType != TaskType.trigger &&
                  element.taskType != TaskType.end)
              ? Positioned(
                  top: -10 * element.zoom,
                  right: 10 * element.zoom,
                  child: Row(
                    children: [
                      Container(
                        width: toolbarIconWrapperSize,
                        height: toolbarIconWrapperSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4f5158),
                          borderRadius:
                              BorderRadius.circular(toolbarIconWrapperSize / 2),
                        ),
                        child: Icon(Icons.edit,
                            color: Colors.white, size: toolbarIconSize),
                      ),
                      SizedBox(
                        width: 8 * element.zoom,
                      ),
                      InkWell(
                          onTap: () {
                            if (element.parentId == "") {
                              dashboard.removeElementById(element.id);
                            } else {
                              dashboard
                                  .removeElementInGroupByElementId(element.id);
                            }
                          },
                          child: Container(
                            width: toolbarIconWrapperSize,
                            height: toolbarIconWrapperSize,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4f5158),
                              borderRadius: BorderRadius.circular(
                                  toolbarIconWrapperSize / 2),
                            ),
                            child: Icon(Icons.delete,
                                color: Colors.white, size: toolbarIconSize),
                          ))
                    ],
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
