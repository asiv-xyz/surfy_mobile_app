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

void main() {

  test('doge test', () async {
    final blockchainData = blockchains[Blockchain.solana];
    final client = SolanaClient(rpcUrl: Uri.parse(blockchainData?.rpc ?? ""), websocketUrl: Uri.parse(blockchainData?.websocket ?? ""));

    // 5sJqTZUyby79qehzah26GjLJMRg1jYQjG2c9nHX2kW1p9WhR8U4Zg4NxAkW28rMmtkEFXj1wV4H7W4Ltn9M4QPrD
    final tx = await client.findSolanaPayTransaction(
      reference: Ed25519HDPublicKey.fromBase58("3gCcy66kYE9AdcFT7H42HSduozdiqAfxHMNLegVB8uKm")
    );

    print(tx);
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
  // test('set balance', () async {
  //   final repository = WalletBalancesRepository(walletService: WalletService());
  //   const ed25519 = "2d6360c5635173ded9fb10873072cbb0d508e90fa72e0957f3e432294c9dc37c0e2c57b64c8ed996d9e02aa23825973ef2496ad225a6f7f1f1e7b2bb5f0175d1";
  //   const secp256k1 = "2d6360c5635173ded9fb10873072cbb0d508e90fa72e0957f3e432294c9dc37c";
  //   final result = await repository.getUserWalletBalances([Token.ETHEREUM, Token.USDC, Token.SOLANA, Token.USDT], secp256k1, ed25519);
  //   print(result);
  // });
}