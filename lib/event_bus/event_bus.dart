import 'package:get/get.dart';
import 'package:surfy_mobile_app/repository/token/token_price_repository.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

enum GlobalEventType {
  forceUpdateTokenBalance,
}

abstract class GlobalEvent {
  GlobalEventType getType();
}

class ForceUpdateTokenBalanceEvent extends GlobalEvent {
  ForceUpdateTokenBalanceEvent({
    required this.token,
    required this.blockchain,
    required this.address,
  });

  final Token token;
  final Blockchain blockchain;
  final String address;

  @override
  GlobalEventType getType() {
    return GlobalEventType.forceUpdateTokenBalance;
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
    for (var listener in _eventListeners) {
      listener.onEventReceived(event);
    }
  }
}