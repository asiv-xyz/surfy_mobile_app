import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/logger/logger.dart';

enum CurrencyType {
  usd, krw,
}

Map<CurrencyType, dynamic> currencyTypes = {
  CurrencyType.usd: {
    "fixedDecimal": 2
  },
  CurrencyType.krw: {
    "fixedDecimal": 0,
  }
};

CurrencyType findCurrencyTypeByName(String name) {
  print('currency name: $name');
  final list = CurrencyType.values.where((ct) => ct.name.toLowerCase() == name.toLowerCase());
  if (list.isEmpty) {
    throw Exception('No currency type');
  }
  return list.first;
}

String getCurrencySymbol(CurrencyType currencyType) {
  switch (currencyType) {
    case CurrencyType.usd:
      return '\$';
    case CurrencyType.krw:
      return '₩';
    default:
      return '?';
  }
}

int getFixedDigitBySymbol(CurrencyType currencyType) {
  switch (currencyType) {
    case CurrencyType.usd:
      return 2;
    case CurrencyType.krw:
      return 0;
    default:
      return 0;
  }
}

class SettingsPreference {
  final userCurrencyType = CurrencyType.usd.obs;
  final Rx<ThemeMode> themeObs = Rx(ThemeMode.system);

  SettingsPreference() {
    getCurrencyType().then((currencyType) {
      userCurrencyType.value = currencyType;
    });
  }

  Future<void> changeCurrencyType(CurrencyType currencyType) async {
    final preference = await SharedPreferences.getInstance();
    userCurrencyType.value = currencyType;
  }

  Future<CurrencyType> getCurrencyType() async {
    final preference = await SharedPreferences.getInstance();
    final value = preference.getString('currency_type');
    if (value == null) {
      logger.i('Not set currency type, USD will be returned.');
      return CurrencyType.usd;
    }
    final result = CurrencyType.values.where((ct) => ct.name == value.toLowerCase()).first;
    return result;
  }

  Future<ThemeMode> getTheme() async {
    final preference = await SharedPreferences.getInstance();
    final value = preference.getString('theme');
    final themeData = ThemeMode.values.where((t) => t.name.toLowerCase() == value);
    return themeData.first;
  }

  Future<void> setTheme(ThemeMode theme) async {
    final preference = await SharedPreferences.getInstance();
    themeObs.value = theme;
  }
}