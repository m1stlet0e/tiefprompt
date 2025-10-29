import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptify/models/payment_model.dart';
import 'package:promptify/models/user_model.dart';
import 'package:promptify/providers/auth_provider.dart';
import 'package:promptify/providers/payment_provider.dart';

/// 支付屏幕
class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text('升级专业版')),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('请先登录'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('返回'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              SizedBox(height: 24),
              
              _buildPricingCard(
                title: 'Promptify Pro',
                price: '¥48',
                period: '一次性购买',
                features: [
                  '自定义主题色',
                  '自定义背景颜色',
                  '字体族选择',
                  '倒计时功能',
                  '垂直遮罩效果',
                  '专业支持',
                ],
              ),
              
              SizedBox(height: 32),
              
              Text(
                '选择支付方式',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              
              SizedBox(height: 16),
              
              _buildPaymentMethodButton(
                context,
                method: PaymentMethod.wechat,
                icon: '微',
                label: '微信支付',
                onTap: () => _initiatePayment(
                  context,
                  ref,
                  user,
                  PaymentMethod.wechat,
                ),
              ),
              
              SizedBox(height: 12),
              
              _buildPaymentMethodButton(
                context,
                method: PaymentMethod.alipay,
                icon: '支',
                label: '支付宝',
                onTap: () => _initiatePayment(
                  context,
                  ref,
                  user,
                  PaymentMethod.alipay,
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _initiatePayment(
    BuildContext context,
    WidgetRef ref,
    User user,
    PaymentMethod method,
  ) async {
    final params = PaymentOrderParams(
      userId: user.userId,
      amount: 48.00,
      method: method.name,
      productId: 'pro',
      productName: 'Promptify Pro',
    );

    final paymentResult = await ref.read(
      createPaymentOrderProvider(params).future,
    );

    if (paymentResult != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('支付过程将启动...')),
      );
    }
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  price,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Text(period, style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 24),
            ...features.map((feature) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.check, color: Colors.green, size: 20),
                  SizedBox(width: 12),
                  Text(feature),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(
    BuildContext context, {
    required PaymentMethod method,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: method == PaymentMethod.wechat
                    ? Color(0xFF09B83E)
                    : Color(0xFF1890FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 16)),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
