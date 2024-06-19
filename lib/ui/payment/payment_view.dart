import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/payment/select_token.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.storeId});

  final String storeId;

  @override
  State<StatefulWidget> createState() {
    return _PaymentPageState();
  }
}

class _PaymentPageState extends State<PaymentPage> {
  final GetWalletBalances getWalletBalancesUseCase = Get.find();
  final GetTokenPrice getTokenPriceUseCase = Get.find();
  final SettingsPreference preference = Get.find();

  final selectedToken = Token.ETHEREUM.obs;
  final SelectToken selectTokenUseCase = Get.find();
  final userTokenBalance = "0".obs;
  final userTokenFiatBalance = "0".obs;
  final isLoading = false.obs;
  final isTokenSelecting = false.obs;

  final _enteredAmount = "0".obs;

  void clickNumberButton(String n) {
    switch (n) {
      case "<-":
        if (_enteredAmount.value.length > 1) {
          _enteredAmount.value = _enteredAmount.value
              .substring(0, _enteredAmount.value.length - 1);
        } else {
          _enteredAmount.value = "0";
        }
        break;
      case "1":
      case "2":
      case "3":
      case "4":
      case "5":
      case "6":
      case "7":
      case "8":
      case "9":
        if (_enteredAmount.value == "0") {
          _enteredAmount.value = n;
        } else {
          _enteredAmount.value += n;
        }
        break;
      case "0":
      case "00":
        if (_enteredAmount.value != "0") {
          _enteredAmount.value += n;
        }
        break;
      case ".":
        _enteredAmount.value += ".";
        break;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            backgroundColor: SurfyColor.black,
            titleSpacing: 0,
            title: Text(
              'Payment',
              style: GoogleFonts.sora(
                  color: SurfyColor.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            iconTheme: const IconThemeData(color: SurfyColor.white),
          ),
          body: Container(
              height: MediaQuery.of(context).size.height,
              color: SurfyColor.black,
              child: Stack(
                children: [
                  Positioned.fill(
                      child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                color: SurfyColor.lightGrey,
                                                fontSize: 16)),
                                        const SizedBox(height: 20),
                                        FutureBuilder<Pair<String, String>>(
                                            future: getWalletBalancesUseCase
                                                .getUiTokenBalance(selectTokenUseCase.selectedToken.value, preference.userCurrencyType.value),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                final crypto =
                                                    snapshot.data?.first ??
                                                        "0.0";
                                                final fiat =
                                                    snapshot.data?.second ??
                                                        "0.0";
                                                return InkWell(
                                                    onTap: () {
                                                      context.push('/select');
                                                    },
                                                    child: Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color:
                                                              SurfyColor.white,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Image.asset(
                                                                  tokens[selectTokenUseCase
                                                                              .selectedToken
                                                                              .value]
                                                                          ?.iconAsset ??
                                                                      "",
                                                                  width: 40,
                                                                  height: 40,
                                                                ),
                                                                const SizedBox(
                                                                    width: 10),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      tokens[selectTokenUseCase.selectedToken.value]
                                                                              ?.name ??
                                                                          "",
                                                                      style: GoogleFonts.sora(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                    Text(
                                                                      crypto,
                                                                      style: GoogleFonts.sora(
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                    Text(
                                                                      "$fiat",
                                                                      style: GoogleFonts.sora(
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  color:
                                                                      SurfyColor
                                                                          .lightGrey),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          8),
                                                              child: Center(
                                                                  child: Text(
                                                                'Change',
                                                                style: GoogleFonts.sora(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16,
                                                                    color: SurfyColor
                                                                        .white),
                                                              )),
                                                            )
                                                          ],
                                                        )));
                                              }

                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        color: SurfyColor.blue),
                                              );
                                            })
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Expanded(
                                  child: Container(
                                color: SurfyColor.black,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                            child: InkWell(
                                                onTap: () {
                                                  clickNumberButton("1");
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: Center(
                                                        child: Text(
                                                      "1",
                                                      style: GoogleFonts.sora(
                                                          color:
                                                              SurfyColor.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ))))),
                                        Flexible(
                                            child: InkWell(
                                                onTap: () {
                                                  clickNumberButton("2");
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: Center(
                                                        child: Text(
                                                      "2",
                                                      style: GoogleFonts.sora(
                                                          color:
                                                              SurfyColor.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ))))),
                                        Flexible(
                                            child: InkWell(
                                                onTap: () {
                                                  clickNumberButton("3");
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: Center(
                                                        child: Text(
                                                      "3",
                                                      style: GoogleFonts.sora(
                                                          color:
                                                              SurfyColor.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ))))),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                            child: InkWell(
                                                onTap: () {
                                                  clickNumberButton("4");
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: Center(
                                                        child: Text(
                                                      "4",
                                                      style: GoogleFonts.sora(
                                                          color:
                                                              SurfyColor.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ))))),
                                        Flexible(
                                            child: InkWell(
                                                onTap: () {
                                                  clickNumberButton("5");
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: Center(
                                                        child: Text(
                                                      "5",
                                                      style: GoogleFonts.sora(
                                                          color:
                                                              SurfyColor.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ))))),
                                        Flexible(
                                            child: InkWell(
                                                onTap: () {
                                                  clickNumberButton("6");
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: Center(
                                                        child: Text(
                                                      "6",
                                                      style: GoogleFonts.sora(
                                                          color:
                                                              SurfyColor.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ))))),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                            child: InkWell(
                                                onTap: () {
                                                  clickNumberButton("7");
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: Center(
                                                        child: Text(
                                                      "7",
                                                      style: GoogleFonts.sora(
                                                          color:
                                                              SurfyColor.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ))))),
                                        Flexible(
                                            child: InkWell(
                                                onTap: () {
                                                  clickNumberButton("8");
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: Center(
                                                        child: Text(
                                                      "8",
                                                      style: GoogleFonts.sora(
                                                          color:
                                                              SurfyColor.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ))))),
                                        Flexible(
                                            child: InkWell(
                                                onTap: () {
                                                  clickNumberButton("9");
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: Center(
                                                        child: Text(
                                                      "9",
                                                      style: GoogleFonts.sora(
                                                          color:
                                                              SurfyColor.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ))))),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                            child: InkWell(
                                                onTap: () {
                                                  clickNumberButton(".");
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: Center(
                                                        child: Text(
                                                      ".",
                                                      style: GoogleFonts.sora(
                                                          color:
                                                              SurfyColor.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ))))),
                                        Flexible(
                                            child: InkWell(
                                                onTap: () {
                                                  clickNumberButton("0");
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: Center(
                                                        child: Text(
                                                      "0",
                                                      style: GoogleFonts.sora(
                                                          color:
                                                              SurfyColor.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ))))),
                                        Flexible(
                                            child: InkWell(
                                                onTap: () {
                                                  clickNumberButton("<-");
                                                },
                                                child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: Center(
                                                        child: Text(
                                                      "<-",
                                                      style: GoogleFonts.sora(
                                                          color:
                                                              SurfyColor.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ))))),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                              InkWell(
                                  onTap: () {},
                                  child: Container(
                                      height: 60,
                                      decoration:
                                          BoxDecoration(color: SurfyColor.blue),
                                      child: Center(
                                          child: Text(
                                        'Send',
                                        style: GoogleFonts.sora(
                                            color: SurfyColor.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ))))
                            ],
                          ))),
                  Obx(() {
                    if (getWalletBalancesUseCase.isLoading.value == true) {
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
