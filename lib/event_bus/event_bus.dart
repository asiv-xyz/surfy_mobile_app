import 'package:surfy_mobile_app/entity/transaction/transaction.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

enum GlobalEventType {
  forceUpdateTokenBalance,
  updateTokenBalanceComplete,
  reloadWalletEvent,
  reloadHistoryEvent,
  changeCurrencyTypeEvent,
  saveTransactionEvent,
}

abstract class GlobalEvent {
  GlobalEventType getType();
}

class ReloadHistoryEvent extends GlobalEvent {
  @override
  GlobalEventType getType() {
    return GlobalEventType.reloadHistoryEvent;
  }

}

class SaveTransactionEvent extends GlobalEvent {
  SaveTransactionEvent(
      this.receiverUserId,
      this.storeId,
      this.fiat,
      this.currencyType, {
    required this.type,
    required this.transactionHash,
    required this.token,
    required this.blockchain,
    required this.senderUserId,
    required this.senderAddress,
    required this.receiverAddress,
    required this.amount,
  });

  final TransactionType type;
  final String transactionHash;
  final Token token;
  final Blockchain blockchain;
  final String senderUserId;
  final String? receiverUserId;
  final String senderAddress;
  final String receiverAddress;
  final BigInt amount;
  final String? storeId;
  final double? fiat;
  final CurrencyType? currencyType;

  @override
  GlobalEventType getType() {
    return GlobalEventType.saveTransactionEvent;
  }
}

class ReloadWalletEvent extends GlobalEvent {
  @override
  GlobalEventType getType() {
    return GlobalEventType.reloadWalletEvent;
  }
}

class ChangeCurrecnyTypeEvent extends GlobalEvent {
  @override
  GlobalEventType getType() {
    return GlobalEventType.changeCurrencyTypeEvent;
  }

}

class UpdateTokenBalanceCompleteEvent extends GlobalEvent {
  @override
  GlobalEventType getType() {
    return GlobalEventType.updateTokenBalanceComplete;
  }
}

class ForceUpdateTokenBalanceEvent extends GlobalEvent {
  ForceUpdateTokenBalanceEvent({
    required this.token,
    required this.blockchain,
    required this.address,
    required this.amount,
  });

  final Token token;
  final Blockchain blockchain;
  final String address;
  final BigInt amount;

  @override
  GlobalEventType getType() {
    return GlobalEventType.forceUpdateTokenBalance;
  }

  @override
  String toString() {
    return {
      "token": token,
      "blockchain": blockchain,
      "address": address,
      "amount": amount,
    }.toString();
  }
}

abstract class EventListener {
  Future<void> onEventReceived(GlobalEvent event);
}

class EventBus {
  final List<EventListener> _eventListeners = [];

  void addEventListener(EventListener listener) {
    _eventListeners.add(listener);
  }

  Future<void> emit(GlobalEvent event) async {
    final job = _eventListeners.map((listener) async => await listener.onEventReceived(event));
    await Future.wait(job);
  }
}