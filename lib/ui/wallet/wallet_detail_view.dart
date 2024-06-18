import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
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
  final GetWalletAddress getWalletAddress = Get.find();
  final GetTokenPrice getTokenPrice = Get.find();
  final _totalTokenAmount = 0.0.obs;
  final _totalCurrencyAmount = 0.0.obs;

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
                        Text(shortAddress(address), style: GoogleFonts.sora(color: SurfyColor.grey, fontSize: 14)),
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
                              icon: const Icon(Icons.copy_outlined, color: SurfyColor.grey),
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
                Text("\$$fiat", style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                Text("$crypto ${tokens[token]?.symbol ?? '???'}", style: GoogleFonts.sora(color: const Color(0xFFBAC2C7), fontSize: 14, fontWeight: FontWeight.w500),)
              ],
            )
          ],
        )
    );
  }

  List<Widget> _buildUserDontHaveWidgets() {
    final copy = [...widget.data];
    final zero = copy.where((balance) => balance.amount == BigInt.zero);
    if (zero.isEmpty) {
      return [
        Container(
            margin: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
                child: Text('No Item', style: GoogleFonts.sora(color: Colors.white),)
            )
        )
      ];
    }
    return zero.map((balance) {
      return _buildItem(balance.blockchain, balance.token, balance.address, "0", "0");
    }).toList();
  }

  Future<List<Widget>> _buildBalanceWidgets() async {
    final tokenPrice = await getTokenPrice.getTokenPrice([widget.token], 'usd');
    _totalCurrencyAmount.value = 0.0;
    _totalTokenAmount.value = 0.0;

    final copy = [...widget.data];

    copy.sort((a, b) {
      if (a.amount < b.amount) {
        return 1;
      } else if (a.amount == b.amount) {
        return 0;
      } else {
        return -1;
      }
    });
    final nonzero = copy.where((balance) => balance.amount > BigInt.zero);
    if (nonzero.isEmpty) {
      return [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 30),
          child: Center(
            child: Text('No Item', style: GoogleFonts.sora(color: Colors.white),)
          )
        )
      ];
    }

    return nonzero.map((balance) {
      _totalTokenAmount.value = _totalTokenAmount.value + balance.toVisibleAmount();
      var currency = (tokenPrice[widget.token]?.price ?? 0) * balance.toVisibleAmount().toDouble();
      _totalCurrencyAmount.value = _totalCurrencyAmount.value + currency;
      return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  TokenIconWithNetwork(blockchain: balance.blockchain, token: balance.token, width: 40, height: 40),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(tokens[balance.token]?.name ?? "", style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 16),),
                          // TODO : for debugging
                          Text("(${balance.blockchain.name})", style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 10))
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(shortAddress(balance.address), style: GoogleFonts.sora(color: SurfyColor.grey, fontSize: 14)),
                          const SizedBox(width: 4),
                          Container(
                            width: 14,
                            height: 14,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 14,
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: balance.address));
                              },
                              icon: Icon(Icons.copy_outlined, color: SurfyColor.grey),
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
                  Text("\$${currency.toStringAsFixed(2)}", style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text("${balance.toUiString()} ${tokens[balance.token]?.symbol ?? ''}", style: GoogleFonts.sora(color: SurfyColor.grey, fontSize: 14, fontWeight: FontWeight.w500),)
                ],
              )
            ],
          )
      );
    }).toList();
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
        child: FutureBuilder<List<Widget>>(
          future: _buildBalanceWidgets(),
          builder: (context, state) {
            if (state.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text("\$${_totalCurrencyAmount.toStringAsFixed(2)}", style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 24),)),
                        Obx(() => Text("${_totalTokenAmount.toStringAsFixed(2)} ${tokenData?.symbol}", style: GoogleFonts.sora(color: SurfyColor.grey, fontSize: 15)))
                      ],
                    )
                  ),
                  Container(
                    width: double.infinity,
                    height: 6,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    color: SurfyColor.darkerGrey,
                  ),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Balances', style: GoogleFonts.sora(color: SurfyColor.white),)
                  ),
                  ...state.data ?? [],
                  Container(
                      width: double.infinity,
                      height: 6,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      color: const Color(0xFF222222)
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Zero balances', style: GoogleFonts.sora(color: Colors.white),)
                  ),
                  ..._buildUserDontHaveWidgets()
                ],
              );
            }
            return Container(
              child: const Center(child: CircularProgressIndicator(color: SurfyColor.blue)),
            );
          },
        )
      ),
    );
  }
}