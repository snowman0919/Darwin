import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart';
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

import 'package:dio/dio.dart';
import 'package:get/get.dart';

void main() async {
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Bottomnavigationbar_Index()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Darwin',
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          dialogBackgroundColor: Colors.white,
          primaryColor: Colors.blue,
          secondaryHeaderColor: Colors.blue,
          indicatorColor: Colors.blue,
          canvasColor: Colors.blue,
          focusColor: Colors.blue,
          splashColor: Color.fromARGB(120, 33, 149, 243),
          highlightColor: Color.fromARGB(150, 33, 149, 243),
          unselectedWidgetColor: Colors.blue,
          dividerColor: Colors.blue,
          hintColor: Colors.blue),
      color: Colors.blue,
    );
  }
}

class SplashScreen extends StatefulWidget {
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
    final storage = FlutterSecureStorage();

    await Future.delayed(Duration(seconds: 2)); // 스플래시 화면 2초 딜레이

    if (await storage.read(key: "token") != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
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
    final storage = FlutterSecureStorage();

    if (await storage.read(key: "token") != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "title",
            body: "context",
            image: Padding(
              padding: const EdgeInsets.all(32),
              child: Image.network(
                  'https://user-images.githubusercontent.com/26322627/143761841-ba5c8fa6-af01-4740-81b8-b8ff23d40253.png'),
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
              builder: (context) => Starting(),
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
    const School(),
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
  String getToday() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyyMMddE', 'ko_KR');
    var strToday = formatter.format(now);
    return strToday;
  }

  String baseUrl = 'https://open.neis.go.kr/hub';
  final pb = PocketBase('https://pocketbase0919.fly.dev');

  Future<dynamic> schooldataprovider() async {
    try {
      String Today = getToday().substring(0, 8);
      // final record = await pb.collection('users').getOne(
      //       'fo3nrj199b9o60k',
      //       expand: 'relField1,relField2.subRelField',
      //     );
      // print(record);
      var meal = await Dio().post(
        '$baseUrl/mealServiceDietInfo?ATPT_OFCDC_SC_CODE=J10&SD_SCHUL_CODE=7781173&TYPE=JSON&MLSV_YMD=$Today',
        // '$baseUrl/mealServiceDietInfo?ATPT_OFCDC_SC_CODE=J10&SD_SCHUL_CODE=7781173&TYPE=JSON&MLSV_YMD=20240603',
        options: Options(
          headers: {},
        ),
        data: {
          "KEY": "cf79fa15b3c34635b2a24876fe0838fc",
        },
      );

      var timetable = await Dio().post(
        '$baseUrl/misTimetable?KEY=cf79fa15b3c34635b2a24876fe0838fc&ATPT_OFCDC_SC_CODE=J10&SD_SCHUL_CODE=7781173&ALL_TI_YMD=$Today&GRADE=3&CLASS_NM=3',
        options: Options(
          headers: {},
        ),
        data: {},
      );

      List<String> ATPT_OFCDC_SC_CODE = []; //교육청 코드
      List<String> SD_SCHUL_CODE = []; //학교 코드
      List<String> SCHUL_NM = []; //학교 이름
      List<String> MMEAL_SC_NM = []; //급식 종류
      List<String> MLSV_YMD = []; //급식 일자
      List<String> MLSV_FGR = []; //칼로리
      List<String> ITRT_CNTNT = [];
      String DDISH_NM = ''; //급식

      Map<String, dynamic> mealdata = jsonDecode(meal.data);
      Map<String, dynamic> timetabledata = jsonDecode(timetable.data);

      // print(mealdata);

      // mealServiceDietInfo 키를 통해 접근
      List<dynamic> mealServiceDietInfo = mealdata['mealServiceDietInfo'];
      List<dynamic> misTimetable = timetabledata['misTimetable'];

      // row가 담긴 인덱스를 탐색
      List<dynamic> rows = mealServiceDietInfo[1]['row'];
      List<dynamic> perios = misTimetable[1]['row'];

      // print(perios);

      for (var row in rows) {
        ATPT_OFCDC_SC_CODE.add(row['ATPT_OFCDC_SC_CODE']);
        SD_SCHUL_CODE.add(row['SD_SCHUL_CODE']);
        SCHUL_NM.add(row['SCHUL_NM']);
        MMEAL_SC_NM.add(row['MMEAL_SC_NM']);
        MLSV_YMD.add(row['MLSV_YMD']);
        MLSV_FGR.add(row['MLSV_FGR'].toString());
        DDISH_NM = row['DDISH_NM'].toString();
      }

      for (var perio in perios) {
        ITRT_CNTNT.add(perio['ITRT_CNTNT']);
      }

      var meal_nm = DDISH_NM.replaceAll('<br/>', '\n').replaceAll('*', '');
      meal_nm = meal_nm.replaceAllMapped(RegExp(r'\([^)]*\)'), (match) {
        return '';
      });

      return [meal_nm, ITRT_CNTNT];

      // Get.snackbar('Success', 'requset success',
      //     backgroundColor: Colors.green, duration: Duration(milliseconds: 500));
    } on DioException catch (e) {
      // 요청이 실패한 경우 상세한 오류 정보를 출력합니다.
      if (e.response != null) {
        print('DioError: ${e.response?.data}');
        // Get.snackbar('Error',
        //     'requset failed: ${e.response?.data['message'] ?? 'Unknown error'}',
        //     backgroundColor: Colors.red, duration: Duration(seconds: 1));
      } else {
        print('DioError: ${e.message}');
        // Get.snackbar('Error', 'requset failed: ${e.message}',
        //     backgroundColor: Colors.red, duration: Duration(seconds: 1));
      }
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      // Get.snackbar('Error', 'requset failed',
      // backgroundColor: Colors.red, duration: Duration(seconds: 10));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pb = PocketBase('https://pocketbase0919.fly.dev');
    String Today = getToday();
    String Month = getToday().substring(4, 6);
    String Day = getToday().substring(6, 8);
    String Day_1 = getToday().substring(8, 9);
    final storage = FlutterSecureStorage();

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text('DARWIN'),
          backgroundColor: Colors.blue,
          shape: Border(
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
            // Container(
            //   padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            //   child: CircleAvatar(
            //     radius: 20,
            //     backgroundImage: const AssetImage('./assets/images/logo.png'),
            //     child: IconButton(
            //       icon: const Icon(Icons.person,
            //           color: Colors.transparent), // 투명 아이콘
            //       onPressed: () {
            //         // Navigator.push(
            //         //   context,
            //         //   MaterialPageRoute(builder: (context) => ProfileScreen()),
            //         // );
            //         print(pb.authStore.token);
            //       },
            //     ),
            //   ),
            // ),
            Container(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: CircleAvatar(
                // foregroundImage: NetworkImage("${user?.profileUrl}"), // 오른쪽 아래 프로필 사진 경로
                radius: 20,
                backgroundImage: const NetworkImage(
                    'https://ionicframework.com/docs/img/demos/avatar.svg'),
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.person,
                      color: Colors.transparent), // 투명 아이콘
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => ProfileScreen()),
                    // );
                    print(pb.authStore.token);
                  },
                ),
              ),
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
                  child: Text("오늘 날짜: $Today"),
                )),
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
                          FutureBuilder<dynamic>(
                              future: schooldataprovider(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('오류: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data[1]!.isEmpty) {
                                  return const Center(
                                    child: Text('\n\n\n오늘은 수업이 없네요.',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.2,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  );
                                } else if (snapshot.data[1].length == 7) {
                                  var data = snapshot.data!;
                                  var timetable = data[1];

                                  return Table(
                                    // border: TableBorder.all(), // 표 경계를 나타내도록 설정합니다.
                                    children: [
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(
                                                    '1교시',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(timetable[0],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text('2교시',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(timetable[1],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text('3교시',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(timetable[2],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text('4교시',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(timetable[3],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text('5교시',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(timetable[4],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text('6교시',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(timetable[5],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text('7교시',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(timetable[6],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  // 데이터가 성공적으로 로드되었을 때
                                  var data = snapshot.data!;
                                  var timetable = data[1];

                                  return Table(
                                    // border: TableBorder.all(), // 표 경계를 나타내도록 설정합니다.
                                    children: [
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(
                                                    '1교시',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(timetable[0],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text('2교시',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(timetable[1],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text('3교시',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(timetable[2],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text('4교시',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(timetable[3],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text('5교시',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(timetable[4],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text('6교시',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text(timetable[5],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text('7교시',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0.4),
                                                  child: Text('없음',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )))),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                              })
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
                            Text("$Month/$Day ($Day_1)급식",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            FutureBuilder<dynamic>(
                                future: schooldataprovider(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text('오류: ${snapshot.error}'));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Center(
                                      child: Text('\n\n\n오늘은 급식이 없네요.',
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
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1.2,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    );
                                  }
                                })
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                SafeArea(
                    child: Column(
                  children: <Widget>[
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "     캘린더",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ]),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Calendar()));
                      },
                      child: Container(
                        width: 418,
                        height: 120,
                        margin: const EdgeInsets.fromLTRB(6, 0, 6, 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(0, 255, 255, 255),
                        ),
                        child: Container(
                          margin: EdgeInsets.all(5),
                          child: Table(
                            border: TableBorder.all(),
                            children: [
                              TableRow(
                                children: <Widget>[
                                  Container(
                                    child: Text("할 일"),
                                    height: 36,
                                  ),
                                  Container(
                                    child: Text("할 일"),
                                    height: 36,
                                  ),
                                ],
                              ),
                              TableRow(
                                children: <Widget>[
                                  Container(
                                    child: Text("할 일"),
                                    height: 36,
                                  ),
                                  Container(
                                    child: Text("할 일"),
                                    height: 36,
                                  ),
                                ],
                              ),
                              TableRow(
                                children: <Widget>[
                                  Container(
                                    child: Text("할 일"),
                                    height: 36,
                                  ),
                                  Container(
                                    child: Text("할 일"),
                                    height: 36,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                )),
                SafeArea(
                    child: Column(
                  children: <Widget>[
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "     우리반 소식",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ]),
                    GestureDetector(
                      onTap: () {
                        // HomeScreen._onNavTapped();
                      },
                      child: Container(
                        width: 418,
                        height: 200,
                        margin: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(0, 255, 255, 255),
                        ),
                      ),
                    ),
                  ],
                )),
                IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    pb.authStore.clear();
                    storage.deleteAll();
                    Get.offAll(() => OnboardingScreen());
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('로그아웃되었습니다.'),
                      backgroundColor: Colors.blue,
                    ));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    schooldataprovider();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.star),
                  onPressed: () async {
                    var id = await storage.read(key: "id");
                    print(id);
                    final resultList = await pb.collection('users').getFullList(
                          sort: '-created',
                        );
                    print(resultList);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StopwatchPage()),
                    );
                  },
                )
              ],
            )))));
  }
}

// 체팅 페이지
class Chating extends StatelessWidget {
  const Chating({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Chating page',
        ),
      ),
    );
  }
}

// 학교 페이지
class School extends StatelessWidget {
  const School({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: false,
        title: const Text("시흥가온중학교 3-3"),
      ),
      body: const Center(
        child: Text(
          'school page',
        ),
      ),
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

  Future<List<List<dynamic>>> postsListView() async {
    final pb = PocketBase('https://pocketbase0919.fly.dev');

    try {
      final records = await pb.collection('posts').getFullList(
            sort: '-created',
          );

      List<String> ids = [];
      List<String> createdDates = [];
      List<String> updatedDates = [];
      List<String> collectionIds = [];
      List<String> collectionNames = [];
      List<String> contents = [];
      List<dynamic> images = [];
      List<String> titles = [];
      List<String> writers = [];

      // print(records);

      for (var record in records) {
        ids.add(record.id);
        createdDates.add(record.created);
        updatedDates.add(record.updated);
        collectionIds.add(record.collectionId);
        collectionNames.add(record.collectionName);
        contents.add(record.data['content'] ?? "");
        images.add(record.data['images'] ?? "");
        titles.add(record.data['title'] ?? "");
        writers.add(record.data['writer'] ?? "");
      }

      // print(titles);

      return [
        ids,
        createdDates,
        updatedDates,
        collectionIds,
        collectionNames,
        contents,
        images,
        titles,
        writers
      ];
    } on DioException catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          '커뮤니티',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        shape: Border(
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
            Tab(text: "소통"),
            Tab(text: "공부"),
            Tab(text: "문제풀이"),
            Tab(text: "우리학교"),
          ],
        ),
      ),
      body: FutureBuilder<List<List<dynamic>>>(
        future: postsListView(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('아직 어떤 글도 없네요...'));
          } else {
            // 데이터가 성공적으로 로드되었을 때
            var data = snapshot.data!;
            var titles = data[7];
            var contents = data[5];
            var author = data[8];

            return TabBarView(
              controller: tabController,
              children: [
                Column(
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
                                          )),
                                );
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    // borderRadius: BorderRadius.circular(20),
                                    color:
                                        const Color.fromARGB(0, 255, 255, 255),
                                  ),
                                  child: ListTile(
                                    title: Text(titles[index]),
                                    leading: FlutterLogo(size: 60.0),
                                    subtitle: Text(contents[index]),
                                    // trailing: Icon(Icons.more_vert),
                                    isThreeLine: true,
                                  )));
                        },
                      ),
                    )),
                  ],
                ),
                Center(child: Text('공부해요 내용')),
                Column(
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
                                          )),
                                );
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    // borderRadius: BorderRadius.circular(20),
                                    color:
                                        const Color.fromARGB(0, 255, 255, 255),
                                  ),
                                  child: ListTile(
                                    title: Text(titles[index]),
                                    leading: FlutterLogo(size: 60.0),
                                    subtitle: Text(contents[index]),
                                    // trailing: Icon(Icons.more_vert),
                                    isThreeLine: true,
                                  )));
                        },
                      ),
                    )),
                  ],
                ),
                Center(child: Text('내 그룹 내용')),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
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
                      alignment: Alignment(1, 0),
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
                    SizedBox(height: 4),
                    Material(
                      color: Colors.white,
                      child: InkWell(
                        splashColor: const Color.fromARGB(120, 33, 149, 243),
                        onTap: () {
                          print('a');
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
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment(-0.95, 0.1),
                                child: Text(
                                  '1',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment(-0.95, 0),
                                child: Text('2'),
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
                          print('a');
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
                          child: Text('hi'),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.white,
                      child: InkWell(
                        splashColor: const Color.fromARGB(120, 33, 149, 243),
                        onTap: () {
                          print('a');
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
                          child: Text('hi'),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.white,
                      child: InkWell(
                        splashColor: const Color.fromARGB(120, 33, 149, 243),
                        onTap: () {
                          print('a');
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
                          child: Text('hi'),
                        ),
                      ),
                    ),
                  ],
                ), // 모달 내부 디자인 영역
              );
            },
          );
        },
        tooltip: 'Writing',
        child: Icon(Icons.edit),
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
        title: Text(
          '글쓰기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: Border(
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
                    decoration: InputDecoration(
                      // fillColor: Colors.blue,
                      hoverColor: Colors.blue,
                      hintText: '제목을 입력하세요',
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 0.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 0.0),
                      ),
                    ),
                  ),
                  TextField(
                    minLines: 2,
                    maxLines: 100000,
                    controller: controller.content,
                    decoration: InputDecoration(
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
          decoration: BoxDecoration(
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
  final String content;
  final String title;

  const ContentPage({super.key, required this.title, required this.content});

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
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Text(content),
        ));
  }
}

class PostsCreationController extends GetxController {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  TextEditingController writer = TextEditingController();

  Future<void> postsCreation() async {
    final pb = PocketBase('https://pocketbase0919.fly.dev');
    try {
      final body = <String, dynamic>{
        "title": title.text,
        "content": content.text,
        "writer": writer.text
      };

      if (title.text != '') {
        // ignore: unused_local_variable
        final record = await pb.collection('posts').create(body: body);
        Get.snackbar('성공!', '작성되었습니다.',
            backgroundColor: Colors.blue, duration: Duration(seconds: 5));
      } else {
        Get.snackbar('실패!', '내용이 없습니다.',
            backgroundColor: Colors.red, duration: Duration(seconds: 5));
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
        shape: Border(
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
      body: Center(
        child: Text(
          'Setting page',
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
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
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
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
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
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
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
                    onPressed: () {},
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
                        final pb = PocketBase('https://pocketbase0919.fly.dev');

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
                        final pb = PocketBase('https://pocketbase0919.fly.dev');

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
                              PocketBase('https://pocketbase0919.fly.dev');

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
                        final pb = PocketBase('https://pocketbase0919.fly.dev');

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
                        final pb = PocketBase('https://pocketbase0919.fly.dev');

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

  final storage = FlutterSecureStorage();

  Future<void> login() async {
    try {
      final pb = PocketBase('https://pocketbase0919.fly.dev');

      // ignore: unused_local_variable
      final authData = await pb.collection('users').authWithPassword(
            userId.text.trim(),
            passWord.text,
          );

      storage.write(key: 'token', value: pb.authStore.token);
      storage.write(key: 'id', value: pb.authStore.model.id);
      // storage.write(key: 'token', value: pb.authStore.token);

      print(pb.authStore.isValid);
      print(pb.authStore.token);
      print(pb.authStore.model.id);

      Get.offAll(() => HomeScreen());
      Get.snackbar('Success', 'Login success',
          backgroundColor: Colors.green, duration: Duration(seconds: 10));
    } on DioException catch (e) {
      // 요청이 실패한 경우 상세한 오류 정보를 출력합니다.
      if (e.response != null) {
        print('DioError: ${e.response?.data}');
        Get.snackbar('Error',
            'Login failed: ${e.response?.data['message'] ?? 'Unknown error'}',
            backgroundColor: Colors.red, duration: Duration(seconds: 10));
      } else {
        print('DioError: ${e.message}');
        Get.snackbar('Error', 'Login failed: ${e.message}',
            backgroundColor: Colors.red, duration: Duration(seconds: 10));
      }
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      Get.snackbar('Error', 'Login failed',
          backgroundColor: Colors.red, duration: Duration(seconds: 10));
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
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
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
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
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
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
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
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 0.0),
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
                        final pb = PocketBase('https://pocketbase0919.fly.dev');

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
                        final pb = PocketBase('https://pocketbase0919.fly.dev');

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
                        final pb = PocketBase('https://pocketbase0919.fly.dev');

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
                        final pb = PocketBase('https://pocketbase0919.fly.dev');

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
                        final pb = PocketBase('https://pocketbase0919.fly.dev');

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
  String baseUrl = 'https://pocketbase0919.fly.dev';
  late Dio dio = Dio();

  TextEditingController student_number = TextEditingController();
  TextEditingController userId = TextEditingController();
  TextEditingController passWord = TextEditingController();
  TextEditingController passWordConfirm = TextEditingController();

  //! 회원가입 기능
  Future<void> register() async {
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
          'password': passWord.text, // 비밀번호가 입력되었는지 확인합니다.
          'passwordConfirm': passWordConfirm.text, // 비밀번호 확인이 일치하는지 확인합니다.
        },
      );
      print(res.data); // res.data를 출력합니다.
      Get.offAll(() => HomeScreen());
      Get.snackbar('Success', 'Register success',
          backgroundColor: Colors.green, duration: Duration(seconds: 10));
    } on DioException catch (e) {
      // 요청이 실패한 경우 상세한 오류 정보를 출력합니다.
      if (e.response != null) {
        print('DioError: ${e.response?.data}');
        Get.snackbar('Error',
            'Register failed: ${e.response?.data['message'] ?? 'Unknown error'}',
            backgroundColor: Colors.red, duration: Duration(seconds: 10));
      } else {
        print('DioError: ${e.message}');
        Get.snackbar('Error', 'Register failed: ${e.message}',
            backgroundColor: Colors.red, duration: Duration(seconds: 10));
      }
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      Get.snackbar('Error', 'Register failed',
          backgroundColor: Colors.red, duration: Duration(seconds: 10));
    }
  }
}

class Calendar extends StatelessWidget {
  const Calendar({super.key});

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
        body: Row(
          children: <Widget>[
            Expanded(
              child: TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime(2022, 1, 1),
                lastDay: DateTime(2030, 1, 31),
                locale: 'ko-KR',
                daysOfWeekHeight: 30,
              ),
            ),
            Container()
          ],
        ));
  }
}

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
        child: Text('AlertDialog'),
      ),
    ));
  }
}

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Setting Page"),
      ),
    );
  }
}

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPage();
}

class _StopwatchPage extends State<StopwatchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("StopwatchPage"),
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
