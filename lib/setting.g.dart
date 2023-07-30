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
      'version': instance.version,
      'wifi_mode': instance.wifiMode,
      'ssid': instance.ssid,
      'password': instance.password,
      'refresh_rate_level': instance.refreshRateLevel,
      'serial_baud_rate': instance.serialBaudRate,
    };
