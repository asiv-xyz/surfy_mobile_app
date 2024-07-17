import 'package:hive/hive.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';

class MerchantCache {
  static const merchantBoxName = 'merchant';
  static const merchantUpdatedTimeBoxName = 'token-price-updated-time';
  static const updateThreshold = 300000;

  Future<void> saveMerchant(String storeId, Merchant merchant) async {
    if (!Hive.isBoxOpen(merchantBoxName)) {
      await Hive.openBox(merchantBoxName);
    }

    final box = Hive.box(merchantBoxName);
    box.put(storeId, merchant);
    await _setUpdatedTime(storeId, DateTime.now().millisecondsSinceEpoch);
    await box.close();
  }

  Future<Merchant?> getMerchant(String storeId) async {
    if (!Hive.isBoxOpen(merchantBoxName)) {
      await Hive.openBox(merchantBoxName);
    }

    final box = Hive.box(merchantBoxName);
    final item = (await box.get(storeId)) as Merchant?;
    await box.close();
    return item;
  }

  Future<void> _setUpdatedTime(String storeId, int timestamp) async {
    if (!Hive.isBoxOpen(merchantUpdatedTimeBoxName)) {
      await Hive.openBox(merchantUpdatedTimeBoxName);
    }

    final box = Hive.box(merchantUpdatedTimeBoxName);
    await box.put(storeId, timestamp);
    await box.close();
  }
}