import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptify/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _loginPhoneController;
  late TextEditingController _loginPasswordController;
  late TextEditingController _registerPhoneController;
  late TextEditingController _registerPasswordController;
  late TextEditingController _registerNicknameController;

  bool _loginPasswordVisible = false;
  bool _registerPasswordVisible = false;
  bool _isLoggingIn = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loginPhoneController = TextEditingController();
    _loginPasswordController = TextEditingController();
    _registerPhoneController = TextEditingController();
    _registerPasswordController = TextEditingController();
    _registerNicknameController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _registerPhoneController.dispose();
    _registerPasswordController.dispose();
    _registerNicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final phone = _loginPhoneController.text.trim();
    final password = _loginPasswordController.text;

    if (phone.isEmpty || password.isEmpty) {
      _showSnackBar('请输入手机号和密码');
      return;
    }

    setState(() => _isLoggingIn = true);

    try {
      await ref
          .read(currentUserProvider.notifier)
          .loginWithPhone(phone, password);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('登录失败: $e');
    } finally {
      setState(() => _isLoggingIn = false);
    }
  }

  Future<void> _handleRegister() async {
    final phone = _registerPhoneController.text.trim();
    final password = _registerPasswordController.text;
    final nickname = _registerNicknameController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showSnackBar('请输入手机号和密码');
      return;
    }

    setState(() => _isRegistering = true);

    try {
      await ref
          .read(currentUserProvider.notifier)
          .registerWithPhone(phone, password, nickname.isEmpty ? null : nickname);

      if (mounted) {
        _showSnackBar('注册成功');
        _tabController.animateTo(0);
        _loginPhoneController.text = phone;
        _loginPasswordController.text = password;
      }
    } catch (e) {
      _showSnackBar('注册失败: $e');
    } finally {
      setState(() => _isRegistering = false);
    }
  }

  Future<void> _handleWechatLogin() async {
    try {
      await ref.read(currentUserProvider.notifier).loginWithWeChat();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('微信登录失败: $e');
    }
  }

  Future<void> _handleAlipayLogin() async {
    try {
      await ref.read(currentUserProvider.notifier).loginWithAlipay();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('支付宝登录失败: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标签栏
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('登录'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('注册'),
                  ),
                ],
              ),
            ),
            // 内容区域
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 登录标签页
                  _buildLoginTab(theme, primaryColor),
                  // 注册标签页
                  _buildRegisterTab(theme, primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTab(ThemeData theme, Color primaryColor) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 欢迎文本
          Text(
            '您好，\n欢迎来到灵感分享！',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24),

          // 手机号输入框
          _buildTextField(
            label: '输入手机号/用户名/邮箱',
            controller: _loginPhoneController,
            keyboardType: TextInputType.text,
            enabled: !_isLoggingIn,
          ),
          SizedBox(height: 12),

          // 密码输入框
          _buildTextField(
            label: '输入密码',
            controller: _loginPasswordController,
            obscureText: !_loginPasswordVisible,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() => _loginPasswordVisible = !_loginPasswordVisible);
              },
              child: Icon(
                _loginPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
                size: 20,
              ),
            ),
            enabled: !_isLoggingIn,
          ),
          SizedBox(height: 8),

          // 忘记密码和免密码登录
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _isLoggingIn ? null : () {},
                child: Text(
                  '忘记密码',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _isLoggingIn ? null : () {},
                child: Text(
                  '免密码登录',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // 登录按钮
          _buildGradientButton(
            label: '登录',
            onPressed: _isLoggingIn ? null : _handleLogin,
            isLoading: _isLoggingIn,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 20),

          // 分割线
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '第三方账号登录',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          SizedBox(height: 20),

          // 社交登录按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIconButton(
                icon: Icons.chat,
                backgroundColor: Color(0xFF09B83E),
                onPressed: _handleWechatLogin,
              ),
              SizedBox(width: 24),
              _buildSocialIconButton(
                icon: Icons.payment,
                backgroundColor: Color(0xFF1890FF),
                onPressed: _handleAlipayLogin,
              ),
            ],
          ),
          SizedBox(height: 16),

          // 底部提示
          Center(
            child: Text(
              '登录即表示同意用户服务协议',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTab(ThemeData theme, Color primaryColor) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 欢迎文本
          Text(
            '登录',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),

          // 手机号输入框
          _buildTextField(
            label: '输入手机号/用户名/邮箱',
            controller: _registerPhoneController,
            keyboardType: TextInputType.text,
            enabled: !_isRegistering,
          ),
          SizedBox(height: 12),

          // 密码输入框
          _buildTextField(
            label: '输入密码',
            controller: _registerPasswordController,
            obscureText: !_registerPasswordVisible,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(
                    () => _registerPasswordVisible = !_registerPasswordVisible);
              },
              child: Icon(
                _registerPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.grey,
                size: 20,
              ),
            ),
            enabled: !_isRegistering,
          ),
          SizedBox(height: 12),

          // 昵称输入框（可选）
          _buildTextField(
            label: '输入昵称（可选）',
            controller: _registerNicknameController,
            enabled: !_isRegistering,
          ),
          SizedBox(height: 8),

          // 忘记密码和免密码登录
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _isRegistering ? null : () {},
                child: Text(
                  '忘记密码',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _isRegistering ? null : () {},
                child: Text(
                  '免密码登录',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // 登录按钮
          _buildGradientButton(
            label: '登录',
            onPressed: _isRegistering ? null : _handleRegister,
            isLoading: _isRegistering,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 20),

          // 分割线
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '第三方账号登录',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          SizedBox(height: 20),

          // 社交登录按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIconButton(
                icon: Icons.chat,
                backgroundColor: Color(0xFF09B83E),
                onPressed: _handleWechatLogin,
              ),
              SizedBox(width: 24),
              _buildSocialIconButton(
                icon: Icons.payment,
                backgroundColor: Color(0xFF1890FF),
                onPressed: _handleAlipayLogin,
              ),
            ],
          ),
          SizedBox(height: 16),

          // 底部提示
          Center(
            child: Text(
              '登录即表示同意用户服务协议',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: suffixIcon != null ? Padding(
          padding: EdgeInsets.only(right: 12),
          child: suffixIcon,
        ) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isLoading,
    required Color primaryColor,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withAlpha(220),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withAlpha(102),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIconButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withAlpha(102),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
