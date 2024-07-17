import 'package:hive/hive.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class TokenPriceCache {
  static const tokenPriceBoxName = 'token-price';
  static const tokenPriceUpdatedTimeBoxName = 'token-price-updated-time';
  static const updateThreshold = 300000;

  String _generateKey(Token token, CurrencyType currencyType) {
    return "${token.name}-${currencyType.name}";
  }

  Future<void> saveTokenPrice(Token token, double price, CurrencyType currencyType) async {
    if (!Hive.isBoxOpen(tokenPriceBoxName)) {
      await Hive.openBox(tokenPriceBoxName);
    }

    final box = Hive.box(tokenPriceBoxName);
    final key = _generateKey(token, currencyType);
    await box.put(key, price);
    await box.close();
    await _setUpdatedTime(token, currencyType, DateTime.now().millisecondsSinceEpoch);
  }

  Future<double> getTokenPrice(Token token, CurrencyType currencyType) async {
    if (!Hive.isBoxOpen(tokenPriceBoxName)) {
      await Hive.openBox(tokenPriceBoxName);
    }

    final box = Hive.box(tokenPriceBoxName);
    final key = _generateKey(token, currencyType);
    final item = await box.get(key);
    await box.close();

    return item;
  }

  Future<int> _getUpdatedTime(Token token, CurrencyType currencyType) async {
    if (!Hive.isBoxOpen(tokenPriceUpdatedTimeBoxName)) {
      await Hive.openBox(tokenPriceUpdatedTimeBoxName);
    }

    final box = Hive.box(tokenPriceUpdatedTimeBoxName);
    final key = _generateKey(token, currencyType);
    final item = await box.get(key, defaultValue: 0);
    await box.close();
    return item;
  }

  Future<void> _setUpdatedTime(Token token, CurrencyType currencyType, int timestamp) async {
    if (!Hive.isBoxOpen(tokenPriceUpdatedTimeBoxName)) {
      await Hive.openBox(tokenPriceUpdatedTimeBoxName);
    }

    final box = Hive.box(tokenPriceUpdatedTimeBoxName);
    final key = _generateKey(token, currencyType);
    await box.put(key, timestamp);
    await box.close();
  }

  Future<bool> needToUpdate(Token token, CurrencyType currencyType) async {
    final lastUpdatedTime = await _getUpdatedTime(token, currencyType);
    if (lastUpdatedTime == 0) {
      logger.i('needToUpdate!');
      return true;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    return now - lastUpdatedTime > updateThreshold;
  }
}