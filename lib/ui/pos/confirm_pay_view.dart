import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/merchant/get_merchants.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/ui/pos/select_payment_token_page.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class ConfirmPayPageProps {
  ConfirmPayPageProps({required this.storeId, required this.receiveCurrency, required this.wantToReceiveAmount});

  final CurrencyType receiveCurrency;
  final double wantToReceiveAmount;
  final String storeId;
}

class ConfirmPayPage extends StatefulWidget {
  const ConfirmPayPage({super.key, required this.storeId, required this.receiveCurrency, required this.wantToReceiveAmount});

  final String storeId;
  final CurrencyType receiveCurrency;
  final double wantToReceiveAmount;

  @override
  State<StatefulWidget> createState() {
    return _ConfirmPayPageState();
  }
}

class _ConfirmPayPageState extends State<ConfirmPayPage> {

  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final GetMerchants _getPlacesUseCase = Get.find();

  final Rx<List<UserTokenData>> _balanceData = Rx([]);
  final Rx<Map<Token, TokenPrice>> _tokenPriceData = Rx({});
  final RxBool _isLoading = false.obs;
  final RxDouble _totalFiatBalance = 0.0.obs;
  final RxDouble _totalFiatBalanceByEachToken = 0.0.obs;
  final RxDouble _totalCryptoBalanceByEachToken = 0.0.obs;

  final Rx<Token> _selectedToken = Rx(Token.ETHEREUM);
  final Rx<Blockchain> _selectedBlockchain = Rx(Blockchain.ETHEREUM);

  final Rx<Merchant?> _placeData = Rx(null);

  Future<void> loadData() async {
    final balanceData = await _getWalletBalancesUseCase.getMultipleTokenDataList(Token.values);
    final tokenPriceData = await _getTokenPriceUseCase.getTokenPrice(Token.values, widget.receiveCurrency);
    _balanceData.value = balanceData;
    _tokenPriceData.value = tokenPriceData;
    balanceData.where((b) => b.amount > BigInt.zero).toList().forEach((tokenData) {
      final tokenPrice = _tokenPriceData.value[tokenData.token];
      final balanceByNetwork = _balanceData.value.where((item) => item.blockchain == tokenData.blockchain).first;
      final crypto = balanceByNetwork.amount / BigInt.from(pow(10, balanceByNetwork.decimal));
      final fiat = (tokenPrice?.price ?? 0.0) * crypto;
      _totalFiatBalance.value += fiat;
    });
    final storeData = await _getPlacesUseCase.getSingle(widget.storeId);
    _placeData.value = storeData;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading.value = true;
      loadData().then((_) {
        // TODO : example
        onChangeToken(Token.ETHEREUM, Blockchain.ETHEREUM_SEPOLIA);
        _isLoading.value = false;
      });
    });
  }

  void onChangeToken(Token token, Blockchain network) {
    final tokenPrice = _tokenPriceData.value[token];
    final balanceByNetwork = _balanceData.value.where((item) => item.blockchain == network).first;
    final crypto = balanceByNetwork.amount / BigInt.from(pow(10, balanceByNetwork.decimal));
    final fiat = (tokenPrice?.price ?? 0.0) * crypto;
    _totalFiatBalanceByEachToken.value = fiat.toDouble();
    _totalCryptoBalanceByEachToken.value = crypto.toDouble();
  }

  bool _canPay() {
    print('want: ${widget.wantToReceiveAmount}, fiat: ${_totalFiatBalanceByEachToken.value}, can: ${widget.wantToReceiveAmount < _totalFiatBalanceByEachToken.value}');
    return widget.wantToReceiveAmount < _totalFiatBalanceByEachToken.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: SurfyColor.white),
        backgroundColor: SurfyColor.black,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: SurfyColor.black,
        child: Obx(() {
          if (_isLoading.isTrue) {
            return const Center(
              child: CircularProgressIndicator(color: SurfyColor.blue)
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text('You pay to ${_placeData.value?.storeName}', style: GoogleFonts.sora(fontSize: 16, color: SurfyColor.white),),),
                            const SizedBox(height: 5,),
                            Text('${widget.wantToReceiveAmount} ${widget.receiveCurrency.name.toUpperCase()}', style: GoogleFonts.sora(fontSize: 48, color: SurfyColor.blue),),
                            Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('My total balance', style: GoogleFonts.sora(fontSize: 16, color: SurfyColor.white),),
                                    const SizedBox(height: 5,),
                                    Obx(() => Text(formatFiat(_totalFiatBalance.value, widget.receiveCurrency), style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: SurfyColor.white),),)
                                  ],
                                )
                            )
                          ],
                        )
                    ),
                    const Divider(color: SurfyColor.darkGrey),
                    Obx(() => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: SurfyColor.greyBg,
                      ),
                      child: Material(
                          color: SurfyColor.greyBg,
                          borderRadius: BorderRadius.circular(30),
                          child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                if (mounted) {
                                  final props = SelectPaymentTokenPageProps(
                                      onSelect: (Token token, Blockchain blockchain) {
                                        _selectedToken.value = token;
                                        _selectedBlockchain.value = blockchain;
                                        onChangeToken(_selectedToken.value, _selectedBlockchain.value);
                                      }, receiveCurrency: widget.receiveCurrency,
                                      wantToReceiveAmount: widget.wantToReceiveAmount);
                                  context.push("/pos/select", extra: props);
                                }
                              },
                              child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          TokenIconWithNetwork(blockchain: _selectedBlockchain.value, token: _selectedToken.value, width: 40, height: 40),
                                          const SizedBox(width: 10),
                                          Text(tokens[_selectedToken.value]?.name ?? "", style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 18),)
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(formatFiat(_totalFiatBalanceByEachToken.value, widget.receiveCurrency), style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 14)),
                                              Text(formatCrypto(_selectedToken.value, _totalCryptoBalanceByEachToken.value), style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 14)),
                                            ],
                                          ),
                                          const SizedBox(width: 10,),
                                          Icon(Icons.navigate_next, color: SurfyColor.white,)
                                        ],
                                      )
                                    ],
                                  )
                              )
                          )
                      ),
                    )),
                    const Divider(color: SurfyColor.darkGrey),
                    Obx(() {
                      if (!_canPay()) {
                        return Container(
                          child: Text('Insufficient balance, check your wallet!', style: GoogleFonts.sora(color: SurfyColor.deepRed),)
                        );
                      }

                      return Container();
                    })
                  ],
                ),
                Obx(() => MaterialButton(
                  height: 60,
                  color: SurfyColor.blue,
                  disabledColor: SurfyColor.lightGrey,
                  onPressed: _canPay() ? () {} : null,
                  child: Center(
                    child: Text('Pay!', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),),
                  )
                ))
                // Material(
                //   color: SurfyColor.blue,
                //   child: InkWell(
                //     onTap: () {
                //
                //     },
                //     child: Container(
                //         width: double.infinity,
                //         height: 60,
                //         child: Center(
                //           child: Text('Pay!', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),),
                //         )
                //     )
                //   )
                // )
              ],
            );
          }
        })
      ),
    );
  }
}