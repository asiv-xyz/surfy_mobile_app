import 'package:get/get.dart';
import 'package:surfy_mobile_app/repository/token/token_price_repository.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

enum GlobalEventType {
  forceUpdateTokenBalance,
  updateTokenBalanceComplete,
}

abstract class GlobalEvent {
  GlobalEventType getType();
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
  void onEventReceived(GlobalEvent event);
}

class EventBus {
  final List<EventListener> _eventListeners = [];

  void addEventListener(EventListener listener) {
    _eventListeners.add(listener);
  }

  void emit(GlobalEvent event) {
    print('Event emit!: $event');
    for (var listener in _eventListeners) {
      print('listener: $listener');
      listener.onEventReceived(event);
    }
  }
}