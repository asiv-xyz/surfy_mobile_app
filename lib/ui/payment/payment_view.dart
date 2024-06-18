import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
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
  List<UserTokenData> _userBalance = <UserTokenData>[];

  final selectedToken = Token.ETHEREUM.obs;
  final userTokenBalance = "0".obs;
  final userTokenFiatBalance = "0".obs;
  final isLoading = false.obs;
  final isTokenSelecting = false.obs;

  Future<bool> loadData() async {
    final data = await getWalletBalancesUseCase.getMultipleTokenDataList(
        Token.values,
        await Web3AuthFlutter.getPrivKey(),
        await Web3AuthFlutter.getEd25519PrivKey());
    await getTokenPriceUseCase.getTokenPrice(Token.values, 'usd');
    setState(() {
      _userBalance = data;
    });

    return true;
  }

  UserTokenData getUserTokenData(Token token) {
    return _userBalance.where((ub) => ub.token == token).reduce(
        (prev, current) => UserTokenData(
            token: prev.token,
            blockchain: prev.blockchain,
            decimal: prev.decimal,
            address: "",
            amount: prev.amount + current.amount));
  }

  Future<void> selectToken(Token token) async {
    selectedToken.value = token;
    final userBalanceData = getUserTokenData(token);
    print('userBalanceData: $userBalanceData');
    userTokenBalance.value =
        userBalanceData.toVisibleAmount().toStringAsFixed(2);

    final tokenPriceData =
        await getTokenPriceUseCase.getTokenPrice(Token.values, 'usd');
    final tokenPrice = tokenPriceData[token]?.price ?? 0.0;
    userTokenFiatBalance.value =
        (userBalanceData.toVisibleAmount() * tokenPrice)
            .toStringAsFixed(tokens[token]?.fixedDecimal ?? 2);
  }

  Future<Pair<String, String>> _getVisibleTokenBalance(Token token) async {
    final userBalanceData = getUserTokenData(token);
    final visibleTokenAmount =
        "${userBalanceData.toVisibleAmount().toStringAsFixed(tokens[token]?.fixedDecimal ?? 2)} ${tokens[token]?.symbol ?? '???'}";

    final tokenPriceData =
        await getTokenPriceUseCase.getTokenPrice(Token.values, 'usd');
    final tokenPrice = tokenPriceData[token]?.price ?? 0.0;
    final visibleFiatAmount = (userBalanceData.toVisibleAmount() * tokenPrice)
        .toStringAsFixed(tokens[token]?.fixedDecimal ?? 2);

    final pair = Pair(visibleTokenAmount, visibleFiatAmount);
    return pair;
  }

  @override
  void initState() {
    super.initState();
    loadData().then((r) {
      selectToken(Token.ETHEREUM);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            backgroundColor: isTokenSelecting.value == true
                ? SurfyColor.black.withOpacity(0.8)
                : SurfyColor.black,
            iconTheme: const IconThemeData(color: SurfyColor.white),
          ),
          body: Container(
              width: double.infinity,
              height: double.infinity,
              color: SurfyColor.black,
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Text('Store Id: ${widget.storeId}', style: GoogleFonts.sora(color: SurfyColor.white),),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('In my wallet',
                                  style: GoogleFonts.sora(
                                      color: SurfyColor.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              FutureBuilder<Pair<String, String>>(
                                future: _getVisibleTokenBalance(selectedToken.value),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final crypto = snapshot.data?.first;
                                    final fiat = snapshot.data?.second;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("\$$fiat", style: GoogleFonts.sora(
                                            color: SurfyColor.white, fontSize: 16)),
                                        const SizedBox(height: 5),
                                        Text("$crypto", style: GoogleFonts.sora(
                                            color: SurfyColor.white, fontSize: 16))
                                      ],
                                    );
                                  }

                                  return Center(
                                    child: CircularProgressIndicator(color: SurfyColor.blue),
                                  );
                                }),
                            ],
                          )),
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        color: SurfyColor.darkerGrey,
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
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
                            Text('0 BTC',
                                style: GoogleFonts.sora(
                                    color: SurfyColor.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40)),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: SurfyColor.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: InkWell(
                                onTap: () {
                                  isTokenSelecting.value = true;
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          child: Image.asset(
                                            "assets/images/tokens/ic_ethereum.png",
                                            width: 40,
                                            height: 40,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Obx(() => Text(
                                                    tokens[selectedToken.value]
                                                            ?.name ??
                                                        "???",
                                                    style: GoogleFonts.sora(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                              SizedBox(height: 2),
                                              Obx(() => Text(
                                                  '${userTokenBalance.value} ${tokens[selectedToken.value]?.symbol}',
                                                  style: GoogleFonts.sora(
                                                      fontSize: 16))),
                                              SizedBox(height: 2),
                                              Obx(() => Text(
                                                  '\$${userTokenFiatBalance.value}',
                                                  style: GoogleFonts.sora(
                                                      fontSize: 16)))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: SurfyColor.grey,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      child: InkWell(
                                          onTap: () {},
                                          child: Center(
                                              child: Text(
                                            'change',
                                            style: GoogleFonts.sora(
                                                fontSize: 18,
                                                color: SurfyColor.white),
                                          ))),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
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
                  Obx(() {
                    if (isTokenSelecting.value == true) {
                      return Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: SurfyColor.white.withOpacity(0.2)),
                              ),
                              Center(
                                  child: Container(
                                height: 400,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: SurfyColor.black),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.only(
                                            top: 10, bottom: 20),
                                        child: Text(
                                          "What coin will you pay with?",
                                          style: GoogleFonts.sora(
                                              color: SurfyColor.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        )),
                                    Container(
                                        height: 300,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: Token.values.map((token) {
                                              return FutureBuilder<
                                                  Pair<String, String>>(
                                                future: _getVisibleTokenBalance(
                                                    token),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    final crypto =
                                                        snapshot.data?.first;
                                                    final fiat =
                                                        snapshot.data?.second;
                                                    return InkWell(
                                                        onTap: () {
                                                          print(
                                                              'select: $token');
                                                          selectedToken.value =
                                                              token;
                                                        },
                                                        child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        5),
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 20,
                                                                vertical: 10),
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    SurfyColor
                                                                        .greyBg,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16)),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Image.asset(
                                                                      tokens[token]
                                                                              ?.iconAsset ??
                                                                          "",
                                                                      width: 40,
                                                                      height:
                                                                          40,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                            tokens[token]?.name ??
                                                                                "",
                                                                            style: GoogleFonts.sora(
                                                                                fontSize: 18,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: SurfyColor.white)),
                                                                        Text(
                                                                            "\$$fiat",
                                                                            style:
                                                                                GoogleFonts.sora(fontSize: 14, color: SurfyColor.white)),
                                                                        Text(
                                                                            "$crypto",
                                                                            style:
                                                                                GoogleFonts.sora(fontSize: 14, color: SurfyColor.white)),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                                Obx(() {
                                                                  return selectedToken
                                                                              .value ==
                                                                          token
                                                                      ? Container(
                                                                          width:
                                                                              28,
                                                                          height:
                                                                              28,
                                                                          decoration: BoxDecoration(
                                                                              color: SurfyColor.blue,
                                                                              borderRadius: BorderRadius.circular(100)),
                                                                          child: Center(child: Icon(Icons.check, color: SurfyColor.white)))
                                                                      : Container(
                                                                          width:
                                                                              28,
                                                                          height:
                                                                              28,
                                                                          decoration: BoxDecoration(
                                                                              color: Color(0xFF2C2C2C),
                                                                              borderRadius: BorderRadius.circular(100)),
                                                                        );
                                                                }),
                                                              ],
                                                            )));
                                                  }

                                                  return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                              color: SurfyColor
                                                                  .blue));
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        )),
                                  ],
                                ),
                              ))
                            ],
                          ));
                    }

                    return Container();
                  })
                ],
              )),
        ));
  }
}
