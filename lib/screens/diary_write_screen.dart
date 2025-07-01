import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vacation_homework_app/models/diary_request.dart';
import 'package:vacation_homework_app/services/diary_service.dart';
import 'package:vacation_homework_app/services/home_service.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryWriteScreen extends StatefulWidget {
  const DiaryWriteScreen({super.key});

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends State<DiaryWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedWeather = 'SUNNY';
  bool _isSaving = false;
  DateTime? _selectedDate;

  int _contentLength = 0;
  int _lastTitleLength = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _openCustomDatePicker() async {
    DateTime focusedDay = _selectedDate ?? DateTime.now();
    DateTime? pickedDate = _selectedDate;
    ValueNotifier<List<DateTime>> availableDates = ValueNotifier([]);

    Future<void> loadAvailableDates(DateTime focusDay) async {
      final hwList = await HomeService.fetchHomeworks(focusDay.year, focusDay.month);
      final writtenDates = hwList
          .map((hw) => DateTime(hw.selectedDate.year, hw.selectedDate.month, hw.selectedDate.day))
          .toSet();

      final allDays = List.generate(
        DateUtils.getDaysInMonth(focusDay.year, focusDay.month),
        (i) => DateTime(focusDay.year, focusDay.month, i + 1),
      );

      availableDates.value = allDays
          .where((d) => !writtenDates.contains(d) && !d.isAfter(DateTime.now()))
          .toList();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("날짜 선택"),
          content: SizedBox(
            height: 400.h,
            width: 300.w,
            child: StatefulBuilder(
              builder: (context, setState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  loadAvailableDates(focusedDay);
                });

                return ValueListenableBuilder<List<DateTime>>(
                  valueListenable: availableDates,
                  builder: (context, dates, _) {
                    return TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: focusedDay,
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: '월',
                      },
                      headerStyle: const HeaderStyle(titleCentered: true),
                      selectedDayPredicate: (day) =>
                          pickedDate != null && _isSameDay(day, pickedDate!),
                      onPageChanged: (newFocusedDay) {
                        focusedDay = newFocusedDay;
                        loadAvailableDates(focusedDay);
                      },
                      enabledDayPredicate: (day) {
                        return dates.any((d) => _isSameDay(d, day));
                      },
                      onDaySelected: (selectedDay, _) {
                        if (dates.any((d) => _isSameDay(d, selectedDay))) {
                          setState(() {
                            pickedDate = selectedDay;
                          });
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
            TextButton(
              onPressed: () {
                if (pickedDate != null) Navigator.pop(context, pickedDate);
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null && value is DateTime) {
        setState(() => _selectedDate = value);
      }
    });
  }

  void _submitDiary() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('날짜를 반드시 선택해주세요.')),
      );
      return;
    }

    if (content.isEmpty || content.length > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('본문은 1자 이상 1000자 이하여야 합니다.')),
      );
      return;
    }

    if (title.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목은 20자 이하여야 합니다')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final request = DiaryRequest(
        title: title,
        weather: _selectedWeather,
        content: content,
        selectedDate: _selectedDate!,
      );
      await DiaryService.createDiary(request);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일기 저장 중 오류 발생')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildWeatherEmoji(String value, String emoji) {
    final isSelected = _selectedWeather == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedWeather = value),
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.3,
        child: Text(
          emoji,
          style: TextStyle(fontSize: 32.sp),
        ),
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
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('일기 작성'),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submitDiary,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 68, 64, 64),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h), // 👈 핵심
                minimumSize: Size(60.w, 32.h),  // 👈 필요 시 최소 높이 강제
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text("등록", style: TextStyle(fontSize: 15.sp)),
            ),
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
                        GestureDetector(
                          onTap: _openCustomDatePicker,
                          child: SizedBox(
                            width: 140.w,
                            child: Text(
                              _selectedDate != null
                                  ? '${DateFormat('yyyy년 MM월 dd일').format(_selectedDate!)}'
                                  : '✅ 날짜 선택하기',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: const Color.fromARGB(255, 75, 65, 65),
                              ),
                            ),
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

                    /// ➡️ 오른쪽: 날씨 텍스트 + 이모지들
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
                child: TextField(
                  controller: _titleController,
                  maxLength: 20,
                  style: TextStyle(fontSize: 16.sp), // 원하는 폰트 크기 설정
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '제목을 입력하세요.',
                    counterText: '',
                    hintStyle: TextStyle(
                      color: Colors.grey, // ← 이게 힌트 텍스트 색!
                    ),
                  ),
                  onChanged: (value) {
                    if (_lastTitleLength < 20 && value.length == 20) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('제목은 20자까지만 입력할 수 있어요.')),
                      );
                    }
                    _lastTitleLength = value.length;
                  },
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h), // 글자수 표시 공간 확보!
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: TextField(
                          controller: _contentController,
                          maxLines: null,
                          expands: true,
                          style: TextStyle(fontSize: 15.sp), // 원하는 폰트 크기 설정
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '오늘 있었던 일을 써 보세요.',
                            hintStyle: TextStyle(
                              color: Colors.grey, // ← 이게 힌트 텍스트 색!
                            ),
                          ),
                          
                          onChanged: (value) =>
                              setState(() => _contentLength = value.length),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16.w,
                      bottom: 4.h,
                      child: Text(
                        '$_contentLength / 1000자',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _contentLength > 1000 ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: const Color.fromARGB(255, 34, 14, 14),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '선생님의 코멘트',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      '일기를 쓰면 선생님의 코멘트가 달려요.',
                      style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              if (_isSaving)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
