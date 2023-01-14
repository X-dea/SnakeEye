// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SnakeEyeSettings _$SnakeEyeSettingsFromJson(Map<String, dynamic> json) =>
    SnakeEyeSettings(
      json['version'] as int,
    )
      ..wifiMode = json['wifi_mode'] as int
      ..ssid = json['ssid'] as String
      ..password = json['password'] as String
      ..refreshRateLevel = json['refresh_rate_level'] as int?
      ..serialBaudRate = json['serial_baud_rate'] as int?;

Map<String, dynamic> _$SnakeEyeSettingsToJson(SnakeEyeSettings instance) =>
    <String, dynamic>{
      'wifi_mode': instance.wifiMode,
      'ssid': instance.ssid,
      'password': instance.password,
      'refresh_rate_level': instance.refreshRateLevel,
      'serial_baud_rate': instance.serialBaudRate,
      'version': instance.version,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SnakeEyeSettings on _SnakeEyeSettings, Store {
  late final _$wifiModeAtom =
      Atom(name: '_SnakeEyeSettings.wifiMode', context: context);

  @override
  int get wifiMode {
    _$wifiModeAtom.reportRead();
    return super.wifiMode;
  }

  @override
  set wifiMode(int value) {
    _$wifiModeAtom.reportWrite(value, super.wifiMode, () {
      super.wifiMode = value;
    });
  }

  late final _$ssidAtom =
      Atom(name: '_SnakeEyeSettings.ssid', context: context);

  @override
  String get ssid {
    _$ssidAtom.reportRead();
    return super.ssid;
  }

  @override
  set ssid(String value) {
    _$ssidAtom.reportWrite(value, super.ssid, () {
      super.ssid = value;
    });
  }

  late final _$passwordAtom =
      Atom(name: '_SnakeEyeSettings.password', context: context);

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  late final _$refreshRateLevelAtom =
      Atom(name: '_SnakeEyeSettings.refreshRateLevel', context: context);

  @override
  int? get refreshRateLevel {
    _$refreshRateLevelAtom.reportRead();
    return super.refreshRateLevel;
  }

  @override
  set refreshRateLevel(int? value) {
    _$refreshRateLevelAtom.reportWrite(value, super.refreshRateLevel, () {
      super.refreshRateLevel = value;
    });
  }

  late final _$serialBaudRateAtom =
      Atom(name: '_SnakeEyeSettings.serialBaudRate', context: context);

  @override
  int? get serialBaudRate {
    _$serialBaudRateAtom.reportRead();
    return super.serialBaudRate;
  }

  @override
  set serialBaudRate(int? value) {
    _$serialBaudRateAtom.reportWrite(value, super.serialBaudRate, () {
      super.serialBaudRate = value;
    });
  }

  @override
  String toString() {
    return '''
wifiMode: ${wifiMode},
ssid: ${ssid},
password: ${password},
refreshRateLevel: ${refreshRateLevel},
serialBaudRate: ${serialBaudRate}
    ''';
  }
}
