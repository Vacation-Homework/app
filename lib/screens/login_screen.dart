import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vacation_homework_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUserId();
  }

  Future<void> _loadSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('savedUserId');
    if (savedUserId != null) {
      _userIdController.text = savedUserId;
    }
  }

  void _login() async {
    setState(() => _isLoading = true);
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      debugPrint('FCM Token: $token');

      final success = await AuthService.login(
        userId: _userIdController.text.trim(),
        password: _passwordController.text.trim(),
        fcmToken: token,
      );

      if (success) {
        // ✅ 로그인 성공한 아이디 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('savedUserId', _userIdController.text.trim());

        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 실패!')),
        );
      }
    } catch (e) {
      debugPrint('[LOGIN] 에러: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/logo.svg',
              height: 170.h,
            ),
            SizedBox(height: 0.h),
            Center(
              child: SizedBox(
                width: 300.w,
                child: TextField(
                  controller: _userIdController,
                  decoration: const InputDecoration(labelText: '아이디'),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 300.w,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '비밀번호'),
                ),
              ),
            ),
            SizedBox(height: 35.h),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 68, 64, 64),
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      '로그인',
                      style: TextStyle(fontSize: 16.sp),
                    ),
            ),
            SizedBox(height: 15.h),
            TextButton(
              onPressed: _goToRegister,
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 39, 39, 39),
              ),
              child: Text(
                '회원가입 하기',
                style: TextStyle(fontSize: 14.sp),
              ),
            )
          ],
        ),
      ),
    );
  }
}
