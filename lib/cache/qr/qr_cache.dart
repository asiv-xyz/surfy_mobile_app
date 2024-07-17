import 'package:hive/hive.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class QrCache {
  static const walletBoxName = 'qr';
  static const merchantBoxName = 'merchant-qr';

  String _generateKey(Token token, Blockchain blockchain, String address) {
    return "${token.name}-${blockchain.name}-$address";
  }

  Future<String?> getWalletQR(Token token, Blockchain blockchain, String address) async {
    if (!Hive.isBoxOpen(walletBoxName)) {
      await Hive.openBox(walletBoxName);
    }

    final box = Hive.box(walletBoxName);
    final item = await box.get(_generateKey(token, blockchain, address), defaultValue: null);
    await box.close();
    return item;
  }

  Future<void> setWalletQR(Token token, Blockchain blockchain, String address, String qrUrl) async {
    if (!Hive.isBoxOpen(walletBoxName)) {
      await Hive.openBox(walletBoxName);
    }

    final box = Hive.box(walletBoxName);
    await box.put(_generateKey(token, blockchain, address), qrUrl);
    await box.close();
  }

  Future<String?> getMerchantQR(String merchantId) async {
    if (!Hive.isBoxOpen(merchantBoxName)) {
      await Hive.openBox(merchantBoxName);
    }

    final box = Hive.box(walletBoxName);
    final item = await box.get(merchantId);
    await box.close();
    return item;
  }

  Future<void> setMerchantQR(String merchantId, String qrUrl) async {
    if (!Hive.isBoxOpen(merchantBoxName)) {
      await Hive.openBox(merchantBoxName);
    }

    final box = Hive.box(walletBoxName);
    await box.put(merchantId, qrUrl);
    await box.close();
  }

}