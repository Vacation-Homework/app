import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vacation_homework_app/models/homework_summary.dart';
import 'package:vacation_homework_app/services/home_service.dart';
import 'package:intl/intl.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _focusedDay;
  Map<DateTime, HomeworkSummary> _homeworksByDate = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now().toLocal();
    _loadHomeworks();
  }

  Future<void> _loadHomeworks() async {
    try {
      final hwList = await HomeService.fetchHomeworks(
        _focusedDay.year,
        _focusedDay.month,
      );
      setState(() {
        _homeworksByDate = {
          for (var hw in hwList)
            DateTime(
              hw.selectedDate.year,
              hw.selectedDate.month,
              hw.selectedDate.day,
            ): hw
        };
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[HOME] 오류 발생: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getWeatherEmoji(String weather) {
    switch (weather) {
      case 'SUNNY':
        return '☀️';
      case 'CLOUDY':
        return '☁️';
      case 'RAINY':
        return '🌧️';
      case 'SNOWY':
        return '❄️';
      default:
        return '📘';
    }
  }

  Widget _buildCalendarCell(DateTime date, bool isToday, {bool isOutside = false}) {
    final d = DateTime(date.year, date.month, date.day);
    final summary = _homeworksByDate[d];
    final emoji = summary != null ? _getWeatherEmoji(summary.weather) : '';
    final hasComment = summary?.commentContent?.isNotEmpty ?? false;

    return GestureDetector(
      onTap: () async {
        if (summary != null) {
          final result = await Navigator.pushNamed(
            context,
            '/detail',
            arguments: summary.homeworkSeq.toString(),
          );
          if (result == true) {
            await _loadHomeworks();
            setState(() {});
          }
        }
      },
      child: SizedBox(
        height: 60.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isOutside ? Colors.grey.shade400 : Colors.black,
              ),
            ),
            SizedBox(height: 2.h),
            Opacity(
              opacity: summary != null ? (hasComment ? 1.0 : 0.4) : 0.0,
              child: Text(
                emoji,
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<HomeworkSummary> dayHomeworks = _homeworksByDate.entries
        .where((entry) => entry.key.month == _focusedDay.month)
        .map((e) => e.value)
        .toList();

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text("나의 방학숙제", style: TextStyle(fontSize: 20.sp)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (_) => false,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: '월',
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextFormatter: (date, locale) =>
                    DateFormat('y년 M월', 'ko').format(date),
                titleTextStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _loadHomeworks();
              },
              onDaySelected: (selectedDay, focusedDay) async {
                setState(() => _focusedDay = focusedDay);
                final selected = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                if (_homeworksByDate.containsKey(selected)) {
                  final hw = _homeworksByDate[selected]!;
                  final result = await Navigator.pushNamed(
                    context,
                    '/detail',
                    arguments: hw.homeworkSeq.toString(),
                  );
                  if (result == true) {
                    await _loadHomeworks();
                    setState(() {});
                  }
                }
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(),
                todayDecoration: BoxDecoration(),
                todayTextStyle: TextStyle(),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, _) => _buildCalendarCell(date, false),
                todayBuilder: (context, date, _) {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final isToday = date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;
                  return _buildCalendarCell(date, isToday);
                },
                outsideBuilder: (context, date, _) =>
                    _buildCalendarCell(date, false, isOutside: true),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Divider(thickness: 1, color: Colors.grey.shade300),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadHomeworks,
              child: dayHomeworks.isEmpty
                  ? Center(
                      child: Text(
                        '일기가 없어요 😊',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
                      itemCount: dayHomeworks.length,
                      itemBuilder: (context, index) {
                        final hw = dayHomeworks[index];
                        final formattedDate = DateFormat('yyyy년 M월 d일').format(hw.selectedDate);
                        final content = hw.content;
                        final comment = hw.commentContent?.isNotEmpty ?? false
                            ? hw.commentContent!
                            : '선생님이 검사중이에요.';

                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/detail',
                              arguments: hw.homeworkSeq.toString(),
                            );
                            if (result == true) {
                              await _loadHomeworks();
                              setState(() {});
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _getWeatherEmoji(hw.weather) + '  ' + hw.title,
                                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  content,
                                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '$comment',
                                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/write');
          if (result == true) {
            setState(() {
              _isLoading = true;
            });
            await _loadHomeworks();
          }
        },
        backgroundColor: const Color.fromARGB(200, 68, 64, 64),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
