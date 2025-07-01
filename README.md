## 방학숙제 : 선생님 AI와 함께하는 특별한 일기쓰기
* 개발 기간 : `2025.06 ~ 2025.07`
* 도메인 : `라이프스타일/일기 앱`
* 팀 및 역할 : `BE/FE 1인, AI 1인 中 BB/FE 개발자로 참여`

</br>
</br>

## 서비스 소개

> 초등학생 시절 방학숙제였던 일기장 컨셉의 앱입니다. </br>
일기를 작성하면, 일정시간 후 일기에 대한 **코멘트와 칭찬도장**이 AI선생님으로부터 도착합니다.

![Frame 2](https://github.com/user-attachments/assets/cd4c3cbf-3155-4b2f-9002-ebbb71654345)

</br>

- [Apple 앱스토어 바로가기](https://apps.apple.com/kr/app/%EB%B0%A9%ED%95%99%EC%88%99%EC%A0%9C-%EC%84%A0%EC%83%9D%EB%8B%98ai%EC%99%80%EC%9D%98-%EC%9D%BC%EA%B8%B0/id6747587236)

</br>
</br>


## 주요기능 소개
**(1) 일기 쓰기**
<p>
  <img src="https://github.com/user-attachments/assets/03a50f7b-9126-461a-b8c4-6abc86a86e2e"  height="50%" width="45%" />
  <img src="https://github.com/user-attachments/assets/65718d46-3ae3-459f-a392-829e72f8972a" height="50%" width="45%" />
</p>

- 제목, 본문, 날씨, 감정 상태 등을 입력하여 일기를 작성할 수 있습니다.
- 작성된 일기는 JWT 인증을 통해 Spring 서버로 전송됩니다.
- 일기 저장 후, AI 분석이 완료되면 자동으로 코멘트가 붙고 알림이 도착합니다.

</br>

**(2) 홈 화면 (캘린더 기반 시각화)**

<img src="https://github.com/user-attachments/assets/30ecd547-1d61-4c1b-be85-2be93fec6c26"  width="45%" />

- Flutter 캘린더 위젯을 커스터마이징하여 월별 일기 작성 현황을 한눈에 보여줍니다.
- 날씨 아이콘 클릭을 통해 특정 날짜의 일기 여부를 직관적으로 확인할 수 있습니다.

</br>

**(3) 일기 상세조회**

<img src="https://github.com/user-attachments/assets/6e4aec04-63e2-46eb-bd5d-73484c95a289"  width="45%" />

- 작성된 일기의 제목, 본문, 감정, 날씨, AI 코멘트, 칭찬 도장 이미지를 함께 확인할 수 있습니다.
- 스크롤이 길어져도 ‘선생님의 코멘트’ 영역은 고정되도록 UI를 설계했습니다.

</br>

**(4) 회원가입 및 JWT 인증 처리**
- 자체 로그인 기반으로 회원가입 및 로그인 기능을 구현했습니다.
- 로그인 후 발급받은 AccessToken은 Bearer 헤더로 요청마다 첨부됩니다.

</br>

**(5) 설정 화면**
- 사용자 닉네임 조회 및 수정, 로그아웃, 회원 탈퇴 기능을 제공합니다.
- API 응답 기반으로 상태를 갱신하며, UX 측면에서도 자연스럽게 반영됩니다.

</br>

**(6) 푸시 알림 (FCM)**

<img src="https://github.com/user-attachments/assets/be3c3023-70d4-4d04-8600-00a300fff5f5"  width="45%" />

- AI 코멘트가 도착하면 FCM 알림을 통해 사용자에게 실시간으로 전달됩니다.
- 기기별 Firebase Token을 저장하여 개별 사용자 대상 전송이 가능합니다.

</br>
</br>

## 디렉토리 구조
```bash
/lib
 ┣ main.dart
 ┣ config/
 ┃ ┗ constants.dart           # API base URL, 환경변수
 ┣ services/
 ┃ ┣ api_client.dart          # Dio 초기화 및 공통 처리
 ┃ ┗ auth_service.dart        # 로그인, 회원가입, 토큰 관리
 ┣ models/
 ┃ ┣ login_request.dart
 ┃ ┣ homework.dart
 ┃ ┗ user.dart
 ┣ screens/
 ┃ ┣ login_screen.dart
 ┃ ┣ home_screen.dart
 ┃ ┣ diary_detail_screen.dart
 ┃ ┗ diary_write_screen.dart
 ┣ widgets/
 ┃ ┣ calendar_widget.dart     # 캘린더 UI
 ┃ ┣ diary_card.dart          # 일기 리스트 카드 UI
 ┗ main.dart                   # 라우팅 및 앱 테마 설정
```

</br>
</br>

## 기술 스택
> **Frontend** </br>
`Flutter`, `flutter_screenutil`, `firebase_messaging`, `flutter_secure_storage`

> **Design / UX**</br>
`초등학생 일기장 스타일 UI`, `카드형 레이아웃`

