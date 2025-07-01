import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vacation_homework_app/config/constants.dart';
import 'package:vacation_homework_app/interceptor/auth_interceptor.dart';
import 'package:vacation_homework_app/models/api_response.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (_) => true,
    ),
  );

  static void setupInterceptor() {
    dio.interceptors.clear();
    dio.interceptors.add(AuthInterceptor(dio));
    debugPrint('[API CLIENT] interceptor 설정 완료');
  }

  // ✅ 공통 GET
  static Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    required T Function(dynamic) fromJsonT,
  }) async {
    final response = await dio.get(
      path, 
      queryParameters: queryParams,
      options: Options(
      ),
    );
    debugPrint("👏 =>  ${response.toString()}");
    return ApiResponse.fromJson(response.data, fromJsonT);
  }

  // ✅ 공통 POST
  static Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(dynamic) fromJsonT,
  }) async {
    final response = await dio.post(path, data: body);
    return ApiResponse.fromJson(response.data, fromJsonT);
  }

  // ✅ 공통 PUT
  static Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(dynamic) fromJsonT,
  }) async {
    final response = await dio.put(path, data: body);
    return ApiResponse.fromJson(response.data, fromJsonT);
  }

  // ✅ 공통 DELETE
  static Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    required T Function(dynamic) fromJsonT,
  }) async {
    final response = await dio.delete(path, queryParameters: queryParams);
    return ApiResponse.fromJson(response.data, fromJsonT);
  }

  // ✅ 공통 PATCH
  static Future<ApiResponse<T>> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(dynamic) fromJsonT,
  }) async {
    final response = await dio.patch(path, data: body);
    return ApiResponse.fromJson(response.data, fromJsonT);
  }
}

