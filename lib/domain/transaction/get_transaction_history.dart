import 'package:get/get.dart';
import 'package:surfy_mobile_app/entity/transaction/transaction.dart';
import 'package:surfy_mobile_app/service/transaction/transaction_service.dart';

class GetTransactionHistory {

  final TransactionService _service = Get.find();

  Future<List<Transaction>> get(String userId) async {
    return await _service.getTransactionsByUserId(userId);
  }
}