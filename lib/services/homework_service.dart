import 'package:vacation_homework_app/models/homework_summary.dart';
import 'package:vacation_homework_app/services/api_client.dart';

class HomeworkService {
  static Future<List<HomeworkSummary>> fetchHomeworks(int year, int month) async {
    final res = await ApiClient.get<List<HomeworkSummary>>(
      '/homeworks',
      queryParams: {'year': year, 'month': month},
      fromJsonT: (jsonList) => (jsonList as List)
          .map((e) => HomeworkSummary.fromJson(e))
          .toList(),
    );

    return res.data;
  }
}
