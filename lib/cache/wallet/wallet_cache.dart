import 'package:hive_flutter/adapters.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class WalletCache {

  // Future<BoxCollection> getCollection() async {
  //   final collection = await BoxCollection.open(
  //     'SurfyBox', // Name of your database
  //     {'wallet', 'wallet-updated-time'}, // Names of your boxes
  //     path: './', // Path where to store your boxes (Only used in Flutter / Dart IO)
  //   );
  //
  //   return collection;
  // }

  String _generateKey(Token token, Blockchain blockchain, String address) {
    return "${token.name}-${blockchain.name}-$address";
  }

  Future<void> saveBalance(Token token, Blockchain blockchain, String address, BigInt amount) async {
    await Hive.openBox('wallet');
    final box = Hive.box('wallet');
    final key = _generateKey(token, blockchain, address);
    box.put(key, amount);
    setUpdatedTime(token, blockchain, address, DateTime.now().millisecondsSinceEpoch);
  }

  Future<BigInt> getBalance(Token token, Blockchain blockchain, String address) async {
    await Hive.openBox('wallet');
    final box = Hive.box('wallet');
    final key = _generateKey(token, blockchain, address);
    return box.get(key);
  }

  Future<int> getUpdatedTime(Token token, Blockchain blockchain, String address) async {
    await Hive.openBox('wallet-updated-time');
    final box = Hive.box('wallet-updated-time');
    final key = _generateKey(token, blockchain, address);
    return box.get(key) ?? 0;
  }

  Future<void> setUpdatedTime(Token token, Blockchain blockchain, String address, int timestamp) async {
    await Hive.openBox('wallet-updated-time');
    final box = Hive.box('wallet-updated-time');
    final key = _generateKey(token, blockchain, address);
    box.put(key, timestamp);
  }

  Future<bool> needToUpdate(Token token, Blockchain blockchain, String address) async {
    final lastUpdatedTime = await getUpdatedTime(token, blockchain, address);
    if (lastUpdatedTime == 0) {
      return true;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    // return now - lastUpdatedTime > 300000;
    return now - lastUpdatedTime > 60000;
  }
}