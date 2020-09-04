import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:jahwa_asset_management_system/provider/facility_location_repository.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:jahwa_asset_management_system/provider/user_repository.dart';
import 'package:jahwa_asset_management_system/routes.dart';
import 'package:jahwa_asset_management_system/util/localization/language_constants.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

/*
Flutter StatefulWidget Page Example
StatefulWidget Lifecycle

1. createState()
2. mounted == true
3. initState()
4. didChangeDependencies()
*. setState()              - 개발자가 필요에 위해 State
*. didUpdateWidget()       - 부모 위젯이 변경된 경우 State 재구성시에만 호출
5. build()
6. deactivate()
7. dispose()
8. mounted == false

*/

class FacilityLocationInspactionPage extends StatefulWidget {
  //1. createState()
  //StatefulWidget이 빌드 되도록 createState() 호출
  //반드시 호출해야하며 아래 코드보다 더 복잡하거나 추가될 것이 없음
  //정상적으로 createState()호출되면 buildContext가 할당되면서 this.mounted 속성 true를 리턴(2. mounted == true)
  @override
  _FacilityLocationInspactionPageState createState() =>
      new _FacilityLocationInspactionPageState();
}

class _FacilityLocationInspactionPageState
    extends State<FacilityLocationInspactionPage> {
  UserRepository $userRepository;
  FacilityTradeCommonRepository $facilityTradeCommonRepository;
  FacilityLocationRepository $facilityLocationRepository;

  //3. initState()
  //위젯이 생성될때 처음 한번 호출되는 메서드
  //initState에서 실행되면 좋은 것들
  //-.생성된 위젯 인스턴스의 BuildContext에 의존적인 것들의 데이터 초기화
  //-.동일 위젯트리내에 부모위젯에 의존하는 속성 초기화
  //-.Stream 구독, 알림변경, 또는 위젯의 데이터를 변경할 수 있는 다른 객체 핸들링.
  @override
  void initState() {
    //부모 initState() 호출
    super.initState();

    //Future 사용이 필요한 경우
    new Future.delayed(Duration.zero, () {});

    // 스트림 리스너 추가
    //cartItemStream.listen((data) {
    //  _updateWidget(data);
    //});
  }

  //4. didChangeDependencies()
  //메서드는 위젯이 최초 생성될때 initState() 다음에 바로 호출
  //위젯이 의존하는 데이터의 객체가 호출될때마다 호출된다. 예를 들면 업데이트되는 위젯을 상속한 경우.
  //공식문서 또한 상속한 위젯이 업데이트 될때 네트워크 호출(API 호출이 필요한 경우 유용)
  @override
  void didChangeDependencies() {
    $userRepository = Provider.of<UserRepository>(context, listen: true);
    $facilityTradeCommonRepository =
        Provider.of<FacilityTradeCommonRepository>(context, listen: true);

    if ($facilityLocationRepository == null) {
      $facilityLocationRepository =
          Provider.of<FacilityLocationRepository>(context, listen: true);
      $facilityLocationRepository.init();
    }

    super.didChangeDependencies();
  }

  //*. didUpdateWidget()   --부모 위젯이 변경되어 재구성시에만 호출
  //부모 위젯이 변경되어 이 위젯을 재 구성해야 하는 경우(다음 데이터를 제공 해야하기 때문)
  //이것은 플러터가 오래동안 유지 되는 state를 다시 사용하기 때문이다. 이 경우 initState() 처럼 읿부 데이터를 다시 초기화 해야 한다.
  //build() 메서드가 Stream이나 변경 가능한 데이터에 의존적인경우 이전 객체에서 구독을 취소하고 didUpdateWidget()에서 새로운 인스턴스에 다시 구독 해야함.
  //tip: 이 메서드는 기본적으로 위젯의 상태와 관련된 위젯을 재 구성해야 하는 경우 initState()을 대치한다.
  //플러터는 항상 이 메서드 수행 후(?)에 build()메서드 호출 하므로, setState() 이후 모든 추가 호출은 불필요 하다.
  // @override
  // void didUpdateWidget(Widget oldWidget) {
  //   if (oldWidget.importantProperty != widget.importantProperty) {
  //     _init();
  //   }
  // }

  //5. build()
  //이 메서드는 자주 호출된다(fps + render라고 생각하면 됨)
  //반드시 Widget을 리턴해야 함
  @override
  Widget build(BuildContext context) {
    //$userRepository = Provider.of<UserRepository>(context, listen: true);
    return Container(
        child: Column(
      children: <Widget>[
        setLocationBox(),
        Expanded(
          child: getListView($userRepository.connectionInfo.company),
        )
      ],
    ));
  }

  //6. deactivate()
  //이 메서드는 거의 사용되지 않는다.
  //tree에서 State가 제거 될때 호출

  //7. dispose()
  //영구적인 State Object가 삭제될때 호출된다. 이 함수는 주로 Stream 이나 애니메이션 을 해제시 사용된다.
  @override
  void dispose() {
    super.dispose();
  }

  //8. User Defined

  //공장
  Widget setPlantBox() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]))),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('공장 : 없음'),
                FlatButton(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.business),
                          Padding(
                            padding: EdgeInsets.all(2),
                          ),
                          Text(getTranslated(context, 'plant'))
                        ],
                      )
                    ],
                  ),
                  onPressed: () => {
                    Navigator.pushNamed(
                        context, facilityLocationSearchFilterRoute)
                  },
                  color: Colors.deepPurple,
                  textColor: Colors.white,
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text('공장을 설정하면 스캔된 설비의 공장이 자동으로 변경됩니다.',
                style: TextStyle(color: Colors.grey[400])),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  //위치 설정 박스
  Widget setLocationBox() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]))),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          '${getTranslated(context, 'plant')} : ${$facilityLocationRepository.settingInspactionLocation.plantCode == '' ? getTranslated(context, 'none') : $facilityLocationRepository.settingInspactionLocation.plantName}'),
                      Text(
                          '${getTranslated(context, 'location')} : ${$facilityLocationRepository.settingInspactionLocation.setupLocationCode == '' ? getTranslated(context, 'none') : $facilityLocationRepository.settingInspactionLocation.setupLocation}'),
                      Text(
                          '${getTranslated(context, 'item_group')} : ${$facilityLocationRepository.settingInspactionLocation.itemGroupCode == '' ? getTranslated(context, 'none') : $facilityLocationRepository.settingInspactionLocation.itemGroupCode}'),
                    ],
                  ),
                ),
                FlatButton(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.location_on),
                          Padding(
                            padding: EdgeInsets.all(2),
                          ),
                          Text(getTranslated(context, 'location'))
                        ],
                      )
                    ],
                  ),
                  onPressed: () => {
                    Navigator.pushNamed(
                        context, facilityLocationInspactionSettingRoute)
                  },
                  color: Colors.deepPurple,
                  textColor: Colors.white,
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text('위치를 설정하면 스캔된 설비의 위치가 자동으로 변경됩니다.',
                style: TextStyle(color: Colors.grey[400])),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  //재물조사 마스터 정보 호출 API
  //Todo. 설비 재물 조사만 가져오 오도록 수정
  Future getInspectionMasterData(String company) async {
    String url =
        'https://japi.jahwa.co.kr/api/InspectionMaster/company/' + company;
    http.Response response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

    return jsonDecode(response.body);
  }

  //재물조사 마스터 진행상태 호출 API
  Future getInspectionMasterProgress(String id) async {
    String url =
        'https://japi.jahwa.co.kr/api/InspectionMaster/StatusByMaster/' + id;
    http.Response response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

    return jsonDecode(response.body);
  }

  //재물조사 마스터 뷰 위젯
  Widget getListView(String company) {
    return FutureBuilder(
      future: getInspectionMasterData(company),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none &&
            snapshot.hasData == null) {
          print('project snapshot data is: ${snapshot.data}');
          return Center(
              child: Text(getTranslated(context, 'empty_value'),
                  style:
                      TextStyle(color: Colors.grey[400])) //'자산 정보가 존재하지 않습니다.'
              );
        } else if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData != null) {
          //print('snapshot.data.length : ${snapshot.data.length}');
          if (snapshot.data.length > 0) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                String id = snapshot.data[index]['id'].toString();
                String company = snapshot.data[index]['company'].toString();
                String subject = snapshot.data[index]['subject'].toString();
                String startDate = snapshot.data[index]['startDate'].toString();
                String endDate = snapshot.data[index]['endDate'].toString();
                return new GestureDetector(
                  onTap: () {
                    goInspection(id);
                  },
                  child: Card(
                    elevation: 3.0,
                    margin: new EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.deepPurple[300]),
                      child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 10.0),
                          title: Text(
                            "[" + company + "] " + subject,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                          subtitle: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 5,
                              ),
                              Text(startDate + " ~ " + endDate,
                                  style: TextStyle(color: Colors.white)),
                              SizedBox(
                                height: 5,
                              ),
                              getLinearProgressIndicator(id),
                            ],
                          ),
                          trailing: Icon(Icons.keyboard_arrow_right,
                              color: Colors.white, size: 30.0)),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
                child: Text(
                    getTranslated(context, 'empty_value')) //'자산 정보가 존재하지 않습니다.'
                );
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center();
        }
      },
    );
  }

  //재물조사 마스터 진행상태 표시 위젯
  Widget getLinearProgressIndicator(String id) {
    return FutureBuilder(
      future: getInspectionMasterProgress(id),
      builder: (context, snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData != null) {
            int totalCount = snapshot.data[0]['total_count'] == null
                ? 0
                : snapshot.data[0]['total_count'];
            int completedCount = snapshot.data[0]['completed_count'] == null
                ? 0
                : snapshot.data[0]['completed_count'];

            double value = completedCount / totalCount;
            String percent = (value * 100).toInt().toString() + '%';

            print(value);
            // return LinearProgressIndicator(
            //   value: value ,
            //   //valueColor: ,
            //   //backgroundColor: Colors.blueAccent,
            // );
            return LinearPercentIndicator(
              //width: 100.0,
              animation: true,
              lineHeight: 15.0,
              percent: value,
              //animationDuration: 1000,
              center: Text(
                percent,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              progressColor: Colors.blue,
            );
          } else {
            //return LinearPercentIndicator(animation: true,lineHeight: 15.0,);
            return LinearProgressIndicator();
          }
        } catch (_) {
          return LinearPercentIndicator(
            animation: true,
            lineHeight: 15.0,
          );
        }
      },
    );
  }

  void goInspection(String masterId) {
    if ($facilityLocationRepository
            .settingInspactionLocation.setupLocationCode ==
        '') {
      showAlertDialog(context);
      return;
    } else {
      Navigator.pushNamed(context, facilitylocationInspactionDetailRoute,
          arguments: masterId);
    }
  }

  void showAlertDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text(''),
          contentPadding: EdgeInsets.fromLTRB(0, 40, 0, 0),
          content: Text(
            getTranslated(context, 'alert_please_select_location_first'),
            textAlign: TextAlign.center,
          ), //위치를 먼저 선택하세요.
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, "OK");
              },
            ),
          ],
        );
      },
    );
  }
}
