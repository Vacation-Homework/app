import 'package:flutter/material.dart';
import 'package:vacation_homework_app/models/homework_detail.dart';
import 'package:vacation_homework_app/models/homework_summary.dart';
import 'package:vacation_homework_app/services/api_client.dart';

class HomeService {
  // 일기 단건 조회
  static Future<HomeworkDetail> fetchHomeworkDetail(int homeworkSeq) async {
    try {
      final res = await ApiClient.get<HomeworkDetail>(
        '/homeworks/$homeworkSeq',
        fromJsonT: (json) => HomeworkDetail.fromJson(json),
      );

      return res.data;
    } catch (e) {
      debugPrint('[HOME] fetchHomeworkDetail 실패: $e');
      rethrow;
    }
  }

  // 홈 일기 리스트 조회
  static Future<List<HomeworkSummary>> fetchHomeworks(int year, int month) async {
    debugPrint('[HOME] fetchHomeworks : $year년 $month월의 일기 리스트를 가져옵니다');

    try {
      final res = await ApiClient.get<List<HomeworkSummary>>(
        '/homeworks',
        queryParams: {'year': year, 'month': month},
        fromJsonT: (jsonList) => (jsonList as List)
            .map((json) => HomeworkSummary.fromJson(json))
            .toList(),
      );

      return res.data;
    } catch (e) {
      debugPrint('[HOME] fetchHomeworks 실패: $e');
      rethrow;
    }
  }

  // 일기 삭제
  static Future<void> deleteHomework(int homeworkSeq) async {
    try {
      await ApiClient.delete<void>(
        '/homeworks/$homeworkSeq',
        fromJsonT: (_) => null,
      );
      debugPrint('[HOME] 삭제 성공');
    } catch (e) {
      debugPrint('[HOME] deleteHomework 실패: $e');
      rethrow;
    }
  }
}
