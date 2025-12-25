import 'dart:convert';

import 'package:mapman/utils/constants/keys.dart';
import 'package:mapman/utils/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static SharedPreferences? _sessionStorage;

  static Future<SharedPreferences> initialize() async {
    _sessionStorage = await SharedPreferences.getInstance();
    return _sessionStorage!;
  }

  static Future<bool> setDeviceId({required String fcmToken}) async {
    assert(_sessionStorage != null, Strings.sessionManagerInitializeError);
    return _sessionStorage!.setString(Keys.fcmToken, fcmToken);
  }

  static Future<bool> setString({required String key, required String value}) {
    return _sessionStorage!.setString(key, value);
  }

  static bool containsKey({required String key}) {
    return _sessionStorage!.containsKey(key);
  }

  static String? getDeviceId() {
    return _sessionStorage!.getString(Keys.fcmToken);
  }

  static Future<bool> setToken({required String token}) async {
    return _sessionStorage!.setString(Keys.token, token);
  }

  static String? getToken() {
    return _sessionStorage!.getString(Keys.token);
  }

  static Future<bool> setMobile({required String phone}) async {
    return _sessionStorage!.setString(Keys.phone, phone);
  }

  static String? getMobile() {
    return _sessionStorage!.getString(Keys.phone);
  }

  static Future<bool> setShopId({required int shopId}) async {
    return _sessionStorage!.setInt(Keys.shopId, shopId);
  }

  static int? getShopId() {
    return _sessionStorage?.getInt(Keys.shopId);
  }

  static Future<bool> setUserId({required int userId}) async {
    return _sessionStorage!.setInt(Keys.userId, userId);
  }

  static int? getUserId() {
    return _sessionStorage?.getInt(Keys.userId);
  }

  static Future<bool> setViewedVideoStatus({required int status}) async {
    return _sessionStorage!.setInt(Keys.isViewedVideo, status);
  }

  static int getViewedVideoStatus() {
    return _sessionStorage!.getInt(Keys.isViewedVideo) ?? 0;
  }

  static Future<bool> setShopName({required String shopName}) async {
    return _sessionStorage!.setString(Keys.shopName, shopName);
  }

  static String? getShopName() {
    return _sessionStorage!.getString(Keys.shopName);
  }

  static Future<bool> setShopCategory({required String shopCategory}) async {
    return _sessionStorage!.setString(Keys.shopCategory, shopCategory);
  }

  static String? getShopCategory() {
    return _sessionStorage!.getString(Keys.shopCategory);
  }

  static Future<bool> clearSession() async {
    final keys = _sessionStorage!.getKeys();
    const List<String> protectedKeys = [Keys.fcmToken, Keys.isFirstTime];
    for (var key in keys) {
      if (!protectedKeys.contains(key)) {
        _sessionStorage!.remove(key);
      }
    }
    return true;
  }

  Future<void> clearPlaceDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('place_details_key');
  }

  /// Store List place details

  Future<CustomPrediction> addPlaceDetail(CustomPrediction newDetail) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> oldJsonList = prefs.getStringList('place_details_key') ?? [];
    List<CustomPrediction> oldList = oldJsonList
        .map((e) => CustomPrediction.fromJson(jsonDecode(e)))
        .toList();
    oldList.add(newDetail);
    if (oldList.length > 10) {
      oldList = oldList.sublist(oldList.length - 10);
    }
    List<String> updatedJsonList = oldList
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    await prefs.setStringList('place_details_key', updatedJsonList);
    return newDetail;
  }

  Future<List<CustomPrediction>> getPlaceDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList("place_details_key");
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }
    final details = jsonList
        .map((jsonStr) => CustomPrediction.fromJson(jsonDecode(jsonStr)))
        .toList();
    return details;
  }

  Future<void> removePlaceDetail(String placeId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> oldJsonList = prefs.getStringList('place_details_key') ?? [];
    List<CustomPrediction> list = oldJsonList
        .map((e) => CustomPrediction.fromJson(jsonDecode(e)))
        .toList();
    list.removeWhere((item) => item.placeId == placeId);
    List<String> updated = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('place_details_key', updated);
  }
}

class CustomPrediction {
  final String? placeId;
  final String? title;
  final String? description;

  CustomPrediction({this.placeId, this.title, this.description});

  factory CustomPrediction.fromJson(Map<String, dynamic> json) {
    return CustomPrediction(
      placeId: json['placeId'] ?? json['place_id'],
      title: _extractTitle(json),
      description: _extractDescription(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {"placeId": placeId, "title": title, "description": description};
  }

  static String? _extractTitle(Map<String, dynamic> json) {
    if (json['title'] != null) return json['title'];

    if (json['structured_formatting'] != null &&
        json['structured_formatting']['main_text'] != null) {
      return json['structured_formatting']['main_text'];
    }

    return null;
  }

  static String? _extractDescription(Map<String, dynamic> json) {
    if (json['description'] != null) return json['description'];

    if (json['structured_formatting'] != null &&
        json['structured_formatting']['secondary_text'] != null) {
      return json['structured_formatting']['secondary_text'];
    }

    return null;
  }
}
