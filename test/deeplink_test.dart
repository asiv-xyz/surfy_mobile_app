import 'package:flutter_test/flutter_test.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/platform/deeplink.dart';

void main() {
  test('', () {
    var case1 = DeepLink.createDeepLink(Blockchain.ethereum, Token.ETHEREUM, "0x123456789");
    print(case1);

    case1 = DeepLink.createDeepLink(Blockchain.base, Token.ETHEREUM, "0x123456789");
    print(case1);

    case1 = DeepLink.createDeepLink(Blockchain.base, Token.ETHEREUM, "0x123456789", amount: BigInt.from(987654321));
    print(case1);

    case1 = DeepLink.createDeepLink(Blockchain.base, Token.USDC, "0x123456789", amount: BigInt.from(1000000));
    print(case1);

    case1 = DeepLink.createDeepLink(Blockchain.solana, Token.USDC, "0x123456789", amount: BigInt.from(1000000));
    print(case1);

    case1 = DeepLink.createDeepLink(Blockchain.solana, Token.SOLANA, "0x123456789", amount: BigInt.from(1200000));
    print(case1);

    case1 = DeepLink.createDeepLink(Blockchain.solana, Token.SOLANA, "0x123456789");
    print(case1);

    case1 = DeepLink.createDeepLink(Blockchain.xrpl, Token.XRP, "0x123456789");
    print(case1);

    case1 = DeepLink.createDeepLink(Blockchain.xrpl, Token.XRP, "0x123456789", amount: BigInt.from(1000000));
    print(case1);
  });
}