import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:promptify/core/constants.dart';
import 'package:promptify/providers/feature_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// 个人资料页面
///
/// 简洁的个人中心，包含以下功能：
/// - 用户头像和欢迎信息
/// - 应用版本信息
/// - 快速访问链接（关于、源代码、隐私政策）
/// - 未来将添加：用户登录、订阅管理等
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  /// 获取应用包信息（版本号等）
  Future<PackageInfo> _getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr("ProfileScreen.title"),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 56,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    theme.scaffoldBackgroundColor,
                    theme.scaffoldBackgroundColor,
                  ]
                : [
                    Color(0xFFFAFBFF),
                    Color(0xFFF0F4FF),
                  ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // 用户信息卡片
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.dividerColor.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 48,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.tr("ProfileScreen.welcome_message"),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<PackageInfo>(
                          future: _getPackageInfo(),
                          builder: (context, snapshot) => Text(
                            "v${snapshot.data?.version ?? 'unknown'}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFA0AEC0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 快速链接
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr("ProfileScreen.more_options"),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFA0AEC0),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickLink(
                      icon: Icons.info_outline,
                      title: context.tr("HomeScreen.IconButton_About"),
                      onTap: () => _showAboutDialog(context),
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                    _buildQuickLink(
                      icon: Icons.privacy_tip_outlined,
                      title: context.tr("ProfileScreen.privacy_policy"),
                      onTap: () => _launchUrl(
                        "https://www.lukechriswalker.at/projects/fe5a26d763326489020000a4",
                      ),
                      theme: theme,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建快速链接按钮
  Widget _buildQuickLink({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: Color(0xFFA0AEC0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String uri) async {
    final Uri url = Uri.parse(uri);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: context.tr("title"),
      applicationLegalese:
          "${context.tr("copyright")}\n${context.tr("credits")}",
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr("AboutDialog.Text_PrivacyText"),
                style: TextStyle(fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _launchUrl(
                  "https://www.lukechriswalker.at/projects/fe5a26d763326489020000a4",
                ),
                child: Text(
                  context.tr("AboutDialog.ElevatedButton_Privacy"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
