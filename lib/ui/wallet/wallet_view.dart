import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/user_header.dart';
import 'package:surfy_mobile_app/ui/components/wallet_item.dart';
import 'package:surfy_mobile_app/ui/navigation_controller.dart';
import 'package:surfy_mobile_app/ui/type/balance.dart';
import 'package:surfy_mobile_app/ui/wallet/viewmodel/wallet_viewmodel.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
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
  final Rx<String> _profileImageUrl = "".obs;
  final Rx<String> _profileName = "".obs;
  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final SettingsPreference _preference = Get.find();
  final Calculator _calculator = Get.find();

  final WalletViewModel _viewModel = WalletViewModel();

  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    loadWallet();

    _viewModel.setListener(this);
    _viewModel.onCreate();
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

  Future<void> loadWallet() async {
    Web3AuthFlutter.getUserInfo().then((user) {
      setState(() {
        _profileName.value = user.name ?? "";
        _profileImageUrl.value = user.profileImage ?? "";
      });
    });
  }

  List<Pair<Token, BigInt>> _balanceListByDesc(List<Token> tokens, List<Balance> balanceList) {
    final list = tokens.map((token) {
      return _viewModel.balances.value.where((t) => t.token == token).reduce((prev, curr) {
        return Balance(
            token: token,
            blockchain: prev.blockchain,
            balance: prev.balance + curr.balance
        );
      });
    }).map((balance) => Pair(balance.token, balance.balance)).toList();

    list.sort((a, b) {
      final fiatA = _calculator.cryptoToFiat(a.first, a.second, _preference.userCurrencyType.value);
      final fiatB = _calculator.cryptoToFiat(b.first, b.second, _preference.userCurrencyType.value);

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
            return const SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: CircularProgressIndicator(color: SurfyColor.blue)
              )
            );
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
                                  profileImageUrl: _profileImageUrl.value,
                                  profileName: _profileName.value,
                                  onRefresh: () async {
                                    _viewModel.refresh();
                                  }
                              )),
                              const SizedBox(height: 8),
                              Column(
                                  children: _balanceListByDesc(Token.values, _viewModel.balances.value).map((item) {
                                    final balance = item.second;
                                    return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                        child: Obx(() => WalletItem(
                                          token: item.first,
                                          tokenAmount: balance,
                                          tokenPrice: _viewModel.prices.value[item.first]?.price ?? 0,
                                          currencyType: _preference.userCurrencyType.value,
                                        ))
                                    );
                                  }).toList()
                              )
                            ],
                          )
                      ),
                    ),
                    Obx(() {
                      if (_getWalletBalancesUseCase.isLoading.value == true) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Color(0xFF3B85F3)),
                          ),
                        );
                      }

                      return Container();
                    })
                  ],
                ));
          }
        })
        );
  }
}
