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

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });
}
