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
const kProId = "io.github.tiefseetauchner.tiefprompt.pro";
