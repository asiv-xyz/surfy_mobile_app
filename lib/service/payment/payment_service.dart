import 'package:dartx/dartx.dart';
import 'package:surfy_mobile_app/cache/payment/payment_cache.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class PaymentService {
  PaymentService({required this.cache});

  final PaymentCache cache;

  Future<Pair<Token, Blockchain>?> getRecentPaymentMethod() async {
    return await cache.get();
  }

  Future<void> setRecentPaymentMethod(Token token, Blockchain blockchain) async {
    await cache.set(token, blockchain);
  }
}