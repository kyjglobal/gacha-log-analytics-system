class AdminDashboard {
  const AdminDashboard({
    required this.totalUsers,
    required this.activeUsers,
    required this.suspendedUsers,
    required this.totalDraws,
    required this.deletedGachaSessions,
    required this.totalCommunityPosts,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    return AdminDashboard(
      totalUsers: json['total_users'] as int,
      activeUsers: json['active_users'] as int,
      suspendedUsers: json['suspended_users'] as int,
      totalDraws: json['total_draws'] as int,
      deletedGachaSessions: json['deleted_gacha_sessions'] as int,
      totalCommunityPosts: json['total_community_posts'] as int,
    );
  }

  final int totalUsers;
  final int activeUsers;
  final int suspendedUsers;
  final int totalDraws;
  final int deletedGachaSessions;
  final int totalCommunityPosts;
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    required this.nickname,
    required this.role,
    required this.status,
    required this.walletBalance,
    required this.totalDraws,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      walletBalance: json['wallet_balance'] as int,
      totalDraws: json['total_draws'] as int,
    );
  }

  final int id;
  final String email;
  final String nickname;
  final String role;
  final String status;
  final int walletBalance;
  final int totalDraws;
}

class AdminUserPage {
  const AdminUserPage({required this.items, required this.total});

  factory AdminUserPage.fromJson(Map<String, dynamic> json) {
    return AdminUserPage(
      items: (json['items'] as List<dynamic>)
          .map((item) => AdminUser.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }

  final List<AdminUser> items;
  final int total;
}

class AdminGachaSession {
  const AdminGachaSession({
    required this.id,
    required this.userId,
    required this.userNickname,
    required this.bannerName,
    required this.drawCount,
    required this.totalCost,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
  });

  factory AdminGachaSession.fromJson(Map<String, dynamic> json) {
    return AdminGachaSession(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userNickname: json['user_nickname'] as String,
      bannerName: json['banner_name'] as String,
      drawCount: json['draw_count'] as int,
      totalCost: json['total_cost'] as int,
      status: json['status'] as String,
      isDeleted: json['is_deleted'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final int id;
  final int userId;
  final String userNickname;
  final String bannerName;
  final int drawCount;
  final int totalCost;
  final String status;
  final bool isDeleted;
  final DateTime createdAt;
}

class AdminGachaSessionPage {
  const AdminGachaSessionPage({required this.items, required this.total});

  factory AdminGachaSessionPage.fromJson(Map<String, dynamic> json) {
    return AdminGachaSessionPage(
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => AdminGachaSession.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      total: json['total'] as int,
    );
  }

  final List<AdminGachaSession> items;
  final int total;
}
