import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/merchant/get_merchants.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/ui/pos/payment_complete_view.dart';
import 'package:surfy_mobile_app/ui/pos/select_payment_token_page.dart';
import 'package:surfy_mobile_app/ui/wallet/send_confirm_view.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:vibration/vibration.dart';

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

  final GetWalletAddress _getWalletAddressUseCase = Get.find();
  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final GetMerchants _getPlacesUseCase = Get.find();
  final SendP2pToken _sendP2pTokenUseCase = Get.find();

  final Rx<List<UserTokenData>> _balanceData = Rx([]);
  final Rx<Map<Token, TokenPrice>> _tokenPriceData = Rx({});
  final RxBool _isLoading = false.obs;
  final RxBool _isSendProcessing = false.obs;

  final RxDouble _totalFiatBalance = 0.0.obs;
  final RxDouble _totalFiatBalanceByEachToken = 0.0.obs;
  final RxDouble _totalCryptoBalanceByEachToken = 0.0.obs;

  final Rx<Token> _selectedToken = Rx(Token.ETHEREUM);
  final Rx<Blockchain> _selectedBlockchain = Rx(Blockchain.ETHEREUM);
  final Rx<BigInt> _gas = BigInt.zero.obs;
  final RxString _receiverAddress = "".obs;
  final RxDouble _payToCrypto = 0.0.obs;

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

    _payToCrypto.value = widget.wantToReceiveAmount / (tokenPrice?.price ?? 1);

    final receiver = _placeData.value?.wallets?.where((w) => w.walletCategory == blockchains[_selectedBlockchain.value]?.category).first;
    _sendP2pTokenUseCase.estimateGas(_selectedToken.value,
        _selectedBlockchain.value,
        receiver?.walletAddress ?? "",
        _payToCrypto.value).then((r) {
      _gas.value = r;
    });
  }

  bool _canPay() {
    return widget.wantToReceiveAmount < _totalFiatBalanceByEachToken.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Obx(() {
          if (_isLoading.isTrue) {
            return const Center(
              child: CircularProgressIndicator(color: SurfyColor.blue)
            );
          } else {
            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => Text('You pay to ${_placeData.value?.storeName}', style: Theme.of(context).textTheme.displayMedium)),
                                const SizedBox(height: 5,),
                                Text('${widget.wantToReceiveAmount} ${widget.receiveCurrency.name.toUpperCase()}', style: GoogleFonts.sora(fontSize: 48, color: SurfyColor.blue),),
                                // Container(
                                //     width: double.infinity,
                                //     margin: const EdgeInsets.only(top: 20),
                                //     child: Column(
                                //       crossAxisAlignment: CrossAxisAlignment.end,
                                //       children: [
                                //         Text('My total balance', style: Theme.of(context).textTheme.displaySmall),
                                //         const SizedBox(height: 5,),
                                //         Obx(() => Text(formatFiat(_totalFiatBalance.value, widget.receiveCurrency), style: Theme.of(context).textTheme.displayMedium))
                                //       ],
                                //     )
                                // )
                              ],
                            )
                        ),
                        Divider(color: Theme.of(context).dividerColor),
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
                        Divider(color: Theme.of(context).dividerColor),
                        Obx(() {
                          final gasData = UserTokenData(
                              blockchain: _selectedBlockchain.value,
                              token: blockchains[_selectedBlockchain.value]?.feeCoin ?? Token.ETHEREUM,
                              amount: _gas.value,
                              decimal: tokens[blockchains[_selectedBlockchain.value]?.feeCoin]?.decimal ?? 1,
                              address: "");
                          final gasFiat = gasData.toVisibleAmount() * (_tokenPriceData.value[_selectedToken]?.price ?? 1);
                          print('gas: $gasData');
                          print('gasFiat: $gasFiat');
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: SurfyColor.greyBg,
                              borderRadius: BorderRadius.circular(15)
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Pay', style: Theme.of(context).textTheme.labelLarge),
                                    Column(
                                      children: [
                                        Text(formatFiat(widget.wantToReceiveAmount, widget.receiveCurrency), style: Theme.of(context).textTheme.bodySmall),
                                        Text(formatCrypto(_selectedToken.value, _payToCrypto.value), style: Theme.of(context).textTheme.bodySmall)
                                      ],
                                    )
                                  ],
                                ),
                                const Divider(color: SurfyColor.black),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Fee', style: Theme.of(context).textTheme.labelLarge),
                                    Column(
                                      children: [
                                        Text(formatFiat(gasFiat, widget.receiveCurrency), style: Theme.of(context).textTheme.bodySmall),
                                        Text(formatCrypto(blockchains[_selectedBlockchain.value]?.feeCoin, gasData.toVisibleAmount()), style: Theme.of(context).textTheme.bodySmall)
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        Obx(() {
                          if (!_canPay()) {
                            return Container(
                                child: Text('Insufficient balance, check your wallet!', style: GoogleFonts.sora(color: SurfyColor.deepRed, fontSize: 14),)
                            );
                          }

                          return Container();
                        })
                      ],
                    ),
                    Obx(() {
                      if (_isSendProcessing.isFalse) {
                        return SwipeButton.expand(
                            height: 60,
                            onSwipeEnd: () async {
                              Vibration.vibrate(duration: 100);
                              _isSendProcessing.value = true;
                              await Future.delayed(Duration(seconds: 2));
                              print('this merchant: ${_placeData.value}');
                              final receiver = _placeData.value?.wallets?.where((w) => w.walletCategory.toLowerCase() == blockchains[_selectedBlockchain.value]?.category).first;
                              if (receiver == null) {
                                // handle error
                              }
                              final receiverAddress = receiver?.walletAddress;

                              final response = await _sendP2pTokenUseCase.send(
                                  _selectedToken.value,
                                  _selectedBlockchain.value,
                                  receiverAddress ?? "",
                                  _payToCrypto.value);

                              print('receiver address: $receiver');
                              _isSendProcessing.value = false;
                              context.go('/pos/check', extra: PaymentCompletePageProps(
                                  storeName: _placeData.value?.storeName ?? "",
                                  fiatAmount: widget.wantToReceiveAmount,
                                  currencyType: widget.receiveCurrency,
                                  txHash: response.transactionHash,
                                  blockchain: _selectedBlockchain.value,
                              ));
                            },
                            enabled: _canPay(),
                            borderRadius: BorderRadius.circular(0),
                            activeTrackColor: SurfyColor.white,
                            activeThumbColor: SurfyColor.blue,
                            child: Text('Swipe to confirm', style: GoogleFonts.sora(color: SurfyColor.blue, fontWeight: FontWeight.bold, fontSize: 16),)
                        );
                      } else {
                        return Container(
                          width: double.infinity,
                          height: 60,
                          color: SurfyColor.blue,
                          child: Center(
                            child: Text('Sending...', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 16),)
                          )
                        );
                      }
                    }),
                  ],
                ),
                Obx(() {
                  if (_isSendProcessing.isTrue) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: SurfyColor.black.withOpacity(0.4),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(color: SurfyColor.blue),
                      )
                    );
                  }

                  return Container();
                })
              ],
            );
          }
        })
      ),
    );
  }
}