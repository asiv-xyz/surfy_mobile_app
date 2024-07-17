import 'package:dartx/dartx.dart';
import 'package:hive/hive.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class PaymentCache {
  static const boxName = 'recent-payment-method';
  static const key = 'recent-payment-method-key';

  Future<Pair<Token, Blockchain>?> get() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }

    final box = Hive.box(boxName);
    if (!box.containsKey(key)) {
      return null;
    }

    final item = await box.get(key, defaultValue: {}) as Map<String, String>;
    final token = findTokenByName(item['token'] ?? "");
    final blockchain = findBlockchainByName(item['blockchain'] ?? "");
    await box.close();
    return Pair(token, blockchain);
  }

  Future<void> set(Token token, Blockchain blockchain) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }

    final box = Hive.box(boxName);
    await box.put(key, { "token": token.name, "blockchain": blockchain.name });
    await box.close();
  }
}