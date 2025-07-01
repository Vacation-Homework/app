import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vacation_homework_app/services/api_client.dart';

class UserService {
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  /// 닉네임 조회
  static Future<String?> fetchNickname() async {
    try {
      final res = await ApiClient.get<Map<String, dynamic>>(
        '/users/nickname',
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      return res.data['nickname'];
    } catch (e) {
      debugPrint('닉네임 조회 실패: $e');
      return null;
    }
  }

  /// 닉네임 변경
  static Future<bool> updateNickname(String newNickname) async {
    try {
      await ApiClient.patch<void>(
        '/users/nickname',
        body: {'newNickname': newNickname},
        fromJsonT: (_) => null,
      );
      return true;
    } catch (e) {
      debugPrint('닉네임 변경 실패: $e');
      return false;
    }
  }

  /// 회원 탈퇴
  static Future<bool> withdraw() async {
    try {
      await ApiClient.delete<void>(
        '/users',
        fromJsonT: (_) => null,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // 토큰 모두 삭제
      return true;
    } catch (e) {
      debugPrint('회원 탈퇴 실패: $e');
      return false;
    }
  }

  /// 로그아웃
  static Future<bool> logout() async {
    try {
      await ApiClient.post<void>(
        '/users/logout',
        fromJsonT: (_) => null,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      return true;
    } catch (e) {
      debugPrint('로그아웃 실패: $e');
      return false;
    }
  }
}