class DiaryRequest {
  final String title;
  final String weather;
  final String content;
  final DateTime selectedDate;

  DiaryRequest({required this.title, required this.weather, required this.content, required this.selectedDate});

  Map<String, dynamic> toJson() => {
        'title' : title,
        'weather': weather,
        'content': content,
        'selectedDate': selectedDate.toUtc().toIso8601String(), // ✅ UTC 변환
      };
}
