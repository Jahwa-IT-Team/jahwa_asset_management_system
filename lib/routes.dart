import 'package:flutter/material.dart';
import 'package:jahwa_asset_management_system/screens/asset_tabs/asset_info_view.dart';
import 'package:jahwa_asset_management_system/screens/asset_tabs/asset_inspecion_qr_scan.dart';
import 'package:jahwa_asset_management_system/screens/asset_tabs/asset_dashboard_dept.dart';
import 'package:jahwa_asset_management_system/screens/asset_tabs/asset_dashboard_dept_detail.dart';
import 'package:jahwa_asset_management_system/screens/bluetooth/bluetooth_reader.dart';
import 'package:jahwa_asset_management_system/screens/bluetooth/bluetooth_scan.dart';
import 'package:jahwa_asset_management_system/screens/facility_location_tabs/facility_location_inspacion_detail.dart';
import 'package:jahwa_asset_management_system/screens/facility_location_tabs/facility_location_inspaction_setting.dart';
import 'package:jahwa_asset_management_system/screens/facility_location_tabs/facility_location_search_filter.dart';
import 'package:jahwa_asset_management_system/screens/facility_trade_tabs/facility_trade_bluetooth_reader.dart';
import 'package:jahwa_asset_management_system/screens/facility_trade_tabs/facility_trade_request_detail_view.dart';
import 'package:jahwa_asset_management_system/screens/login/login.dart';
import 'package:jahwa_asset_management_system/screens/home/home.dart';
import 'package:jahwa_asset_management_system/screens/error/not_found_page.dart';
import 'package:jahwa_asset_management_system/screens/asset_tabs/asset_tabs.dart';
import 'package:jahwa_asset_management_system/screens/facility_location_tabs/facility_location_tabs.dart';
import 'package:jahwa_asset_management_system/screens/facility_trade_tabs/facility_trade_tabs.dart';
import 'package:jahwa_asset_management_system/screens/facility_location_tabs/facility_location_inspaction_detail_setting.dart';

const String loginRoute = "login";
const String homeRoute = "home";
const String aboutRoute = "about";
const String settingsRoute = "settings";
const String errorRoute = "error";
const String assetTabsRoute = "assetTabs";
const String assetInfoViewRoute = "assetInfoView";
const String assetInspectionQRScanRoute = "assetInspectionQRScan";
const String assetDashboardDeptRoute = "assetDashboardDept";
const String assetDashboardDeptDetailRoute = "assetDashboardDeptDetail";
const String facilityLocationTabsRoute = "facilityLocationTabs";
const String facilityLocationSearchFilterRoute =
    "facilityLoationSearchFilterRoute";
const String facilityLocationInspactionSettingRoute =
    "facilityLocationInspactionSettingRoute";
const String facilitylocationInspactionDetailRoute =
    "facilitylocationInspactionDetailRoute";
const String facilityTradeTabsRoute = "facilityTradeTabsRoute";
const String facilityTradeRequestDetailViewRoute =
    "facilityTradeRequestDetailViewRoute";
const String facilityTradeBluetoothReaderRoute =
    "facilityTradeBluetoothReaderRoute";
const String bluetoothScanRoute = "bluetoothScanRoute";
const String bluetoothScan2Route = "bluetoothScan2Route";
const String bluetoothReaderRoute = "bluetoothReaderRoute";
const String facilitylocationInspactionDetailSettingRoute =
    "facilitylocationInspactionDetailSettingRoute";

class CustomRouter {
  static Route<dynamic> generatedRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case errorRoute:
        return MaterialPageRoute(builder: (_) => NotFoundPage());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => HomePage());
      case assetTabsRoute:
        return MaterialPageRoute(builder: (_) => AssetTabs());
      case assetInfoViewRoute:
        return MaterialPageRoute(
            builder: (_) =>
                AssetInfoViewPage(assetNo: settings.arguments.toString()));
      case assetInspectionQRScanRoute:
        return MaterialPageRoute(
            builder: (_) => AssetInspectionQRScanPage(
                masterId: settings.arguments.toString()));
      case assetDashboardDeptRoute:
        return MaterialPageRoute(
            builder: (_) => AssetDashbaordDeptPage(
                masterId: settings.arguments.toString()));
      case assetDashboardDeptDetailRoute:
        return MaterialPageRoute(
            builder: (_) =>
                AssetDashbaordDeptDetailPage(args: settings.arguments));
      case facilityLocationTabsRoute:
        return MaterialPageRoute(builder: (_) => FacilityLocationTabs());
      case facilityLocationSearchFilterRoute:
        return MaterialPageRoute(
            builder: (_) => FacilityLocationSearchFilterPage());
      case facilityLocationInspactionSettingRoute:
        return MaterialPageRoute(
            builder: (_) => FacilityLocationInspactionSettingPage());
      case facilitylocationInspactionDetailRoute:
        return MaterialPageRoute(
            builder: (_) => FacilityLocationInspactionDetailPage(
                  pageArguments: settings.arguments,
                ));
      case facilityTradeTabsRoute:
        return MaterialPageRoute(builder: (_) => FacilityTradTabs());
      case facilityTradeRequestDetailViewRoute:
        return MaterialPageRoute(
            builder: (_) => FacilityTradeRequestDetailViewPage(
                  pageType: settings.arguments,
                ));
      case facilityTradeBluetoothReaderRoute:
        return MaterialPageRoute(
            builder: (_) => FacilityTradeBluetoothReaderPage(
                  screenArguments: settings.arguments,
                ));
      case bluetoothScanRoute:
        return MaterialPageRoute(builder: (_) => BluetoothScanPage());
      case bluetoothReaderRoute:
        return MaterialPageRoute(
            builder: (_) => BluetoothReaderPage(
                  address: settings.arguments.toString(),
                ));
      case facilitylocationInspactionDetailSettingRoute:
        return MaterialPageRoute(
          builder: (_) => FacilityLocationInspactionDetailSettingPage(
            index: settings.arguments.toString(),
          ));
      default:
        return MaterialPageRoute(builder: (_) => NotFoundPage());
    }
  }
}
