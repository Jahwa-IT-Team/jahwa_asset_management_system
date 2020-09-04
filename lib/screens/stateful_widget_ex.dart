import 'package:flutter/widgets.dart';

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

/*
//페이지에 Arguments 사용 할 경우
class StatefulWidgetExamplePageArguments {
  final String address;
  final String pageType;

  StatefulWidgetExamplePageArguments(
      {@required this.address, @required this.pageType});  //@required 필수 전달 사항
}
*/

//StatefulWidgetExamplePage 사용할 이름으료 변경하세요.
class StatefulWidgetExamplePage extends StatefulWidget {
  /*
  //페이지에 Arguments 사용 할 경우
  final StatefulWidgetExamplePageArguments pageArguments;
  StatefulWidgetExamplePage({Key key, @required this.pageArguments})
      : super(key: key);
  */
  //1. createState()
  //StatefulWidget이 빌드 되도록 createState() 호출
  //반드시 호출해야하며 아래 코드보다 더 복잡하거나 추가될 것이 없음
  //정상적으로 createState()호출되면 buildContext가 할당되면서 this.mounted 속성 true를 리턴(2. mounted == true)
  @override
  _StatefulWidgetExamplePageState createState() =>
      new _StatefulWidgetExamplePageState();
}

class _StatefulWidgetExamplePageState extends State<StatefulWidgetExamplePage> {
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
    return Container();
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
}
