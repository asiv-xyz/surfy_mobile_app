import 'package:get/get.dart';
import 'package:surfy_mobile_app/cache/wallet/wallet_cache.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/type/balance.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/wallet/wallet_view.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:web3auth_flutter/output.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

class WalletViewModel implements EventListener {
  WalletViewModel() {
    final EventBus bus = Get.find();
    bus.addEventListener(this);
  }

  late WalletPageInterface listener;

  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final GetWalletAddress _getWalletAddressUseCase = Get.find();
  final GetTokenPrice _getTokenPrice = Get.find();
  final SettingsPreference _preference = Get.find();
  final EventBus _bus = Get.find();

  Rx<List<Balance>> observableBalances = Rx([]);
  Rx<Map<Token, Map<CurrencyType, TokenPrice>>> observablePrices = Rx({});
  RxString observableProfileImageUrl = "".obs;
  RxString observableProfileName = "".obs;
  Rx<TorusUserInfo?> observableUser = Rx(null);

  void setListener(WalletPageInterface item) {
    listener = item;
  }

  Future<void> init() async {
    observableUser.value = await Web3AuthFlutter.getUserInfo();

    await refresh(true);
  }

  Future<void> refresh(bool fromRemote) async {
    listener.onLoading();

    await _bus.emit(ReloadWalletEvent());

    final getBalanceJobList = Token.values.map((token) async {
      final networks = tokens[token]?.supportedBlockchain;
      final balanceList = networks?.map((network) async {
        final address = await _getWalletAddressUseCase.getAddress(network);
        final balance = fromRemote ? await _getWalletBalancesUseCase.getBalanceFromRemote(token, network, address)
            : await _getWalletBalancesUseCase.getBalance(token, network, address);
        if (!fromRemote) {
          print('Event and updated balance: ${balance}');
        }
        return Balance(
          token: token,
          blockchain: network,
          balance: balance
        );
      }).toList() ?? [];

      return await Future.wait(balanceList);
    }).toList();

    final balanceList = (await Future.wait(getBalanceJobList)).expand((e) => e);
    observableBalances.value = [];
    for (var balance in balanceList) {
      observableBalances.value.add(balance);
    }

    final tokenPrices = await _getTokenPrice.getTokenPrice(Token.values, _preference.userCurrencyType.value);
    print('tokenPrices: $tokenPrices');
    observablePrices.value = tokenPrices;

    listener.offLoading();
  }


  @override
  Future<void> onEventReceived(GlobalEvent event) async {
    if (event is UpdateTokenBalanceCompleteEvent) {
      print('Event: UpdateTokenBalanceCompleteEvent received');
      await refresh(false);
    } else if (event is ChangeCurrecnyTypeEvent) {
      print('Event: ChangeCurrencyTypeEvent received');
      await refresh(true);
    }
  }
}