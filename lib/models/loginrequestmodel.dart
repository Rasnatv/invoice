
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

LoginRequest loginRequestFromJson(String str) =>
    LoginRequest.fromJson(json.decode(str));

String loginRequestToJson(LoginRequest data) => json.encode(data.toJson());

class LoginRequest {
  String email;
  String password;
  String fcmToken;
  String appVersion;
  String model;
  String modelName;
  String modelVersion;

  LoginRequest({
    required this.email,
    required this.password,
    required this.fcmToken,
    required this.appVersion,
    required this.model,
    required this.modelName,
    required this.modelVersion,
  });

  /// Builds the request and fills in the device fields automatically.
  static Future<LoginRequest> create({
    required String email,
    required String password,
  }) async {
    final pkg = await PackageInfo.fromPlatform();
    final plugin = DeviceInfoPlugin();

    String fcm = '';
    try {
      fcm = await FirebaseMessaging.instance.getToken() ?? '';
    } catch (_) {
      // Don't block login if FCM is unavailable
    }

    String model, modelName, modelVersion;
    if (Platform.isAndroid) {
      final a = await plugin.androidInfo;
      model = 'Android';
      modelName = '${a.manufacturer} ${a.model}';
      modelVersion = 'Android ${a.version.release}';
    } else {
      final i = await plugin.iosInfo;
      model = 'iOS';
      modelName = i.utsname.machine;
      modelVersion = '${i.systemName} ${i.systemVersion}';
    }

    return LoginRequest(
      email: email,
      password: password,
      fcmToken: fcm,
      appVersion: pkg.version,
      model: model,
      modelName: modelName,
      modelVersion: modelVersion,
    );
  }

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    email: json["email"],
    password: json["password"],
    fcmToken: json["fcm_token"],
    appVersion: json["app_version"],
    model: json["model"],
    modelName: json["model_name"],
    modelVersion: json["model_version"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "password": password,
    "fcm_token": fcmToken,
    "app_version": appVersion,
    "model": model,
    "model_name": modelName,
    "model_version": modelVersion,
  };
}