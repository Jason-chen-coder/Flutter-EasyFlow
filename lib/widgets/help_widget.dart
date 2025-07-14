import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Help widget that shows what users can do with Flutter-EasyFlow
class HelpWidget extends StatelessWidget {
  const HelpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('你可以做什么 - What Can You Do'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Flutter-EasyFlow 功能介绍',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Flutter-EasyFlow 是一个强大的流程图创建和管理工具，让你能够轻松构建复杂的流程图和数据可视化图表。',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    // Quick tutorial button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Trigger tutorial overlay
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('互动教程即将推出！Interactive tutorial coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_circle_fill),
                        label: const Text('开始互动教程 - Start Interactive Tutorial'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Core Features Section
            _buildFeatureSection(
              context,
              '🎯 核心功能',
              [
                FeatureItem(
                  icon: Icons.add_box,
                  title: '节点管理',
                  description: '添加、删除、编辑和拖拽各种类型的节点',
                ),
                FeatureItem(
                  icon: Icons.hub,
                  title: '连接管理',
                  description: '在节点间创建连接线，建立流程关系',
                ),
                FeatureItem(
                  icon: Icons.zoom_in,
                  title: '画布交互',
                  description: '缩放、平移、点击画布进行各种操作',
                ),
                FeatureItem(
                  icon: Icons.data_object,
                  title: '实时数据',
                  description: '基于 JSON 数据实时渲染和更新流程图',
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Node Types Section
            _buildFeatureSection(
              context,
              '📐 节点类型',
              [
                FeatureItem(
                  icon: Icons.crop_square,
                  title: '矩形节点',
                  description: '标准流程步骤，最常用的节点类型',
                ),
                FeatureItem(
                  icon: Icons.change_history,
                  title: '菱形节点',
                  description: '决策点，用于条件判断和分支',
                ),
                FeatureItem(
                  icon: Icons.circle_outlined,
                  title: '椭圆节点',
                  description: '开始和结束节点，标记流程边界',
                ),
                FeatureItem(
                  icon: Icons.hexagon_outlined,
                  title: '六边形节点',
                  description: '特殊处理步骤或准备阶段',
                ),
                FeatureItem(
                  icon: Icons.storage,
                  title: '存储节点',
                  description: '数据存储和数据库操作',
                ),
                FeatureItem(
                  icon: Icons.image,
                  title: '图片节点',
                  description: '支持插入图片的自定义节点',
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Advanced Features Section
            _buildFeatureSection(
              context,
              '🚀 高级功能',
              [
                FeatureItem(
                  icon: Icons.group_work,
                  title: '分组管理',
                  description: '将相关节点组织到一起，便于管理',
                ),
                FeatureItem(
                  icon: Icons.edit_note,
                  title: 'JSON 编辑器',
                  description: '树形和文本模式编辑流程图数据',
                ),
                FeatureItem(
                  icon: Icons.palette,
                  title: '主题定制',
                  description: '自定义颜色、样式和外观',
                ),
                FeatureItem(
                  icon: Icons.devices,
                  title: '多平台支持',
                  description: 'Web、移动端、桌面端全平台兼容',
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Quick Start Section
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.play_circle_fill, color: Colors.green, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          '🎮 快速开始',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildQuickStartStep('1', '点击画布空白区域添加新节点'),
                    _buildQuickStartStep('2', '拖拽节点边缘连接点创建连接线'),
                    _buildQuickStartStep('3', '右键点击节点打开设置菜单'),
                    _buildQuickStartStep('4', '使用 JSON 编辑器查看和导出数据'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Future Features
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.upcoming, color: Colors.orange, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          '📋 即将推出',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('• 可折叠分组节点', style: Theme.of(context).textTheme.bodyLarge),
                    Text('• 本地数据持久化', style: Theme.of(context).textTheme.bodyLarge),
                    Text('• 动画 JSON 数据面板', style: Theme.of(context).textTheme.bodyLarge),
                    Text('• 更多自定义选项', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureSection(BuildContext context, String title, List<FeatureItem> features) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => _buildFeatureItem(context, feature)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(BuildContext context, FeatureItem feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(feature.icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickStartStep(String step, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  
  const FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}