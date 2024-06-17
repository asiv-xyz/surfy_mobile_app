import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

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
  final _secp256k1Address = "".obs;
  final _ed25519Address = "".obs;
  final getWalletAddress = GetWalletAddress();
  final getBalances = GetWalletBalances();
  final GetTokenPrice getTokenPrice = Get.find();
  final _totalTokenAmount = 0.0.obs;
  final _totalCurrencyAmount = 0.0.obs;

  Future<List<Widget>> _buildBalanceWidgets() async {
    final tokenPrice = await getTokenPrice.getTokenPrice([widget.token], 'usd');
    _totalCurrencyAmount.value = 0.0;
    _totalTokenAmount.value = 0.0;

    return widget.data.map((balance) {
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
                  // Image.asset(tokens[balance.token]?.iconAsset ?? "", width: 40, height: 40),
                  TokenIconWithNetwork(blockchain: balance.blockchain, token: balance.token, width: 40, height: 40),
                  const SizedBox(width: 10),
                  Text(tokens[balance.token]?.name ?? "", style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                  // TODO : for debugging
                  Text("(${balance.blockchain.name})", style: GoogleFonts.sora(color: Colors.white, fontSize: 10))
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("\$${currency.toStringAsFixed(2)}", style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text("${balance.toUiString()} ${tokens[balance.token]?.symbol ?? ''}", style: GoogleFonts.sora(color: const Color(0xFFBAC2C7), fontSize: 14, fontWeight: FontWeight.w500),)
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
    final tokenData = tokens[widget.token];
    if (tokenData != null) {
      tokenData.supportedBlockchain.toList().forEach((blockchain) {
        final blockchainData = blockchains[blockchain];
        if (blockchainData?.curve == EllipticCurve.SECP256K1) {
          Web3AuthFlutter.getPrivKey().then((key) async => _secp256k1Address.value = await getWalletAddress.getAddress(blockchain, key));
        } else {
          Web3AuthFlutter.getPrivKey().then((key) async => _ed25519Address.value = await getWalletAddress.getAddress(blockchain, key));
        }
      });
    }
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
        title: Text(tokenData.name, style: GoogleFonts.sora(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
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
                    child: Obx(() => Text("\$${_totalCurrencyAmount.toStringAsFixed(2)}", style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),))
                  ),
                  ...state.data ?? []
                ],
              );
            }
            return Text('loading...');
          },
        )
      ),
    );
  }
}