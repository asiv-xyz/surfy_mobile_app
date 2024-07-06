import 'package:get/get.dart';
import 'package:surfy_mobile_app/entity/transaction/transaction.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/service/transaction/transaction_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class SaveTransaction {


  final TransactionService _service = Get.find();

  Future<void> run({
    required TransactionType type,
    required String transactionHash,
    required String senderUserId,
    required String senderAddress,
    required String receiverAddress,
    required BigInt amount,
    required Token token,
    required Blockchain blockchain,
    String? receiverUserId,
    String? storeId,
    double? fiat,
    CurrencyType? currencyType,
    double? tokenPrice,
    CurrencyType? tokenPriceCurrencyType,
  }) async {
    await _service.postTransaction(Transaction(
        id: "",
        type: type,
        transactionHash: transactionHash,
        sender: senderUserId,
        receiver: receiverUserId,
        amount: amount,
        senderAddress: senderAddress,
        receiverAddress: receiverAddress,
        token: token,
        blockchain: blockchain,
        createdAt: DateTime.now(),
        storeId: storeId,
        fiat: fiat,
        currencyType: currencyType,
        tokenPrice: tokenPrice,
        tokenPriceCurrencyType: tokenPriceCurrencyType,
    ));
  }
}