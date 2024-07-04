

import 'package:flutter_test/flutter_test.dart';
import 'package:surfy_mobile_app/entity/transaction/transaction.dart';
import 'package:surfy_mobile_app/service/transaction/transaction_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

void main() {
  test('test service', () async {
    final service = TransactionService();
    final result = await service.getTransactionsByUserId('test_sender');
    print(result);

    // await service.postTransaction(Transaction(
    //     id: 'test-id',
    //     transactionHash: 'test-tx-hash',
    //     sender: 'sender',
    //     receiver: 'receiver',
    //     amount: BigInt.from(500),
    //     senderAddress: '0x12345',
    //     receiverAddress: '0x54321',
    //     token: Token.ETHEREUM,
    //     blockchain: Blockchain.ETHEREUM,
    //     createdAt: DateTime.now(),
    //     storeId: null,
    //     fiat: 1000,
    //     currencyType: CurrencyType.krw)
    // );
  });
}