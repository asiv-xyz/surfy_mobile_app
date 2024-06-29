import 'package:hive/hive.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';

class MerchantCache {
  static const merchantBoxName = 'merchant';
  static const merchantUpdatedTimeBoxName = 'token-price-updated-time';
  static const updateThreshold = 60000;

  Future<void> saveMerchant(String storeId, Merchant merchant) async {
    if (!Hive.isBoxOpen(merchantBoxName)) {
      await Hive.openBox(merchantBoxName);
    }

    final box = Hive.box(merchantBoxName);
    box.put(storeId, merchant);
    await _setUpdatedTime(storeId, DateTime.now().millisecondsSinceEpoch);
  }

  Future<Merchant?> getMerchant(String storeId) async {
    if (!Hive.isBoxOpen(merchantBoxName)) {
      await Hive.openBox(merchantBoxName);
    }

    final box = Hive.box(merchantBoxName);
    return (await box.get(storeId)) as Merchant?;
  }

  Future<int> _getUpdatedTime(String storeId) async {
    if (!Hive.isBoxOpen(merchantUpdatedTimeBoxName)) {
      await Hive.openBox(merchantUpdatedTimeBoxName);
    }

    final box = Hive.box(merchantUpdatedTimeBoxName);
    return box.get(storeId);
  }

  Future<void> _setUpdatedTime(String storeId, int timestamp) async {
    if (!Hive.isBoxOpen(merchantUpdatedTimeBoxName)) {
      await Hive.openBox(merchantUpdatedTimeBoxName);
    }

    final box = Hive.box(merchantUpdatedTimeBoxName);
    box.put(storeId, timestamp);
  }
}