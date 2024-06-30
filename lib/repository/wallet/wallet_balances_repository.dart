import 'dart:async';

import 'package:get/get.dart';
import 'package:surfy_mobile_app/cache/wallet/wallet_cache.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/wallet/wallet_service.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class WalletBalancesRepository implements EventListener {
  WalletBalancesRepository({required this.walletService, required this.walletCache});

  final WalletService walletService;
  final WalletCache walletCache;

  Future<BigInt> getBalance(Token token, Blockchain blockchain, String address, { fromRemote }) async {
    if (fromRemote == true) {
      final result = await walletService.getBalance(token, blockchain, address);
      await walletCache.saveBalance(token, blockchain, address, result.amount);
      return result.amount;
    }

    if (!await walletCache.needToUpdate(token, blockchain, address)) {
      print('balance from cache!');
      return await walletCache.getBalance(token, blockchain, address);
    }

    final result = await walletService.getBalance(token, blockchain, address);
    await walletCache.saveBalance(token, blockchain, address, result.amount);
    return result.amount;
  }

  @override
  Future<void> onEventReceived(GlobalEvent event) async {
    if (event is ForceUpdateTokenBalanceEvent) {
      if (!await walletCache.needToUpdate(event.token, event.blockchain, event.address)) {
        print('Event: Update cache!');
        final existedItem = await walletCache.getBalance(event.token, event.blockchain, event.address);
        await walletCache.saveBalanceOnly(event.token, event.blockchain, event.address, existedItem - event.amount);
      }
      final EventBus bus = Get.find();
      bus.emit(UpdateTokenBalanceCompleteEvent());
      // TODO : How about need to cache update?
      // logger.i("Force update user balance, token=${event.token}, blockchain=${event.blockchain}, address=${event.address}");
      // getBalance(event.token, event.blockchain, event.address, fromRemote: true);
    }
  }
}