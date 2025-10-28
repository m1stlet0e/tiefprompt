import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:promptify/core/constants.dart';
import 'package:promptify/providers/auth_provider.dart';
import 'package:promptify/providers/feature_provider.dart';
import 'package:promptify/ui/screens/login_screen.dart';
import 'package:promptify/ui/screens/payment_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// 个人资料页面
///
/// 简洁的个人中心，包含以下功能：
/// - 用户头像和欢迎信息
/// - 应用版本信息
/// - 快速访问链接（关于、源代码、隐私政策）
/// - 用户登录、订阅管理
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
    
    // 监听认证状态
    final userAsync = ref.watch(currentUserProvider);

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
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            // 未登录状态
            return _buildUnAuthenticatedView(context, theme);
          } else {
            // 已登录状态
            return _buildAuthenticatedView(context, theme, user);
          }
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  /// 未登录视图
  Widget _buildUnAuthenticatedView(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.brightness == Brightness.dark
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: theme.primaryColor),
            SizedBox(height: 24),
            Text('你还未登录', style: theme.textTheme.headlineSmall),
            SizedBox(height: 12),
            Text('登录后可享受更多功能'),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              icon: Icon(Icons.login),
              label: Text('立即登录'),
            ),
          ],
        ),
      ),
    );
  }

  /// 已登录视图
  Widget _buildAuthenticatedView(
    BuildContext context,
    ThemeData theme,
    dynamic user,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.brightness == Brightness.dark
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
            // 用户信息卡片
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text(
                    user.nickname ?? 'User',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user.phone ?? 'No phone',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            // 会员状态
            ListTile(
              title: Text('会员状态'),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: user.isPaidUser ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.isPaidUser ? '专业版' : '免费版',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // 升级到专业版
            if (!user.isPaidUser)
              ListTile(
                title: Text('升级专业版'),
                subtitle: Text('解锁所有高级功能'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentScreen()),
                  );
                },
              ),
            
            Divider(),
            
            // 快速链接
            ListTile(
              title: Text('关于应用'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => _showAboutDialog(context),
            ),
            
            ListTile(
              title: Text('隐私政策'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => _launchUrl(
                "https://www.lukechriswalker.at/projects/fe5a26d763326489020000a4",
              ),
            ),
            
            Divider(),
            
            // 登出按钮
            ListTile(
              title: Text('登出'),
              trailing: Icon(Icons.logout),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('确认登出？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(currentUserProvider.notifier).logout();
                          Navigator.pop(context);
                        },
                        child: Text('登出'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
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
