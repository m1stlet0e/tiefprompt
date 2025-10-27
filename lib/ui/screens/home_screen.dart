import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tiefprompt/core/constants.dart';
import 'package:tiefprompt/providers/feature_provider.dart';
import 'package:tiefprompt/providers/prompter_provider.dart';
import 'package:tiefprompt/providers/script_provider.dart';
import 'package:tiefprompt/services/script_service.dart';
import 'package:tiefprompt/ui/screens/profile_screen.dart';

/// 主页屏幕
///
/// 应用的主界面，包含以下功能：
/// - 稿件输入框：输入或粘贴提词器稿件
/// - 已保存稿件列表：显示数据库中的所有稿件
/// - 功能按钮：打开文件、进入提词器、设置等
/// - 侧边抽屉：关于信息、许可证、购买专业版等
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// 稿件输入框控制器
  late TextEditingController _controller;
  
  /// 稿件Provider的监听订阅
  /// 用于同步Provider状态到输入框
  ProviderSubscription? _scriptListener;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  /// 当依赖的Provider变化时调用
  ///
  /// 这里设置监听器，将稿件Provider的文本同步到输入框
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 关闭旧的监听器（如果存在）
    _scriptListener?.close();
    
    // 监听稿件Provider的变化
    _scriptListener = ref.listenManual(scriptProvider, (previous, next) {
      // 当稿件文本变化时，更新输入框内容
      // 但要避免在用户正在输入时更新（检查composing状态）
      if (previous?.text != next.text &&
          _controller.text != next.text &&
          !_controller.value.composing.isValid) {
        // 将光标移到末尾
        final selection = TextSelection.collapsed(offset: next.text.length);
        _controller.value = TextEditingValue(
          text: next.text,
          selection: selection,
        );
      }
    });
  }

  @override
  void dispose() {
    _scriptListener?.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 注册字体许可证，用于"关于"页面显示
    LicenseRegistry.addLicense(() async* {
      final openDyslexicLicense = await rootBundle.loadString(
        'assets/licenses/openDyslexicLicense.txt',
      );
      yield LicenseEntryWithLineBreaks(['OpenDyslexic'], openDyslexicLicense);
      final robotoLicense = await rootBundle.loadString(
        'assets/licenses/robotoLicense.txt',
      );
      yield LicenseEntryWithLineBreaks(['roboto'], robotoLicense);
      final robotoMonoLicense = await rootBundle.loadString(
        'assets/licenses/robotoMonoLicense.txt',
      );
      yield LicenseEntryWithLineBreaks(['roboto mono'], robotoMonoLicense);
      final robotoSlabLicense = await rootBundle.loadString(
        'assets/licenses/robotoSlabLicense.txt',
      );
      yield LicenseEntryWithLineBreaks(['roboto slab'], robotoSlabLicense);
    });

    // 获取主题色
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // 高级品牌化 AppBar - 左上角个人 + 右上角设置
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.person_outline, size: 24),
          onPressed: () {
            // 从左到右的页面切换动画
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return const ProfileScreen();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;
                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  final offsetAnimation = animation.drive(tween);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          tooltip: context.tr("HomeScreen.IconButton_Profile"),
        ),
        title: Column(
          children: [
            Text(
              context.tr("title"),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            // 品牌 Slogan
            Text(
              "专注你的表达",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 72,
        actions: [
          // 右上角设置按钮
          IconButton(
            icon: Icon(Icons.settings_outlined, size: 24),
            onPressed: () => context.push('/settings'),
            tooltip: context.tr("HomeScreen.IconButton_Settings"),
          ),
        ],
      ),
      // 高级渐变背景 + 品牌纹理
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
        // 添加品牌水印纹理
        child: Stack(
          children: [
            // 品牌水印
            if (!isDark)
              Positioned(
                top: 80,
                right: -50,
                child: Opacity(
                  opacity: 0.03,
                  child: Icon(
                    Icons.mic,
                    size: 280,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            // 主内容 - 充满整个屏幕
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // 高级输入框
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                  offset: Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(isDark ? 0 : 0.8),
                                  blurRadius: 4,
                                  offset: Offset(0, -1),
                                ),
                              ],
                            ),
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.75,
                                color: Color(0xFF2D3748),
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: theme.cardColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor.withOpacity(0.08),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Color(0xFF5E7CE2),
                                    width: 2,
                                  ),
                                ),
                                hintText: context.tr("HomeScreen.TextField_hintText"),
                                hintStyle: TextStyle(
                                  color: Color(0xFFA0AEC0),
                                  fontSize: 15,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                              ),
                              maxLines: (MediaQuery.of(context).size.height / 70).floor(),
                              controller: _controller,
                              onChanged: (value) {
                                ref.read(scriptProvider.notifier).setText(value);
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          // 高级按钮布局
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF5E7CE2).withOpacity(0.25),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                ref.invalidate(prompterProvider);
                                context.push('/teleprompter');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF5E7CE2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.tr("HomeScreen.ElevatedButton_Start"),
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 次要按钮
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    context.push('/open_file');
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Color(0xFF4A5568),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.folder_open_outlined,
                                    size: 18,
                                    color: Color(0xFFA0AEC0),
                                  ),
                                  label: Text(
                                    context.tr("HomeScreen.ElevatedButton_Select"),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                  child: VerticalDivider(
                                    color: Color(0xFFA0AEC0).withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (dialogContext) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: theme.scaffoldBackgroundColor,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(24),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.15),
                                                blurRadius: 20,
                                                offset: Offset(0, -4),
                                              ),
                                            ],
                                          ),
                                          child: SafeArea(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                24.0,
                                                28.0,
                                                24.0,
                                                MediaQuery.of(context).viewInsets.bottom + 24.0,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                    child: Container(
                                                      width: 40,
                                                      height: 4,
                                                      margin: EdgeInsets.only(bottom: 20),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFA0AEC0).withOpacity(0.3),
                                                        borderRadius: BorderRadius.circular(2),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    context.tr("HomeScreen.BottomSheet.Text_Title"),
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF2D3748),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  TextField(
                                                    autofocus: true,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: theme.cardColor,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                        borderSide: BorderSide.none,
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                        borderSide: BorderSide(
                                                          color: Color(0xFFA0AEC0).withOpacity(0.2),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                        borderSide: BorderSide(
                                                          color: Color(0xFF5E7CE2),
                                                          width: 2,
                                                        ),
                                                      ),
                                                      hintText: context.tr(
                                                        "HomeScreen.BottomSheet.TextField_hintText",
                                                      ),
                                                      hintStyle: TextStyle(
                                                        color: Color(0xFFA0AEC0),
                                                      ),
                                                      contentPadding: EdgeInsets.all(16),
                                                    ),
                                                    onChanged: (value) => ref
                                                        .read(scriptProvider.notifier)
                                                        .setTitle(value),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    height: 52,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        ScriptService().save(
                                                          ref.watch(scriptProvider),
                                                        );
                                                        dialogContext.pop();
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Color(0xFF5E7CE2),
                                                        foregroundColor: Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        elevation: 0,
                                                      ),
                                                      child: Text(
                                                        context.tr(
                                                          "HomeScreen.BottomSheet.ElevatedButton_Save",
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          letterSpacing: 0.3,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Color(0xFF4A5568),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.save_outlined,
                                    size: 18,
                                    color: Color(0xFFA0AEC0),
                                  ),
                                  label: Text(
                                    context.tr('HomeScreen.ElevatedButton_Save'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
