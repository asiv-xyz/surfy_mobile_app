import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/user_header.dart';
import 'package:surfy_mobile_app/ui/components/wallet_item.dart';
import 'package:surfy_mobile_app/ui/navigation_controller.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletPageState();
  }
}

class _WalletPageState extends State<WalletPage> implements INavigationLifeCycle {
  final Rx<String> _profileImageUrl = "".obs;
  final Rx<String> _profileName = "".obs;
  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final GetTokenPrice _getTokenPrice = Get.find();
  final SettingsPreference _preference = Get.find();
  final Rx<List<Token>> _tokenList = Rx([]);

  @override
  void initState() {
    super.initState();
    final NavigationController controller = Get.find();
    controller.addListener(0, this);
    loadWallet();
  }

  Future<void> loadWallet() async {
    Web3AuthFlutter.getUserInfo().then((user) {
      setState(() {
        _profileName.value = user.name ?? "";
        _profileImageUrl.value = user.profileImage ?? "";
        final list = Token.values.map((token) => _getWalletBalancesUseCase.aggregateTokenBalance(token, _getWalletBalancesUseCase.userDataObs.value, _getTokenPrice.tokenPriceObs.value[token]?.price ?? 0.0, _preference.userCurrencyType.value))
            .toList();
        list.sort((a, b) {
          if (a.second < b.second) {
            return 1;
          } else if (a.second == b.second) {
            return 0;
          } else {
            return -1;
          }
        });
        _tokenList.value = list.map((pair) => pair.first).toList();
        print('tokenList: ${_tokenList.value}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar()
        ),
        body: Container(
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
                              print('onRefresh!');
                              final GetWalletBalances getWalletBalancesUseCase = Get.find();
                              final KeyService keyService = Get.find();
                              final key = await keyService.getKey();
                              getWalletBalancesUseCase.loadNewTokenDataList(Token.values, key.first, key.second);

                              final list = Token.values.map((token) => _getWalletBalancesUseCase.aggregateTokenBalance(token, _getWalletBalancesUseCase.userDataObs.value, _getTokenPrice.tokenPriceObs.value[token]?.price ?? 0.0, _preference.userCurrencyType.value))
                                  .toList();
                              list.sort((a, b) {
                                if (a.second < b.second) {
                                  return 1;
                                } else if (a.second == b.second) {
                                  return 0;
                                } else {
                                  return -1;
                                }
                              });
                              _tokenList.value = list.map((pair) => pair.first).toList();

                              print('tokenList: ${_tokenList.value}');
                            }
                        )),
                        const SizedBox(height: 8),
                        Obx(() => Column(
                          children: _tokenList.value.map((token) {
                            print('token: $token');
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: WalletItem(token: token),
                            );
                          }).toList(),
                        ))
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
            ))
        );
  }

  @override
  void onPageEnd() {
    print('onPageEnd');
  }

  @override
  void onPageStart() {
    print('onPageStart');
  }
}
