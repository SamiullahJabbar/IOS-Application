import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userBoxName = 'users';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _currentUserIdKey = 'currentUserId';

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<Box<UserModel>> _getUserBox() async {
    if (!Hive.isBoxOpen(_userBoxName)) {
      return await Hive.openBox<UserModel>(_userBoxName);
    }
    return Hive.box<UserModel>(_userBoxName);
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final box = await _getUserBox();

    // Check if email already exists
    final existingUser = box.values.where(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
    );

    if (existingUser.isNotEmpty) {
      return {'success': false, 'message': 'Email already registered'};
    }

    final user = UserModel(
      id: const Uuid().v4(),
      fullName: fullName,
      email: email.toLowerCase(),
      passwordHash: hashPassword(password),
      createdAt: DateTime.now(),
    );

    await box.put(user.id, user);

    // Automatically log in and skip onboarding after registration
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_currentUserIdKey, user.id);
    await prefs.setBool('onboarding_seen', true);

    return {'success': true, 'message': 'Account created successfully', 'userId': user.id};
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final box = await _getUserBox();

    final users = box.values.where(
      (user) =>
          user.email.toLowerCase() == email.toLowerCase() &&
          user.passwordHash == hashPassword(password),
    );

    if (users.isEmpty) {
      return {'success': false, 'message': 'Invalid email or password'};
    }

    final user = users.first;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_currentUserIdKey, user.id);
    await prefs.setBool('onboarding_seen', true);

    return {'success': true, 'message': 'Login successful', 'userId': user.id};
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_currentUserIdKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserIdKey);
    if (userId == null) return null;

    final box = await _getUserBox();
    return box.get(userId);
  }

  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserIdKey);
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_seen') ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final box = await _getUserBox();

    final users = box.values.where(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
    );

    if (users.isEmpty) {
      return {'success': false, 'message': 'Email not found'};
    }

    final oldUser = users.first;
    final updatedUser = UserModel(
      id: oldUser.id,
      fullName: oldUser.fullName,
      email: oldUser.email,
      passwordHash: hashPassword(newPassword),
      createdAt: oldUser.createdAt,
    );

    await box.put(oldUser.id, updatedUser);

    return {'success': true, 'message': 'Password reset successful'};
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? profileImageBase64,
  }) async {
    final box = await _getUserBox();
    final user = box.get(userId);
    if (user == null) {
      return {'success': false, 'message': 'User not found'};
    }

    final updated = user.copyWith(
      fullName: fullName,
      phone: phone,
      profileImageBase64: profileImageBase64,
    );
    await box.put(userId, updated);
    return {'success': true, 'message': 'Profile updated', 'user': updated};
  }

  static Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final box = await _getUserBox();
    final user = box.get(userId);
    if (user == null) {
      return {'success': false, 'message': 'User not found'};
    }

    if (user.passwordHash != hashPassword(currentPassword)) {
      return {'success': false, 'message': 'Current password is incorrect'};
    }

    final updated = user.copyWith(passwordHash: hashPassword(newPassword));
    await box.put(userId, updated);
    return {'success': true, 'message': 'Password changed successfully'};
  }
}
