import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/balance_view.dart';
import 'package:surfy_mobile_app/ui/components/current_price.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class WalletDetailPage extends StatefulWidget {
  const WalletDetailPage({super.key, required this.token, required this.data});

  final Token token;
  final List<UserTokenData> data;

  @override
  State<StatefulWidget> createState() {
    return _WalletDetailPageState();
  }
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  final GetWalletAddress getWalletAddressUseCase = Get.find();
  final GetTokenPrice getTokenPriceUseCase = Get.find();
  final GetWalletBalances getWalletBalancesUseCase = Get.find();
  final SettingsPreference preference = Get.find();
  final _totalTokenAmount = 0.0.obs;
  final _totalCurrencyAmount = 0.0.obs;
  final _onlyHeldShow = true.obs;

  String shortAddress(String address) {
    return "${address.substring(0, 8)}...${address.substring(address.length - 8, address.length - 1)}";
  }

  Widget _buildItem(Blockchain blockchain, Token token, String address, String fiat, String crypto) {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                TokenIconWithNetwork(blockchain: blockchain, token: token, width: 40, height: 40),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(tokens[token]?.name ?? "", style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 16),),
                        // TODO : for debugging
                        Text("(${blockchain.name})", style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 10))
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(shortAddress(address), style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 14)),
                        const SizedBox(width: 4),
                        SizedBox(
                            width: 14,
                            height: 14,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 14,
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: address));
                              },
                              icon: const Icon(Icons.copy_outlined, color: SurfyColor.lightGrey),
                            )
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
            FutureBuilder<Pair<String, String>>(
              future: getWalletBalancesUseCase.getUiTokenBalanceWithNetwork(token, blockchain, preference.userCurrencyType.value),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("${snapshot.data?.second}", style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      Text("${snapshot.data?.first}", style: GoogleFonts.sora(color: const Color(0xFFBAC2C7), fontSize: 14, fontWeight: FontWeight.w500),)
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                          color: SurfyColor.lightGrey,
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                    const SizedBox(height: 6,),
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                          color: SurfyColor.lightGrey,
                          borderRadius: BorderRadius.circular(10)
                      ),
                    )
                  ],
                );
              })
          ],
        )
    );
  }

  Widget _buildEachItem() {
    var cloneData = [...widget.data];
    cloneData.sort((a, b) {
      if (a.amount < b.amount) {
        return 1;
      } else if (a.amount == b.amount) {
        return 0;
      } else {
        return -1;
      }
    });

    if (_onlyHeldShow.isTrue) {
      cloneData = cloneData.where((item) => item.amount > BigInt.zero).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cloneData.map((item) {
        return FutureBuilder(
          future: getWalletBalancesUseCase.getUiTokenBalanceWithNetwork(item.token, item.blockchain, preference.userCurrencyType.value),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return InkWell(
                onTap: () {
                  context.push('/send', extra: Pair<Token, Blockchain>(item.token, item.blockchain));
                },
                child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            TokenIconWithNetwork(blockchain: item.blockchain, token: item.token, width: 40, height: 40),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(tokens[item.token]?.name ?? "", style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 16),),
                                    Text("(${item.blockchain.name})", style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 8)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(shortAddress(item.address), style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 14)),
                                    const SizedBox(width: 4),
                                    Container(
                                        width: 14,
                                        height: 14,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: 14,
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: item.address));
                                          },
                                          icon: Icon(Icons.copy_outlined, color: SurfyColor.lightGrey),
                                        )
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("${snapshot.data?.second}", style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                            Text("${snapshot.data?.first}", style: GoogleFonts.sora(color: const Color(0xFFBAC2C7), fontSize: 14, fontWeight: FontWeight.w500),)
                          ],
                        )
                      ],
                    )
                )
              );
            }

            return Container();
          });
      }).toList(),
    );

  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tokenData = tokens[widget.token];
    if (tokenData == null) {
      return Container(
        child: Text('404'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(tokenData.iconAsset, width: 40, height: 40),
            const SizedBox(width: 10),
            Text(tokenData.name, style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 18, fontWeight: FontWeight.bold),)
          ],
        ),
        backgroundColor: SurfyColor.black,
        iconTheme: const IconThemeData(color: SurfyColor.white),
      ),
      backgroundColor: SurfyColor.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: getWalletBalancesUseCase.getUiTokenBalance(widget.token, preference.userCurrencyType.value),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: BalanceView(fiatBalance: snapshot.data?.second ?? "", cryptoBalance: snapshot.data?.first ?? "")
                  );
                }

                return Container();
              }),
            FutureBuilder<TokenPrice?>(
              future: getTokenPriceUseCase.getSingleTokenPrice(widget.token, preference.userCurrencyType.value),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final price = snapshot.data;
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: CurrentPrice(
                        mainAxisAlignment: MainAxisAlignment.end,
                        tokenName: tokens[price?.token]?.name ?? "",
                        price: price?.price ?? 0.0,
                        currency: preference.userCurrencyType.value),
                  );
                }

                return Container();
              },
            ),
            Container(
              width: double.infinity,
              height: 6,
              margin: const EdgeInsets.symmetric(vertical: 10),
              color: SurfyColor.darkGrey,
            ),
            Row(
              children: [
                Obx(() => Checkbox(value: _onlyHeldShow.value, onChanged: (value) {
                  _onlyHeldShow.value = value ?? false;
                }),),
                InkWell(
                    onTap: () {
                      _onlyHeldShow.value = !_onlyHeldShow.value;
                    },
                    child: Text('Only coins held', style: GoogleFonts.sora(fontSize: 14, color: SurfyColor.white),)
                )
              ],
            ),
            Obx(() => _buildEachItem()),
          ],
        )
      ),
    );
  }
}