class HomeworkSummary  {
  final int homeworkSeq;
  final String title;
  final String content;
  final String weather;
  final DateTime selectedDate;
  final String? commentContent;

  HomeworkSummary ({
    required this.homeworkSeq,
    required this.title,
    required this.content,
    required this.weather,
    required this.selectedDate,
    required this.commentContent,
  });

  factory HomeworkSummary .fromJson(Map<String, dynamic> json) {
    return HomeworkSummary (
      homeworkSeq: json['homeworkSeq'],
      title: json['title'],
      content: json['content'],
      weather: json['weather'],
      selectedDate: DateTime.parse(json['selectedDate']).toLocal(), // ✅ KST로 변환
      commentContent: json['commentContent'] != null ? json['commentContent'] as String : null,
    );
  }
}
