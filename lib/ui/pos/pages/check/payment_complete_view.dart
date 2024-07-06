import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentCompletePageProps {
  const PaymentCompletePageProps({
    required this.storeName,
    required this.fiatAmount,
    required this.currencyType,
    required this.blockchain,
    required this.txHash,
  });

  final String storeName;
  final double fiatAmount;
  final CurrencyType currencyType;
  final Blockchain blockchain;
  final String txHash;
}

class PaymentCompletePage extends StatefulWidget {
  const PaymentCompletePage({
    super.key,
    required this.storeName,
    required this.fiatAmount,
    required this.currencyType,
    required this.blockchain,
    required this.txHash,
  });

  final String storeName;
  final double fiatAmount;
  final CurrencyType currencyType;
  final Blockchain blockchain;
  final String txHash;

  @override
  State<StatefulWidget> createState() {
    return _PaymentCompletePageState();
  }
}

class _PaymentCompletePageState extends State<PaymentCompletePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LottieBuilder.asset("assets/images/animation_complete.json"),
                      const SizedBox(height: 24),
                      ElevatedButton(
                          onPressed: () {
                            final scanUrl = blockchains[widget.blockchain]?.getScanUrl(widget.txHash);
                            final Uri url = Uri.parse(scanUrl);
                            launchUrl(url);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SurfyColor.black,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/ic_link.png", width: 24, height: 24, color: SurfyColor.white),
                              const SizedBox(width: 10),
                              Text('Check in scan', style: Theme.of(context).textTheme.headlineMedium),
                            ],
                          )
                      )
                    ],
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                    onPressed: () {
                      checkAuthAndGo(context, "/wallet");
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: SurfyColor.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Center(
                        child: Text('OK', style: Theme.of(context).textTheme.headlineMedium)
                    ))
              )
            ],
          ),
        )
      )
    );
  }

}