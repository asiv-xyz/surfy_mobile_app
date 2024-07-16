import 'package:dio/dio.dart';
import 'package:surfy_mobile_app/entity/transaction/transaction.dart';
import 'package:surfy_mobile_app/utils/dio_utils.dart';

class TransactionService {

  Future<List<Transaction>> getTransactionsByUserId(String id) async {
    final result = await dioObject.get('https://wgs0z4xv93.execute-api.ap-northeast-2.amazonaws.com/Prod/transaction/id/$id',
        options: Options(responseType: ResponseType.json));
    return result.data?.map<Transaction>((item) => Transaction.fromJson(item)).toList();
  }

  Future<List<Transaction>> getTransactionByWalletAddress(String address) async {
    final result = await dioObject.get('https://wgs0z4xv93.execute-api.ap-northeast-2.amazonaws.com/Prod/transaction/address/$address',
        options: Options(responseType: ResponseType.json));
    return result.data?.map<Transaction>((item) => Transaction.fromJsonByReceiver(item)).toList();
  }

  Future<void> postTransaction(Transaction tx) async {
    final result = await dioObject.post('https://wgs0z4xv93.execute-api.ap-northeast-2.amazonaws.com/Prod/transaction',
        data: tx.toJson(),
        options: Options(responseType: ResponseType.json));
  }
}