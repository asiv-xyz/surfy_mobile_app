import 'package:hive_flutter/adapters.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class WalletCache {
  static const walletBoxName = 'wallet';
  static const walletUpdatedTimeBoxName = 'wallet-updated-time';
  static const walletAddress = 'walletAddress';
  static const updateThreshold = 300000;

  String _generateKey(Token token, Blockchain blockchain, String address) {
    return "${token.name}-${blockchain.name}-$address";
  }

  Future<String> getWalletAddress(Blockchain blockchain) async {
    if (!Hive.isBoxOpen(walletAddress)) {
      await Hive.openBox(walletAddress);
    }

    final box = Hive.box(walletAddress);
    final address = await box.get(blockchain.name, defaultValue: "");
    await box.close();
    return address;
  }

  Future<void> saveWalletAddress(Blockchain blockchain, String address) async {
    if (!Hive.isBoxOpen(walletAddress)) {
      await Hive.openBox(walletAddress);
    }

    final box = Hive.box(walletAddress);
    final key = blockchain.name;
    await box.put(key, address);
    await box.close();
  }

  Future<void> saveBalanceOnly(Token token, Blockchain blockchain, String address, BigInt amount) async {
    if (!Hive.isBoxOpen(walletBoxName)) {
      await Hive.openBox(walletBoxName);
    }

    final box = Hive.box(walletBoxName);
    final key = _generateKey(token, blockchain, address);
    await box.put(key, amount);
    await box.close();
  }

  Future<void> saveBalance(Token token, Blockchain blockchain, String address, BigInt amount) async {
    if (!Hive.isBoxOpen(walletBoxName)) {
      await Hive.openBox(walletBoxName);
    }

    final box = Hive.box(walletBoxName);
    final key = _generateKey(token, blockchain, address);
    await box.put(key, amount);
    await box.close();
    _setUpdatedTime(token, blockchain, address, DateTime.now().millisecondsSinceEpoch);
  }

  Future<BigInt> getBalance(Token token, Blockchain blockchain, String address) async {
    if (!Hive.isBoxOpen(walletBoxName)) {
      await Hive.openBox(walletBoxName);
    }

    final box = Hive.box(walletBoxName);
    final key = _generateKey(token, blockchain, address);
    final item = await box.get(key);
    await box.close();
    return item;
  }

  Future<int> _getUpdatedTime(Token token, Blockchain blockchain, String address) async {
    if (!Hive.isBoxOpen(walletUpdatedTimeBoxName)) {
      await Hive.openBox(walletUpdatedTimeBoxName);
    }

    final box = Hive.box(walletUpdatedTimeBoxName);
    final key = _generateKey(token, blockchain, address);
    final item = await box.get(key, defaultValue: 0);
    await box.close();
    return item;
  }

  Future<void> _setUpdatedTime(Token token, Blockchain blockchain, String address, int timestamp) async {
    if (!Hive.isBoxOpen(walletUpdatedTimeBoxName)) {
      await Hive.openBox(walletUpdatedTimeBoxName);
    }

    final box = Hive.box(walletUpdatedTimeBoxName);
    final key = _generateKey(token, blockchain, address);
    await box.put(key, timestamp);
    await box.close();
  }

  Future<bool> needToUpdate(Token token, Blockchain blockchain, String address) async {
    final lastUpdatedTime = await _getUpdatedTime(token, blockchain, address);
    if (lastUpdatedTime == 0) {
      return true;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    return now - lastUpdatedTime > updateThreshold;
  }

  Future<void> clearCache() async {
    logger.i('clearCache()');
    if (await Hive.boxExists(walletBoxName)) {
      if (!Hive.isBoxOpen(walletBoxName)) {
        await Hive.openBox(walletBoxName);
      }

      final box = Hive.box(walletBoxName);
      await box.clear();
      await box.close();
    }

    if (await Hive.boxExists(walletUpdatedTimeBoxName)) {
      if (!Hive.isBoxOpen(walletUpdatedTimeBoxName)) {
        await Hive.openBox(walletUpdatedTimeBoxName);
      }

      final box = Hive.box(walletUpdatedTimeBoxName);
      await box.clear();
      await box.close();
    }

    if (await Hive.boxExists(walletAddress)) {
      if (!Hive.isBoxOpen(walletAddress)) {
        await Hive.openBox(walletAddress);
      }

      final box = Hive.box(walletAddress);
      await box.clear();
      await box.close();
    }

    logger.i('finish clearCache()');
  }
}