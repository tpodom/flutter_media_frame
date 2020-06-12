import 'package:flutter/material.dart';
import 'package:mediaframe/media_asset.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SharedPreferences _sharedPreferences;
  List<MediaAsset> _assets;
  int _clockDelayMinutes;
  bool _enableNightMode;
  bool _enableWeather;
  TimeOfDay _nightStart;
  TimeOfDay _nightEnd;
  int _slideDelaySeconds;
  String _unlockCode;
  bool _use24HourTime;
  bool _useUnlockCode;
  double _volume;
  String _weatherAPIKey;

  Future<void> load() async {
    this._sharedPreferences = await SharedPreferences.getInstance();
    _assets = (this._sharedPreferences.getStringList('slideshowAssets') ?? []).map((path) => MediaAsset.path(path)).toList();
    _clockDelayMinutes = this._sharedPreferences.getInt('clockDelayMinutes') ?? 15;
    _enableNightMode = this._sharedPreferences.getBool('enableNightMode') ?? true;
    _enableWeather = this._sharedPreferences.getBool('enableWeather') ?? true;
    _nightEnd = TimeOfDay(hour: this._sharedPreferences.getInt('nightEndHour') ?? 8, minute: this._sharedPreferences.getInt('nightEndMinute') ?? 0);
    _nightStart = TimeOfDay(hour: this._sharedPreferences.getInt('nightStartHour') ?? 21, minute: this._sharedPreferences.getInt('nightStartMinute') ?? 0);
    _slideDelaySeconds = this._sharedPreferences.getInt('slideDelaySeconds') ?? 15;
    _unlockCode = this._sharedPreferences.getString('unlockCode') ?? '';
    _use24HourTime = this._sharedPreferences.getBool('use24HourTime') ?? false;
    _useUnlockCode = this._sharedPreferences.getBool('useUnlockCode') ?? false;
    _volume = this._sharedPreferences.getDouble('mediaVolume') ?? 0.7;
    _weatherAPIKey = this._sharedPreferences.getString('weatherAPIKey');
    notifyListeners();
  }

  List<MediaAsset> get assets => _assets;

  set assets(List<MediaAsset> value) {
    _assets = value;
    this._sharedPreferences.setStringList('slideshowAssets', value.map((asset) => asset.file.path).toList());
    notifyListeners();
  }

  int get clockDelayMinutes => _clockDelayMinutes;

  set clockDelayMinutes(int value) {
    _clockDelayMinutes = value;
    this._sharedPreferences.setInt('clockDelayMinutes', value);
    notifyListeners();
  }

  bool get enableNightMode => _enableNightMode;

  set enableNightMode(bool value) {
    _enableNightMode = value;
    this._sharedPreferences.setBool('enableNightMode', value);
    notifyListeners();
  }

  bool get enableWeather => _enableWeather;

  set enableWeather(bool value) {
    _enableWeather = value;
    this._sharedPreferences.setBool('enableWeather', value);
    notifyListeners();
  }

  TimeOfDay get nightStart => _nightStart;

  set nightStart(TimeOfDay value) {
    _nightStart = value;
    this._sharedPreferences.setInt('nightStartHour', value.hour);
    this._sharedPreferences.setInt('nightStartMinute', value.minute);
    notifyListeners();
  }

  TimeOfDay get nightEnd => _nightEnd;

  set nightEnd(TimeOfDay value) {
    _nightEnd = value;
    this._sharedPreferences.setInt('nightEndHour', value.hour);
    this._sharedPreferences.setInt('nightEndMinute', value.minute);
    notifyListeners();
  }

  int get slideDelaySeconds => _slideDelaySeconds;

  set slideDelaySeconds(int value) {
    _slideDelaySeconds = value;
    this._sharedPreferences.setInt('slideDelaySeconds', value);
    notifyListeners();
  }

  String get unlockCode => _unlockCode;

  set unlockCode(String value) {
    _unlockCode = value;
    this._sharedPreferences.setString('unlockCode', value);
    notifyListeners();
  }

  bool get use24HourTime => _use24HourTime;

  set use24HourTime(bool value) {
    _use24HourTime = value;
    this._sharedPreferences.setBool('use24HourTime', value);
    notifyListeners();
  }

  bool get useUnlockCode => _useUnlockCode;

  set useUnlockCode(bool value) {
    _useUnlockCode = value;
    this._sharedPreferences.setBool('useUnlockCode', value);
    notifyListeners();
  }

  double get volume => _volume;

  set volume(double value) {
    _volume = value;
    this._sharedPreferences.setDouble('mediaVolume', value);
    notifyListeners();
  }

  String get weatherAPIKey => _weatherAPIKey;

  set weatherAPIKey(String value) {
    _weatherAPIKey = value;
    this._sharedPreferences.setString('weatherAPIKey', value);
    notifyListeners();
  }

}
