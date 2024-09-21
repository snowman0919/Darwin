import 'package:dio/dio.dart';
import 'dart:convert';

void main() {
  // var original =
  //     '오색현미밥<br/>떡만두국* (1.5.6.10.16.18)<br/>숙주나물무침-악 (5.6.18)<br/>치폴레통살명태까스* (1.5.6)<br/>배추김치 (9)<br/>망고푸딩* ';
  // var newString = original.replaceAll('<br/>', '\n').replaceAll('*', '');
  // newString = newString.replaceAllMapped(RegExp(r' \([^)]*\)'), (match) {
  //   return '';
  // });
  // print(newString);
  Future<dynamic> schooldataprovider() async {
    try {
      var timetable = await Dio().post(
        'http://168.126.63.2:4082/st',
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
      String DDISH_NM = ''; //급식

      Map<String, dynamic> timetabledata = jsonDecode(timetable.data);

      // List<dynamic> misTimetable = timetabledata['misTimetable'];

      // List<dynamic> perios = misTimetable[1];

      print(timetabledata);

      // for (var row in rows) {
      //   ATPT_OFCDC_SC_CODE.add(row['ATPT_OFCDC_SC_CODE']);
      //   SD_SCHUL_CODE.add(row['SD_SCHUL_CODE']);
      //   SCHUL_NM.add(row['SCHUL_NM']);
      //   MMEAL_SC_NM.add(row['MMEAL_SC_NM']);
      //   MLSV_YMD.add(row['MLSV_YMD']);
      //   MLSV_FGR.add(row['MLSV_FGR'].toString());
      //   DDISH_NM = row['DDISH_NM'].toString();
      // }
      print('요청 성공');
    } on DioException catch (e) {
      // 요청이 실패한 경우 상세한 오류 정보를 출력합니다.
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

  schooldataprovider();
}
