import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vacation_homework_app/models/homework_detail.dart';
import 'package:vacation_homework_app/services/home_service.dart';

class DiaryDetailScreen extends StatefulWidget {
  final String homeworkSeq;
  const DiaryDetailScreen({super.key, required this.homeworkSeq});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  HomeworkDetail? _homework;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final seq = int.parse(widget.homeworkSeq);
    _fetchDetail(seq);
  }

  Future<void> _fetchDetail(int seq) async {
    try {
      final hw = await HomeService.fetchHomeworkDetail(seq);
      setState(() {
        _homework = hw;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[DETAIL] 조회 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일기 정보를 불러오는 데 실패했습니다.')),
      );
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('이 일기를 삭제하시겠어요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteHomework();
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteHomework() async {
    try {
      await HomeService.deleteHomework(_homework!.homeworkSeq);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제가 완료되었습니다.')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('[DELETE] 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제에 실패했습니다.')),
      );
    }
  }

  Widget _buildWeatherEmoji(String value, String emoji) {
    final isSelected = _homework?.weather == value;
    return Opacity(
      opacity: isSelected ? 1.0 : 0.3,
      child: Text(
        emoji,
        style: TextStyle(fontSize: 32.sp),
      ),
    );
  }

  Widget _buildGridRow({required Widget child, double? height, bool withTopBorder = false}) {
    const borderLineColor = Color(0xFFBDBDBD);
    return Container(
      height: height ?? 60.h,
      decoration: BoxDecoration(
        border: Border(
          top: withTopBorder ? BorderSide(color: borderLineColor) : BorderSide.none,
          bottom: BorderSide(color: borderLineColor),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _homework == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final formattedDate = DateFormat('yyyy년 MM월 dd일').format(_homework!.selectedDate);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('일기'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('삭제하기'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 16.h),
          child: Column(
            children: [
              _buildGridRow(
                withTopBorder: true,
                height: 50.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// ⬅️ 왼쪽: 날짜 + 구분선
                    Row(
                      children: [
                        SizedBox(
                          width: 140.w,
                          child: Text(
                            formattedDate,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 1.w,
                          height: 30.h,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),

                    /// ➡️ 오른쪽: 날씨 텍스트 + 이모지
                    Row(
                      children: [
                        Text('날씨:', style: TextStyle(fontSize: 16.sp)),
                        SizedBox(width: 8.w),
                        _buildWeatherEmoji('SUNNY', '☀️'),
                        SizedBox(width: 10.w),
                        _buildWeatherEmoji('CLOUDY', '☁️'),
                        SizedBox(width: 10.w),
                        _buildWeatherEmoji('RAINY', '🌧️'),
                        SizedBox(width: 10.w),
                        _buildWeatherEmoji('SNOWY', '❄️'),
                      ],
                    ),
                  ],
                ),
              ),

              _buildGridRow(
                child: Text(
                  _homework!.title,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 400.h,
                    minHeight: 300.h,
                  ),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            _homework!.content,
                            style: TextStyle(fontSize: 15.sp),
                          ),
                        ),
                      ),
                      if (_homework!.commentContent.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          right: 0,    
                          child: Opacity(
                          opacity: 0.9,
                          child: Image.asset(
                            'assets/images/good_sign.png',
                            width: 90.w,
                            height: 90.w,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: const Color.fromARGB(255, 34, 14, 14),
              ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('선생님의 코멘트', style: TextStyle(fontSize: 16.sp)),
                      SizedBox(height: 10.h),

                      Expanded( // 👈 여기가 스크롤 가능하도록 설정된 영역
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _homework!.commentContent.isNotEmpty
                                      ? _homework!.commentContent
                                      : '선생님이 검사중이에요.',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 23.sp,
                                    fontFamily: 'nanum_matitnen',
                                    color: const Color.fromARGB(255, 41, 41, 41),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),


              
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
