

import 'package:flutter_test/flutter_test.dart';
import 'package:surfy_mobile_app/domain/wallet/handlers/address_handlers.dart';

void main() {
  test('solana key generation test', () async {
    final solanaAddressHandler = SolanaAddressHandler();
    final t = await solanaAddressHandler.getAddress('014ffc87a3c815a6775dd1a7b47e749d65de85c4f2a337bb5bef9904d34d993dc0a33454154f58948023bea99d1e483d81fcd2f5b7badc5227dbdaf781556710');
    print(t);
  });
}