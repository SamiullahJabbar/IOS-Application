import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String passwordHash;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? phone;

  @HiveField(6)
  final String? profileImageBase64;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    this.phone,
    this.profileImageBase64,
  });

  UserModel copyWith({
    String? fullName,
    String? email,
    String? passwordHash,
    String? phone,
    String? profileImageBase64,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt,
      phone: phone ?? this.phone,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
    );
  }
}
