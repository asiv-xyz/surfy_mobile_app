import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_chain/tron/src/keys/private_key.dart';
import 'package:solana/solana.dart';
import 'package:surfy_mobile_app/service/wallet/balance_handlers/balance_handlers.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:web3dart/crypto.dart';
import 'package:xrpl_dart/xrpl_dart.dart';


void main() {
  test('xrpl key generation test', () async {
    // final solanaAddressHandler = SolanaAddressHandler();
    // final t = await solanaAddressHandler.getAddress('014ffc87a3c815a6775dd1a7b47e749d65de85c4f2a337bb5bef9904d34d993dc0a33454154f58948023bea99d1e483d81fcd2f5b7badc5227dbdaf781556710');
    // print(t);
    // final hex = hexToBytes('014ffc87a3c815a6775dd1a7b47e749d65de85c4f2a337bb5bef9904d34d993dc0a33454154f58948023bea99d1e483d81fcd2f5b7badc5227dbdaf781556710');
    // final keyPair = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: hex.take(32).toList());
    // print(hex.take(32));

    // var wallet = XRPPrivateKey.fromHex('00ED539C0F6409A847F31FBBAC93F758454ACC070D5A74F62120E7E162F4729520');
    // print(wallet.getPublic().toAddress());

    //2d6360c5635173ded9fb10873072cbb0d508e90fa72e0957f3e432294c9dc37c
    final seed = BytesUtils.fromHexString("2d6360c5635173ded9fb10873072cbb0d508e90fa72e0957f3e432294c9dc37c0e2c57b64c8ed996d9e02aa23825973ef2496ad225a6f7f1f1e7b2bb5f0175d1");
    final bip44 = Bip44.fromSeed(seed, Bip44Coins.tron);
    final pk = TronPrivateKey.fromBytes(bip44.privateKey.raw);
    print(pk.toHex());
  });
}
// 5243753334559
// 5243753.334772 XRP