import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:surfy_mobile_app/repository/wallet/wallet_balances_repository.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/wallet/viewmodel/check_viewmodel.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class CheckViewProps {
  CheckViewProps({
    required this.token,
    required this.blockchain,
    required this.transactionHash,
    required this.receiver,
    required this.crypto,
    required this.fiat,
    required this.currency,
  });

  final Token token;
  final Blockchain blockchain;
  final String transactionHash;
  final String receiver;
  final BigInt crypto;
  final double fiat;
  final CurrencyType currency;

  @override
  String toString() {
    return {
      "token": token.name,
      "blockchain": blockchain.name,
      "transactionHash": transactionHash,
      "receiver": receiver,
      "crypto": crypto,
      "fiat": fiat,
      "currency": currency,
    }.toString();
  }
}

class CheckView extends StatefulWidget {
  const CheckView({super.key,
    required this.token,
    required this.blockchain,
    required this.transactionHash,
    required this.receiver,
    required this.crypto,
    required this.fiat,
    required this.currency,
  });

  final Token token;
  final Blockchain blockchain;
  final String transactionHash;
  final String receiver;
  final BigInt crypto;
  final double fiat;
  final CurrencyType currency;

  @override
  State<StatefulWidget> createState() {
    return _CheckViewState();
  }
}

abstract class CheckViewInterface {
  void onCreate();
}

class _CheckViewState extends State<CheckView> with SingleTickerProviderStateMixin implements CheckViewInterface {
  
  late AnimationController controller;
  late Animation<int> alpha;
  late Animation<double> animation;

  final CheckViewModel _viewModel = CheckViewModel();
  final WalletBalancesRepository _repository = Get.find();

  @override
  void onCreate() {

  }

  @override
  void initState() {
    super.initState();
    _viewModel.setView(this);
    controller = AnimationController(duration: Duration(seconds: 1), vsync: this);
    alpha = IntTween(begin: 0, end: 255).animate(controller);
    animation = Tween<double>(begin: 0, end: 300).animate(controller)..addListener(() {
      setState(() {

      });
    });
    controller.forward();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(
                  height: animation.value,
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/ic_blue_check.png", width: 40, height: 40),
                      const SizedBox(width: 10),
                      Text('Check please!', style: Theme.of(context).textTheme.headlineMedium)
                    ],
                  ),
                ),
                Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tx Hash', style: Theme.of(context).textTheme.displaySmall),
                            Text(shortAddress(widget.transactionHash), style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        )
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: 60,
              child: Material(
                color: SurfyColor.blue,
                child: InkWell(
                  onTap: () {
                    if (mounted) {
                      context.go('/wallet');
                    }
                  },
                  child: Center(
                    child: Text('Click to home', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 18))
                  )
                )
              )
            )
          ],
        )
      )
    );
  }

}