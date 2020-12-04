// {
//     "platform": "Android",
//     "outputType": "apk",
//     "versionName": "1.0.0",
//     "versionCode": 1,
//     "path": ""
//   }
class AppInfo {
  String platform;
  String outputType;
  String versionName;
  int versionCode;
  String path;
  String downloadUrl;
  bool isAutoVersionCheck;

  AppInfo(
      {this.platform,
      this.outputType,
      this.versionCode,
      this.versionName,
      this.path,
      this.downloadUrl,
      this.isAutoVersionCheck});

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      platform: json['platform'] as String,
      outputType: json['outputType'] as String,
      versionCode: json['versionCode'] as int,
      versionName: json['versionName'] as String,
      path: json['path'] as String,
      downloadUrl: json['downloadUrl'] as String,
      isAutoVersionCheck: json['isAutoVersionCheck'] as bool,
    );
  }
}
