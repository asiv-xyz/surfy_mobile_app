import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/entity/transaction/transaction.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryDetailPage extends StatelessWidget {
  HistoryDetailPage({super.key, required this.tx});

  final Transaction tx;
  final Calculator _calculator = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Transaction Detail')
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  TokenIconWithNetwork(
                      blockchain: tx.blockchain,
                      token: tx.token,
                      width: 40,
                      height: 40),
                  const SizedBox(width: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tokens[tx.token]?.name ?? "", style: Theme.of(context).textTheme.titleLarge),
                      Text(blockchains[tx.blockchain]?.name ?? "", style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  )
                ],
              )
            ),
            Container(
              decoration: BoxDecoration(
                color: SurfyColor.greyBg,
                borderRadius: BorderRadius.circular(14)
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(formatCrypto(tx.token, _calculator.cryptoToDouble(tx.token, tx.amount)), style: Theme.of(context).textTheme.displayMedium,)
              )
            ),
            Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: SurfyColor.greyBg),
                    borderRadius: BorderRadius.circular(14)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('To', style: Theme.of(context).textTheme.titleSmall),
                    Text(tx.receiverAddress, style: Theme.of(context).textTheme.bodySmall)
                  ],
                )
            ),
            Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: SurfyColor.greyBg),
                  borderRadius: BorderRadius.circular(14)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date', style: Theme.of(context).textTheme.titleSmall),
                    Text(tx.createdAt.toString(), style: Theme.of(context).textTheme.bodySmall)
                  ],
                )
            ),
            Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: SurfyColor.greyBg),
                    borderRadius: BorderRadius.circular(14)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tx hash', style: Theme.of(context).textTheme.titleSmall),
                        Text(shortAddress(tx.transactionHash), style: Theme.of(context).textTheme.bodySmall)
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        final scanUrl = blockchains[tx.blockchain]?.getScanUrl(tx.transactionHash);
                        final Uri url = Uri.parse(scanUrl);
                        launchUrl(url);
                      },
                      icon: Icon(Icons.open_in_browser_outlined)
                    )
                  ],
                )
            ),
          ],
        )
      ),
    );
  }

}