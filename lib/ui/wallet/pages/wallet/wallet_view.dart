import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/components/user_header.dart';
import 'package:surfy_mobile_app/ui/wallet/components/wallet_item/wallet_item.dart';
import 'package:surfy_mobile_app/ui/type/balance.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/wallet/viewmodel/wallet_viewmodel.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletPageState();
  }
}

abstract class WalletPageInterface {
  void onRefresh();
  void onLoading();
  void offLoading();
}

class _WalletPageState extends State<WalletPage> implements WalletPageInterface {
  final WalletViewModel _viewModel = WalletViewModel();

  final SettingsPreference _preference = Get.find();
  final Calculator _calculator = Get.find();
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();

    _viewModel.setListener(this);
    _viewModel.init();
  }

  @override
  void onRefresh() {
    logger.i('onRefresh()');
  }

  @override
  void onLoading() {
    logger.i('onLoading()');
    _isLoading.value = true;
  }

  @override
  void offLoading() {
    logger.i('offLoading()');
    _isLoading.value = false;
  }

  List<Pair<Token, BigInt>> _balanceListByDesc(List<Token> tokens, List<Balance> balanceList) {
    final list = tokens.map((token) {
      return _viewModel.observableBalances.value
          .where((t) => t.token == token)
          .where((t) {
            if (!_preference.isShowTestnet.value && (blockchains[t.blockchain]?.isTestnet ?? true)) {
              return false;
            }
            return true;
          })
          .reduce((prev, curr) {
        return Balance(
            token: token,
            blockchain: prev.blockchain,
            balance: prev.balance + curr.balance
        );
      });
    }).map((balance) => Pair(balance.token, balance.balance)).toList();

    list.sort((a, b) {
      final fiatA = _calculator.cryptoToFiatV2(a.first, a.second, _viewModel.observablePrices.value[a.first]?[_preference.userCurrencyType.value]?.price ?? 0.0);
      final fiatB = _calculator.cryptoToFiatV2(b.first, b.second, _viewModel.observablePrices.value[b.first]?[_preference.userCurrencyType.value]?.price ?? 0.0);

      if (fiatA < fiatB) {
        return 1;
      } else if (fiatA == fiatB) {
        return 0;
      } else {
        return -1;
      }
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar()
        ),
        body: Obx(() {
          if (_isLoading.isTrue) {
            return const LoadingWidget(opacity: 0.4);
          } else {
            return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                        width: MediaQuery.of(context).size.width,
                        bottom: 0,
                        child: const Image(
                            image: AssetImage('assets/images/wallet_bg.png'),
                            width: double.infinity)),
                    SingleChildScrollView(
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            children: [
                              Obx(() => UserHeader(
                                  profileImageUrl: _viewModel.observableUser.value?.profileImage ?? "",
                                  profileName: _viewModel.observableUser.value?.name ?? "",
                                  onRefresh: () async {
                                    _viewModel.refresh(true);
                                  }
                              )),
                              const SizedBox(height: 8),
                              Column(
                                  children: _balanceListByDesc(Token.values, _viewModel.observableBalances.value).map((item) {
                                    final balance = item.second;
                                    return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                        child: Obx(() => WalletItem(
                                          token: item.first,
                                          tokenAmount: balance,
                                          tokenPrice: _viewModel.observablePrices.value[item.first]?[_preference.userCurrencyType.value]?.price ?? 0,
                                          currencyType: _preference.userCurrencyType.value,
                                        ))
                                    );
                                  }).toList()
                              )
                            ],
                          )
                      ),
                    ),
                  ],
                ));
          }
        })
        );
  }
}
