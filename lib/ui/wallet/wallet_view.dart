import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
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
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.black,
          )
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
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
                        Obx(() => UserHeader(profileImageUrl: _profileImageUrl.value, profileName: _profileName.value)),
                        const SizedBox(height: 8),
                        Column(
                          children: Token.values.map((token) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: WalletItem(token: token),
                            );
                          }).toList(),
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
                      decoration: BoxDecoration(
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
