import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/token/token_price_service.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class TokenPriceRepository {
  TokenPriceRepository({required this.service});

  static const updateThreshold = 300000; // 5 minutes
  final TokenPriceService service;
  int _lastUpdated = 0;
  Map<Token, TokenPrice> _data = {};


  Future<Map<Token, TokenPrice>> getTokenPrice(List<Token> tokenList, String currency) async {
    logger.i('getTokenPrice');
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    print('current: $currentTimestamp, lastuptaed: $_lastUpdated');
    if (_lastUpdated == 0 || currentTimestamp - _lastUpdated > updateThreshold) {
      logger.i('Cache expired. Update token price');
      final cgIdentifiers = tokenList
          .map((token) => tokens[token]?.cgIdentifier ?? "").toList();
      final newBalances = await service.getTokenBalance(cgIdentifiers, currency);
      _data = newBalances;
      _lastUpdated = DateTime.now().millisecondsSinceEpoch;
    } else {
      logger.i('Cache not expired!');
    }

    return _data;
  }
}