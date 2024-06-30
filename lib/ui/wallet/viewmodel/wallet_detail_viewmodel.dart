import 'package:dartx/dartx.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/type/balance.dart';
import 'package:surfy_mobile_app/ui/wallet/wallet_detail_view.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class WalletDetailViewModel {
  late WalletDetailPageInterface view;

  final Rx<List<Balance>> balances = Rx([]);
  final Rx<Map<Blockchain, String>> addresses = Rx({});
  final RxDouble tokenPrice = 0.0.obs;

  final GetWalletBalances _getWalletBalances = Get.find();
  final GetWalletAddress _getWalletAddress = Get.find();
  final GetTokenPrice _getTokenPrice = Get.find();
  final SettingsPreference _preference = Get.find();

  void setView(WalletDetailPageInterface view) {
    this.view = view;
  }

  Future<void> init(Token token, CurrencyType currency) async {
    view.onLoading();
    final networks = tokens[token]?.supportedBlockchain ?? [];
    final job = networks
        .where((network) {
          if (_preference.isShowTestnet.value == false && (blockchains[network]?.isTestnet ?? false)) {
            return false;
          }
          return true;
        })
        .map((network) async {
          final address = await _getWalletAddress.getAddress(network);
          addresses.value[network] = address;
          final result = await _getWalletBalances.getBalance(token, network, address);
          return Balance(token: token, blockchain: network, balance: result);
        }
    ).toList();
    final result = await Future.wait(job);
    balances.value = result;

    final price = await _getTokenPrice.getSingleTokenPrice(token, currency);
    tokenPrice.value = price?.price ?? 0.0;

    view.offLoading();
  }

  BigInt aggregateBalance() {
    final aggregatedList = balances.value.reduce((prev, curr) => Balance(
        token: prev.token, blockchain: prev.blockchain, balance: prev.balance + curr.balance));
    return aggregatedList.balance;
  }

  List<Balance> sortByDesc(bool nonzero) {
    final copy = [...balances.value];
    copy.sort((a, b) {
      if (a.balance < b.balance) {
        return 1;
      } else if (a.balance == b.balance) {
        return 0;
      } else {
        return -1;
      }
    });

    if (nonzero) {
      return copy.where((item) => item.balance > BigInt.zero).toList();
    } else {
      return copy;
    }
  }
}