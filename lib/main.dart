import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screen_time_api_ios/screen_time_api_ios.dart';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

void main() async {
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Bottomnavigationbar_Index()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Darwin',
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.blue,
        secondaryHeaderColor: Colors.blue,
        indicatorColor: Colors.blue,
        splashColor: const Color.fromARGB(120, 33, 149, 243),
        highlightColor: const Color.fromARGB(150, 33, 149, 243),
      ),
      color: Colors.blue,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus(); // 스플래시 화면이 나타난 후 바로 온보딩 상태를 확인합니다.
  }

  Future<void> _checkOnboardingStatus() async {
    const storage = FlutterSecureStorage();

    await Future.delayed(const Duration(seconds: 2)); // 스플래시 화면 2초 딜레이
    try {
      final pb = PocketBase('http://snowman0919.kro.kr:8080');
      String? email = await storage.read(key: "email");
      String? password = await storage.read(key: "password");

      // ignore: unused_local_variable
      final authData = await pb.collection('users').authWithPassword(
            email!,
            password!,
          );

      print(pb.authStore.isValid);
      print(pb.authStore.token);
      print(pb.authStore.model.id);

      Get.offAll(() => const HomeScreen());
    } on DioException catch (e) {
      Get.offAll(() => const OnboardingScreen());
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
      // 요청이 실패한 경우 상세한 오류 정보를 출력합니다.
      if (e.response != null) {
        print('DioError: ${e.response?.data}');
      } else {
        print('DioError: ${e.message}');
      }
    } catch (e, stackTrace) {
      Get.offAll(() => const OnboardingScreen());
      print(e);
      print(stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('./assets/images/logo.png', height: 100),
      ),
    );
  }
}

class MyAppPage extends StatefulWidget {
  const MyAppPage({super.key});

  @override
  _MyAppPageState createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyAppPage> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    const storage = FlutterSecureStorage();

    if (await storage.read(key: "token") != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Darwin으로 더 편안한 학교 생활을 보내세요!",
            body: "성적관리, 급식정보, 숙제 etc. 다양한 기능",
            image: const Padding(
                padding: EdgeInsets.all(32),
                child: Image(
                  image: AssetImage('./assets/images/logo.png'),
                  width: 200,
                )
                // Image.network('https://user-images.githubusercontent.com/26322627/143761841-ba5c8fa6-af01-4740-81b8-b8ff23d40253.png'),
                ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                color: Colors.blueAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          PageViewModel(
            title: "title",
            body: "context",
            image: Image.network(
                'https://user-images.githubusercontent.com/26322627/143761841-ba5c8fa6-af01-4740-81b8-b8ff23d40253.png'),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                color: Colors.blueAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
        ],
        next: const Text(
          "다음",
          style: TextStyle(color: Colors.blue),
        ),
        done: const Text(
          "시작하기",
          style: TextStyle(color: Colors.blue),
        ),
        showBackButton: true,
        back: const Text(
          "뒤로",
          style: TextStyle(color: Colors.blue),
        ),
        onDone: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Starting(),
            ),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _navScreens = [
    const MainPage(),
    const Chating(),
    School(),
    const CommunityPage(),
    const Functions(),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navScreens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        fixedColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '메인',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '학교',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_circle),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dehaze),
            label: '전체',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}

// 메인 페이지
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int TodayanTomorrow = 0;
  List<Map<String, dynamic>> user = [];

  Future<void> userdata() async {
    const storage = FlutterSecureStorage();
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    String? id = await storage.read(key: "id");

    if (id == null || id.isEmpty) {
      print('No valid ID found in storage.');
      return;
    }
    try {
      final record = await pb.collection('users').getOne(id);

      user.add({
        'id': record.id,
        'created': record.created,
        'updated': record.updated,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'nickname': record.data['nickname'] ?? "",
        'avatar': record.data['avatar'] ?? "",
        'schoolId': record.data['school_id'] ?? 0,
        'username': record.data['username'] ?? "",
        'introducing': record.data['introducing'] ?? "",
        'student_number': record.data['student_number'] ?? 0,
        'subject': record.data['subject'] ?? "",
        'teacher': record.data['teacher'] ?? false,
        'School_nm': record.data['School_nm'] ?? "",
        "school_id": record.data['school_id'] ?? 0,
        "grade": record.data['grade'] ?? 0,
        "class": record.data['class'] ?? 0,
        "edu_code": record.data['edu_code'] ?? "",
      });
    } on DioException catch (e) {
      print('Error fetching user data: ${e.message}');
      if (e.response?.statusCode == 404) {
        print('User not found for ID: $id');
      }
      rethrow;
    }
  }

  String getToday() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyyMMddE', 'ko_KR');
    var strToday = formatter.format(now);
    return strToday;
  }

  String getTomorrow() {
    DateTime now = DateTime.now().add(const Duration(days: 1));
    DateFormat formatter = DateFormat('yyyyMMddE', 'ko_KR');
    var strTomorrow = formatter.format(now);
    return strTomorrow;
  }

  String baseUrl = 'https://open.neis.go.kr/hub';
  final pb = PocketBase('http://snowman0919.kro.kr:8080');

  String selectedSubject = '오늘';
  List<String> subjects = ['오늘', '내일'];

  Future<dynamic> schooldataprovider(int day) async {
    userdata();
    try {
      String Today = getToday().substring(0, 8);
      String Tomorrow = getTomorrow().substring(0, 8);
      late SharedPreferences prefs;
      prefs = await SharedPreferences.getInstance();

      if (day == 0) {
        var meal = await Dio().post(
          '$baseUrl/mealServiceDietInfo?KEY=cf79fa15b3c34635b2a24876fe0838fc&ATPT_OFCDC_SC_CODE=${user[0]['edu_code']}&SD_SCHUL_CODE=${user[0]['school_id']}&TYPE=JSON&MLSV_YMD=$Today',
          options: Options(
            headers: {},
          ),
          data: {},
        );

        var timetable = await Dio().post(
          '$baseUrl/misTimetable?KEY=cf79fa15b3c34635b2a24876fe0838fc&ATPT_OFCDC_SC_CODE=${user[0]['edu_code']}&SD_SCHUL_CODE=${user[0]['school_id']}&ALL_TI_YMD=$Today&GRADE=3&CLASS_NM=${user[0]['class']}',
          options: Options(
            headers: {},
          ),
          data: {},
        );

        List<String> atptOfcdcScCode = [];
        List<String> sdSchulCode = [];
        List<String> schulNm = [];
        List<String> mmealScNm = [];
        List<String> mlsvYmd = [];
        List<String> mlsvFgr = [];
        List<String> itrtCntnt = [];
        String ddishNm = '';

        Map<String, dynamic> mealdata = meal.data;
        Map<String, dynamic> timetabledata = timetable.data;

        // Ensure mealServiceDietInfo and misTimetable are not null
        List<dynamic>? mealServiceDietInfo = mealdata['mealServiceDietInfo'];
        List<dynamic>? misTimetable = timetabledata['misTimetable'];

        if (mealServiceDietInfo != null && mealServiceDietInfo.length > 1) {
          List<dynamic> rows = mealServiceDietInfo[1]['row'] ?? [];
          for (var row in rows) {
            atptOfcdcScCode.add(row['ATPT_OFCDC_SC_CODE']);
            sdSchulCode.add(row['SD_SCHUL_CODE']);
            schulNm.add(row['SCHUL_NM']);
            mmealScNm.add(row['MMEAL_SC_NM']);
            mlsvYmd.add(row['MLSV_YMD']);
            mlsvFgr.add(row['MLSV_FGR'].toString());
            ddishNm = row['DDISH_NM'].toString();
          }
        }

        if (misTimetable != null && misTimetable.length > 1) {
          List<dynamic> perios = misTimetable[1]['row'] ?? [];
          for (var perio in perios) {
            itrtCntnt.add(perio['ITRT_CNTNT']);
          }
        }

        var mealNm = ddishNm.replaceAll('<br/>', '\n').replaceAll('*', '');
        mealNm = mealNm.replaceAllMapped(RegExp(r'\([^)]*\)'), (match) {
          return '';
        });

        return [mealNm, itrtCntnt];
      } else {
        var meal = await Dio().post(
          '$baseUrl/mealServiceDietInfo?KEY=cf79fa15b3c34635b2a24876fe0838fc&ATPT_OFCDC_SC_CODE=${user[0]['edu_code']}&SD_SCHUL_CODE=${user[0]['school_id']}&TYPE=JSON&MLSV_YMD=$Tomorrow',
          options: Options(
            headers: {},
          ),
          data: {},
        );

        var timetable = await Dio().post(
          '$baseUrl/misTimetable?KEY=cf79fa15b3c34635b2a24876fe0838fc&ATPT_OFCDC_SC_CODE=${user[0]['edu_code']}&SD_SCHUL_CODE=${user[0]['school_id']}&ALL_TI_YMD=$Tomorrow&GRADE=${user[0]['grade']}&CLASS_NM=${user[0]['class']}',
          options: Options(
            headers: {},
          ),
          data: {},
        );

        List<String> atptOfcdcScCode = [];
        List<String> sdSchulCode = [];
        List<String> schulNm = [];
        List<String> mmealScNm = [];
        List<String> mlsvYmd = [];
        List<String> mlsvFgr = [];
        List<String> itrtCntnt = [];
        String ddishNm = '';

        Map<String, dynamic> mealdata = meal.data;
        Map<String, dynamic> timetabledata = timetable.data;

        // Ensure mealServiceDietInfo and misTimetable are not null
        List<dynamic>? mealServiceDietInfo = mealdata['mealServiceDietInfo'];
        List<dynamic>? misTimetable = timetabledata['misTimetable'];

        if (mealServiceDietInfo != null && mealServiceDietInfo.length > 1) {
          List<dynamic> rows = mealServiceDietInfo[1]['row'] ?? [];
          for (var row in rows) {
            atptOfcdcScCode.add(row['ATPT_OFCDC_SC_CODE']);
            sdSchulCode.add(row['SD_SCHUL_CODE']);
            schulNm.add(row['SCHUL_NM']);
            mmealScNm.add(row['MMEAL_SC_NM']);
            mlsvYmd.add(row['MLSV_YMD']);
            mlsvFgr.add(row['MLSV_FGR'].toString());
            ddishNm = row['DDISH_NM'].toString();
          }
        }

        if (misTimetable != null && misTimetable.length > 1) {
          List<dynamic> perios = misTimetable[1]['row'] ?? [];
          for (var perio in perios) {
            itrtCntnt.add(perio['ITRT_CNTNT']);
          }
        }

        var mealNm = ddishNm.replaceAll('<br/>', '\n').replaceAll('*', '');
        mealNm = mealNm.replaceAllMapped(RegExp(r'\([^)]*\)'), (match) {
          return '';
        });

        return [mealNm, itrtCntnt];
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('DioError: ${e.response?.data}');
      } else {
        print('DioError: ${e.message}');
      }
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
    }
  }

  final List<Map<String, Object>> _toDoItems = [];
  Color selectedColor = Colors.blue; // 기본 색상

  // 할 일을 완료로 표시
  void _toggleComplete(int index, bool? value) {
    setState(() {
      _toDoItems[index]['completed'] = value ?? false;
    });
  }

  // 할 일 추가 대화 상자
  void _showAddToDoDialog() {
    String taskName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("새 할 일 추가"),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: "할 일 이름"),
                    onChanged: (value) {
                      taskName = value;
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text("색상 선택"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _colorCircle(Colors.red, setDialogState),
                      _colorCircle(Colors.green, setDialogState),
                      _colorCircle(Colors.blue, setDialogState),
                      _colorCircle(Colors.orange, setDialogState),
                      _colorCircle(Colors.purple, setDialogState),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                if (taskName.isNotEmpty) {
                  _addToDoItem(taskName, selectedColor);
                  Navigator.of(context).pop();
                }
              },
              child: const Text("추가"),
            ),
          ],
        );
      },
    );
  }

  Widget _colorCircle(Color color, StateSetter setDialogState) {
    return ClipOval(
      child: InkWell(
        onTap: () {
          setDialogState(() {
            // 상태가 변경되면 부모에서 color 변수를 참조
            selectedColor = color; // 선택된 색상 업데이트
          });
        },
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: selectedColor == color ? Colors.black : Colors.transparent,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // 할 일 추가
  void _addToDoItem(String task, Color color) {
    setState(() {
      _toDoItems.add({
        "task": task == '' ? '이름 없는 할 일' : task,
        "completed": false,
        "color": color,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    userdata();
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    // ignore: unused_local_variable
    String Today = getToday();
    String year = getToday().substring(0, 4);
    String Month = getToday().substring(4, 6);
    String Day = getToday().substring(6, 8);
    String day1 = getToday().substring(8, 9);
    const storage = FlutterSecureStorage();

    void initState() {
      super.initState();
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text('DARWIN'),
          backgroundColor: Colors.blue,
          shape: const Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
          // leading:
          //     const ImageIcon(AssetImage('./assets/images/darwin_title.png')),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Notification()));
              },
            ),
            FutureBuilder<void>(
              future: userdata(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Loading indicato
                } else if (snapshot.hasError) {
                  return Icon(Icons.error, color: Colors.red); // Error icon
                } else if (user[0]['avatar'] == '') {
                  return Icon(Icons.person, color: Colors.grey); // Default icon
                } else {
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(), // Replace with your profile screen widget
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            "http://snowman0919.kro.kr:8080/api/files/${user[0]['collectionId']}/${user[0]['id']}/${user[0]['avatar']}",
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  );
                }
              },
            ),
          ],
        ),
        body: RefreshIndicator(
            color: Colors.blue,
            backgroundColor: Colors.white,
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
                child: Container(
                    child: Column(
              children: [
                SafeArea(
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(3, 10, 3, 0),
                        child: Row(children: [
                          const SizedBox(width: 10),
                          Text(
                            "오늘 날짜: $year년 $Month월 $Day일 $day1",
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Row(
                            children: subjects.map((subject) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSubject = subject;
                                    TodayanTomorrow = subject == "오늘" ? 0 : 1;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: subject == selectedSubject
                                        ? Colors.blue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  child: Text(
                                    subject,
                                    style: TextStyle(
                                      color: subject == selectedSubject
                                          ? Colors.white
                                          : Colors.blue,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(width: 10),
                        ]))),
                SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        width: 200,
                        height: 200,
                        margin: const EdgeInsets.fromLTRB(6, 10, 3, 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(0, 255, 255, 255),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.grey.withOpacity(0.5),
                          //     spreadRadius: 5,
                          //     blurRadius: 7,
                          //     offset: const Offset(0, 3), // changes position of shadow
                          //   ),
                          // ],
                        ),
                        child: Column(children: [
                          const Text(
                            "시간표",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (day1 != '토' && day1 != "일" ||
                              (day1 == "일" && TodayanTomorrow == 1)) ...[
                            Center(
                                child: FutureBuilder<dynamic>(
                                    future: schooldataprovider(TodayanTomorrow),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(child: Container());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child:
                                                Text('오류: ${snapshot.error}'));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data[1]!.isEmpty) {
                                        return const Center(
                                          child: Text('\n\n\n오류가 발생했어요.',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 16,
                                                height: 1.2,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        );
                                      } else if (snapshot.data[1][0].length >=
                                              10 &&
                                          snapshot.data[1].length == 7) {
                                        var data = snapshot.data!;
                                        var timetable = data[1];

                                        return Table(
                                          // border: TableBorder.all(), // 표 경계를 나타내도록 설정합니다.
                                          children: [
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text(
                                                          '1교시',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[0],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text('2교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[1],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text('3교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[2],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text('4교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[3],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text('5교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[4],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text('6교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[5],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text('7교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[6],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                          ],
                                        );
                                      } else if (snapshot.data[1][0].length >=
                                              10 &&
                                          snapshot.data[1].length == 6) {
                                        // 데이터가 성공적으로 로드되었을 때
                                        var data = snapshot.data!;
                                        var timetable = data[1];

                                        return Column(children: [
                                          const SizedBox(height: 10),
                                          Table(
                                            // border: TableBorder.all(), // 표 경계를 나타내도록 설정합니다.
                                            children: [
                                              TableRow(
                                                children: [
                                                  const TableCell(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.4),
                                                          child: Text(
                                                            '1교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ))),
                                                  TableCell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.4),
                                                          child: Text(
                                                              timetable[0],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  const TableCell(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.4),
                                                          child: Text('2교시',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                  TableCell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.4),
                                                          child: Text(
                                                              timetable[1],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  const TableCell(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.4),
                                                          child: Text('3교시',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                  TableCell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.4),
                                                          child: Text(
                                                              timetable[2],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  const TableCell(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.4),
                                                          child: Text('4교시',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                  TableCell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.4),
                                                          child: Text(
                                                              timetable[3],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  const TableCell(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.4),
                                                          child: Text('5교시',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                  TableCell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.4),
                                                          child: Text(
                                                              timetable[4],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  const TableCell(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.4),
                                                          child: Text('6교시',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                  TableCell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.4),
                                                          child: Text(
                                                              timetable[5],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                ],
                                              ),
                                            ],
                                          )
                                        ]);
                                      } else if (snapshot.data[1].length == 7 &&
                                          snapshot.data[1][0].length <= 10) {
                                        var data = snapshot.data!;
                                        var timetable = data[1];

                                        return Table(
                                          // border: TableBorder.all(), // 표 경계를 나타내도록 설정합니다.
                                          children: [
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text(
                                                          '1교시',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[0],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text('2교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[1],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text('3교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[2],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text('4교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[3],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text('5교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[4],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text('6교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[5],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0.4),
                                                        child: Text('7교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                                TableCell(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.4),
                                                        child: Text(
                                                            timetable[6],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )))),
                                              ],
                                            ),
                                          ],
                                        );
                                      } else {
                                        // 데이터가 성공적으로 로드되었을 때
                                        var data = snapshot.data!;
                                        var timetable = data[1];

                                        return Column(children: [
                                          const SizedBox(height: 10),
                                          Table(
                                            // border: TableBorder.all(), // 표 경계를 나타내도록 설정합니다.
                                            children: [
                                              TableRow(
                                                children: [
                                                  const TableCell(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.4),
                                                          child: Text(
                                                            '1교시',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ))),
                                                  TableCell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.4),
                                                          child: Text(
                                                              timetable[0],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  const TableCell(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.4),
                                                          child: Text('2교시',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                  TableCell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.4),
                                                          child: Text(
                                                              timetable[1],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  const TableCell(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.4),
                                                          child: Text('3교시',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                  TableCell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.4),
                                                          child: Text(
                                                              timetable[2],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  const TableCell(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.4),
                                                          child: Text('4교시',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                  TableCell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.4),
                                                          child: Text(
                                                              timetable[3],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  const TableCell(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.4),
                                                          child: Text('5교시',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                  TableCell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.4),
                                                          child: Text(
                                                              timetable[4],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  const TableCell(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.4),
                                                          child: Text('6교시',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                  TableCell(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.4),
                                                          child: Text(
                                                              timetable[5],
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )))),
                                                ],
                                              ),
                                            ],
                                          )
                                        ]);
                                      }
                                    }))
                          ] else ...[
                            const Center(
                              child: Text('\n\n\n오늘은 수업이 없네요.',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.2,
                                    fontWeight: FontWeight.bold,
                                  )),
                            )
                          ]
                        ]),
                      )),
                      Expanded(
                          child: Container(
                        width: 200,
                        height: 200,
                        margin: const EdgeInsets.fromLTRB(3, 10, 6, 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(0, 255, 255, 255),
                        ),
                        child: Column(
                          children: [
                            if (day1 == "일" && TodayanTomorrow == 1) ...[
                              Text("$Month/${int.parse(Day) + 1} (월)급식",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ] else ...[
                              Text("$Month/$Day ($day1)급식",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ],
                            if (day1 != '토' && day1 != "일" ||
                                (day1 == "일" && TodayanTomorrow == 1)) ...[
                              FutureBuilder<dynamic>(
                                  future: schooldataprovider(TodayanTomorrow),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(child: Container());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Text('오류: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                        child: Text('\n\n\n오류가 발생했어요.',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 16,
                                              height: 1.2,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      );
                                    } else {
                                      // 데이터가 성공적으로 로드되었을 때
                                      var data = snapshot.data!;
                                      var meal = data[0];

                                      return Center(
                                        child: Text("\n$meal",
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              height: 1.2,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      );
                                    }
                                  })
                            ] else ...[
                              const Center(
                                child: Text('\n\n\n오늘은 급식이 없네요.',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.2,
                                      fontWeight: FontWeight.bold,
                                    )),
                              )
                            ]
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(
                              "캘린더",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => Calendar(
                          //           events: _toDoItems,
                          //           )),
                          // );
                        },
                        child: Container(
                          width: 418,
                          margin: const EdgeInsets.fromLTRB(6, 0, 6, 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromARGB(0, 255, 255, 255),
                          ),
                          child: Card(
                            elevation: 0.0,
                            color: Colors.white,
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _toDoItems.length + 1, // 추가 버튼을 포함
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // 한 줄에 2개의 항목
                                  childAspectRatio: 3, // 항목의 가로세로 비율 조정
                                  crossAxisSpacing: 10, // 항목 간 가로 간격
                                  mainAxisSpacing: 10, // 항목 간 세로 간격
                                ),
                                itemBuilder: (context, index) {
                                  if (index == _toDoItems.length) {
                                    // 마지막 인덱스일 경우 추가 버튼 표시
                                    return GestureDetector(
                                      onTap: _showAddToDoDialog, // 대화상자 표시
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          color: Colors.grey.shade100,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "+ 추가하기",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        color: Colors.grey.shade100,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            // 색상 구분 원
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: (_toDoItems[index]
                                                        ['color'] as Color?) ??
                                                    Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            // 할 일 내용
                                            Expanded(
                                              child: Text(
                                                _toDoItems[index]['task']
                                                    as String,
                                                style: TextStyle(
                                                  decoration: (_toDoItems[index]
                                                          ['completed'] as bool)
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                            // 체크박스
                                            Checkbox(
                                              value: _toDoItems[index]
                                                  ['completed'] as bool,
                                              onChanged: (value) {
                                                _toggleComplete(index, value);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                    child: Column(
                  children: <Widget>[
                    const Row(
                      children: [
                        SizedBox(width: 25),
                        Text(
                          "우리반 소식",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Spacer()
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // HomeScreen._onNavTapped();
                      },
                      child: Container(
                        width: 418,
                        margin: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(0, 255, 255, 255),
                        ),
                        child: Card(
                          elevation: 0.0,
                          color: Colors.white,
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            child: const Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 5),
                                    Text(
                                      '내일',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Text(
                                      '국어 수행평가 - 주제를 갖고 토론하기',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 5),
                                    Text(
                                      '수요일',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Text(
                                      '수학 숙제 - 20번 학습지 풀어오기',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 5),
                                    Text(
                                      '목요일',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Text(
                                      '역사 수행평가 - 역사 일기쓰기',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Text(
                                      '영어 수행평가 - 7과 단어시험',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    SizedBox(width: 25),
                    Text(
                      "학습도구",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Spacer()
                  ],
                ),
                Container(
                    margin: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                            width: 418,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            child: Material(
                                color: const Color.fromARGB(0, 255, 255, 255),
                                child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const StopwatchPage()),
                                      );
                                    },
                                    child: Container(
                                      child: const Column(
                                        children: [
                                          Spacer(),
                                          Row(
                                            children: [
                                              SizedBox(width: 12),
                                              Icon(
                                                Icons.timer,
                                                size: 32,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                '스탑워치 - 공부 시간을 측정하고 경쟁하기',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              )
                                            ],
                                          ),
                                          Spacer()
                                        ],
                                      ),
                                    )))))),
                const SizedBox(height: 12),
                Container(
                    margin: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                            width: 418,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            child: Material(
                                color: const Color.fromARGB(0, 255, 255, 255),
                                child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Performance_Manager()),
                                      );
                                    },
                                    child: Container(
                                      child: const Column(
                                        children: [
                                          Spacer(),
                                          Row(
                                            children: [
                                              SizedBox(width: 12),
                                              Icon(
                                                Icons.book_rounded,
                                                size: 32,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                '성적관리 - 내 내신을 기록하고 확인하기',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                              )
                                            ],
                                          ),
                                          Spacer()
                                        ],
                                      ),
                                    )))))),
                const SafeArea(
                    child: Column(
                  children: [
                    SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(width: 25),
                        Text(
                          "오늘의 인기글",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Spacer()
                      ],
                    ),
                  ],
                )),
                IconButton(
                  icon: const Icon(Icons.star),
                  onPressed: () async {
                    String? id = await storage.read(key: "id");
                    print(id);
                    final record = await pb.collection('users').getFullList(
                          filter: 'id == "$id"',
                        );
                    print(record);
                  },
                ),
              ],
            )))));
  }
}

void logout(context) {
  final pb = PocketBase('http://snowman0919.kro.kr:8080');
  const storage = FlutterSecureStorage();

  pb.authStore.clear();
  storage.deleteAll();
  Get.offAll(() => const OnboardingScreen());
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('로그아웃되었습니다.'),
    backgroundColor: Colors.blue,
  ));
}

// 채팅방 json 정리
class ChatRoom {
  final String id;
  final String created;
  final String updated;
  final String chatingName;
  final String? content;
  final List<String> users;

  ChatRoom({
    required this.id,
    required this.created,
    required this.updated,
    required this.chatingName,
    this.content,
    required this.users,
  });

  // JSON 데이터를 모델로 변환하는 함수
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      created: json['created'],
      updated: json['updated'],
      chatingName: json['Chating_Name'] ?? '채팅방이 없습니다.',
      content: json['content'],
      users: List<String>.from(json['users'] ?? []), // users 필드가 null일 경우 빈 리스트
    );
  }
}

// 체팅 페이지
class Chating extends StatefulWidget {
  const Chating({super.key});

  @override
  _ChatingState createState() => _ChatingState();
}

class _ChatingState extends State<Chating> {
  @override
  Widget build(BuildContext context) {
    Future<void> leaveChatRoom(
        int chatRoomIndex, List<ChatRoom> chatRooms) async {
      final chatRoomId = chatRooms[chatRoomIndex].id;
      final pb = PocketBase('http://snowman0919.kro.kr:8080');

      try {
        // Delete all messages associated with this chat room
        final messageRecords = await pb
            .collection('messages')
            .getFullList(filter: 'room = "$chatRoomId"');
        for (final message in messageRecords) {
          await pb.collection('messages').delete(message.id);
        }
        // Delete the chat room itself
        await pb.collection('Chating_Room').delete(chatRoomId);

        // Provide feedback to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채팅방 및 그 메시지가 삭제되었습니다.')),
        );
        setState(() {});
      } catch (e) {
        print('Error deleting chat room or messages: $e');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채팅방 삭제 중 오류가 발생했습니다.')),
        );
      }
    }

    void showChatRoomOptionsDialog(
        int chatRoomIndex, List<ChatRoom> chatRooms) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('채팅방 옵션'),
            content: const Text('무엇을 하시겠습니까?'),
            actions: <Widget>[
              TextButton(
                child: const Text('채팅방 삭제'),
                onPressed: () {
                  Navigator.of(context).pop();
                  leaveChatRoom(chatRoomIndex, chatRooms);
                },
              ),
              TextButton(
                child: const Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    Future<List<ChatRoom>> Chating_List_Call() async {
      const storage = FlutterSecureStorage();
      String? id = await storage.read(key: "id");
      final pb = PocketBase('http://snowman0919.kro.kr:8080');
      try {
        final resultList = await pb
            .collection('Chating_Room')
            .getFullList(filter: 'users ?~ "$id"');
        return resultList
            .map((item) => ChatRoom.fromJson(item.toJson()))
            .toList();
      } catch (e) {
        print('Error fetching chat rooms: $e');
        throw Exception('채팅방 데이터를 불러오는 중 오류가 발생했습니다.');
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          '채팅',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_add,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Chating_Add(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ChatRoom>>(
        future: Chating_List_Call(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('데이터 로드 중 오류 발생'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('채팅방이 없습니다.'));
          } else {
            final chatRooms = snapshot.data!;
            return ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];
                return ListTile(
                  title: Text(chatRoom.chatingName.isNotEmpty
                      ? chatRoom.chatingName
                      : '이름없는 채팅'),
                  subtitle: Text('${chatRoom.users.length}명 참여'),
                  onLongPress: () {
                    showChatRoomOptionsDialog(index, chatRooms);
                    print(chatRoom.chatingName);
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatRoomScreen(chatRoom: chatRoom),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ChatRoomScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatRoomScreen({super.key, required this.chatRoom});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final PocketBase pb = PocketBase('http://snowman0919.kro.kr:8080');
  List<Map<String, dynamic>> _messages = [];
  String? _currentUserId; // 현재 사용자 ID를 저장할 변수
  final ImagePicker _picker = ImagePicker();
  List<XFile> pickedImages = []; // 변수명 변경

  Future<void> _pickImg() async {
    final List<XFile> images = await _picker.pickMultiImage();
    // null 체크 수정
    setState(() {
      pickedImages = images;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _subscribeToMessages();
    _loadUserId(); // 사용자 ID 로드
  }

  @override
  void dispose() {
    pb.realtime.unsubscribe('messages');
    super.dispose();
  }

  Future<void> _loadUserId() async {
    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: "id");
    setState(() {
      _currentUserId = id; // 사용자 ID 저장
    });
  }

  // 메시지 가져오기
  Future<void> _fetchMessages() async {
    try {
      final resultList = await pb.collection('messages').getFullList(
            filter: 'room = "${widget.chatRoom.id}"',
            sort: '-created',
          );

      setState(() {
        _messages = resultList.map((e) => e.toJson()).toList();
      });
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  // 실시간 메시지 수신
  void _subscribeToMessages() {
    pb.realtime.subscribe('messages', (event) {
      print('Received event: ${event.toJson()}');
      final data = jsonDecode(event.data);
      if (data is Map<String, dynamic> && data['record'] != null) {
        final newMessage = data['record'];
        if (newMessage['room'] == widget.chatRoom.id) {
          setState(() {
            _messages.insert(0, newMessage); // 최신 메시지를 가장 위에 추가
          });
        }
      }
    });
  }

  // 메시지 전송
  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty && pickedImages.isEmpty) return;

    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: "id");
    // var contentHash = base64Encode(utf8.encode(content)).toString();
    // print(base64Decode(contentHash));

    try {
      var url = Uri.parse(
          'http://snowman0919.kro.kr:8080/api/collections/messages/records');
      var request = http.MultipartRequest('POST', url);

      // 필드 추가
      request.fields['room'] = widget.chatRoom.id;
      request.fields['content'] = content;
      request.fields['user'] = id ?? '';

      // 여러 이미지 파일 추가
      for (var image in pickedImages) {
        request.files.add(await http.MultipartFile.fromPath(
          'image', // 서버에서 기대하는 필드명
          image.path,
        ));
      }

      // 요청 전송
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Message sent successfully');
        setState(() {
          pickedImages = []; // 전송 후 이미지 초기화
        });
        _messageController.clear();
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoom.chatingName),
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchMessages,
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isCurrentUser = message['user'] == _currentUserId;

                  return Container(
                    alignment: isCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if ((message['content'] != null &&
                                message['content'].isNotEmpty) ||
                            (message['image'] != null &&
                                message['image'].isNotEmpty))
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Colors.blue
                                  : const Color.fromARGB(255, 233, 233, 235),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: isCurrentUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                // 텍스트 메시지
                                if (message['content'] != null &&
                                    message['content'].isNotEmpty)
                                  Text(
                                    message['content'],
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),

                                // 이미지 메시지
                                if (message['image'] != null &&
                                    message['image'].isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: GestureDetector(
                                        onTap: () {
                                          // 팝업 다이얼로그 열기
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                  backgroundColor:
                                                      Colors.black, // 배경 색상
                                                  insetPadding:
                                                      const EdgeInsets.all(
                                                          0), // 다이얼로그 여백 조정
                                                  child: Stack(children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0), // 추가 패딩 제거
                                                      child: PhotoView(
                                                        imageProvider:
                                                            NetworkImage(
                                                          'http://snowman0919.kro.kr:8080/api/files/${message['collectionId']}/${message['id']}/${message['image'][0]}',
                                                        ),
                                                        minScale:
                                                            PhotoViewComputedScale
                                                                .contained, // 최소 배율 조정
                                                        maxScale:
                                                            PhotoViewComputedScale
                                                                    .covered *
                                                                2, // 최대 배율 조정
                                                        loadingBuilder:
                                                            (BuildContext
                                                                    context,
                                                                ImageChunkEvent?
                                                                    loadingProgress) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return const Center(
                                                                child:
                                                                    CircularProgressIndicator());
                                                          }
                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              value: loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      (loadingProgress
                                                                              .expectedTotalBytes ??
                                                                          1)
                                                                  : null,
                                                            ),
                                                          );
                                                        },
                                                        errorBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Object error,
                                                                StackTrace?
                                                                    stackTrace) {
                                                          return const Center(
                                                              child: Text(
                                                                  '이미지를 불러오는 데 실패했습니다.',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)));
                                                        },
                                                      ),
                                                    ),
                                                    Positioned(
                                                      left: 0,
                                                      top: 10,
                                                      child: IconButton(
                                                        icon: const Icon(
                                                            Icons.close,
                                                            color: Colors
                                                                .white), // Close button icon
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                        },
                                                      ),
                                                    )
                                                  ]));
                                            },
                                          );
                                        },
                                        child: Image.network(
                                          'http://snowman0919.kro.kr:8080/api/files/${message['collectionId']}/${message['id']}/${message['image'][0]}',
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        (loadingProgress
                                                                .expectedTotalBytes ??
                                                            1)
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (BuildContext context,
                                              Object error,
                                              StackTrace? stackTrace) {
                                            return const Text(
                                                '이미지를 불러오는 데 실패했습니다.');
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // 이미지 미리보기 추가
          if (pickedImages.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pickedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(pickedImages[index].path),
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              pickedImages.removeAt(index); // 해당 이미지 삭제
                            });
                          },
                          child: const CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '메시지 입력',
                    fillColor: const Color.fromARGB(255, 155, 205, 230),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _pickImg, // 직접 호출
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        _sendMessage(_messageController.text);
                      },
                    ),
                  ),
                ),
              ),
            ])),
      ),
    );
  }
}

class Chating_Add extends StatefulWidget {
  @override
  _Chating_AddState createState() => _Chating_AddState();
}

class _Chating_AddState extends State<Chating_Add> {
  Future<List<dynamic>> userListCall() async {
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: "id");

    try {
      final records =
          await pb.collection('users').getFullList(sort: '-created');

      List<Map<String, dynamic>> users = [];

      for (var record in records) {
        if (record.id != id) {
          users.add({
            'id': record.id,
            'created': record.created,
            'updated': record.updated,
            'collectionId': record.collectionId,
            'collectionName': record.collectionName,
            'avatar': record.data['avatar'] ?? "",
            'schoolId': record.data['school_id'] ?? 0,
            'grade': record.data['grade'] ?? 0,
            'class': record.data['class'] ?? 0,
            'username': record.data['nickname'] ?? "",
            'introducing': record.data['introducing'] ?? "",
            'studentNumber': record.data['student_number'] ?? 0,
            'subject': record.data['subject'] ?? "",
            'teacher': record.data['teacher'] ?? false,
          });
        }
      }

      return users;
    } on DioException catch (e) {
      print(e);
      rethrow;
    }
  }

  String userType = '학생'; // '학생' 또는 '선생님'을 선택하는 옵션
  String selectedGrade = '전체'; // 학년 필터 ('전체'는 모든 학년 포함)
  String chatRoomName = '';

  List<Map<String, dynamic>> myUserData = [];

  Future<void> userData() async {
    const storage = FlutterSecureStorage();
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    String? id = await storage.read(key: "id");

    if (id == null || id.isEmpty) {
      print('No valid ID found in storage.');
      return;
    }
    try {
      final record = await pb.collection('users').getOne(id);

      myUserData.add({
        'id': record.id,
        'created': record.created,
        'updated': record.updated,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'nickname': record.data['nickname'] ?? "",
        'avatar': record.data['avatar'] ?? "",
        'schoolId': record.data['school_id'] ?? 0,
        'username': record.data['username'] ?? "",
        'introducing': record.data['introducing'] ?? "",
        'studentNumber': record.data['student_number'] ?? 0,
        'subject': record.data['subject'] ?? "",
        'teacher': record.data['teacher'] ?? false,
        'School_nm': record.data['School_nm'] ?? "",
        'grade': record.data['grade'] ?? 0,
        'class': record.data['class'] ?? 0,
      });
    } on DioException catch (e) {
      print('Error fetching user data: ${e.message}');
      if (e.response?.statusCode == 404) {
        print('User not found for ID: $id');
      }
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    userData();
  }

  @override
  Widget build(BuildContext contextmain) {
    userListCall();
    userData();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(contextmain);
          },
        ),
        title: const Text(
          '대화 추가',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: userType,
                  items: <String>['학생', '선생님'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      userType = newValue!;
                      if (userType == '선생님') {
                        selectedGrade = '전체'; // 선생님을 선택하면 학년 필터를 초기화
                      }
                    });
                  },
                ),
                if (userType == '학생') // 학생일 때만 학년 필터 보여줌
                  DropdownButton<String>(
                    value: selectedGrade,
                    items:
                        <String>['전체', '1학년', '2학년', '3학년'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGrade = newValue!;
                      });
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: userListCall(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('데이터 로드 중 오류 발생'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('초대할 사람이 없습니다.'));
                } else {
                  final users = snapshot.data!;
                  final filteredUsers = users.where((user) {
                    final bool isTeacher = user['teacher'];
                    final String grade = user['grade'].toString();

                    if (userType == '학생') {
                      return !isTeacher &&
                          (selectedGrade == '전체' ||
                              grade == selectedGrade.replaceAll('학년', ''));
                    } else {
                      return isTeacher;
                    }
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return ListTile(
                        title: Text(user['username']),
                        subtitle: user['teacher']
                            ? Text('선생님 - ${user['subject']}')
                            : Text('학생 - ${user['grade']}학년 ${user['class']}반'),
                        onTap: () async {
                          print('${user['username']} 눌림');
                          showDialog(
                            context: contextmain,
                            builder: (BuildContext context) {
                              String tempChatRoomName = chatRoomName;
                              userData();
                              return AlertDialog(
                                title: const Text('채팅방 이름 입력'),
                                content: TextField(
                                  onChanged: (value) {
                                    tempChatRoomName = value;
                                  },
                                  decoration: const InputDecoration(
                                    hintText: '채팅방 이름',
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('취소'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('확인'),
                                    onPressed: () async {
                                      print(myUserData[0]['id']);
                                      setState(() {
                                        chatRoomName = tempChatRoomName;
                                      });
                                      if (chatRoomName.isNotEmpty) {
                                        final pb = PocketBase(
                                            'http://snowman0919.kro.kr:8080');
                                        final body = <String, dynamic>{
                                          "Chating_Name": chatRoomName,
                                          "users": [
                                            myUserData[0]['id'],
                                            user['id']
                                          ]
                                        };

                                        try {
                                          await pb
                                              .collection('Chating_Room')
                                              .create(body: body);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '채팅방 "$chatRoomName" 생성됨'),
                                            ),
                                          );
                                          Navigator.of(context)
                                              .pop(); // Close dialog
                                        } catch (e) {
                                          print('Error creating chat room: $e');
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('채팅방 이름을 입력하세요.'),
                                          ),
                                        );
                                      }
                                      Navigator.of(contextmain).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 학교 페이지
// ignore: must_be_immutable
class School extends StatefulWidget {
  @override
  _SchoolState createState() => _SchoolState();
}

class _SchoolState extends State<School> {
  late int dDayCount;
  List<Map<String, dynamic>> dDayRecords = [];
  final ImagePicker _picker = ImagePicker();
  List<XFile> pickedImages = []; // 변수명 변경

  Future<void> _pickImg() async {
    final List<XFile> images = await _picker.pickMultiImage();
    // null 체크 수정
    setState(() {
      pickedImages = images;
    });
  }

  Future<int> D_Day() async {
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    // ignore: unused_local_variable

    try {
      const storage = FlutterSecureStorage();
      String? id = await storage.read(key: 'id');
      final record = await pb.collection('D_Day').getFullList(
            filter: 'user = "${id}"',
          );

      // print(record);

      dDayRecords = record.map((record) {
        DateTime targetDate = DateTime.parse(record.data['day']);
        dDayCount = targetDate.difference(DateTime.now()).inDays;

        return {
          'title': record.data['title'],
          'dDayCount': dDayCount,
          'targetDate': targetDate,
        };
      }).toList();

      return dDayCount;
    } on DioException catch (e) {
      print(e);
      rethrow;
    }
  }

  List<Map<String, dynamic>> user = [];

  Future<void> userdata() async {
    const storage = FlutterSecureStorage();
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    String? id = await storage.read(key: "id");

    if (id == null || id.isEmpty) {
      print('No valid ID found in storage.');
      return;
    }
    try {
      final record = await pb.collection('users').getOne(id);

      user.add({
        'id': record.id,
        'created': record.created,
        'updated': record.updated,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'nickname': record.data['nickname'] ?? "",
        'avatar': record.data['avatar'] ?? "",
        'school_id': record.data['school_id'] ?? 0,
        'username': record.data['username'] ?? "",
        'introducing': record.data['introducing'] ?? "",
        'studentNumber': record.data['student_number'] ?? 0,
        'subject': record.data['subject'] ?? "",
        'teacher': record.data['teacher'] ?? false,
        'School_nm': record.data['School_nm'] ?? "",
        'grade': record.data['grade'] ?? 0,
        'class': record.data['class'] ?? 0,
        'edu_code': record.data['edu_code'] ?? 0,
      });
    } on DioException catch (e) {
      print('Error fetching user data: ${e.message}');
      if (e.response?.statusCode == 404) {
        print('User not found for ID: $id');
      }
      rethrow;
    }
  }

  String recordid = '';
  String images = '';
  List<String> aisum = [];

  Future<void> uploadImage(XFile imageFile) async {
    final url = Uri.parse(
        'http://snowman0919.kro.kr:8080/api/collections/Assessment/records');
    const storage = FlutterSecureStorage();
    String? edu_code = await storage.read(key: "edu_code");

    try {
      print('Preparing the request...');
      var request = http.MultipartRequest('POST', url);

      // 필드 추가: 필드 이름이 정확한지 확인
      request.fields['title'] = '';
      request.fields['edu_num'] = edu_code!;
      request.fields['school_num'] = user[0]['school_id'].toString();
      request.fields['grade'] = user[0]['grade'].toString();
      request.fields['class'] = user[0]['class'].toString();

      final originalImage = img.decodeImage(await imageFile.readAsBytes());

      final directory = await getTemporaryDirectory();
      final compressedImagePath = '${directory.path}/compressed_image.jpg';

      // 압축된 이미지 파일로 저장
      File(compressedImagePath)
        ..writeAsBytesSync(img.encodeJpg(originalImage!, quality: 50));
      print('Image compressed and saved at: $compressedImagePath');

      // 압축된 이미지를 XFile로 반환
      // XFile(compressedImagePath);

      // 이미지 파일 추가
      request.files.add(await http.MultipartFile.fromPath(
        'images', // PocketBase에서 설정한 필드명
        compressedImagePath,
      ));

      print('Sending the request...');
      final response = await request.send();
      print('Response received.');

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        final responseString = await response.stream.bytesToString();
        var responseData = jsonDecode(responseString);
        recordid = responseData['id'];
        images = responseData['images'][0];
        print(images);

        print(responseData); // 업로드 후 응답 처리
      } else {
        print('Failed to upload image: ${response.statusCode}');
        final errorString = await response.stream.bytesToString();
        print('Error: $errorString');
      }
    } catch (e) {
      print('Error during image upload: $e');
    }
  }

  Future<void> callOpenAI(XFile imageFile) async {
    final String apiKey =
        ''; // OpenAI API 키
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          // "image": base64Image,
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text":
                      "문서/사진 내용을 한국어로 주제, 과목(예: 국어, 영어, 수학)(수행평가 시 수행평가 표시, ex. 국어 수행평가)(준비물 가져와야 할 숙제 시 숙제 표시, ex. 수학 숙제), 날짜(예: 년도-월-일), 내용(수행평가 시 요약, 숙제 시 ~해오기)만 추출해 출력해"
                },
                {
                  "type": "image_url",
                  "image_url": {
                    "url":
                        "http://snowman0919.kro.kr:8080/api/files/11l8p9zs8zs795v/$recordid/$images",
                    "detail": "low"
                  }
                }
              ]
            }
          ],
          'max_tokens': 2000,
          'temperature': 1,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        print("OpenAI Response: ${data['choices'][0]['message']['content']}");

        final String topic = RegExp(r'주제:\s*(.+)')
                .firstMatch(data['choices'][0]['message']['content'])
                ?.group(1) ??
            '';
        final String subject = RegExp(r'과목:\s*(.+)')
                .firstMatch(data['choices'][0]['message']['content'])
                ?.group(1) ??
            '';
        final String date = RegExp(r'날짜:\s*(.+)')
                .firstMatch(data['choices'][0]['message']['content'])
                ?.group(1) ??
            '';
        final String content = RegExp(r'내용:\s*(.+)')
                .firstMatch(data['choices'][0]['message']['content'])
                ?.group(1) ??
            '';
        aisum = [topic, subject, date, content];
      } else {
        throw Exception("Failed to generate text: ${response.body}");
      }
    } catch (e) {
      print("Error calling OpenAI: $e");
    }
  }

  Map<String, List<String>> groupedByWeekday = {};

  Future<List<List<dynamic>>> classnews() async {
    const storage = FlutterSecureStorage();
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    String? id = await storage.read(key: "id");

    try {
      final records = await pb.collection('Assessment').getFullList(
          sort: '-day',
          filter:
              'school_num = "${user[0]['school_id']}" && edu_num = "${user[0]['edu_code']}" && grade = "${user[0]['grade']}" && class = "${user[0]['class']}"');

      List<String> ids = [];
      List<String> createdDates = [];
      List<String> updatedDates = [];
      List<String> collectionIds = [];
      List<String> collectionNames = [];
      List<String> subject = [];
      List<dynamic> images = [];
      List<String> title = [];
      List<String> topic = [];
      List<String> day = [];

      // print(records);

      for (var record in records) {
        ids.add(record.id);
        createdDates.add(record.created);
        updatedDates.add(record.updated);
        collectionIds.add(record.collectionId);
        collectionNames.add(record.collectionName);
        subject.add(record.data['content'] ?? "");
        images.add(record.data['images'] ?? "");
        title.add(record.data['title'] ?? "");
        topic.add(record.data['writer'] ?? "");
        day.add(record.data['day'] ?? "");
      }
      print(title);
      print(day);

      for (int i = 0; i < day.length; i++) {
        DateTime date = DateTime.parse(day[i]);
        String weekdayName =
            DateFormat('EEEE', 'ko_KR').format(date); // 요일 이름을 한국어로 변환

        if (!groupedByWeekday.containsKey(weekdayName)) {
          groupedByWeekday[weekdayName] = [];
        }
        groupedByWeekday[weekdayName]!.add(title[i]);
      }

      return [
        ids,
        createdDates,
        updatedDates,
        collectionIds,
        collectionNames,
        subject,
        images,
        title,
        topic,
        day,
      ];
    } on DioException catch (e) {
      print('Error fetching user data: ${e.message}');
      if (e.response?.statusCode == 404) {
        print('User not found for ID: $id');
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: userdata(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 데이터를 로드하는 동안 로딩 스피너를 표시합니다.
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 오류가 발생한 경우 오류 메시지를 표시합니다.
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // 데이터 로드가 완료된 후 화면을 구성합니다.
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder(
                          future: userdata(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: Container());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text("Error loading user data"));
                            } else {
                              return Text(
                                  '${user[0]['School_nm'].toString()} ${user[0]['grade'].toString()}학년 ${user[0]['class'].toString()}반',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20));
                            }
                          }),
                      FutureBuilder<int>(
                        future: D_Day(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DDay_Counter()),
                                  );
                                },
                                child: Text(
                                  '설정 안됨',
                                  style: TextStyle(color: Colors.red),
                                ));
                          } else {
                            int dDayCount = snapshot.data ?? 0;
                            return TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DDay_Counter()),
                                );
                              },
                              child: Text(
                                dDayCount == 0
                                    ? '${dDayRecords[0]['title']} D-Day'
                                    : (dDayCount > 0
                                        ? '${dDayRecords[0]['title']} D-${dDayCount + 1}'
                                        : '${dDayRecords[0]['title']} D+${dDayCount.abs()}'),
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  shape: const Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 과제 및 숙제
                      SizedBox(height: 10),
                      SafeArea(
                          child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 418,
                              margin: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(20),
                                color: const Color.fromARGB(0, 255, 255, 255),
                              ),
                              child: Card(
                                elevation: 0.0,
                                color: Colors.white,
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            "우리반 소식",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          const Spacer(),
                                          IconButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder:
                                                      (BuildContext contextin) {
                                                    return Container(
                                                      height: 250, // 모달 높이 크기
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors
                                                            .white, // 모달 배경색
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft: Radius.circular(
                                                              20), // 모달 좌상단 라운딩 처리
                                                          topRight: Radius.circular(
                                                              20), // 모달 우상단 라운딩 처리
                                                        ),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(
                                                              height: 4),
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  '새 소식 추가하기',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          25),
                                                                ),
                                                              ]),
                                                          const SizedBox(
                                                              height: 8),
                                                          Center(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      await _pickImg();
                                                                      if (pickedImages
                                                                          .isNotEmpty) {
                                                                        await uploadImage(
                                                                            pickedImages[0]);
                                                                        await callOpenAI(
                                                                            pickedImages[0]);
                                                                      }
                                                                      Navigator.pop(
                                                                          contextin);
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                assessment_add(aisum: aisum, ai: 1)),
                                                                      );
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      margin: EdgeInsets
                                                                          .fromLTRB(
                                                                              6,
                                                                              0,
                                                                              6,
                                                                              0),
                                                                      height:
                                                                          150,
                                                                      width:
                                                                          150,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.black),
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          SizedBox(
                                                                              height: 15),
                                                                          Icon(
                                                                            Icons.image,
                                                                            color:
                                                                                Colors.blueGrey,
                                                                            size:
                                                                                90,
                                                                          ),
                                                                          SizedBox(
                                                                              height: 8),
                                                                          Text(
                                                                            '이미지 업로드하기',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )),
                                                                SizedBox(
                                                                  width: 15,
                                                                ),
                                                                InkWell(
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          contextin);
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                assessment_add(aisum: [], ai: 0)),
                                                                      );
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      margin: EdgeInsets
                                                                          .fromLTRB(
                                                                              0,
                                                                              0,
                                                                              6,
                                                                              0),
                                                                      height:
                                                                          150,
                                                                      width:
                                                                          150,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.black),
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          SizedBox(
                                                                              height: 15),
                                                                          Icon(
                                                                            Icons.edit_document,
                                                                            color:
                                                                                Colors.blueGrey,
                                                                            size:
                                                                                90,
                                                                          ),
                                                                          SizedBox(
                                                                              height: 8),
                                                                          Text(
                                                                            '직접 추가하기',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              icon: const Icon(Icons.add))
                                        ],
                                      ),
                                      const Row(
                                        children: [
                                          SizedBox(width: 5),
                                          Text(
                                            '월요일',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const Row(
                                        children: [
                                          SizedBox(width: 15),
                                          Text(
                                            '국어 수행평가 - 주제를 갖고 토론하기',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      const Row(
                                        children: [
                                          SizedBox(width: 5),
                                          Text(
                                            '수요일',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const Row(
                                        children: [
                                          SizedBox(width: 15),
                                          Text(
                                            '수학 숙제 - 20번 학습지 풀어오기',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      const Row(
                                        children: [
                                          SizedBox(width: 5),
                                          Text(
                                            '목요일',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const Row(
                                        children: [
                                          SizedBox(width: 15),
                                          Text(
                                            '역사 수행평가 - 역사 일기쓰기',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      const Row(
                                        children: [
                                          SizedBox(width: 15),
                                          Text(
                                            '영어 수행평가 - 7과 단어시험',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      const Row(
                                        children: [
                                          SizedBox(width: 15),
                                          Text(
                                            '국어 숙제 - 문법 문제지 풀어오기',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(height: 20),
                      // SafeArea(
                      //     child: Column(
                      //   children: <Widget>[
                      //     GestureDetector(
                      //       onTap: () {},
                      //       child: Container(
                      //         width: 418,
                      //         margin: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      //         decoration: BoxDecoration(
                      //           border: Border.all(color: Colors.grey),
                      //           borderRadius: BorderRadius.circular(20),
                      //           color: const Color.fromARGB(0, 255, 255, 255),
                      //         ),
                      //         child: Card(
                      //           elevation: 0.0,
                      //           color: Colors.white,
                      //           child: Container(
                      //             margin: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                      //             child: Column(
                      //               children: [
                      //                 Row(
                      //                   children: [
                      //                     const Text(
                      //                       "우리반 소식",
                      //                       style: TextStyle(
                      //                         fontSize: 22,
                      //                         fontWeight: FontWeight.bold,
                      //                       ),
                      //                       textAlign: TextAlign.left,
                      //                     ),
                      //                     const Spacer(),
                      //                     IconButton(
                      //                         onPressed: () {
                      //                           showModalBottomSheet(
                      //                             context: context,
                      //                             builder:
                      //                                 (BuildContext contextin) {
                      //                               return Container(
                      //                                 height: 250, // 모달 높이 크기
                      //                                 decoration:
                      //                                     const BoxDecoration(
                      //                                   color: Colors
                      //                                       .white, // 모달 배경색
                      //                                   borderRadius:
                      //                                       BorderRadius.only(
                      //                                     topLeft: Radius.circular(
                      //                                         20), // 모달 좌상단 라운딩 처리
                      //                                     topRight: Radius.circular(
                      //                                         20), // 모달 우상단 라운딩 처리
                      //                                   ),
                      //                                 ),
                      //                                 child: Column(
                      //                                   children: [
                      //                                     const SizedBox(
                      //                                         height: 4),
                      //                                     Row(
                      //                                         mainAxisAlignment:
                      //                                             MainAxisAlignment
                      //                                                 .center,
                      //                                         children: [
                      //                                           Text(
                      //                                             '새 소식 추가하기',
                      //                                             style: TextStyle(
                      //                                                 fontWeight:
                      //                                                     FontWeight
                      //                                                         .bold,
                      //                                                 fontSize:
                      //                                                     25),
                      //                                           ),
                      //                                         ]),
                      //                                     const SizedBox(
                      //                                         height: 8),
                      //                                     Center(
                      //                                       child: Row(
                      //                                         mainAxisAlignment:
                      //                                             MainAxisAlignment
                      //                                                 .center,
                      //                                         children: [
                      //                                           InkWell(
                      //                                               onTap:
                      //                                                   () async {
                      //                                                 await _pickImg();
                      //                                                 if (pickedImages
                      //                                                     .isNotEmpty) {
                      //                                                   await uploadImage(
                      //                                                       pickedImages[0]);
                      //                                                   await callOpenAI(
                      //                                                       pickedImages[0]);
                      //                                                 }
                      //                                                 Navigator.pop(
                      //                                                     contextin);
                      //                                                 Navigator
                      //                                                     .push(
                      //                                                   context,
                      //                                                   MaterialPageRoute(
                      //                                                       builder: (context) =>
                      //                                                           assessment_add(aisum: aisum, ai: 1)),
                      //                                                 );
                      //                                               },
                      //                                               child:
                      //                                                   Container(
                      //                                                 margin: EdgeInsets
                      //                                                     .fromLTRB(
                      //                                                         6,
                      //                                                         0,
                      //                                                         6,
                      //                                                         0),
                      //                                                 height:
                      //                                                     150,
                      //                                                 width:
                      //                                                     150,
                      //                                                 decoration:
                      //                                                     BoxDecoration(
                      //                                                   border: Border.all(
                      //                                                       color:
                      //                                                           Colors.black),
                      //                                                   borderRadius:
                      //                                                       BorderRadius.circular(20),
                      //                                                 ),
                      //                                                 child:
                      //                                                     Column(
                      //                                                   children: [
                      //                                                     SizedBox(
                      //                                                         height: 15),
                      //                                                     Icon(
                      //                                                       Icons.image,
                      //                                                       color:
                      //                                                           Colors.blueGrey,
                      //                                                       size:
                      //                                                           90,
                      //                                                     ),
                      //                                                     SizedBox(
                      //                                                         height: 8),
                      //                                                     Text(
                      //                                                       '이미지 업로드하기',
                      //                                                       style:
                      //                                                           TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      //                                                     )
                      //                                                   ],
                      //                                                 ),
                      //                                               )),
                      //                                           SizedBox(
                      //                                             width: 15,
                      //                                           ),
                      //                                           InkWell(
                      //                                               onTap: () {
                      //                                                 Navigator.pop(
                      //                                                     contextin);
                      //                                                 Navigator
                      //                                                     .push(
                      //                                                   context,
                      //                                                   MaterialPageRoute(
                      //                                                       builder: (context) =>
                      //                                                           assessment_add(aisum: [], ai: 0)),
                      //                                                 );
                      //                                               },
                      //                                               child:
                      //                                                   Container(
                      //                                                 margin: EdgeInsets
                      //                                                     .fromLTRB(
                      //                                                         0,
                      //                                                         0,
                      //                                                         6,
                      //                                                         0),
                      //                                                 height:
                      //                                                     150,
                      //                                                 width:
                      //                                                     150,
                      //                                                 decoration:
                      //                                                     BoxDecoration(
                      //                                                   border: Border.all(
                      //                                                       color:
                      //                                                           Colors.black),
                      //                                                   borderRadius:
                      //                                                       BorderRadius.circular(20),
                      //                                                 ),
                      //                                                 child:
                      //                                                     Column(
                      //                                                   children: [
                      //                                                     SizedBox(
                      //                                                         height: 15),
                      //                                                     Icon(
                      //                                                       Icons.edit_document,
                      //                                                       color:
                      //                                                           Colors.blueGrey,
                      //                                                       size:
                      //                                                           90,
                      //                                                     ),
                      //                                                     SizedBox(
                      //                                                         height: 8),
                      //                                                     Text(
                      //                                                       '직접 추가하기',
                      //                                                       style:
                      //                                                           TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      //                                                     )
                      //                                                   ],
                      //                                                 ),
                      //                                               )),
                      //                                         ],
                      //                                       ),
                      //                                     ),
                      //                                   ],
                      //                                 ),
                      //                               );
                      //                             },
                      //                           );
                      //                         },
                      //                         icon: const Icon(Icons.add))
                      //                   ],
                      //                 ),
                      //                 FutureBuilder<List<List<dynamic>>>(
                      //                     future: classnews(),
                      //                     builder: (context, snapshot) {
                      //                       if (snapshot.connectionState ==
                      //                           ConnectionState.waiting) {
                      //                         return Center(child: Container());
                      //                       } else if (snapshot.hasError) {
                      //                         return Center(
                      //                             child: Text(
                      //                                 'Error: ${snapshot.error}'));
                      //                       } else if (!snapshot.hasData ||
                      //                           snapshot.data!.isEmpty) {
                      //                         return Center(
                      //                             child: Text(
                      //                                 'No news available'));
                      //                       } else {
                      //                         Map<String, List<String>>
                      //                             groupedTasks = {};

                      //                         for (int i = 0;
                      //                             i < snapshot.data![9].length;
                      //                             i++) {
                      //                           String date = snapshot.data![9]
                      //                                       [i]
                      //                                   .split(' ')[
                      //                               0]; // 'YYYY-MM-DD'만 추출

                      //                           if (groupedTasks
                      //                               .containsKey(date)) {
                      //                             groupedTasks[date]!.add(
                      //                                 snapshot.data![7][i]);
                      //                           } else {
                      //                             groupedTasks[date] = [
                      //                               snapshot.data![7][i]
                      //                             ];
                      //                           }
                      //                         }

                      //                         // Print the grouped tasks
                      //                         groupedTasks
                      //                             .forEach((date, tasks) {
                      //                           print('$date: $tasks');
                      //                         });
                      //                         return Column(children: [
                      //                           Row(
                      //                             children: [
                      //                               SizedBox(width: 5),
                      //                               Text(
                      //                                 '월요일',
                      //                                 style: TextStyle(
                      //                                     fontSize: 20,
                      //                                     fontWeight:
                      //                                         FontWeight.bold),
                      //                               ),
                      //                             ],
                      //                           ),
                      //                           FutureBuilder<
                      //                                   List<List<dynamic>>>(
                      //                               future: classnews(),
                      //                               builder:
                      //                                   (context, snapshot) {
                      //                                 if (snapshot
                      //                                         .connectionState ==
                      //                                     ConnectionState
                      //                                         .waiting) {
                      //                                   return Center(
                      //                                       child:
                      //                                           CircularProgressIndicator());
                      //                                 } else if (snapshot
                      //                                     .hasError) {
                      //                                   return Center(
                      //                                       child: Text(
                      //                                           'Error: ${snapshot.error}'));
                      //                                 } else if (!snapshot
                      //                                         .hasData ||
                      //                                     snapshot
                      //                                         .data!.isEmpty) {
                      //                                   return Center(
                      //                                       child: Text(
                      //                                           'No news available'));
                      //                                 } else {
                      //                                   var titles =
                      //                                       snapshot.data![7];

                      //                                   return Expanded(
                      //                                       child:
                      //                                           RefreshIndicator(
                      //                                               color: Colors
                      //                                                   .blue,
                      //                                               backgroundColor:
                      //                                                   Colors
                      //                                                       .white,
                      //                                               onRefresh:
                      //                                                   () async {
                      //                                                 setState(
                      //                                                     () {});
                      //                                               },
                      //                                               child: ListView.builder(
                      //                                                   itemCount: titles.length,
                      //                                                   itemBuilder: (context, index) {
                      //                                                     return InkWell(
                      //                                                         onTap: () {},
                      //                                                         child: Container(
                      //                                                             child: Row(
                      //                                                           children: [
                      //                                                             SizedBox(width: 15),
                      //                                                             Text(
                      //                                                               '${snapshot.data![5][index]} 수행평가 - 주제를 갖고 토론하기',
                      //                                                               style: TextStyle(fontSize: 16),
                      //                                                             ),
                      //                                                           ],
                      //                                                         )));
                      //                                                   })));
                      //                                 }
                      //                               }),
                      //                         ]);
                      //                       }
                      //                     }),
                      //                 const Row(
                      //                   children: [
                      //                     SizedBox(width: 5),
                      //                     Text(
                      //                       '수요일',
                      //                       style: TextStyle(
                      //                           fontSize: 20,
                      //                           fontWeight: FontWeight.bold),
                      //                     ),
                      //                   ],
                      //                 ),
                      //                 const Row(
                      //                   children: [
                      //                     SizedBox(width: 15),
                      //                     Text(
                      //                       '수학 숙제 - 20번 학습지 풀어오기',
                      //                       style: TextStyle(fontSize: 16),
                      //                     ),
                      //                   ],
                      //                 ),
                      //                 const Row(
                      //                   children: [
                      //                     SizedBox(width: 5),
                      //                     Text(
                      //                       '목요일',
                      //                       style: TextStyle(
                      //                           fontSize: 20,
                      //                           fontWeight: FontWeight.bold),
                      //                     ),
                      //                   ],
                      //                 ),
                      //                 const Row(
                      //                   children: [
                      //                     SizedBox(width: 15),
                      //                     Text(
                      //                       '역사 수행평가 - 역사 일기쓰기',
                      //                       style: TextStyle(fontSize: 16),
                      //                     ),
                      //                   ],
                      //                 ),
                      //                 const Row(
                      //                   children: [
                      //                     SizedBox(width: 15),
                      //                     Text(
                      //                       '영어 수행평가 - 7과 단어시험',
                      //                       style: TextStyle(fontSize: 16),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // )),
                      // const SizedBox(height: 20),

                      // 이번 주의 수행 평가
                      SafeArea(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // HomeScreen._onNavTapped();
                              },
                              child: Container(
                                width: 418,
                                margin: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color.fromARGB(0, 255, 255, 255),
                                ),
                                child: Card(
                                  elevation: 0.0,
                                  color: Colors.white,
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '이번주의 수행평가',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),

                                        const SizedBox(height: 10),
                                        // 수행평가 테이블
                                        Table(
                                          border: TableBorder.all(),
                                          children: const [
                                            TableRow(
                                              children: [
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          '월',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ))),
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          '화',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ))),
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          '수',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ))),
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          '목',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ))),
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          '금',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text('국어'))),
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(''))),
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(''))),
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(''))),
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text('역사'))),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(''))),
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(''))),
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(''))),
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(''))),
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text('영어'))),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ));
          }
        });
  }
}

class assessment_add extends StatefulWidget {
  @override
  _assessment_addState createState() => _assessment_addState();
  final List<String> aisum;
  final num ai;

  const assessment_add({
    super.key,
    required this.aisum,
    required this.ai,
  });
}

class _assessment_addState extends State<assessment_add> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedSubject;
  String? _selectedtopics;

  final List<String> _subjects = [
    '국어',
    '수학',
    '영어',
    '사회',
    '과학',
    '역사',
    '도덕',
    '기술가정',
    '체육',
    '미술',
    '기타'
  ];
  final List<String> _topics = ['수행평가', '숙제', '기타'];
  final Map<int, String> _weekdays = {
    1: '월요일',
    2: '화요일',
    3: '수요일',
    4: '목요일',
    5: '금요일',
    6: '토요일',
    7: '일요일',
  };

  XFile? _selectedImage;

  List<Map<String, dynamic>> user = [];

  Future<void> userdata() async {
    const storage = FlutterSecureStorage();
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    String? id = await storage.read(key: "id");

    if (id == null || id.isEmpty) {
      print('No valid ID found in storage.');
      return;
    }
    try {
      final record = await pb.collection('users').getOne(id);

      user.add({
        'id': record.id,
        'created': record.created,
        'updated': record.updated,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'nickname': record.data['nickname'] ?? "",
        'avatar': record.data['avatar'] ?? "",
        'school_id': record.data['school_id'] ?? 0,
        'username': record.data['username'] ?? "",
        'introducing': record.data['introducing'] ?? "",
        'studentNumber': record.data['student_number'] ?? 0,
        'subject': record.data['subject'] ?? "",
        'teacher': record.data['teacher'] ?? false,
        'School_nm': record.data['School_nm'] ?? "",
        'grade': record.data['grade'] ?? 0,
        'class': record.data['class'] ?? 0,
        'edu_code': record.data['edu_code'] ?? 0,
      });
    } on DioException catch (e) {
      print('Error fetching user data: ${e.message}');
      if (e.response?.statusCode == 404) {
        print('User not found for ID: $id');
      }
      rethrow;
    }
  }

  Future<void> userdataupdate() async {
    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: "id");

    if (id == null || id.isEmpty) {
      print('Error: User ID is null or empty');
      return;
    }

    userdata();

    try {
      final pb = PocketBase('http://snowman0919.kro.kr:8080');

      if (_titleController.text.isEmpty ||
          user[0]['edu_code'] == null ||
          user[0]['school_id'] == null ||
          user[0]['grade'] == null ||
          user[0]['class'] == null ||
          _contentController.text.isEmpty ||
          _selectedDate == null ||
          _selectedSubject == null ||
          _selectedtopics == null) {
        print('Error: Missing required fields');
        return;
      }

      Map<String, dynamic> fields = {
        'title': _titleController.text,
        'edu_num': user[0]['edu_code'],
        'school_num': user[0]['school_id'].toString(),
        'grade': user[0]['grade'].toString(),
        'class': user[0]['class'].toString(),
        'content': _contentController.text,
        'day': _selectedDate.toString(),
        'subject': _selectedSubject.toString(),
        'topic': _selectedtopics.toString(),
      };

      List<http.MultipartFile> files = [];

      if (_selectedImage != null) {
        final originalImage =
            img.decodeImage(await _selectedImage!.readAsBytes());

        if (originalImage != null) {
          final directory = await getTemporaryDirectory();
          final compressedImagePath = '${directory.path}/compressed_image.jpg';

          // Compress and save the image
          File(compressedImagePath)
            ..writeAsBytesSync(img.encodeJpg(originalImage, quality: 50));
          print('Image compressed and saved at: $compressedImagePath');

          // Add image file to the list of files
          files.add(await http.MultipartFile.fromPath(
            'images', // Ensure this matches your API's expected field name
            compressedImagePath,
          ));
        } else {
          print('Error: Failed to decode image');
          return;
        }
      }

      // Update user data in PocketBase
      // ignore: unused_local_variable
      final response =
          await pb.collection('Assessment').create(body: fields, files: files);

      Navigator.pop(context);
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: userdata(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 데이터를 로드하는 동안 로딩 스피너를 표시합니다.
            return Container();
          } else if (snapshot.hasError) {
            // 오류가 발생한 경우 오류 메시지를 표시합니다.s
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // 데이터 로드가 완료된 후 화면을 구성합니다.
            return Scaffold(
              appBar: AppBar(
                title: Text('소식 추가하기'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                        controller: _titleController,
                        decoration:
                            InputDecoration(labelText: '제목(ex. 33번 학습지 가져오기)'),
                        validator: (value) =>
                            value!.isEmpty ? '(ex. 33번 학습지 가져오기)' : null,
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedSubject,
                        decoration: InputDecoration(labelText: '과목'),
                        items: _subjects.map((String subject) {
                          return DropdownMenuItem<String>(
                            value: subject,
                            child: Text(subject),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSubject = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? '과목을 선택하세요.' : null,
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedtopics,
                        decoration: InputDecoration(labelText: '형식'),
                        items: _topics.map((String subject) {
                          return DropdownMenuItem<String>(
                            value: subject,
                            child: Text(subject),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedtopics = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? '과목을 선택하세요.' : null,
                      ),
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(labelText: '내용'),
                        maxLines: 8,
                        validator: (value) =>
                            value!.isEmpty ? '상세 내용을 입력하세요.' : null,
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue, // Text color
                            ),
                            onPressed: _pickImage,
                            child: Text('이미지 추가하기'),
                          ),
                          SizedBox(width: 10),
                          _selectedImage != null
                              ? Text(_selectedImage!.name.length >= 20
                                  ? '${_selectedImage!.name.substring(0, 20)}...'
                                  : _selectedImage!.name)
                              : Text('이미지 없음'),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue, // Text color
                            ),
                            onPressed: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2999),
                              ).then((selectedDate) {
                                setState(() {
                                  _selectedDate = selectedDate;
                                });
                              });
                            },
                            child: const Text("날짜 선택"),
                          ),
                          SizedBox(width: 35),
                          Text(
                              _selectedDate != null
                                  ? '${_selectedDate.toString().split(" ")[0]} ${_weekdays[_selectedDate!.weekday]}'
                                  : "날짜가 아직 선택되지 않음",
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue, // Text color
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // 데이터 처리 로직 추가
                            print('Submitted');
                            userdataupdate();
                          }
                        },
                        child: Text('등록하기'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}

class DDay_Counter extends StatefulWidget {
  const DDay_Counter({super.key});

  @override
  State<DDay_Counter> createState() => _DDay_CounterState();
}

class _DDay_CounterState extends State<DDay_Counter> {
  DateTime? _selectedDate;
  final TextEditingController _controller = TextEditingController();
  late int dDayCheckResult;
  List<Map<String, dynamic>> dDayRecords = [];

  @override
  void initState() {
    super.initState();
    // 비동기 함수 호출
    initializeD_Day_Check();
  }

  Future<int> D_Day_Check() async {
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    try {
      const storage = FlutterSecureStorage();
      String? id = await storage.read(key: 'id');
      final record = await pb.collection('D_Day').getFullList(
            filter: 'user = "$id"',
          );

      dDayRecords = record.map((record) {
        DateTime targetDate = DateTime.parse(record.data['day']);
        return {
          'id': record.id,
          'title': record.data['title'],
          'targetDate': targetDate,
        };
      }).toList();

      if (record.isEmpty) {
        // print(0);
        return 0;
      } else {
        // print(1);
        return 1;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> initializeD_Day_Check() async {
    dDayCheckResult = await D_Day_Check();
    setState(() {}); // dDayCheckResult가 업데이트되었음을 알리기 위해 setState 호출
  }

  Future<void> D_Day() async {
    try {
      final pb = PocketBase('http://snowman0919.kro.kr:8080');
      const storage = FlutterSecureStorage();
      String? id = await storage.read(key: 'id');

      if (dDayCheckResult == 0 &&
          _controller.text.isNotEmpty == true &&
          _selectedDate.toString().isNotEmpty == true) {
        final body = <String, dynamic>{
          "user": id,
          "day": _selectedDate.toString(),
          "title": _controller.text
        };

        // ignore: unused_local_variable
        final record = await pb.collection('D_Day').create(body: body);

        Navigator.pop(context);
        Get.snackbar('성공!', 'D-Day가 설정되었습니다.',
            backgroundColor: Colors.blue, duration: const Duration(seconds: 3));
      } else if (dDayCheckResult == 1 &&
          _controller.text.isNotEmpty == true &&
          _selectedDate.toString().isNotEmpty == true) {
        final body = <String, dynamic>{
          "user": id,
          "title": _controller.text,
          "day": _selectedDate.toString()
        };

        // print(dDayRecords);

        // ignore: unused_local_variable
        final record = await pb
            .collection('D_Day')
            .update('${dDayRecords[0]['id']}', body: body);
        Navigator.pop(context);
        Get.snackbar('성공!', 'D-Day가 변경되었습니다.',
            backgroundColor: Colors.blue, duration: const Duration(seconds: 3));
      } else {
        Get.snackbar('실패!', 'D-Day가 존재하지 않습니다.',
            backgroundColor: Colors.red, duration: const Duration(seconds: 3));
      }
    } on DioException catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: (D_Day_Check() != 0)
            ? Text(
                'D-Day 설정하기',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                'D-Day 수정하기',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          TextButton(
              onPressed: () {
                D_Day();
              },
              child: const Text(
                '저장',
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ))
        ],
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 242, 242, 246),
      body: Column(
        children: [
          SafeArea(
              child: Container(
            width: 500,
            height: 300,
            margin: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black45),
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
              child: Container(
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                          labelText: 'D-day 이름을 입력하세요.',
                          fillColor: Colors.blue,
                          hoverColor: Colors.blue,
                          focusColor: Colors.blue),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue, // Text color
                      ),
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2999),
                        ).then((selectedDate) {
                          setState(() {
                            _selectedDate = selectedDate;
                          });
                        });
                      },
                      child: const Text("날짜 선택"),
                    ),
                    Text(
                        _selectedDate != null
                            ? _selectedDate.toString().split(" ")[0]
                            : "날짜가 아직 선택되지 않음",
                        style: const TextStyle(fontSize: 22)),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

Future<String> id() async {
  try {
    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: 'id');
    print(id);

    return id!;
  } on DioException catch (e) {
    print(e);
    rethrow;
  }
}

class LikeButton extends StatefulWidget {
  final int index;
  final String postId;
  final int initialLike;

  const LikeButton(this.index, this.postId, this.initialLike, {super.key});

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    likeCount = widget.initialLike;
  }

  void toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    await pb.collection('posts_commu').update(widget.postId, body: {
      'Like': likeCount,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : null),
          onPressed: toggleLike,
        ),
        Text(likeCount.toString()),
      ],
    );
  }
}

// 커뮤니티 페이지
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => CommunityState();
}

class CommunityState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController = TabController(
    length: 4,
    vsync: this,
    initialIndex: 0,
    animationDuration: const Duration(milliseconds: 400),
  );

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<List<List<dynamic>>> postsListView_commu() async {
    final pb = PocketBase('http://snowman0919.kro.kr:8080');

    try {
      final records = await pb.collection('posts_commu').getFullList(
            sort: '-created',
          );

      List<String> ids = [];
      List<String> createdDates = [];
      List<String> updatedDates = [];
      List<String> collectionIds = [];
      List<String> collectionNames = [];
      List<int> Like = [];
      List<int> commentNum = [];
      List<String> contents = [];
      List<dynamic> images = [];
      List<String> titles = [];
      List<String> writers = [];
      List<String> authorname = [];
      List<String> profilename = [];

      // print(records);

      for (var record in records) {
        ids.add(record.id);
        createdDates.add(record.created);
        updatedDates.add(record.updated);
        collectionIds.add(record.collectionId);
        collectionNames.add(record.collectionName);
        Like.add(record.data['Like'] ?? 0);
        commentNum.add(record.data['Comment_num'] ?? 0);
        contents.add(record.data['content'] ?? "");
        images.add(record.data['images'] ?? "");
        titles.add(record.data['title'] ?? "");
        writers.add(record.data['writer'] ?? "");
      }

      for (var id in writers) {
        final record = await pb.collection('users').getOne(id);

        authorname.add(record.data['nickname']);
      }

      for (var id in writers) {
        final record = await pb.collection('users').getOne(id);

        profilename.add(record.data['avatar'] ?? '');
      }

      return [
        ids,
        createdDates,
        updatedDates,
        collectionIds,
        collectionNames,
        contents,
        images,
        titles,
        authorname,
        Like,
        commentNum,
        writers,
        profilename
      ];
    } on DioException catch (e) {
      print(e);
      rethrow;
    }
  }

  String selectedTopic_commu = '전체';
  List<String> topics_commu = ['전체', '인기글', '일상대화', '노래/그림', '덕질', '연애'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          '커뮤니티',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.blue,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: "소통하기"),
            Tab(text: "공부하기"),
            Tab(text: "문제풀이"),
            Tab(text: "우리학교"),
          ],
        ),
      ),
      body: Column(children: [
        Expanded(
            child: TabBarView(
          controller: tabController,
          children: [
            FutureBuilder<List<dynamic>>(
                future: postsListView_commu(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('오류: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('아직 어떤 글도 없네요...'));
                  } else {
                    // 데이터가 성공적으로 로드되었을 때
                    var data = snapshot.data!;
                    var ids = data[0];
                    var titles = data[7];
                    var contents = data[5];
                    var author = data[8];
                    var like = data[9];
                    var commentNum = data[10];
                    var updatedDates = data[1];
                    var authorid = data[11];
                    var profile = data[12];

                    return Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: topics_commu.map((topic) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedTopic_commu = topic;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  margin: const EdgeInsets.fromLTRB(4, 5, 4, 5),
                                  decoration: BoxDecoration(
                                    color: topic == selectedTopic_commu
                                        ? Colors.blue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  child: Text(
                                    topic,
                                    style: TextStyle(
                                      color: topic == selectedTopic_commu
                                          ? Colors.white
                                          : Colors.blue,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Expanded(
                            child: RefreshIndicator(
                          color: Colors.blue,
                          backgroundColor: Colors.white,
                          onRefresh: () async {
                            setState(() {});
                          },
                          child: ListView.builder(
                            itemCount: titles.length, // 게시물 수
                            itemBuilder: (context, index) {
                              return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ContentPage(
                                                title: titles[index],
                                                content: contents[index],
                                                author: author[index],
                                                like: like[index],
                                                time: updatedDates[index],
                                                comment_num: commentNum[index],
                                                authorid: authorid[index],
                                                profile: profile[index],
                                              )),
                                    );
                                  },
                                  child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                          color: Colors.grey, // 보더 색상
                                          width: 1.0, // 보더 너비
                                        )),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.white,
                                                    backgroundImage: NetworkImage(
                                                        "http://snowman0919.kro.kr:8080/api/files/users/${authorid[index]}/${profile[index]}")),
                                                const SizedBox(width: 10),
                                                Text(
                                                  author[index],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const Spacer(
                                                  flex: 1,
                                                ),
                                                Text(
                                                  updatedDates[index]
                                                      .substring(0, 19),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              titles[index],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              contents[index],
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Text(
                                                    '소주제',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.favorite_border),
                                                  onPressed: () async {
                                                    final pb = PocketBase(
                                                        'http://snowman0919.kro.kr:8080');
                                                    final body =
                                                        <String, dynamic>{
                                                      "title": titles[index],
                                                      "content":
                                                          contents[index],
                                                      "writer": author[index],
                                                      "Like": like[index] + 1,
                                                      "Comment_num":
                                                          commentNum[index],
                                                      // "topic": "a",
                                                      // "Comment": "JSON"
                                                    };

                                                    // ignore: unused_local_variable
                                                    final record = await pb
                                                        .collection(
                                                            'posts_commu')
                                                        .update(ids[index],
                                                            body: body);
                                                  },
                                                ),
                                                Text(like[index].toString()),
                                                const SizedBox(width: 16),
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.comment),
                                                  onPressed: () {},
                                                ),
                                                Text(commentNum[index]
                                                    .toString()),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )));
                            },
                          ),
                        )),
                      ],
                    );
                  }
                }),
            FutureBuilder<List<dynamic>>(
                future: postsListView_commu(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('오류: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('아직 어떤 글도 없네요...'));
                  } else {
                    // 데이터가 성공적으로 로드되었을 때
                    var data = snapshot.data!;
                    var ids = data[0];
                    var titles = data[7];
                    var contents = data[5];
                    var author = data[8];
                    var like = data[9];
                    var commentNum = data[10];
                    var updatedDates = data[1];
                    var authorid = data[11];
                    var profile = data[12];

                    return Column(
                      children: [
                        Expanded(
                            child: RefreshIndicator(
                          color: Colors.blue,
                          backgroundColor: Colors.white,
                          onRefresh: () async {
                            setState(() {});
                          },
                          child: ListView.builder(
                            itemCount: titles.length, // 게시물 수
                            itemBuilder: (context, index) {
                              return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ContentPage(
                                                title: titles[index],
                                                content: contents[index],
                                                author: author[index],
                                                like: like[index],
                                                time: updatedDates[index],
                                                comment_num: commentNum[index],
                                                authorid: authorid[index],
                                                profile: profile[index],
                                              )),
                                    );
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey, // 보더 색상
                                          width: 1.0, // 보더 너비
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                  backgroundImage: AssetImage(
                                                      'assets/profile.jpg'), // 프로필 이미지 경로 설정
                                                  radius: 12,
                                                ),
                                                const SizedBox(width: 10),
                                                const Text(
                                                  '작성자 닉네임',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const Spacer(
                                                  flex: 1,
                                                ),
                                                Text(
                                                  updatedDates[index],
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              titles[index],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              contents[index],
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Text(
                                                    '소주제',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.favorite_border),
                                                  onPressed: () {},
                                                ),
                                                const Text('2'),
                                                const SizedBox(width: 16),
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.comment),
                                                  onPressed: () {},
                                                ),
                                                const Text('12'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )));
                            },
                          ),
                        )),
                      ],
                    );
                  }
                }),
            FutureBuilder<List<dynamic>>(
                future: postsListView_commu(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('오류: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('아직 어떤 글도 없네요...'));
                  } else {
                    // 데이터가 성공적으로 로드되었을 때
                    var data = snapshot.data!;
                    var ids = data[0];
                    var titles = data[7];
                    var contents = data[5];
                    var author = data[8];
                    var like = data[9];
                    var commentNum = data[10];
                    var updatedDates = data[1];
                    var authorid = data[11];
                    var profile = data[12];

                    return Column(
                      children: [
                        Expanded(
                            child: RefreshIndicator(
                          color: Colors.blue,
                          backgroundColor: Colors.white,
                          onRefresh: () async {
                            setState(() {});
                          },
                          child: ListView.builder(
                            itemCount: titles.length, // 게시물 수
                            itemBuilder: (context, index) {
                              return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ContentPage(
                                                title: titles[index],
                                                content: contents[index],
                                                author: author[index],
                                                like: like[index],
                                                time: updatedDates[index],
                                                comment_num: commentNum[index],
                                                authorid: authorid[index],
                                                profile: profile[index],
                                              )),
                                    );
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey, // 보더 색상
                                          width: 1.0, // 보더 너비
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                  backgroundImage: AssetImage(
                                                      'assets/profile.jpg'), // 프로필 이미지 경로 설정
                                                  radius: 12,
                                                ),
                                                const SizedBox(width: 10),
                                                const Text(
                                                  '작성자 닉네임',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const Spacer(
                                                  flex: 1,
                                                ),
                                                Text(
                                                  updatedDates[index],
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              titles[index],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              contents[index],
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Text(
                                                    '소주제',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.favorite_border),
                                                  onPressed: () {},
                                                ),
                                                const Text('2'),
                                                const SizedBox(width: 16),
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.comment),
                                                  onPressed: () {},
                                                ),
                                                const Text('12'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )));
                            },
                          ),
                        )),
                      ],
                    );
                  }
                }),
            FutureBuilder<List<dynamic>>(
                future: postsListView_commu(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('오류: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('아직 어떤 글도 없네요...'));
                  } else {
                    // 데이터가 성공적으로 로드되었을 때
                    var data = snapshot.data!;
                    var ids = data[0];
                    var titles = data[7];
                    var contents = data[5];
                    var author = data[8];
                    var like = data[9];
                    var commentNum = data[10];
                    var updatedDates = data[1];
                    var authorid = data[11];
                    var profile = data[12];

                    return Column(
                      children: [
                        Expanded(
                            child: RefreshIndicator(
                          color: Colors.blue,
                          backgroundColor: Colors.white,
                          onRefresh: () async {
                            setState(() {});
                          },
                          child: ListView.builder(
                            itemCount: titles.length, // 게시물 수
                            itemBuilder: (context, index) {
                              return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ContentPage(
                                                title: titles[index],
                                                content: contents[index],
                                                author: author[index],
                                                like: like[index],
                                                time: updatedDates[index],
                                                comment_num: commentNum[index],
                                                authorid: authorid[index],
                                                profile: profile[index],
                                              )),
                                    );
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey, // 보더 색상
                                          width: 1.0, // 보더 너비
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                  backgroundImage: AssetImage(
                                                      'assets/profile.jpg'), // 프로필 이미지 경로 설정
                                                  radius: 12,
                                                ),
                                                const SizedBox(width: 10),
                                                const Text(
                                                  '작성자 닉네임',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const Spacer(
                                                  flex: 1,
                                                ),
                                                Text(
                                                  updatedDates[index],
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              titles[index],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              contents[index],
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Text(
                                                    '소주제',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.favorite_border),
                                                  onPressed: () {},
                                                ),
                                                const Text('2'),
                                                const SizedBox(width: 16),
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.comment),
                                                  onPressed: () {},
                                                ),
                                                const Text('12'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )));
                            },
                          ),
                        )),
                      ],
                    );
                  }
                })
          ],
        ))
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 400, // 모달 높이 크기
                decoration: const BoxDecoration(
                  color: Colors.white, // 모달 배경색
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20), // 모달 좌상단 라운딩 처리
                    topRight: Radius.circular(20), // 모달 우상단 라운딩 처리
                  ),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: const Alignment(1, 0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.settings,
                          size: 35,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Setting()));
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Material(
                      color: Colors.white,
                      child: InkWell(
                        splashColor: const Color.fromARGB(120, 33, 149, 243),
                        onTap: () {
                          PostsCreationController controller =
                              Get.put(PostsCreationController());
                          controller.clearContents();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Writing(),
                            ),
                          ).then((value) {
                            setState(() {});
                          });
                        },
                        child: Container(
                          height: 75,
                          width: double
                              .infinity, // Expand to fill the width of parent
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Column(
                            children: [
                              Align(
                                alignment: Alignment(-0.90, 0.2),
                                child: Text(
                                  '소통하기',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment(-0.80, 0),
                                child: Text('다양한 주제로 대화해요.'),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.white,
                      child: InkWell(
                        splashColor: const Color.fromARGB(120, 33, 149, 243),
                        onTap: () {
                          PostsCreationController controller =
                              Get.put(PostsCreationController());
                          controller.clearContents();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Writing(),
                            ),
                          ).then((value) {
                            setState(() {});
                          });
                        },
                        child: Container(
                          height: 75,
                          width: double
                              .infinity, // Expand to fill the width of parent
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Column(
                            children: [
                              Align(
                                alignment: Alignment(-0.9, 0.2),
                                child: Text(
                                  '공부해요',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment(-0.8, 0),
                                child: Text('주로 학업 관련해서 대화해요.'),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.white,
                      child: InkWell(
                        splashColor: const Color.fromARGB(120, 33, 149, 243),
                        onTap: () {
                          PostsCreationController controller =
                              Get.put(PostsCreationController());
                          controller.clearContents();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Writing(),
                            ),
                          ).then((value) {
                            setState(() {});
                          });
                        },
                        child: Container(
                          height: 75,
                          width: double
                              .infinity, // Expand to fill the width of parent
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Column(
                            children: [
                              Align(
                                alignment: Alignment(-0.9, 0.2),
                                child: Text(
                                  '문제풀이',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment(-0.8, 0),
                                child: Text('모르는 문제를 서로 물어봐요.'),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.white,
                      child: InkWell(
                        splashColor: const Color.fromARGB(120, 33, 149, 243),
                        onTap: () {
                          PostsCreationController controller =
                              Get.put(PostsCreationController());
                          controller.clearContents();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Writing(),
                            ),
                          ).then((value) {
                            setState(() {});
                          });
                        },
                        child: Container(
                          height: 75,
                          width: double
                              .infinity, // Expand to fill the width of parent
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Column(
                            children: [
                              Align(
                                alignment: Alignment(-0.9, 0.2),
                                child: Text(
                                  '우리학교',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment(-0.8, 0),
                                child: Text('같은학교 친구들과만 대화해요.'),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        tooltip: 'Writing',
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class Writing extends StatelessWidget {
  const Writing({super.key});

  @override
  Widget build(BuildContext context) {
    PostsCreationController controller = Get.put(PostsCreationController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '글쓰기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                children: [
                  TextField(
                    controller: controller.title,
                    decoration: const InputDecoration(
                      // fillColor: Colors.blue,
                      hoverColor: Colors.blue,
                      hintText: '제목을 입력하세요',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.0),
                      ),
                    ),
                  ),
                  TextField(
                    minLines: 2,
                    maxLines: 100000,
                    controller: controller.content,
                    decoration: const InputDecoration(
                      hintText: '내용을 입력하세요',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ))),
      bottomNavigationBar: Expanded(
        child: Container(
          height: 80,
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(
                color: Colors.grey,
                width: 1,
              ))),
          child: Center(
            child: GestureDetector(
              onTap: () {
                controller.postsCreation();
                Navigator.pop(context);
              },
              child: Container(
                width: 250,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue,
                ),
                child: const Center(
                  child: Text(
                    '작성하기',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ContentPage extends StatelessWidget {
  final String title;
  final String content;
  final String author;
  final int like;
  final int comment_num;
  final String time;
  final String authorid;
  final String profile;

  const ContentPage({
    super.key,
    required this.title,
    required this.content,
    required this.author,
    required this.like,
    required this.comment_num,
    required this.time,
    required this.authorid,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            '게시물',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: const Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(children: [
          Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // 보더 색상
                  width: 1.0, // 보더 너비
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '소주제',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                                "http://snowman0919.kro.kr:8080/api/files/users/${authorid}/${profile}")),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${time.substring(0, 19)}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              )),
          Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                  const Text('2'),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () {},
                  ),
                  const Text('0'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                ],
              )),
          const Spacer()
        ]),
        bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '우리 모두 깨끗한 댓글 문화를 만들어요!',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.image),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                ]))));
  }
}

class PostsCreationController extends GetxController {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  TextEditingController writer = TextEditingController();

  Future<void> postsCreation() async {
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: "id");
    try {
      final body = <String, dynamic>{
        "title": title.text,
        "content": content.text,
        "writer": id
      };

      if (title.text != '') {
        // ignore: unused_local_variable
        final record = await pb.collection('posts_commu').create(body: body);
        Get.snackbar('성공!', '작성되었습니다.',
            backgroundColor: Colors.blue, duration: const Duration(seconds: 5));
      } else {
        Get.snackbar('실패!', '내용이 없습니다.',
            backgroundColor: Colors.red, duration: const Duration(seconds: 5));
      }
    } on DioException catch (e) {
      print(e);
      rethrow;
    }
  }

  void clearContents() {
    title.clear();
    content.clear();
  }
}

// 기타 기능 페이지
class Functions extends StatelessWidget {
  const Functions({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> delete_real() async {
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'token');

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('정말로 삭제하시겠습니까?'),
            content: const Text('이 작업을 다시 되돌릴 수 없습니다.'),
            backgroundColor: const Color.fromARGB(255, 242, 242, 246),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "취소",
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pb = PocketBase('http://snowman0919.kro.kr:8080');
                  await pb.collection('users').delete(token!);
                  logout(context);
                },
                child: const Text(
                  "삭제",
                  style: TextStyle(fontSize: 15, color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    }

    Future<List<Map<String, dynamic>>> userdata() async {
      const storage = FlutterSecureStorage();
      final pb = PocketBase('http://snowman0919.kro.kr:8080');
      String? id = await storage.read(key: "id");

      // ID가 null 또는 빈 문자열인 경우 처리
      if (id == null || id.isEmpty) {
        print('No valid ID found in storage.');
        return []; // 빈 맵 반환
      }
      try {
        // 사용자 레코드 가져오기
        final records =
            await pb.collection('users').getFullList(sort: '-created');

        List<Map<String, dynamic>> user = [];

        for (var record in records) {
          if (record.id == id) {
            user.add({
              'id': record.id,
              'created': record.created,
              'updated': record.updated,
              'collectionId': record.collectionId,
              'collectionName': record.collectionName,
              'nickname': record.data['nickname'] ?? "",
              'avatar': record.data['avatar'] ?? "",
              'schoolId': record.data['school_id'] ?? 0,
              'username': record.data['username'] ?? "",
              'introducing': record.data['introducing'] ?? "소개글이 없습니다.",
              'studentNumber': record.data['student_number'] ?? 0,
              'subject': record.data['subject'] ?? "",
              'teacher': record.data['teacher'] ?? false,
            });
          }
        }

        // print('User data: $user'); // 사용자 정보 출력

        return user;
      } on DioException catch (e) {
        print('Error fetching user data: ${e.message}');
        // 404 오류일 경우 추가 처리
        if (e.response?.statusCode == 404) {
          print('User not found for ID: $id');
        }
        rethrow; // 예외를 다시 발생시켜 호출자에게 전달
      }
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text(
            '전체',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          shape: const Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
          // leading:
          //     const ImageIcon(AssetImage('./assets/images/darwin_title.png')),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Setting()));
              },
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 242, 242, 246),
        body: SingleChildScrollView(
            child: Column(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: userdata(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                // 로딩 상태일 때 아무것도 표시하지 않음
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(); // 빈 컨테이너 반환
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  String nickname = snapshot.data?[0]['nickname'];
                  return Container(
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    width: 418,
                    height: 150,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.white),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(15),
                          child: (snapshot.data?[0]['avatar'] != '')
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(),
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(
                                      "http://snowman0919.kro.kr:8080/api/files/${snapshot.data?[0]['collectionId']}/${snapshot.data?[0]['id']}/${snapshot.data?[0]['avatar']}",
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 45,
                                ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Text(
                              nickname,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              snapshot.data?[0]['introducing'],
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text('No Data'));
                }
              },
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              width: 418,
              height: 205,
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white),
              child: Column(
                children: [
                  ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Container(
                          width: 418,
                          height: 50,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              color: Colors.white),
                          child: Material(
                              color: const Color.fromARGB(0, 255, 255, 255),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileScreen()));
                                  },
                                  child: Container(
                                    child: const Row(
                                      children: [
                                        SizedBox(width: 15),
                                        Icon(Icons.account_circle),
                                        SizedBox(width: 15),
                                        Text(
                                          '프로필',
                                          style: TextStyle(fontSize: 18),
                                        )
                                      ],
                                    ),
                                  ))))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 6, 0),
                    height: 1,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38)),
                  ),
                  Container(
                      width: 418,
                      height: 50,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Material(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Performance_Manager()));
                              },
                              child: Container(
                                child: const Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Icon(Icons.auto_graph),
                                    SizedBox(width: 15),
                                    Text(
                                      '성적관리',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              )))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 6, 0),
                    height: 1,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38)),
                  ),
                  Container(
                      width: 418,
                      height: 50,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Material(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Calendar(
                                              events: [],
                                            )));
                              },
                              child: Container(
                                child: const Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Icon(Icons.calendar_month),
                                    SizedBox(width: 15),
                                    Text(
                                      '캘린더',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              )))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 6, 0),
                    height: 1,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38)),
                  ),
                  ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      child: Container(
                          width: 418,
                          height: 50,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                              color: Colors.white),
                          child: Material(
                              color: const Color.fromARGB(0, 255, 255, 255),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StopwatchPage()));
                                  },
                                  child: Container(
                                    child: const Row(
                                      children: [
                                        SizedBox(width: 15),
                                        Icon(Icons.timer),
                                        SizedBox(width: 15),
                                        Text(
                                          '스톱워치',
                                          style: TextStyle(fontSize: 18),
                                        )
                                      ],
                                    ),
                                  ))))),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              width: 418,
              height: 562,
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white),
              child: Column(
                children: [
                  ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Container(
                          width: 418,
                          height: 50,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              color: Colors.white),
                          child: Material(
                              color: const Color.fromARGB(0, 255, 255, 255),
                              child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    child: const Row(
                                      children: [
                                        SizedBox(width: 15),
                                        Icon(Icons.access_time),
                                        SizedBox(width: 15),
                                        Text(
                                          '시간표 보기',
                                          style: TextStyle(fontSize: 18),
                                        )
                                      ],
                                    ),
                                  ))))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 6, 0),
                    height: 1,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38)),
                  ),
                  Container(
                      width: 418,
                      height: 50,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Material(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          child: InkWell(
                              onTap: () {},
                              child: Container(
                                child: const Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Icon(Icons.restaurant),
                                    SizedBox(width: 15),
                                    Text(
                                      '급식표 보기',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              )))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 6, 0),
                    height: 1,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38)),
                  ),
                  Container(
                      width: 418,
                      height: 50,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Material(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const School_Setting(register: 0)));
                              },
                              child: Container(
                                child: const Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Icon(Icons.school),
                                    SizedBox(width: 15),
                                    Text(
                                      '학교 변경하기',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              )))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 6, 0),
                    height: 1,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38)),
                  ),
                  Container(
                      width: 418,
                      height: 50,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Material(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Class_Setting(register: 0)));
                              },
                              child: Container(
                                child: const Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Icon(Icons.numbers),
                                    SizedBox(width: 15),
                                    Text(
                                      '학년/반 변경하기',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              )))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 6, 0),
                    height: 1,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38)),
                  ),
                  Container(
                      width: 418,
                      height: 50,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Material(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          child: InkWell(
                              onTap: () {},
                              child: Container(
                                child: const Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Icon(Icons.book),
                                    SizedBox(width: 15),
                                    Text(
                                      '사전',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              )))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 6, 0),
                    height: 1,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38)),
                  ),
                  Container(
                      width: 418,
                      height: 50,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Material(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          child: InkWell(
                              onTap: () {},
                              child: Container(
                                child: const Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Icon(Icons.calculate),
                                    SizedBox(width: 15),
                                    Text(
                                      '계산기',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              )))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 6, 0),
                    height: 1,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38)),
                  ),
                  Container(
                      width: 418,
                      height: 50,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Material(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          child: InkWell(
                              onTap: () {},
                              child: Container(
                                child: const Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Icon(Icons.lightbulb_rounded),
                                    SizedBox(width: 15),
                                    Text(
                                      'AI QnA 채팅',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              )))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 6, 0),
                    height: 1,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38)),
                  ),
                  Container(
                      width: 418,
                      height: 50,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Material(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          child: InkWell(
                              onTap: () {},
                              child: Container(
                                child: const Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Icon(Icons.map),
                                    SizedBox(width: 15),
                                    Text(
                                      '주변 고등학교 정보',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              )))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 6, 0),
                    height: 1,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38)),
                  ),
                  Container(
                      width: 418,
                      height: 50,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Material(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          child: InkWell(
                              onTap: () {},
                              child: Container(
                                child: const Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Icon(Icons.import_contacts),
                                    SizedBox(width: 15),
                                    Text(
                                      '주변 학원 정보',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              )))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 6, 0),
                    height: 1,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38)),
                  ),
                  Container(
                      width: 418,
                      height: 50,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Material(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          child: InkWell(
                              onTap: () {},
                              child: Container(
                                child: const Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Icon(Icons.add_to_queue),
                                    SizedBox(width: 15),
                                    Text(
                                      '기능 추가 제안',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              )))),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 6, 0),
                    height: 1,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38)),
                  ),
                  ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      child: Container(
                          width: 418,
                          height: 50,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                              color: Colors.white),
                          child: Material(
                              color: const Color.fromARGB(0, 255, 255, 255),
                              child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    child: const Row(
                                      children: [
                                        SizedBox(width: 15),
                                        Icon(Icons.bug_report),
                                        SizedBox(width: 15),
                                        Text(
                                          '버그 신고',
                                          style: TextStyle(fontSize: 18),
                                        )
                                      ],
                                    ),
                                  ))))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 418,
              height: 50,
              child: Center(
                // Center를 추가해 InkWell의 터치 영역을 제한합니다
                child: Material(
                  color: Colors.transparent, // Material의 색을 투명하게
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(10), // InkWell의 borderRadius 추가
                    onTap: () {
                      delete_real();
                    },
                    child: Container(
                      width: 250,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red,
                      ),
                      child: const Center(
                        child: Text(
                          '탈퇴하기',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 418,
              height: 50,
              child: Center(
                // Center를 추가해 InkWell의 터치 영역을 제한합니다
                child: Material(
                  color: Colors.transparent, // Material의 색을 투명하게
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(10), // InkWell의 borderRadius 추가
                    onTap: () {
                      logout(context);
                    },
                    child: Container(
                      width: 250,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(200, 244, 67, 54),
                      ),
                      child: const Center(
                        child: Text(
                          '로그아웃하기',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
          ],
        )));
  }
}

// 프로필 페이지
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> user = [{}];
  bool _isInitialized = false;

  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _statusController = TextEditingController();
  XFile? _profileImage;

  @override
  void initState() {
    super.initState();
    userdata();
  }

  Future<void> userdata() async {
    const storage = FlutterSecureStorage();
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    String? id = await storage.read(key: "id");

    if (id == null || id.isEmpty) {
      print('No valid ID found in storage.');
      return;
    }
    try {
      final record = await pb.collection('users').getOne(id);

      setState(() {
        user[0] = {
          'id': record.id,
          'created': record.created,
          'updated': record.updated,
          'collectionId': record.collectionId,
          'collectionName': record.collectionName,
          'email': record.data['email'] ?? "",
          'nickname': record.data['nickname'] ?? "",
          'avatar': record.data['avatar'] ?? "",
          'school_id': record.data['school_id'] ?? 0,
          'username': record.data['username'] ?? "",
          'introducing': record.data['introducing'] ?? "",
          'studentNumber': record.data['student_number'] ?? 0,
          'subject': record.data['subject'] ?? "",
          'teacher': record.data['teacher'] ?? false,
          'School_nm': record.data['School_nm'] ?? "",
          'grade': record.data['grade'] ?? 0,
          'class': record.data['class'] ?? 0,
          'edu_code': record.data['edu_code'] ?? 0,
        };

        if (!_isInitialized) {
          _nicknameController.text = user[0]['nickname'];
          _statusController.text = user[0]['introducing'];
          _isInitialized = true;
        }
      });
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow;
    }
  }

  Future<void> userdataupdate() async {
    const storage = FlutterSecureStorage();
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    String? id = await storage.read(key: "id");

    if (id == null || id.isEmpty) {
      return;
    }
    try {
      final url = Uri.parse(
          'http://snowman0919.kro.kr:8080/api/collections/users/records/$id');

      var request = http.MultipartRequest('PATCH', url);

      // 필드 추가: 필드 이름이 정확한지 확인

      request.fields['emailVisibility'] = 'true';
      request.fields['nickname'] = _nicknameController.text;
      request.fields['introducing'] = _statusController.text;

      final originalImage = img.decodeImage(await _profileImage!.readAsBytes());

      final directory = await getTemporaryDirectory();
      final compressedImagePath = '${directory.path}/compressed_image.jpg';

      // 압축된 이미지 파일로 저장
      File(compressedImagePath)
        ..writeAsBytesSync(img.encodeJpg(originalImage!, quality: 50));
      print('Image compressed and saved at: $compressedImagePath');

      // 이미지 파일 추가
      request.files.add(await http.MultipartFile.fromPath(
        'avatar', // PocketBase에서 설정한 필드명
        compressedImagePath,
      ));

      // ignore: unused_local_variable
      final response = await request.send();

      // final body = <String, dynamic>{
      //   "emailVisibility": true,
      //   "nickname": _nicknameController.text,
      //   "introducing": _statusController.text,
      // };

      // // 프로필 이미지를 포함하여 서버에 데이터 업데이트
      // if (_profileImage != null) {
      //   body["avatar"] = await _profileImage!.readAsBytes();
      // }

      // // ignore: unused_local_variable
      // final record = await pb.collection('users').update(id, body: body);
      Navigator.pop(context);
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          fillColor: Colors.grey[200],
          filled: true,
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: content,
            border: InputBorder.none,
            enabled: false,
            fillColor: Colors.grey[200],
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildLinkingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '연동 계정',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.login, color: Colors.blue),
          title: Text('이메일로 로그인됨'),
        ),
        _buildInfoSection('이메일', '${user[0]['email']}'),
        _buildInfoSection('다윈 고유 ID', '#${user[0]['username']}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 프로필'),
        backgroundColor: const Color.fromARGB(255, 205, 240, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(File(_profileImage!.path))
                    : (user[0]['avatar'] != ''
                        ? NetworkImage(
                            "http://snowman0919.kro.kr:8080/api/files/${user[0]['collectionId']}/${user[0]['id']}/${user[0]['avatar']}",
                          )
                        : null) as ImageProvider<Object>?,
                child: _profileImage == null && user[0]['avatar'] == ''
                    ? Icon(Icons.add_a_photo, size: 50)
                    : null,
              ),
            ),
            TextButton(
              onPressed: _pickImage,
              child: Text(
                '사진 바꾸기',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            _buildTextField('닉네임', _nicknameController),
            _buildTextField('상태 메시지(소개글)', _statusController),
            _buildInfoSection('학교', '${user[0]['School_nm']}'),
            _buildInfoSection('학년', '${user[0]['grade']}'),
            _buildInfoSection('학급(반)', '${user[0]['class']}'),
            SizedBox(height: 20),
            _buildLinkingSection(),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              onPressed: userdataupdate,
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}

// 로그인 페이지
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    LoginPageController controller = Get.put(LoginPageController());
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
            child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 15),
                Center(
                    child: Image.asset('./assets/images/logo.png',
                        height: 100)), // 로고 이미지
                const SizedBox(height: 20),
                TextField(
                  controller: controller.student_number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.school),
                    labelText: '학번 (ex. 30327)',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.userId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: '이메일',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  controller: controller.passWord,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: '비밀번호',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text("아이디 찾기",
                        style: TextStyle(color: Colors.black)),
                  ),
                  TextButton(
                    onPressed: () async {
                      controller.change_password();
                    },
                    child: const Text(
                      "비밀번호 찾기",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ]),

                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    controller.login();
                  },
                  child: Container(
                    width: 250,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue,
                    ),
                    child: const Center(
                      child: Text(
                        '로그인',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Center(child: Text('소셜계정으로 로그인')),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: SvgPicture.asset('./assets/images/apple_logo.svg',
                          height: 50),
                      onPressed: () async {
                        // 애플 로그인 동작
                        final pb = PocketBase('http://snowman0919.kro.kr:8080');

                        // ignore: unused_local_iable
                        final authData = await pb
                            .collection('users')
                            .authWithOAuth2('apple', (url) async {
                          await launchUrl(url);
                        });

                        print(pb.authStore.isValid);
                        print(pb.authStore.token);
                        print(pb.authStore.model.id);
                      },
                    ),
                    IconButton(
                      icon: SvgPicture.asset('./assets/images/kakao_logo.svg',
                          height: 50),
                      onPressed: () async {
                        // 카카오톡 로그인 동작
                        final pb = PocketBase('http://snowman0919.kro.kr:8080');

                        // ignore: unused_local_variable
                        final authData = await pb
                            .collection('users')
                            .authWithOAuth2('kakao', (url) async {
                          await launchUrl(url);
                        });

                        print(pb.authStore.isValid);
                        print(pb.authStore.token);
                        print(pb.authStore.model.id);
                      },
                    ),
                    IconButton(
                        icon: SvgPicture.asset(
                            './assets/images/google_logo.svg',
                            height: 50),
                        onPressed: () async {
                          // 구글 로그인 동작
                          final pb =
                              PocketBase('http://snowman0919.kro.kr:8080');

                          // ignore: unused_local_variable
                          final authData = await pb
                              .collection('users')
                              .authWithOAuth2('google', (url) async {
                            await launchUrl(url);
                          });

                          print(pb.authStore.isValid);
                          print(pb.authStore.token);
                          print(pb.authStore.model.id);
                        }),
                    IconButton(
                      icon: SvgPicture.asset('./assets/images/insta_logo.svg',
                          height: 50),
                      onPressed: () async {
                        // 인스타그램 로그인 동작
                        final pb = PocketBase('http://snowman0919.kro.kr:8080');

                        // ignore: unused_local_variable
                        final authData = await pb
                            .collection('users')
                            .authWithOAuth2('instagram', (url) async {
                          await launchUrl(url);
                        });

                        print(pb.authStore.isValid);
                        print(pb.authStore.token);
                        print(pb.authStore.model.id);
                      },
                    ),
                    IconButton(
                      icon: SvgPicture.asset('./assets/images/github_logo.svg',
                          height: 50),
                      onPressed: () async {
                        // 깃허브 로그인 동작
                        final pb = PocketBase('http://snowman0919.kro.kr:8080');

                        // ignore: unused_local_variable
                        final authData = await pb
                            .collection('users')
                            .authWithOAuth2('github', (url) async {
                          await launchUrl(url);
                        });

                        print(pb.authStore.isValid);
                        print(pb.authStore.token);
                        print(pb.authStore.model.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        )));
  }
}

// 로그인 기능
class LoginPageController extends GetxController {
  TextEditingController student_number = TextEditingController();
  TextEditingController userId = TextEditingController();
  TextEditingController passWord = TextEditingController();

  final storage = const FlutterSecureStorage();

  Future<void> change_password() async {
    try {
      var bytes = utf8.encode(passWord.text);
      var passwordHash = sha256.convert(bytes).toString();

      var pb = new PocketBase('http://snowman0919.kro.kr:8080');
      await pb.collection('users').requestPasswordReset(userId.text.trim());

      Get.offAll(() => const HomeScreen());
      Get.snackbar('Success', 'Login success',
          backgroundColor: Colors.green, duration: const Duration(seconds: 10));
    } on DioException catch (e) {
      // 요청이 실패한 경우 상세한 오류 정보를 출력합니다.
      if (e.response != null) {
        print('DioError: ${e.response?.data}');
        Get.snackbar('Error',
            'Login failed: ${e.response?.data['message'] ?? 'Unknown error'}',
            backgroundColor: Colors.red, duration: const Duration(seconds: 10));
      } else {
        print('DioError: ${e.message}');
        Get.snackbar('Error', 'Login failed: ${e.message}',
            backgroundColor: Colors.red, duration: const Duration(seconds: 10));
      }
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      Get.snackbar('Error', 'Login failed',
          backgroundColor: Colors.red, duration: const Duration(seconds: 10));
    }
  }

  Future<void> login() async {
    try {
      final pb = PocketBase('http://snowman0919.kro.kr:8080');
      var bytes = utf8.encode(passWord.text);
      var passwordHash = sha256.convert(bytes).toString();

      // ignore: unused_local_variable
      final authData = await pb.collection('users').authWithPassword(
            userId.text.trim(),
            passwordHash,
          );

      storage.write(key: 'email', value: userId.text.trim());
      storage.write(key: 'password', value: passwordHash);
      storage.write(key: 'token', value: pb.authStore.token);
      storage.write(key: 'id', value: pb.authStore.model.id);
      // storage.write(key: 'token', value: pb.authStore.token);

      print(pb.authStore.isValid);
      print(pb.authStore.token);
      print(pb.authStore.model.id);

      Get.offAll(() => const HomeScreen());
      Get.snackbar('Success', 'Login success',
          backgroundColor: Colors.green, duration: const Duration(seconds: 10));
    } on DioException catch (e) {
      // 요청이 실패한 경우 상세한 오류 정보를 출력합니다.
      if (e.response != null) {
        print('DioError: ${e.response?.data}');
        Get.snackbar('Error',
            'Login failed: ${e.response?.data['message'] ?? 'Unknown error'}',
            backgroundColor: Colors.red, duration: const Duration(seconds: 10));
      } else {
        print('DioError: ${e.message}');
        Get.snackbar('Error', 'Login failed: ${e.message}',
            backgroundColor: Colors.red, duration: const Duration(seconds: 10));
      }
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      Get.snackbar('Error', 'Login failed',
          backgroundColor: Colors.red, duration: const Duration(seconds: 10));
    }
  }
}

// 회원가입 페이지
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    RegisterPageController controller = Get.put(RegisterPageController());
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
            child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                    child: Image.asset('./assets/images/logo.png',
                        height: 100)), // 로고 이미지
                const SizedBox(height: 20),
                TextField(
                  controller: controller.student_number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.school),
                    labelText: '학번 (ex. 30327)',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.userId,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: '이메일',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.passWord,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: '비밀번호',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.passWordConfirm,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: '비밀번호 확인',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.0),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    controller.register();
                  },
                  child: Container(
                    width: 250,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue,
                    ),
                    child: const Center(
                      child: Text(
                        '가입하기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Center(child: Text('소셜계정으로 가입하기')),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: SvgPicture.asset('./assets/images/apple_logo.svg',
                          height: 50),
                      onPressed: () async {
                        // 애플 로그인 동작
                        final pb = PocketBase('http://snowman0919.kro.kr:8080');

                        // ignore: unused_local_variable
                        final authData = await pb
                            .collection('users')
                            .authWithOAuth2('apple', (url) async {
                          await launchUrl(url);
                        });

                        print(pb.authStore.isValid);
                        print(pb.authStore.token);
                        print(pb.authStore.model.id);
                      },
                    ),
                    IconButton(
                      icon: SvgPicture.asset('./assets/images/kakao_logo.svg',
                          height: 50),
                      onPressed: () async {
                        // 카카오톡 로그인 동작
                        final pb = PocketBase('http://snowman0919.kro.kr:8080');

                        // ignore: unused_local_variable
                        final authData = await pb
                            .collection('users')
                            .authWithOAuth2('kakao', (url) async {
                          await launchUrl(url);
                        });

                        print(pb.authStore.isValid);
                        print(pb.authStore.token);
                        print(pb.authStore.model.id);
                      },
                    ),
                    IconButton(
                      icon: SvgPicture.asset('./assets/images/google_logo.svg',
                          height: 50),
                      onPressed: () async {
                        // 구글 로그인 동작
                        final pb = PocketBase('http://snowman0919.kro.kr:8080');

                        // ignore: unused_local_variable
                        final authData = await pb
                            .collection('users')
                            .authWithOAuth2('google', (url) async {
                          await launchUrl(url);
                        });

                        print(pb.authStore.isValid);
                        print(pb.authStore.token);
                        print(pb.authStore.model.id);
                      },
                    ),
                    IconButton(
                      icon: SvgPicture.asset('./assets/images/insta_logo.svg',
                          height: 50),
                      onPressed: () async {
                        // 인스타그램 로그인 동작
                        final pb = PocketBase('http://snowman0919.kro.kr:8080');

                        // ignore: unused_local_variable
                        final authData = await pb
                            .collection('users')
                            .authWithOAuth2('instagram', (url) async {
                          await launchUrl(url);
                        });

                        print(pb.authStore.isValid);
                        print(pb.authStore.token);
                        print(pb.authStore.model.id);
                      },
                    ),
                    IconButton(
                      icon: SvgPicture.asset('./assets/images/github_logo.svg',
                          height: 50),
                      onPressed: () async {
                        // 깃허브 로그인 동작
                        final pb = PocketBase('http://snowman0919.kro.kr:8080');

                        // ignore: unused_local_variable
                        final authData = await pb
                            .collection('users')
                            .authWithOAuth2('github', (url) async {
                          await launchUrl(url);
                        });

                        print(pb.authStore.isValid);
                        print(pb.authStore.token);
                        print(pb.authStore.model.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        )));
  }
}

class RegisterPageController extends GetxController {
  String baseUrl = 'http://snowman0919.kro.kr:8080';
  late Dio dio = Dio();

  TextEditingController student_number = TextEditingController();
  TextEditingController userId = TextEditingController();
  TextEditingController passWord = TextEditingController();
  TextEditingController passWordConfirm = TextEditingController();

  //! 회원가입 기능
  Future<void> register() async {
    var bytes = utf8.encode(passWord.text);
    var passwordHash = sha256.convert(bytes).toString();
    var bytes_conf = utf8.encode(passWord.text);
    var passwordHash_conf = sha256.convert(bytes_conf).toString();

    if (student_number.text.isNotEmpty) {
      try {
        var res = await dio.post(
          '$baseUrl/api/collections/users/records',
          options: Options(
            headers: {
              'Authorization':
                  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MjQ3NjczMjUsImlkIjoia2puZHlybDA2OHo5OXJ6IiwidHlwZSI6ImFkbWluIn0.7YyvCBunKYC1Vk7PHHX6ycfDM7Hjqidgcpto-DSHh9w',
              'Content-Type': 'application/json',
            },
          ),
          data: {
            'student_number': student_number.text,
            'email': userId.text.trim(), // 공백을 제거합니다.
            'password': passwordHash, // 비밀번호가 입력되었는지 확인합니다.
            'passwordConfirm': passwordHash_conf, // 비밀번호 확인이 일치하는지 확인합니다.
          },
        );
        const storage = FlutterSecureStorage();
        final pb = PocketBase('http://snowman0919.kro.kr:8080');

        // ignore: unused_local_variable
        final authData = await pb.collection('users').authWithPassword(
              userId.text.trim(),
              passwordHash,
            );

        storage.write(key: 'email', value: userId.text.trim());
        storage.write(key: 'password', value: passwordHash);
        storage.write(key: 'token', value: pb.authStore.token);
        storage.write(key: 'id', value: pb.authStore.model.id);
        // storage.write(key: 'token', value: pb.authStore.token);

        print(res.data); // res.data를 출력합니다.
        Get.offAll(() => School_Setting(register: 1));
        // Get.snackbar('성공', 'Register success',
        //     backgroundColor: Colors.green,
        //     duration: const Duration(seconds: 10));
      } on DioException catch (e) {
        // 요청이 실패한 경우 상세한 오류 정보를 출력합니다.
        if (e.response != null) {
          print('DioError: ${e.response?.data}');
          Get.snackbar('Error',
              'Register failed: ${e.response?.data['message'] ?? 'Unknown error'}',
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 10));
        } else {
          print('DioError: ${e.message}');
          Get.snackbar('Error', 'Register failed: ${e.message}',
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 10));
        }
      } catch (e, stackTrace) {
        print(e);
        print(stackTrace);
        Get.snackbar('Error', 'Register failed',
            backgroundColor: Colors.red, duration: const Duration(seconds: 10));
      }
    }
  }
}

class CalendarEvent {
  final String title; // 이벤트 제목
  final DateTime date; // 이벤트 날짜
  final Color color; // 이벤트 색상

  CalendarEvent({required this.title, required this.date, required this.color});
}

// 캘린더 페이지
class Calendar extends StatelessWidget {
  final List<CalendarEvent> events;

  const Calendar({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: TableCalendar(
              focusedDay: DateTime.now(),
              firstDay: DateTime(2022, 1, 1),
              lastDay: DateTime(2030, 1, 31),
              locale: 'ko-KR',
              daysOfWeekHeight: 30,
              eventLoader: (day) {
                return events
                    .where((event) => isSameDay(event.date, day))
                    .map((event) => event.title)
                    .toList();
              },
            ),
          ),
          // Show events below calendar
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(events[index].title),
                  subtitle: Text("${events[index].date}"),
                  leading: CircleAvatar(
                    backgroundColor: events[index].color,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//초기 화면 페이지
class Starting extends StatelessWidget {
  const Starting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Spacer(flex: 2),
          // 로고 이미지
          Image.asset(
            'assets/images/logo.png', // 이미지 경로를 맞춰주세요
            width: 150,
            height: 150,
          ),

          const SizedBox(height: 8),
          const Text(
            'Darwin으로 학습에 도움을 받으세요',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const Spacer(flex: 3),
          // 버튼들
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()));
                    },
                    child: Container(
                      width: 250,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(169, 33, 149, 243),
                      ),
                      child: const Center(
                        child: Text(
                          '로그인',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()));
                    },
                    child: Container(
                      width: 250,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue,
                      ),
                      child: const Center(
                        child: Text(
                          '새로 시작하기',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    ));
  }
}

// 알림 모아보기 페이지
class Notification extends StatelessWidget {
  const Notification({super.key});

  void _permissionWithNotification() async {
    await [Permission.notification].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ElevatedButton(
        onPressed: () async {
          _permissionWithNotification();
          // FlutterLocalNotification.showNotification();
          // NotificationDetails details = const NotificationDetails(
          //   iOS: DarwinNotificationDetails(
          //     presentAlert: true,
          //     presentBadge: true,
          //     presentSound: true,
          //   ),
          //   android: AndroidNotificationDetails(
          //     "1",
          //     "test",
          //     importance: Importance.max,
          //     priority: Priority.high,
          //   ),
          // );
        },
        child: const Text('AlertDialog'),
      ),
    ));
  }
}

// 설정 페이지
class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Setting Page"),
      ),
    );
  }
}

// 스톱워치 페이지
class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPage();
}

class _StopwatchPage extends State<StopwatchPage> {
  // final _screenTimeApiIosPlugin = ScreenTimeApiIos();
  String subjectName = '';
  Color selectedColor = Colors.red;

  final List<Map<String, dynamic>> subjects = [
    {'name': '국어', 'color': Colors.red, 'time': '00:00:00'},
    {'name': '수학', 'color': Colors.purple, 'time': '00:00:00'},
    {'name': '영어', 'color': Colors.teal, 'time': '00:00:00'},
    {'name': '과학', 'color': Colors.orange, 'time': '00:00:00'},
    {'name': '역사', 'color': Colors.grey, 'time': '00:00:00'},
    {'name': '사회', 'color': Colors.yellow, 'time': '00:00:00'},
    {'name': '기타(수행평가, 프로그래밍 등)', 'color': Colors.blue, 'time': '00:00:00'},
  ];

  void showAddSubjectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('과목 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  subjectName = value;
                },
                decoration: const InputDecoration(
                  hintText: '과목명',
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton<Color>(
                value: selectedColor,
                items: const [
                  DropdownMenuItem(
                    value: Colors.red,
                    child: Text('빨간색'),
                  ),
                  DropdownMenuItem(
                    value: Colors.purple,
                    child: Text('보라색'),
                  ),
                  DropdownMenuItem(
                    value: Colors.teal,
                    child: Text('청록색'),
                  ),
                  DropdownMenuItem(
                    value: Colors.orange,
                    child: Text('주황색'),
                  ),
                  DropdownMenuItem(
                    value: Colors.grey,
                    child: Text('회색'),
                  ),
                  DropdownMenuItem(
                    value: Colors.yellow,
                    child: Text('노란색'),
                  ),
                  DropdownMenuItem(
                    value: Colors.blue,
                    child: Text('파란색'),
                  ),
                ],
                onChanged: (Color? newValue) {
                  setState(() {
                    selectedColor = newValue ?? Colors.red;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (subjectName.isNotEmpty) {
                  setState(() {
                    subjects.add({
                      'name': subjectName,
                      'color': selectedColor,
                      'time': '00:00:00'
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const Column(
              mainAxisSize: MainAxisSize.min, // Column의 크기가 최소화되도록 설정
              children: [
                Text(
                  'Sun, 9/22',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                Text(
                  'D-60',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: () {
                final _screenTimeApiIosPlugin = ScreenTimeApiIos();
                _screenTimeApiIosPlugin.selectAppsToDiscourage();
                print(_screenTimeApiIosPlugin);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              child: const Text(
                '00:00:00',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.grey[800],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: subjects.length + 1, // "새로 추가하기" 포함
              itemBuilder: (context, index) {
                if (index < subjects.length) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: subjects[index]['color'],
                      child: const Icon(Icons.play_arrow, color: Colors.white),
                    ),
                    title: Text(subjects[index]['name']),
                    trailing: Text(
                      subjects[index]['time'],
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      // 타이머 시작 또는 상세보기 이동
                      final _screenTimeApiIosPlugin = ScreenTimeApiIos();
                      _screenTimeApiIosPlugin.encourageAll();
                    },
                    onLongPress: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 400, // 모달 높이 크기
                              decoration: const BoxDecoration(
                                color: Colors.white, // 모달 배경색
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20), // 모달 좌상단 라운딩 처리
                                  topRight:
                                      Radius.circular(20), // 모달 우상단 라운딩 처리
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 100, // 모달 높이 크기
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    height: 100, // 모달 높이 크기
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                  );
                } else {
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                    title: const Text("새로 추가하기"),
                    // trailing: Text('00:00:00'),
                    onTap: () {
                      showAddSubjectDialog();
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 스탑워치 활성화 페이지
class StopwatchActivePage extends StatefulWidget {
  const StopwatchActivePage({super.key});

  @override
  State<StopwatchActivePage> createState() => _StopwatchActivePage();
}

class _StopwatchActivePage extends State<StopwatchActivePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

// 성적관리 페이지
class Performance_Manager extends StatefulWidget {
  const Performance_Manager({super.key});

  @override
  State<Performance_Manager> createState() => _Performance_Manager();
}

class _Performance_Manager extends State<Performance_Manager> {
  String selectedSubject = '전체';

  List<String> subjects = [
    '전체',
    '수학',
    '국어',
    '영어',
    '사회',
    '과학',
    '정보',
    '음악',
    '미술',
    '체육',
    '역사',
    '생활 외국어',
  ];

  void delete_real() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('정말로 삭제하시겠습니까?'),
          content: const Text('이 작업을 다시 되돌릴 수 없습니다.'),
          backgroundColor: const Color.fromARGB(255, 242, 242, 246),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "취소",
                style: TextStyle(fontSize: 15, color: Colors.blue),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text(
                "삭제",
                style: TextStyle(fontSize: 15, color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '성적관리',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
              onPressed: () {
                delete_real();
              },
              child: const Text(
                "삭제",
                style: TextStyle(fontSize: 15, color: Colors.red),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: subjects.map((subject) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSubject = subject;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: subject == selectedSubject
                              ? Colors.blue
                              : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Text(
                          subject,
                          style: TextStyle(
                            color: subject == selectedSubject
                                ? Colors.white
                                : Colors.blue,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Overall Score Section
              Card(
                color: const Color.fromARGB(255, 242, 242, 246),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('원점수 전체 평균',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildScoreBar('2-1', 99.5, 96.3),
                          _buildScoreBar('2-2', 98.7, null),
                          _buildScoreBar('3-1', 99.7, null),
                          _buildScoreBar('3-2', 98.4, null),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Estimated Score Section
              const SizedBox(
                  width: 418,
                  child: Card(
                    color: Color.fromARGB(255, 242, 242, 246),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('내신 점수 예상',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          Text('198.649 / 200',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('설정지역: 경기 / 입력완료 된 성적을 졸업까지 유지할 경우',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
              // Semester Score Table
              SizedBox(
                  width: 418,
                  child: Card(
                    color: const Color.fromARGB(255, 242, 242, 246),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('학기별 성적표',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                            width: 400,
                                            height: 40,
                                            margin: const EdgeInsets.fromLTRB(
                                                1, 0, 1, 0),
                                            decoration: const BoxDecoration(),
                                            child: Material(
                                              color: const Color.fromARGB(
                                                  0, 255, 255, 255),
                                              child: Container(
                                                child: const Row(
                                                  children: [
                                                    SizedBox(width: 12),
                                                    Text(
                                                      '학기',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 40),
                                                    Text(
                                                      '국',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      '수',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      '영',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      '사',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      '과',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      '역',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      '음',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      '미',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      '체',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      '외',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ))
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 36, 0),
                                      height: 2,
                                      width: 350,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black87)),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            width: 400,
                                            height: 30,
                                            margin: const EdgeInsets.fromLTRB(
                                                1, 0, 1, 0),
                                            decoration: const BoxDecoration(),
                                            child: Material(
                                                color: const Color.fromARGB(
                                                    0, 255, 255, 255),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Performance_Manager_write(
                                                                term: '2-1',
                                                              )),
                                                    );
                                                  },
                                                  child: Container(
                                                    child: const Row(
                                                      children: [
                                                        SizedBox(width: 12),
                                                        Text(
                                                          '2-1',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(width: 42),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 16),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Icon(Icons.arrow_right)
                                                      ],
                                                    ),
                                                  ),
                                                )))
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 36, 0),
                                      height: 1,
                                      width: 350,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black38)),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            width: 400,
                                            height: 30,
                                            margin: const EdgeInsets.fromLTRB(
                                                1, 0, 1, 0),
                                            decoration: const BoxDecoration(),
                                            child: Material(
                                                color: const Color.fromARGB(
                                                    0, 255, 255, 255),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Performance_Manager_write(
                                                                term: '2-2',
                                                              )),
                                                    );
                                                  },
                                                  child: Container(
                                                    child: const Row(
                                                      children: [
                                                        SizedBox(width: 12),
                                                        Text(
                                                          '2-2',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(width: 40),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Icon(Icons.arrow_right)
                                                      ],
                                                    ),
                                                  ),
                                                )))
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 36, 0),
                                      height: 1,
                                      width: 350,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black38)),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            width: 400,
                                            height: 30,
                                            margin: const EdgeInsets.fromLTRB(
                                                1, 0, 1, 0),
                                            decoration: const BoxDecoration(),
                                            child: Material(
                                                color: const Color.fromARGB(
                                                    0, 255, 255, 255),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Performance_Manager_write(
                                                                term: '3-1',
                                                              )),
                                                    );
                                                  },
                                                  child: Container(
                                                    child: const Row(
                                                      children: [
                                                        SizedBox(width: 12),
                                                        Text(
                                                          '3-1',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(width: 42),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Icon(Icons.arrow_right)
                                                      ],
                                                    ),
                                                  ),
                                                )))
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 36, 0),
                                      height: 1,
                                      width: 350,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black38)),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            width: 400,
                                            height: 30,
                                            margin: const EdgeInsets.fromLTRB(
                                                1, 0, 1, 0),
                                            decoration: const BoxDecoration(),
                                            child: Material(
                                                color: const Color.fromARGB(
                                                    0, 255, 255, 255),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Performance_Manager_write(
                                                                term: '3-2',
                                                              )),
                                                    );
                                                  },
                                                  child: Container(
                                                    child: const Row(
                                                      children: [
                                                        SizedBox(width: 12),
                                                        Text(
                                                          '3-2',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(width: 40),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Text(
                                                          'A',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Icon(Icons.arrow_right)
                                                      ],
                                                    ),
                                                  ),
                                                )))
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
              // Activity Score Section
              Card(
                elevation: 2,
                color: const Color.fromARGB(255, 242, 242, 246),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('비교과 활동 점수 계산',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('비교과 항목')),
                          DataColumn(label: Text('내신수')),
                          DataColumn(label: Text('만점')),
                        ],
                        rows: const [
                          DataRow(cells: [
                            DataCell(Text('출결')),
                            DataCell(Text('15.8')),
                            DataCell(Text('20')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('봉사')),
                            DataCell(Text('20')),
                            DataCell(Text('20')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('창의적 체험활동')),
                            DataCell(Text('0')),
                            DataCell(Text('0')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('행동특성')),
                            DataCell(Text('8')),
                            DataCell(Text('10')),
                          ]),
                        ],
                      ),
                      const Divider(),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text('비교과 활동점수 합계: 43.8 / 50',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBar(String semester, double? score, double? average) {
    return Column(
      children: [
        Text(
          score != null ? score.toString() : '--',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          width: 60,
          height: 200,
          color: Colors.blue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (average != null)
                Container(
                  color: Colors.black,
                  width: 60,
                  height: 200 - (average * 2),
                  child: Center(
                    child: Text(
                      average.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          semester,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}

// 성적 입력하기
class Performance_Manager_write extends StatelessWidget {
  final String term;
  const Performance_Manager_write({
    super.key,
    required this.term,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 241, 247),
      appBar: AppBar(
        title: Text('$term 성적'),
        backgroundColor: const Color.fromARGB(255, 243, 241, 247),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildGradeRow(context, '국어', 85.0, 'B', 81.1),
                  _buildGradeRow(context, '수학', 96.0, 'A', 79.4),
                  _buildGradeRow(context, '영어', 98.5, 'A', 82.2),
                  _buildGradeRow(context, '과학', 96.0, 'A', 77.7),
                  _buildGradeRow(context, '사회', 0.0, '-', 0.0),
                  _buildGradeRow(context, '역사', 96.0, 'A', 78.8),
                  _buildGradeRow(context, '도덕', 0.0, '-', 0.0),
                  _buildGradeRow(context, '기술·가정', 0.0, '-', 0.0),
                  _buildGradeRow(context, '정보', 94.0, 'A', 86.4),
                  _buildGradeRow(context, '체육', 88.0, 'A', 0.0),
                  _buildGradeRow(context, '미술', 79.0, 'B', 0.0),
                  _buildGradeRow(context, '음악', 93.0, 'A', 0.0),
                  _buildGradeRow(context, '생활 외국어', 99.0, '-', 90.3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeRow(BuildContext context, String subject, double score,
      String grade, double avg) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(subject),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('원점수: $score'),
            Text('성취도: $grade'),
            Text('평균: $avg'),
          ],
        ),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubjectDetailPage(
                  subject: subject, score: score, grade: grade, avg: avg),
            ),
          );
        },
      ),
    );
  }
}

// 성적 자세히보기
class SubjectDetailPage extends StatelessWidget {
  final String subject;
  final double score;
  final String grade;
  final double avg;

  const SubjectDetailPage({
    super.key,
    required this.subject,
    required this.score,
    required this.grade,
    required this.avg,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$subject 성적'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreOverview(),
            const SizedBox(height: 16),
            _buildEvaluationDetails(),
            const Spacer(),
            _buildFooterNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreOverview() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildScoreTile('원점수', score.toString(), Colors.blue),
                _buildScoreTile('성취도', grade, Colors.blue),
                _buildScoreTile('과목평균', avg.toString(), Colors.black),
              ],
            ),
            const SizedBox(height: 8),
            const Text('평가항목 상세',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreTile(String title, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _buildEvaluationDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEvaluationRow('지필', '1차 고사', '-', '-', '-'),
            _buildEvaluationRow('지필', '2차 고사', '50%', '100.0', '90.0'),
            _buildEvaluationRow('수행', '발표문 쓰기', '30%', '30.0', '26.0'),
            _buildEvaluationRow('수행', '설명문 쓰기', '20%', '20.0', '14.0'),
            _buildEvaluationRow('수행', '수행평가 입력', '-', '-', '-'),
            _buildEvaluationRow('수행', '수행평가 입력', '-', '-', '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationRow(
      String type, String item, String weight, String max, String score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(type, style: const TextStyle(fontSize: 14)),
          Text(item, style: const TextStyle(fontSize: 14)),
          Text(weight, style: const TextStyle(fontSize: 14)),
          Text(max, style: const TextStyle(fontSize: 14)),
          Text(score, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          '* 지필평가와 수행평가 점수를 미리 입력하여 원점수를 계산할 수 있습니다.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          '* 반영비율이 100%가 되면 계산결과가 표시됩니다.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// 학교 세팅 페이지
class School_Setting extends StatefulWidget {
  final int register;

  const School_Setting({
    super.key,
    required this.register,
  });

  @override
  State<School_Setting> createState() => _School_Setting();
}

class _School_Setting extends State<School_Setting> {
  final TextEditingController searchController = TextEditingController();
  String selectedEducationOffice = "서울특별시교육청"; // 초기 선택값을 설정
  String search = '';
  List<List<dynamic>> schoolData = [[], [], [], [], [], [], []];
  List<Map<String, dynamic>> user = [];

  final Map<String, String> educationOffices = {
    "서울특별시교육청": "B10",
    "부산광역시교육청": "C10",
    "대구광역시교육청": "D10",
    "인천광역시교육청": "E10",
    "광주광역시교육청": "F10",
    "대전광역시교육청": "G10",
    "울산광역시교육청": "H10",
    "세종특별자치시교육청": "I10",
    "경기도교육청": "J10",
    "강원도교육청": "K10",
    "충청북도교육청": "M10",
    "충청남도교육청": "N10",
    "전북특별자치도교육청": "P10",
    "전라남도교육청": "Q10",
    "경상북도교육청": "R10",
    "경상남도교육청": "S10",
    "제주특별자치도교육청": "T10",
  };

  Future<void> userdata() async {
    const storage = FlutterSecureStorage();
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    String? id = await storage.read(key: "id");

    if (id == null || id.isEmpty) {
      print('No valid ID found in storage.');
      return;
    }
    try {
      final record = await pb.collection('users').getOne(id);

      user.add({
        'id': record.id,
        'created': record.created,
        'updated': record.updated,
        'collectionId': record.collectionId,
        'collectionName': record.collectionName,
        'nickname': record.data['nickname'] ?? "",
        'avatar': record.data['avatar'] ?? "",
        'schoolId': record.data['school_id'] ?? 0,
        'username': record.data['username'] ?? "",
        'introducing': record.data['introducing'] ?? "",
        'studentNumber': record.data['student_number'] ?? 0,
        'subject': record.data['subject'] ?? "",
        'teacher': record.data['teacher'] ?? false,
        'School_nm': record.data['School_nm'] ?? "",
      });
    } on DioException catch (e) {
      print('Error fetching user data: ${e.message}');
      if (e.response?.statusCode == 404) {
        print('User not found for ID: $id');
      }
      rethrow;
    }
  }

  Future<void> schooldataprovider(String ScCode, String search) async {
    try {
      var schoolinfo = await Dio().post(
        'https://open.neis.go.kr/hub/schoolInfo?ATPT_OFCDC_SC_CODE=$ScCode&KEY=cf79fa15b3c34635b2a24876fe0838fc&SCHUL_NM=$search',
        options: Options(
          headers: {},
        ),
        data: {},
      );

      List<String> ATPT_OFCDC_SC_CODE = [];
      List<String> ATPT_OFCDC_SC_NM = [];
      List<String> SD_SCHUL_CODE = [];
      List<String> schulNm = [];
      List<String> SCHUL_KND_SC_NM = [];
      List<String> HMPG_ADRES = [];
      List<String> FOND_SC_NM = [];

      Map<String, dynamic> schooldata = schoolinfo.data;
      List<dynamic> schooldataInfo = schooldata['schoolInfo'];
      List<dynamic> rows = schooldataInfo[1]['row'];

      for (var row in rows) {
        ATPT_OFCDC_SC_CODE.add(row['ATPT_OFCDC_SC_CODE'] ?? '');
        ATPT_OFCDC_SC_NM.add(row['ATPT_OFCDC_SC_NM'] ?? '');
        SD_SCHUL_CODE.add(row['SD_SCHUL_CODE'] ?? '');
        schulNm.add(row['SCHUL_NM'] ?? '');
        SCHUL_KND_SC_NM.add(row['SCHUL_KND_SC_NM'] ?? '');
        HMPG_ADRES.add(row['HMPG_ADRES'] ?? '');
        FOND_SC_NM.add(row['FOND_SC_NM'].toString() ?? '');
      }
      schoolData = [
        ATPT_OFCDC_SC_CODE,
        ATPT_OFCDC_SC_NM,
        SD_SCHUL_CODE,
        schulNm,
        SCHUL_KND_SC_NM,
        HMPG_ADRES,
        FOND_SC_NM
      ];
    } on DioException catch (e) {
      if (e.response != null) {
        print('DioError: ${e.response?.data}');
      } else {
        print('DioError: ${e.message}');
      }
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    int register = widget.register;
    return Scaffold(
      appBar: AppBar(
        title: Text("학교 설정"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                DropdownButton<String>(
                  value: selectedEducationOffice,
                  onChanged: (newValue) {
                    setState(() {
                      selectedEducationOffice = newValue!;
                      schooldataprovider(
                          educationOffices[selectedEducationOffice]!, search);
                    });
                  },
                  items: educationOffices.keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: searchController,
                  onChanged: (value) => {
                    setState(() {
                      search = value;
                    }),
                    schooldataprovider(
                        educationOffices[selectedEducationOffice]!, search),
                  },
                  decoration: InputDecoration(
                    labelText: '학교 이름 검색',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                // ElevatedButton(
                //   onPressed: () async => {
                //     schooldataprovider(
                //         educationOffices[selectedEducationOffice]!, search),
                //     await _refreshData(),
                //     setState(() {})
                //   }, // 검색 버튼 클릭 시 필터링
                //   child: Text("검색"),
                // ),
              ],
            ),
          ),
          if (schoolData != []) ...[
            Expanded(
              child: ListView.builder(
                itemCount: schoolData[0].length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(schoolData[3][index]),
                    subtitle: Text(
                        '${schoolData[1][index]} | ${schoolData[4][index]} | ${schoolData[6][index]}'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () async {
                      print("Selected School: ${schoolData[3][index]}");
                      userdata();
                      const storage = FlutterSecureStorage();
                      final pb = PocketBase('http://snowman0919.kro.kr:8080');

                      final body = <String, dynamic>{
                        "school_id": schoolData[2][index],
                        "edu_code": schoolData[0][index],
                        "School_nm": schoolData[3][index]
                      };

                      // ignore: unused_local_variable
                      final record = await pb
                          .collection('users')
                          .update(user[0]['id'].toString(), body: body);
                      // storage.write(
                      //     key: 'school_id', value: schoolData[2][index]);
                      storage.write(
                          key: 'edu_code', value: schoolData[0][index]);

                      if (register == 0) {
                        Get.snackbar('성공!', '학교 정보가 변경되었습니다.',
                            backgroundColor: Colors.blue,
                            duration: const Duration(seconds: 3));
                        Navigator.pop(context);
                      } else {
                        Get.offAll(() => Class_Setting(register: 1));
                      }
                    },
                  );
                },
              ),
            )
          ] else ...[
            Expanded(
                child: Center(
              child: Text('검색어를 입력해주세요....'),
            )),
          ]
        ],
      ),
    );
  }
}

// 반 세팅 페이지
class Class_Setting extends StatefulWidget {
  final int register;

  const Class_Setting({
    super.key,
    required this.register,
  });

  @override
  State<Class_Setting> createState() => _Class_Setting();
}

class _Class_Setting extends State<Class_Setting> {
  final TextEditingController searchController = TextEditingController();
  String selectedgrade = "1학년";
  String selectedclass = "1반";
  List<Map<String, dynamic>> user = [];
  List<List<dynamic>> schoolData = [[], [], [], [], []];

  final List<String> grade = ['1학년', '2학년', '3학년'];
  final List<String> selclass = List.generate(20, (index) => '${index + 1}반');

  Future<void> userdata() async {
    const storage = FlutterSecureStorage();
    final pb = PocketBase('http://snowman0919.kro.kr:8080');
    String? id = await storage.read(key: "id");
    try {
      final record = await pb.collection('users').getOne(id!);

      user.add({
        'id': record.id,
        'school_id': record.data['school_id'] ?? "",
        'edu_code': record.data['edu_code'] ?? "",
      });
    } on DioException catch (e) {
      print('Error fetching user data: ${e.message}');
      if (e.response?.statusCode == 404) {
        print('User not found for ID: $id');
      }
      rethrow;
    }
  }

  Future<void> schooldataprovider() async {
    try {
      userdata();
      var schoolinfo = await Dio().post(
        'https://open.neis.go.kr/hub/classInfo?ATPT_OFCDC_SC_CODE=${user[0]['edu_code']}&KEY=cf79fa15b3c34635b2a24876fe0838fc&SD_SCHUL_CODE=${user[0]['school_id']}&AY=${DateTime.now().year}',
        options: Options(
          headers: {},
        ),
        data: {},
      );

      List<String> ATPT_OFCDC_SC_CODE = [];
      List<String> ATPT_OFCDC_SC_NM = [];
      List<String> SD_SCHUL_CODE = [];
      List<String> schulNm = [];
      List<String> GRADE = [];
      List<String> CLASS_NM = [];

      Map<String, dynamic> schooldata = schoolinfo.data;

      if (schooldata.containsKey('classInfo')) {
        List<dynamic> classInfo = schooldata['classInfo'];
        if (classInfo.length > 1) {
          // Ensure that there is a 'row' object in the second element
          List<dynamic> rows = classInfo[1]['row'];

          for (var row in rows) {
            ATPT_OFCDC_SC_CODE.add(row['ATPT_OFCDC_SC_CODE'] ?? '');
            ATPT_OFCDC_SC_NM.add(row['ATPT_OFCDC_SC_NM'] ?? '');
            SD_SCHUL_CODE.add(row['SD_SCHUL_CODE'] ?? '');
            schulNm.add(row['SCHUL_NM'] ?? '');
            GRADE.add(row['GRADE'] ?? '');
            CLASS_NM.add(row['CLASS_NM'] ?? '');
          }
        }
      }

      // Combine the parsed data into a list
      schoolData = [
        ATPT_OFCDC_SC_CODE,
        ATPT_OFCDC_SC_NM,
        SD_SCHUL_CODE,
        schulNm,
        GRADE,
        CLASS_NM,
      ];
    } on DioException catch (e) {
      if (e.response != null) {
        print('DioError: ${e.response?.data}');
      } else {
        print('DioError: ${e.message}');
      }
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    int register = widget.register;
    schooldataprovider();
    return Scaffold(
      appBar: AppBar(
        title: Text("학번 설정"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100, // Set a specific width if needed
                  child: DropdownButton<String>(
                    value: selectedgrade,
                    onChanged: (newValue) {
                      setState(() {
                        selectedgrade = newValue!;
                      });
                    },
                    items: grade.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  width: 100, // Set a specific width if needed
                  child: DropdownButton<String>(
                    value: selectedclass,
                    onChanged: (newValue) {
                      setState(() {
                        selectedclass = newValue!;
                      });
                    },
                    items:
                        selclass.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Add spacing if needed
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Text color
              ),
              onPressed: () async {
                print("선택된 학년: $selectedgrade, 선택된 반: $selectedclass");
                final pb = PocketBase('http://snowman0919.kro.kr:8080');
                if (schoolData[4].contains(selectedgrade.substring(0, 1)) &&
                    schoolData[5].contains(selectedclass.replaceAll('반', ''))) {
                  final body = <String, dynamic>{
                    "grade": selectedgrade.substring(0, 1),
                    "class": selectedclass.substring(0, 1),
                  };

                  // ignore: unused_local_variable
                  final record = await pb
                      .collection('users')
                      .update(user[0]['id'].toString(), body: body);
                  if (register == 0) {
                    Get.snackbar('성공!', '학년/반 정보가 변경되었습니다.',
                        backgroundColor: Colors.blue,
                        duration: const Duration(seconds: 3));
                    Navigator.pop(context);
                  } else {
                    Get.offAll(() => HomeScreen());
                  }
                } else {
                  Get.snackbar('오류!', '학년 또는 반이 존재하지 않습니다.',
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3));
                }
              },
              child: Text("학번 설정 완료"),
            ),
          ],
        ),
      ),
    );
  }
}

class Bottomnavigationbar_Index with ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void add() {
    _index++;
    notifyListeners();
  }

  void remove() {
    _index--;
    notifyListeners();
  }
}
