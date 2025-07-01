class HomeworkDetail {
  final int homeworkSeq;
  final String title;
  final String content;
  final String weather;
  final String photoUrl;
  final DateTime selectedDate;
  final String commentContent;
  final String spellCheckResult;

  HomeworkDetail({
    required this.homeworkSeq,
    required this.title,
    required this.content,
    required this.weather,
    required this.photoUrl,
    required this.selectedDate,
    required this.commentContent,
    required this.spellCheckResult,
  });

  factory HomeworkDetail.fromJson(Map<String, dynamic> json) {
    return HomeworkDetail(
      homeworkSeq: json['homeworkSeq'],
      title: json['title'],
      content: json['content'],
      weather: json['weather'],
      photoUrl: json['photoUrl'] ?? '',
      selectedDate: DateTime.parse(json['selectedDate']).toLocal(),
      commentContent: json['commentContent'] ?? '',
      spellCheckResult: json['spellCheckResult'] ?? '',
    );
  }
}
