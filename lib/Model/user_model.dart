class LoginResponse {
  final User user;
  final String token;

  LoginResponse({
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }
}

class User {
  final int userId;
  final String username;
  final String lvlUsers;
  final String? faceId;
  final String? faceRegisteredAt;
  final String? faceImagePath;
  final String? faceEncoding;
  final String verificationStatus;

  User({
    required this.userId,
    required this.username,
    required this.lvlUsers,
    this.faceId,
    this.faceRegisteredAt,
    this.faceImagePath,
    this.faceEncoding,
    required this.verificationStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      lvlUsers: json['lvl_users'],
      faceId: json['face_id'],
      faceRegisteredAt: json['face_registered_at'],
      faceImagePath: json['face_image_path'],
      faceEncoding: json['face_encoding'],
      verificationStatus: json['verification_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'lvl_users': lvlUsers,
      'face_id': faceId,
      'face_registered_at': faceRegisteredAt,
      'face_image_path': faceImagePath,
      'face_encoding': faceEncoding,
      'verification_status': verificationStatus,
    };
  }
}
