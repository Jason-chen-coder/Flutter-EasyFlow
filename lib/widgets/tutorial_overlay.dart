import 'package:flutter/material.dart';

/// Tutorial overlay widget that shows interactive tips
class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const TutorialOverlay({
    super.key,
    required this.child,
    this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  int currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<TutorialStep> tutorialSteps = [
    TutorialStep(
      title: '欢迎使用 Flutter-EasyFlow!',
      description: '让我们通过简单的教程来了解基本功能',
      position: TutorialPosition.center,
      targetKey: null,
    ),
    TutorialStep(
      title: '画布区域',
      description: '这是主要的工作区域。点击空白处可以添加新节点',
      position: TutorialPosition.center,
      targetKey: null,
    ),
    TutorialStep(
      title: '节点操作',
      description: '右键点击节点可以打开设置菜单，编辑属性和样式',
      position: TutorialPosition.topLeft,
      targetKey: null,
    ),
    TutorialStep(
      title: '连接节点',
      description: '拖拽节点边缘的连接点可以创建连接线',
      position: TutorialPosition.bottomRight,
      targetKey: null,
    ),
    TutorialStep(
      title: 'JSON 编辑器',
      description: '右侧的 JSON 编辑器可以查看和编辑流程图数据',
      position: TutorialPosition.left,
      targetKey: null,
    ),
    TutorialStep(
      title: '完成教程',
      description: '现在你可以开始创建自己的流程图了！点击画布试试看',
      position: TutorialPosition.center,
      targetKey: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (currentStep < tutorialSteps.length - 1) {
      setState(() {
        currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _completeTutorial() {
    widget.onComplete?.call();
  }

  void _skipTutorial() {
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final currentTutorialStep = tutorialSteps[currentStep];
    
    return Stack(
      children: [
        widget.child,
        
        // Semi-transparent overlay
        Container(
          color: Colors.black.withOpacity(0.7),
          child: const SizedBox.expand(),
        ),
        
        // Tutorial content
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: 20,
          right: 20,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (currentStep + 1) / tutorialSteps.length,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${currentStep + 1}/${tutorialSteps.length}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(
                      currentTutorialStep.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Description
                    Text(
                      currentTutorialStep.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip button
                        TextButton(
                          onPressed: _skipTutorial,
                          child: const Text('跳过教程'),
                        ),
                        
                        // Navigation buttons
                        Row(
                          children: [
                            if (currentStep > 0)
                              TextButton(
                                onPressed: _previousStep,
                                child: const Text('上一步'),
                              ),
                            
                            const SizedBox(width: 8),
                            
                            ElevatedButton(
                              onPressed: _nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                currentStep == tutorialSteps.length - 1 ? '完成' : '下一步',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Highlight area (if targetKey is provided)
        if (currentTutorialStep.targetKey != null)
          _buildHighlightArea(currentTutorialStep),
      ],
    );
  }

  Widget _buildHighlightArea(TutorialStep step) {
    // This would need to be implemented based on the target widget
    // For now, just return an empty container
    return Container();
  }
}

class TutorialStep {
  final String title;
  final String description;
  final TutorialPosition position;
  final GlobalKey? targetKey;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.position,
    this.targetKey,
  });
}

enum TutorialPosition {
  center,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  left,
  right,
  top,
  bottom,
}

/// Widget to show tutorial for first-time users
class TutorialManager extends StatefulWidget {
  final Widget child;
  final bool showTutorial;
  final VoidCallback? onTutorialComplete;

  const TutorialManager({
    super.key,
    required this.child,
    this.showTutorial = false,
    this.onTutorialComplete,
  });

  @override
  State<TutorialManager> createState() => _TutorialManagerState();
}

class _TutorialManagerState extends State<TutorialManager> {
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _showTutorial = widget.showTutorial;
  }

  void _onTutorialComplete() {
    setState(() {
      _showTutorial = false;
    });
    widget.onTutorialComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_showTutorial) {
      return TutorialOverlay(
        onComplete: _onTutorialComplete,
        child: widget.child,
      );
    }
    
    return widget.child;
  }
  
  /// Show tutorial programmatically
  void showTutorial() {
    setState(() {
      _showTutorial = true;
    });
  }
}