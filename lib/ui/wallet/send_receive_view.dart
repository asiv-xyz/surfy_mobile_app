import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/address_badge.dart';
import 'package:surfy_mobile_app/ui/components/current_price.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class SendReceivePage extends StatefulWidget {
  const SendReceivePage({super.key, required this.token, required this.blockchain});

  final Token token;
  final Blockchain blockchain;

  @override
  State<StatefulWidget> createState() {
    return _SendReceivePageState();
  }
}

class _SendReceivePageState extends State<SendReceivePage> {
  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final GetWalletBalances _getWalletBalances = Get.find();
  final SettingsPreference _preference = Get.find();
  final GetWalletAddress _getWalletAddressUseCase = Get.find();
  final _address = "".obs;

  Future<Pair<TokenPrice?, Pair<String, String>>> _getMetadata() async {
    final tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(widget.token, _preference.userCurrencyType.value);
    final userBalance = await _getWalletBalances.getUiTokenBalanceWithNetwork(widget.token, widget.blockchain, _preference.userCurrencyType.value);
    _address.value = await _getWalletAddressUseCase.getAddress(widget.blockchain);
    return Pair(tokenPrice, userBalance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: SurfyColor.black,
        iconTheme: const IconThemeData(color: SurfyColor.white),
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(tokens[widget.token]?.iconAsset ?? "", width: 40, height: 40,),
            const SizedBox(width: 10,),
            Text(tokens[widget.token]?.name ?? "", style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 18),)
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: SurfyColor.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  FutureBuilder<Pair<TokenPrice?, Pair<String, String>>>(
                    future: _getMetadata(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final tokenPrice = snapshot.data?.first;
                        final userBalance = snapshot.data?.second;
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("${userBalance?.second}", style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 36)),
                              const SizedBox(height: 5,),
                              Text("${userBalance?.first}", style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 24)),
                              const SizedBox(height: 5,),
                              CurrentPrice(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  tokenName: tokens[widget.token]?.name ?? "",
                                  price: tokenPrice?.price ?? 0.0,
                                  currency: _preference.userCurrencyType.value),
                              const SizedBox(height: 5,),
                              Obx(() {
                                if (_address.value.isNullOrEmpty) {
                                  return Container();
                                } else {
                                  return AddressBadge(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    address: _address.value
                                  );
                                }
                              })
                            ],
                          )
                        );
                      }

                      return const Center(child: CircularProgressIndicator(color: SurfyColor.blue));
                    }
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              if (mounted) {
                                context.push('/send', extra: Pair(widget.token, widget.blockchain));
                              }
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                color: SurfyColor.blue,
                                borderRadius: BorderRadius.circular(100)
                              ),
                              child: const Icon(Icons.arrow_upward_outlined, size: 30)
                            ),
                          ),
                          Text('Send', style: GoogleFonts.sora(color: SurfyColor.white),)
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              if (mounted) {
                                context.push('/receive', extra: Pair(widget.token, widget.blockchain));
                              }
                            },
                            child: Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                    color: SurfyColor.blue,
                                    borderRadius: BorderRadius.circular(100)
                                ),
                                child: const Icon(Icons.arrow_downward_outlined, size: 30)
                            ),
                          ),
                          Text('Receive', style: GoogleFonts.sora(color: SurfyColor.white),)
                        ],
                      )
                    ],
                  )
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

}