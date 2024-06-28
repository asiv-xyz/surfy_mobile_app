import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/domain/payment/select_token.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/keyboard_view.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.storeId});

  final String storeId;

  @override
  State<StatefulWidget> createState() {
    return _PaymentPageState();
  }
}

class _PaymentPageState extends State<PaymentPage> {
  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final SettingsPreference _preference = Get.find();
  final SelectToken _selectTokenUseCase = Get.find();

  final _enteredAmount = "0".obs;
  final _currency = "".obs;
  final _isLoading = false.obs;
  final _tokenPrice = 0.0.obs;

  @override
  void initState() {
    super.initState();
    _preference.getCurrencyType().then((currencyType) async {
      _currency.value = currencyType.name.toUpperCase();
      _isLoading.value = true;
      final tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(_selectTokenUseCase.selectedToken.value, currencyType);
      _tokenPrice.value = tokenPrice?.price ?? 0.0;
      _isLoading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: const Text('Payment',),
          ),
          body: Container(
              height: MediaQuery.of(context).size.height,
              color: SurfyColor.black,
              child: Stack(
                children: [
                  KeyboardView(
                    buttonText: 'Send',
                    isFiatInputMode: false,
                    onClickSend: () {},
                    inputAmount: _enteredAmount,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('To ${widget.storeId}',
                            style: GoogleFonts.sora(
                                color: SurfyColor.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('${_enteredAmount.value} USD',
                            style: GoogleFonts.sora(
                                color: SurfyColor.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 40)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('0.005 BTC',
                            style: GoogleFonts.sora(
                                color: SurfyColor.lightGrey, fontSize: 16)),
                        const SizedBox(height: 20),
                        FutureBuilder<Pair<String, String>>(
                            future: _getWalletBalancesUseCase.getUiTokenBalance(
                                _selectTokenUseCase.selectedToken.value,
                                _preference.userCurrencyType.value),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final crypto = snapshot.data?.first ?? "0.0";
                                final fiat = snapshot.data?.second ?? "0.0";
                                return InkWell(
                                    onTap: () {
                                      context.push('/select');
                                    },
                                    child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: SurfyColor.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  tokens[_selectTokenUseCase
                                                              .selectedToken
                                                              .value]
                                                          ?.iconAsset ??
                                                      "",
                                                  width: 40,
                                                  height: 40,
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      tokens[_selectTokenUseCase
                                                                  .selectedToken
                                                                  .value]
                                                              ?.name ??
                                                          "",
                                                      style: GoogleFonts.sora(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      crypto,
                                                      style: GoogleFonts.sora(
                                                          fontSize: 14),
                                                    ),
                                                    Text(
                                                      "$fiat",
                                                      style: GoogleFonts.sora(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: SurfyColor.lightGrey),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 8),
                                              child: Center(
                                                  child: Text(
                                                'Change',
                                                style: GoogleFonts.sora(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: SurfyColor.white),
                                              )),
                                            )
                                          ],
                                        )));
                              }

                              return const Center(
                                child: CircularProgressIndicator(
                                    color: SurfyColor.blue),
                              );
                            })
                      ],
                    ),
                  ),
                  Obx(() {
                    if (_getWalletBalancesUseCase.isLoading.value == true) {
                      return Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                              color: SurfyColor.black.withOpacity(0.8)),
                          child: const Center(
                              child: CircularProgressIndicator(
                                  color: SurfyColor.blue)));
                    }

                    return Container();
                  }),
                ],
              )),
        ));
  }
}
