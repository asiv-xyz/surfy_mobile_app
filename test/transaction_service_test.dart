

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
  });
}