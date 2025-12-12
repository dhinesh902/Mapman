import 'dart:convert';

import 'package:google_places_autocomplete/google_places_autocomplete.dart';
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

  /// Store List place details

  Future<Prediction> addPlaceDetail(Prediction newDetail) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> oldJsonList = prefs.getStringList('place_details_key') ?? [];

    List<Prediction> oldList = oldJsonList
        .map((e) => Prediction.fromMap(jsonDecode(e)))
        .toList();

    oldList.add(newDetail);

    if (oldList.length > 10) {
      oldList = oldList.sublist(oldList.length - 10);
    }

    List<String> updatedJsonList = oldList
        .map((e) => jsonEncode(e.toMap()))
        .toList();

    await prefs.setStringList('place_details_key', updatedJsonList);
    return newDetail;
  }

  Future<List<Prediction>> getPlaceDetails() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? jsonList = prefs.getStringList("place_details_key");

    if (jsonList == null) return [];

    return jsonList
        .map((jsonStr) => Prediction.fromMap(jsonDecode(jsonStr)))
        .toList();
  }
}
