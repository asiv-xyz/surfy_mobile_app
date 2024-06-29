import 'package:hive_flutter/adapters.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class WalletCache {
  static const walletBoxName = 'wallet';
  static const walletUpdatedTimeBoxName = 'wallet-updated-time';
  static const updateThreshold = 60000;

  String _generateKey(Token token, Blockchain blockchain, String address) {
    return "${token.name}-${blockchain.name}-$address";
  }

  Future<void> saveBalance(Token token, Blockchain blockchain, String address, BigInt amount) async {
    if (!Hive.isBoxOpen(walletBoxName)) {
      await Hive.openBox(walletBoxName);
    }

    final box = Hive.box(walletBoxName);
    final key = _generateKey(token, blockchain, address);
    box.put(key, amount);
    _setUpdatedTime(token, blockchain, address, DateTime.now().millisecondsSinceEpoch);
  }

  Future<BigInt> getBalance(Token token, Blockchain blockchain, String address) async {
    if (!Hive.isBoxOpen(walletBoxName)) {
      await Hive.openBox(walletBoxName);
    }

    final box = Hive.box(walletBoxName);
    final key = _generateKey(token, blockchain, address);
    return box.get(key);
  }

  Future<int> _getUpdatedTime(Token token, Blockchain blockchain, String address) async {
    if (!Hive.isBoxOpen(walletUpdatedTimeBoxName)) {
      await Hive.openBox(walletUpdatedTimeBoxName);
    }

    final box = Hive.box(walletUpdatedTimeBoxName);
    final key = _generateKey(token, blockchain, address);
    return box.get(key) ?? 0;
  }

  Future<void> _setUpdatedTime(Token token, Blockchain blockchain, String address, int timestamp) async {
    if (!Hive.isBoxOpen(walletUpdatedTimeBoxName)) {
      await Hive.openBox(walletUpdatedTimeBoxName);
    }

    final box = Hive.box(walletUpdatedTimeBoxName);
    final key = _generateKey(token, blockchain, address);
    box.put(key, timestamp);
  }

  Future<bool> needToUpdate(Token token, Blockchain blockchain, String address) async {
    final lastUpdatedTime = await _getUpdatedTime(token, blockchain, address);
    if (lastUpdatedTime == 0) {
      return true;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    return now - lastUpdatedTime > updateThreshold;
  }
}