import 'package:flutter/material.dart';
import 'package:vacation_homework_app/models/diary_request.dart';
import 'package:vacation_homework_app/services/api_client.dart';

class DiaryService {
  static Future<void> createDiary(DiaryRequest request) async {
    debugPrint('[WRITE] 저장 시도');

    try {
      await ApiClient.post<void>(
        '/homeworks',
        body: request.toJson(),
        fromJsonT: (_) => null,
      );

      debugPrint('[WRITE] 저장 완료');
    } catch (e) {
      debugPrint('[WRITE] 저장 실패: $e');
      rethrow;
    }
  }
}
