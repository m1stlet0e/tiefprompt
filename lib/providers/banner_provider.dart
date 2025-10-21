import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Banner消息提供者
///
/// 用于在应用顶部显示全局消息（如错误、提示等）
/// 当有消息时，BannerListener会自动显示消息横幅
final bannerMessageProvider = StateProvider<String?>((ref) => null);
