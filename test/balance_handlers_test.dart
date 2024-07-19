import 'dart:isolate';
import 'dart:math';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:solana/solana_pay.dart';
import 'package:surfy_mobile_app/repository/wallet/wallet_balances_repository.dart';
import 'package:surfy_mobile_app/service/wallet/balance_handlers/balance_handlers.dart';
import 'package:surfy_mobile_app/service/wallet/wallet_service.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/utils/bitcoin_explorer_service.dart';
import 'package:surfy_mobile_app/utils/electrum_ssl_service.dart';
import 'package:surfy_mobile_app/utils/xrpl_http_service.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:http/http.dart' as http;

void main() {

  test('doge test', () async {
    final syncRpc = XRPLRpc(RPCHttpService(RPCConst.mainetUri, http.Client()));
    final result = await syncRpc.request(RPCTransactionEntry(txHash: "1E4A84666A07AD091194A20A55A3BCC2598E157E4D98FA58465A60B44256E643"));
    print(result);
  });

  //test('isolate test', () async {
    // final handler = TronBalanceHandler();
    // final balance = await handler.getBalance(Token.TRON, Blockchain.TRON, "TEPSrSYPDSQ7yXpMFPq91Fb1QEWpMkRGfn");
    // print(balance.toVisibleAmount());
    // final handler = TrcBalanceHandler();
    // final result = await handler.getBalance(Token.USDT, Blockchain.TRON, "TTU9Xp33s5wpWkoNvLsC9fTAXqpeafL27W");
    // print(result.toVisibleAmount());


  //});
  // test('ethereum balance handler test', () async {
  //   final handler = EthereumBalanceHandler();
  //   final balance = await handler.getBalance(Token.ETHEREUM, Blockchain.BASE, "0x8341B0d5d2d2672BF092C7c6A8142530e7ed4C73");
  //   print(balance);
  // });
  //
  // test('usdc balance handler test', () async {
  //   const handler = Erc20BalanceHandler(token: Token.USDC);
  //   final balance = await handler.getBalance(Token.USDC, Blockchain.BASE, "0xe2b597796Fd84b27aaDAee73d6b40158035B5ecD");
  //   print(balance);
  //   print(balance.toUiString());
  // });
  //
  // test('usdt balance handler test', () async {
  //   const handler = Erc20BalanceHandler(token: Token.USDT);
  //   final balance = await handler.getBalance(Token.USDT, Blockchain.ETHEREUM, "0xF977814e90dA44bFA03b6295A0616a897441aceC");
  //   print(balance);
  //   print(balance.toUiString());
  // });
  //
  // test('usdt(solana) balance handler test', () async {
  //   const handler = SplBalanceHandler(token: Token.USDT);
  //   final balance = await handler.getBalance(
  //       Token.USDT,
  //       Blockchain.SOLANA,
  //       "u6PJ8DtQuPFnfmwHbGFULQ4u4EgjDiyYKjVEsynXq2w"
  //   );
  //   print(balance);
  //   print(balance.toUiString());
  // });
  //
}