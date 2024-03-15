class UserModel {
  const UserModel(
      {required this.userId,
      required this.token,
      required this.fcmToken,
      required this.deviceId});

  final int userId;
  final String token;
  final String fcmToken;
  final String deviceId;
}
