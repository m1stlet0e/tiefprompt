/// 用户数据模型
class User {
  final String userId;
  final String? phone;
  final String? wechatId;
  final String? alipayId;
  final String? nickname;
  final String? avatar;
  final bool isAuthenticated;
  final bool isPaidUser;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.userId,
    required this.phone,
    this.wechatId,
    this.alipayId,
    this.nickname,
    this.avatar,
    this.isAuthenticated = false,
    this.isPaidUser = false,
    this.createdAt,
    this.lastLoginAt,
  });

  /// 从 JSON 创建 User
  static User fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      phone: json['phone'] as String?,
      wechatId: json['wechatId'] as String?,
      alipayId: json['alipayId'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      isAuthenticated: json['isAuthenticated'] as bool? ?? false,
      isPaidUser: json['isPaidUser'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : null,
      lastLoginAt: json['lastLoginAt'] != null
        ? DateTime.parse(json['lastLoginAt'] as String)
        : null,
    );
  }

  /// copyWith 方法用于创建修改后的副本
  User copyWith({
    String? userId,
    String? phone,
    String? wechatId,
    String? alipayId,
    String? nickname,
    String? avatar,
    bool? isAuthenticated,
    bool? isPaidUser,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      wechatId: wechatId ?? this.wechatId,
      alipayId: alipayId ?? this.alipayId,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isPaidUser: isPaidUser ?? this.isPaidUser,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          phone == other.phone &&
          wechatId == other.wechatId &&
          alipayId == other.alipayId &&
          nickname == other.nickname &&
          avatar == other.avatar &&
          isAuthenticated == other.isAuthenticated &&
          isPaidUser == other.isPaidUser &&
          createdAt == other.createdAt &&
          lastLoginAt == other.lastLoginAt;

  @override
  int get hashCode =>
      userId.hashCode ^
      phone.hashCode ^
      wechatId.hashCode ^
      alipayId.hashCode ^
      nickname.hashCode ^
      avatar.hashCode ^
      isAuthenticated.hashCode ^
      isPaidUser.hashCode ^
      createdAt.hashCode ^
      lastLoginAt.hashCode;

  @override
  String toString() {
    return 'User(userId: $userId, phone: $phone, wechatId: $wechatId, alipayId: $alipayId, nickname: $nickname, avatar: $avatar, isAuthenticated: $isAuthenticated, isPaidUser: $isPaidUser, createdAt: $createdAt, lastLoginAt: $lastLoginAt)';
  }
}

/// 登录请求参数
class LoginRequest {
  final String? phone;
  final String? password;
  final String? smsCode;
  final String? wechatCode;
  final String? alipayCode;

  const LoginRequest({
    this.phone,
    this.password,
    this.smsCode,
    this.wechatCode,
    this.alipayCode,
  });
}

/// 登录响应
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
  
  static LoginResponse fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: User(
        userId: json['user']['userId'] as String,
        phone: json['user']['phone'] as String?,
        wechatId: json['user']['wechatId'] as String?,
        alipayId: json['user']['alipayId'] as String?,
        nickname: json['user']['nickname'] as String?,
        avatar: json['user']['avatar'] as String?,
        isAuthenticated: json['user']['isAuthenticated'] as bool? ?? false,
        isPaidUser: json['user']['isPaidUser'] as bool? ?? false,
        createdAt: json['user']['createdAt'] != null 
          ? DateTime.parse(json['user']['createdAt'] as String)
          : null,
        lastLoginAt: json['user']['lastLoginAt'] != null
          ? DateTime.parse(json['user']['lastLoginAt'] as String)
          : null,
      ),
    );
  }
}
