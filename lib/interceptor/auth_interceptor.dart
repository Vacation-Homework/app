import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vacation_homework_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vacation_homework_app/services/user_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  static final List<String> noAuthPaths = [
    '/auth/login',
    '/auth/register',
    '/users/valid/id',
  ];

  bool _isNoAuthPath(String path) {
    return noAuthPaths.any((noAuthPath) => path.startsWith(noAuthPath));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_isNoAuthPath(options.path)) {
      return handler.next(options);
    }

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken != null) {
      debugPrint('[INTERCEPTOR] accessToken 추가됨');
      options.headers['Authorization'] = 'Bearer ${accessToken.trim()}';
    } else {
      debugPrint('[INTERCEPTOR] accessToken 없음');
    }
    debugPrint('[INTERCEPTOR] 최종 요청 헤더: ${options.headers}');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ✅ API 응답이 success: false이면 자동 토스트 처리
    final data = response.data;
    if (data is Map<String, dynamic> && data['success'] == false) {
      final msg = data['message'] ?? '오류가 발생했습니다.';
      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }

    handler.next(response); // 꼭 호출해야 함
  }


  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final response = err.response;

    debugPrint('[INTERCEPTOR] 에러 발생');
    debugPrint('[INTERCEPTOR] statusCode: ${response?.statusCode}');
    debugPrint('[INTERCEPTOR] response.data: ${response?.data}');
    debugPrint('[INTERCEPTOR] 요청 경로: ${requestOptions.path}');

    // 로그인/리프레시 요청은 예외 처리 안 함
    if (requestOptions.path.contains('/auth/login') ||
        requestOptions.path.contains('/auth/refresh')) {
      return handler.next(err);
    }

    // ✅ 401 또는 403이면 무조건 리프레시 시도
    if (response?.statusCode == 401 || response?.statusCode == 403) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final refreshToken = prefs.getString('refreshToken');

        if (refreshToken == null) {
          debugPrint('[INTERCEPTOR] refreshToken 없음 -> 로그아웃 처리');
          
          // ✅ 리프레쉬도 없으면 바로 무효처리
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('accessToken');
          await prefs.remove('refreshToken');

          //✅ 로그인 화면으로 이동
          navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
          return handler.reject(err);
        }

        final refreshResponse = await dio.post(
          '/auth/refresh',
          options: Options(
            headers: {
              'Authorization': 'Bearer $refreshToken',
            },
          ),
        );

        final newAccessToken = refreshResponse.data['accessToken'];
        final newRefreshToken = refreshResponse.data['refreshToken'];

        debugPrint('[INTERCEPTOR] 새로운 accessToken: $newAccessToken');
        debugPrint('[INTERCEPTOR] 새로운 refreshToken: $newRefreshToken');

        await prefs.setString('accessToken', newAccessToken);
        await prefs.setString('refreshToken', newRefreshToken);

        debugPrint('[INTERCEPTOR] 토큰 재발급 성공 (자동 재요청은 직접 구현 필요)');

        // 🔁 자동 재요청
        final retryResponse = await _retryRequest(requestOptions, newAccessToken);
        return handler.resolve(retryResponse);

      } catch (e) {
        debugPrint('[INTERCEPTOR] refresh 실패 → 로그아웃 처리');
        Fluttertoast.showToast(
          msg: "세션이 만료되었습니다. 다시 로그인해주세요.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );

        await UserService.logout();
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        return handler.reject(err);
      }
    }

    return handler.next(err);
  }


  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions, String newAccessToken) async {
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers['Authorization'] = 'Bearer $newAccessToken';

    final options = Options(
      method: requestOptions.method,
      headers: headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      followRedirects: requestOptions.followRedirects,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
    );

    debugPrint('[INTERCEPTOR] 요청 재시도: ${requestOptions.path}');
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}