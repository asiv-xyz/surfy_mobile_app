import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

enum GlobalEventType {
  forceUpdateTokenBalance,
  updateTokenBalanceComplete,
  reloadWalletEvent,
  changeCurrencyTypeEvent,
}

abstract class GlobalEvent {
  GlobalEventType getType();
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
    print('Event Emit: $event');
    final job = _eventListeners.map((listener) async => await listener.onEventReceived(event));
    await Future.wait(job);
  }
}