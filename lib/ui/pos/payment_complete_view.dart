import 'package:flutter/material.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
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
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 100,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/ic_blue_check.png", width: 40, height: 40),
                      const SizedBox(width: 10),
                      Text('Complete crypto payment!', style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Text('You paid to ${widget.storeName} ${formatFiat(widget.fiatAmount, widget.currencyType)}', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 10,),
                  InkWell(
                      onTap: () {
                        final scanUrl = blockchains[widget.blockchain]?.getScanUrl(widget.txHash);
                        final Uri url = Uri.parse(scanUrl);
                        launchUrl(url);
                      },
                      child: Text('Check in explorer', style: Theme.of(context).textTheme.headlineMedium)
                  )
                ],
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextButton(
                    onPressed: () {
                      context.go('/wallet');
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: SurfyColor.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15)
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