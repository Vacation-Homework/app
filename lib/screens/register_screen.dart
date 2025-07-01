import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vacation_homework_app/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _nickController = TextEditingController();

  Timer? _debounceId;
  Timer? _debouncePw;
  Timer? _debounceNick;

  bool _isIdValid = false;
  bool _isPwValid = false;
  bool _isNickValid = false;
  bool _isLoading = false;
  bool _isPwObscured = true;

  String _checkedUserId = '';

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _nickController.dispose();
    _debounceId?.cancel();
    _debouncePw?.cancel();
    _debounceNick?.cancel();
    super.dispose();
  }

  void _onIdChanged(String value) {
    setState(() {
      _isIdValid = false;
      _checkedUserId = '';
    });

    _debounceId?.cancel();
    _debounceId = Timer(const Duration(milliseconds: 800), () async {
      final userId = value.trim();
      if (userId.length < 5 || userId.length > 20) return;

      final isAvailable = await AuthService.checkIdDuplicate(userId);
      setState(() {
        _isIdValid = isAvailable;
        if (isAvailable) {
          _checkedUserId = userId;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사용 가능한 아이디입니다')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미 사용 중인 아이디입니다')),
          );
        }
      });
    });
  }

  void _onPwChanged(String value) {
    _debouncePw?.cancel();
    _debouncePw = Timer(const Duration(milliseconds: 500), () {
      final pw = value.trim();
      setState(() {
        _isPwValid = pw.length >= 8 && pw.length <= 15;
      });
    });
  }

  void _onNickChanged(String value) {
    _debounceNick?.cancel();
    _debounceNick = Timer(const Duration(milliseconds: 500), () {
      final nick = value.trim();
      setState(() {
        _isNickValid = nick.length <= 5;
      });
    });
  }

  void _register() async {
    final userId = _idController.text.trim();
    final password = _pwController.text.trim();
    final nickname = _nickController.text.trim();

    if (!_isIdValid || _checkedUserId != userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 아이디를 입력해주세요')),
      );
      return;
    }

    if (!_isPwValid || !_isNickValid) return;

    setState(() => _isLoading = true);
    final success = await AuthService.register(
      userId: userId,
      password: password,
      nickname: nickname,
    );
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 성공! 로그인해주세요')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 실패!')),
      );
    }
  }

  Icon? _buildCheckIcon(bool isValid) {
    return Icon(
      isValid ? Icons.check_circle : Icons.check_circle_outline,
      color: isValid ? Colors.green : Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 50.h),
                SvgPicture.asset('assets/images/logo.svg', height: 150.h),
                Text(
                  '방학숙제에 오신것을 환영합니다!',
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 30.h),

                // 아이디 입력
                SizedBox(
                  width: 300.w,
                  child: TextField(
                    controller: _idController,
                    onChanged: _onIdChanged,
                    decoration: InputDecoration(
                      labelText: '아이디 (5~20자)',
                      suffixIcon: _buildCheckIcon(_isIdValid),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // 비밀번호 입력
                SizedBox(
                  width: 300.w,
                  child: TextField(
                    controller: _pwController,
                    obscureText: _isPwObscured,
                    onChanged: _onPwChanged,
                    decoration: InputDecoration(
                      labelText: '비밀번호 (8~15자)',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isPwObscured ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPwObscured = !_isPwObscured;
                              });
                            },
                          ),
                          if (_buildCheckIcon(_isPwValid) != null)
                            _buildCheckIcon(_isPwValid)!,
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // 닉네임 입력
                SizedBox(
                  width: 300.w,
                  child: TextField(
                    controller: _nickController,
                    onChanged: _onNickChanged,
                    decoration: InputDecoration(
                      labelText: '닉네임 (5자 이하)',
                      suffixIcon: _buildCheckIcon(_isNickValid),
                    ),
                  ),
                ),
                SizedBox(height: 60.h),

                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 68, 64, 64),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 14.h),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('회원가입', style: TextStyle(fontSize: 16.sp)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
