import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:promptify/providers/auth_provider.dart';

/// 登录屏幕
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _smsController;
  int _smsCountdown = 0;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _smsController = TextEditingController();
  }

  Future<void> _sendSmsCode() async {
    final phone = _phoneController.text;
    
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入手机号')),
      );
      return;
    }

    setState(() => _isLoggingIn = true);

    final authService = ref.read(authServiceProvider);
    final success = await authService.sendSmsCode(phone);

    if (success) {
      setState(() => _smsCountdown = 60);
      _startCountdown();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('验证码已发送')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送失败，请重试')),
      );
    }

    setState(() => _isLoggingIn = false);
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_smsCountdown > 0 && mounted) {
        setState(() => _smsCountdown--);
        _startCountdown();
      }
    });
  }

  Future<void> _loginWithPhone() async {
    final phone = _phoneController.text;
    final smsCode = _smsController.text;

    if (phone.isEmpty || smsCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请填写手机号和验证码')),
      );
      return;
    }

    setState(() => _isLoggingIn = true);

    try {
      await ref.read(currentUserProvider.notifier).loginWithPhone(phone, smsCode);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登录失败: $e')),
      );
    } finally {
      setState(() => _isLoggingIn = false);
    }
  }

  Future<void> _loginWithWeChat() async {
    try {
      await ref.read(currentUserProvider.notifier).loginWithWeChat();
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('微信登录失败: $e')),
      );
    }
  }

  Future<void> _loginWithAlipay() async {
    try {
      await ref.read(currentUserProvider.notifier).loginWithAlipay();
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('支付宝登录失败: $e')),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('登录 / 注册'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              /// 标题部分 (紧凑版)
              Text(
                '快速登录',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 4),
              
              Text(
                '享受无缝提词体验',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              
              SizedBox(height: 20),
              
              /// 手机号登录部分 (上面)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '手机号快速登录',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: 10),
                  
                  InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber value) {
                      _phoneController.text = value.phoneNumber ?? '';
                    },
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      leadingPadding: 8,
                    ),
                    initialValue: PhoneNumber(isoCode: 'CN'),
                    textFieldController: _phoneController,
                    formatInput: true,
                    inputBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    countries: ['CN'],
                  ),
                  
                  SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _smsController,
                          decoration: InputDecoration(
                            hintText: '验证码',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: _smsCountdown > 0 ? null : _sendSmsCode,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            _smsCountdown > 0 ? '${_smsCountdown}s' : '获取验证码',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 10),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isLoggingIn ? null : _loginWithPhone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoggingIn
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text('登录', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              /// 分割线
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('或', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              
              SizedBox(height: 12),
              
              /// 微信和支付宝登录 (下面)
              Text(
                '其他登录方式',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: _buildCompactSocialButton(
                      icon: '微',
                      label: '微信',
                      onPressed: _loginWithWeChat,
                      backgroundColor: Color(0xFF09B83E),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactSocialButton(
                      icon: '支',
                      label: '支付宝',
                      onPressed: _loginWithAlipay,
                      backgroundColor: Color(0xFF1890FF),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              /// 底部提示
              Text(
                '登录即表示同意用户协议和隐私政策',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 紧凑版社交登录按钮
  Widget _buildCompactSocialButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                icon,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
