import 'dart:ui';

// ==================== 提词器参数限制 ====================

/// 提词器最小滚动速度（行/秒）
const double kPrompterMinSpeed = 0.1;

/// 提词器最大滚动速度（行/秒）
const double kPrompterMaxSpeed = 20.0;

/// 提词器最小字体大小（点）
const double kPrompterMinFontSize = 12.0;

/// 提词器最大字体大小（点）
const double kPrompterMaxFontSize = 420.0;

/// 侧边距最小值（百分比）
const double kPrompterMinSideMargin = 0.0;

/// 侧边距最大值（百分比）
const double kPrompterMaxSideMargin = 99.0;

// ==================== 可用字体列表 ====================

/// 应用支持的所有字体系列
/// - Roboto: 标准 Google 字体
/// - RobotoMono: 等宽字体
/// - RobotoSlab: 衬线字体
/// - OpenDyslexic: 阅读障碍友好字体
const List<String> kAvailableFonts = [
  'Roboto',
  'RobotoMono',
  'RobotoSlab',
  'OpenDyslexic',
];

// ==================== 国际化支持 ====================

/// 应用支持的所有语言
/// 格式：(显示名称, Locale对象)
const kSupportedLocales = [
  ("English", Locale("en", "US")),
  ("简体中文", Locale("zh", "CN")),
  ("Deutsch", Locale("de", "DE")),
  ("Pirate English", ExtendedLocale("en", "pirate")), // 海盗英语（彩蛋）
];

/// 扩展的 Locale 类，支持特殊的语言代码格式
/// 用于支持非标准的语言代码，如 "en@pirate"
class ExtendedLocale extends Locale {
  const ExtendedLocale(super.languageCode, [super.countryCode]);

  /// 重写 toString 方法，将下划线替换为 @ 符号
  /// 例如：en_pirate -> en@pirate
  @override
  String toString() {
    return super.toString().split("_").join("@");
  }
}

// ==================== 功能特性系统 ====================

/// 应用的所有功能特性枚举
/// 用于区分免费版和专业版的功能
enum Feature {
  appLanguage,              // 应用语言设置
  appTheme,                 // 应用主题（亮色/暗色）
  primaryAppColor,          // 应用主题色
  scrollSpeed,              // 滚动速度调整
  flipX,                    // X轴镜像（水平翻转）
  flipY,                    // Y轴镜像（垂直翻转）
  readingIndicatorBoxes,    // 助读区显示
  verticalMargins,          // 垂直遮罩
  verticalMarginFade,       // 遮罩渐变效果
  sideMargins,              // 侧边距调整
  countdownTimer,           // 倒计时功能
  prompterBackgroundColor,  // 提词器背景色
  prompterTextColor,        // 提词器文本色
  fontSize,                 // 字体大小
  textAlignment,            // 文本对齐
  fontFamily,               // 字体选择
}

/// 应用版本类型
/// 用于区分不同的构建版本和功能权限
enum FeatureKind {
  unverifiedBuild,  // 未验证构建（开发版，所有功能可用但有警告）
  freeVersion,      // 免费版（基础功能）
  paidVersion,      // 专业版（所有功能）
  fossVersion       // 开源版（所有功能，从 F-Droid 等渠道下载）
}

/// 功能特性的描述文本映射
/// 键：功能特性枚举
/// 值：对应的国际化翻译键
const kFeatureDescriptions = {
  Feature.appLanguage: "app_language_description",
  Feature.appTheme: "app_theme_description",
  Feature.primaryAppColor: "primary_app_color_description",
  Feature.scrollSpeed: "scroll_speed_description",
  Feature.flipX: "flip_x_description",
  Feature.flipY: "flip_y_description",
  Feature.readingIndicatorBoxes: "reading_indicator_boxes_description",
  Feature.verticalMargins: "vertical_margins_description",
  Feature.verticalMarginFade: "vertical_margin_fade_description",
  Feature.sideMargins: "side_margins_description",
  Feature.countdownTimer: "countdown_timer_description",
  Feature.prompterBackgroundColor: "prompter_background_color_description",
  Feature.prompterTextColor: "prompter_text_color_description",
  Feature.fontSize: "font_size_description",
  Feature.textAlignment: "text_alignment_description",
  Feature.fontFamily: "font_family_description",
};

/// 所有功能特性列表（专业版和开源版可用）
const kAllFeatures = [
  Feature.appLanguage,
  Feature.appTheme,
  Feature.primaryAppColor,
  Feature.scrollSpeed,
  Feature.flipX,
  Feature.flipY,
  Feature.readingIndicatorBoxes,
  Feature.verticalMargins,
  Feature.verticalMarginFade,
  Feature.sideMargins,
  Feature.countdownTimer,
  Feature.prompterBackgroundColor,
  Feature.prompterTextColor,
  Feature.fontSize,
  Feature.textAlignment,
  Feature.fontFamily,
];

/// 免费版可用的功能列表（基础功能）
const kFreeFeatures = [
  Feature.appLanguage,
  Feature.appTheme,
  Feature.scrollSpeed,
  Feature.flipX,
  Feature.flipY,
  Feature.readingIndicatorBoxes,
  Feature.sideMargins,
  Feature.fontSize,
  Feature.textAlignment,
];

// ==================== 应用内购买 ====================

/// 专业版产品 ID（用于应用内购买）
const kProId = "io.github.tiefseetauchner.promptify.pro";

/// API 端点常量
abstract class ApiEndpoints {
  /// 基础 URL - 可在此切换本地/云端服务
  /// 开发环境：http://localhost:5000
  /// 生产环境：https://api.example.com
  static const String baseUrl = 'http://localhost:5000/api';

  // ===== 认证端点 =====
  static const String loginPhone = '/auth/login-phone';
  static const String registerPhone = '/auth/register-phone';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String loginWeChat = '/auth/login-wechat';
  static const String loginAlipay = '/auth/login-alipay';

  // ===== 支付端点 =====
  static const String createOrder = '/payment/create-order';
  static const String queryOrder = '/payment/order';
  static const String confirmPayment = '/payment/confirm';

  // ===== 用户端点 =====
  static const String getUserProfile = '/user/profile';
  static const String updateUserProfile = '/user/profile';
  static const String getUserScripts = '/user/scripts';
  static const String deleteScript = '/user/scripts';
}

/// 应用配置
abstract class AppConfig {
  /// Token 过期时间（单位：小时）
  static const int tokenExpirationHours = 24;
  
  /// Token 刷新提前时间（单位：分钟）
  /// 当 Token 还剩 5 分钟过期时自动刷新
  static const int tokenRefreshBeforeMinutes = 5;
  
  /// HTTP 请求超时时间（单位：秒）
  static const int httpTimeoutSeconds = 30;
  
  /// 微信 App ID（开发时先用 Mock，后续替换）
  static const String wechatAppId = 'WECHAT_APP_ID_PLACEHOLDER';
  
  /// 支付宝 App ID（开发时先用 Mock，后续替换）
  static const String alipayAppId = 'ALIPAY_APP_ID_PLACEHOLDER';
}

/// Mock 数据配置
abstract class MockConfig {
  /// 是否使用 Mock 数据
  /// 在真实后端没有准备好前，设置为 true
  static const bool useMockData = true;
  
  /// Mock 网络延迟（单位：毫秒）
  /// 模拟真实网络环境的延迟
  static const int mockNetworkDelay = 500;
  
  /// 是否打印 Debug 日志
  static const bool enableDebugLogging = true;
}
