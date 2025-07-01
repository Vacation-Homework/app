import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vacation_homework_app/models/login.dart';
import 'package:vacation_homework_app/services/api_client.dart';

class AuthService {

  // 로그인
  static Future<bool> login({
    required String userId,
    required String password,
    required String? fcmToken,
  }) async {
    try {
      debugPrint('[LOGIN] 시도');

      final res = await ApiClient.post<LoginResponse>(
        '/auth/login',
        body: {
          'userId': userId,
          'password': password,
          'fcmToken': fcmToken,
        },
        fromJsonT: (json) => LoginResponse.fromJson(json),
      );

      final loginResponse = res.data;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', loginResponse.accessToken);
      await prefs.setString('refreshToken', loginResponse.refreshToken);

      return true;
    } catch (e) {
      debugPrint('로그인 중 에러: $e');
      return false;
    }
  }

  // 회원가입
  static Future<bool> register({
    required String userId,
    required String password,
    required String nickname,
  }) async {
    try {
      await ApiClient.post<void>(
        '/users',
        body: {
          'userId': userId,
          'password': password,
          'nickname': nickname,
        },
        fromJsonT: (_) => null, // 응답 본문 없음
      );
      return true;
    } catch (e) {
      print('회원가입 실패: $e');
      return false;
    }
  }

  // 액세스토큰 꺼내기
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // ID 중복 검사
  static Future<bool> checkIdDuplicate(String userId) async {
    debugPrint('[ID 중복검사]');
    try {
      final res = await ApiClient.get<Map<String, dynamic>>(
        '/users/valid/id',
        queryParams: {'userId': userId},
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      final duplicated = res.data['duplicated'] == true;
      debugPrint('[ID 중복검사] duplicated: $duplicated');

      return duplicated; // false면 중복
    } catch (e) {
      debugPrint('[ID 중복검사] 예외 발생: $e');
      return false;
    }
  }
}
