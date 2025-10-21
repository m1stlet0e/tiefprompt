import 'package:flutter/material.dart';

/// 倒计时组件
///
/// 在提词器开始播放前显示一个倒计时，让用户有准备时间
/// 显示一个圆形进度条和倒计时数字
///
/// **使用场景**：
/// - 用户点击播放后，给予准备时间（如3秒）
/// - 倒计时结束后自动开始滚动
///
/// **视觉效果**：
/// - 圆形进度条逐渐减少
/// - 中心显示剩余秒数
class CountdownTimer extends StatefulWidget {
  /// 倒计时总时长（秒）
  final int duration;

  const CountdownTimer({super.key, required this.duration});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  /// 剩余时间（秒）
  late int remainingTime;
  
  /// 进度值（0.0-1.0）
  late double progress;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.duration;
    progress = 1.0;  // 开始时进度条满的
    startCountdown();
  }

  /// 开始倒计时
  /// 
  /// 使用递归的Future.delayed实现每秒tick
  void startCountdown() {
    Future.delayed(const Duration(seconds: 1), tick);
  }

  /// 每秒执行一次
  /// 
  /// 更新剩余时间和进度，当时间未到时继续递归调用
  void tick() {
    if (!mounted) return;  // 防止组件已销毁时更新状态
    
    if (remainingTime > 0) {
      setState(() {
        remainingTime--;
        progress = remainingTime / widget.duration;  // 计算进度百分比
      });
      startCountdown();  // 递归调用，继续倒计时
    }
  }

  /// 构建倒计时UI
  ///
  /// 布局结构：
  /// - 外层：200x200的容器
  /// - 背景：灰色圆形
  /// - 进度条：蓝色圆形进度指示器
  /// - 中心文字：显示剩余秒数
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 进度条层
          Stack(
            children: [
              // 背景圆圈
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
              ),
              // 圆形进度条
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,  // 进度值（0.0-1.0）
                  strokeWidth: 16,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ],
          ),
          // 中心数字
          Text(
            '$remainingTime',
            key: ValueKey<int>(remainingTime),  // 使用ValueKey确保动画正确
            style: const TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
