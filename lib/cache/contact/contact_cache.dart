import 'package:hive/hive.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/contact/contact.dart';

class ContactCache {
  static const recentSentContactBoxName = 'recent-sent-contact';

  String _generateKey(Blockchain blockchain) {
    return blockchain.name;
  }

  Future<void> addRecentSentContact(Blockchain blockchain, String address, String? memo) async {
    if (!Hive.isBoxOpen(recentSentContactBoxName)) {
      await Hive.openBox(recentSentContactBoxName);
    }

    final box = Hive.box(recentSentContactBoxName);
    final key = _generateKey(blockchain);
    if (!box.containsKey(key)) {
      await box.put(key, [Contact(blockchain.name, address, memo)]);
    } else {
      final item = box.get(key);

      await box.put(key, {...item, Contact(blockchain.name, address, memo)}.toList());
    }

    await box.close();
  }

  Future<List<Contact>> getRecentSentContacts(Blockchain blockchain) async {
    if (!Hive.isBoxOpen(recentSentContactBoxName)) {
      await Hive.openBox(recentSentContactBoxName);
    }

    final box = Hive.box(recentSentContactBoxName);
    final key = _generateKey(blockchain);
    if (!box.containsKey(key)) {
      return [];
    }

    final item = await box.get(key);
    await box.close();
    return item;
  }
}