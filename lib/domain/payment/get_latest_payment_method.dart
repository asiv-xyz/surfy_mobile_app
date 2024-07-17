import 'package:dartx/dartx.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/service/payment/payment_service.dart';

class GetLatestPaymentMethod {
  GetLatestPaymentMethod({required this.service});

  final PaymentService service;

  Future<Pair<Token, Blockchain>?> get() async {
    return await service.getRecentPaymentMethod();
  }

  Future<void> set(Token token, Blockchain blockchain) async {
    await service.setRecentPaymentMethod(token, blockchain);
  }
}