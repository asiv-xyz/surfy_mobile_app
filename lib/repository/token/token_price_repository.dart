import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/token/token_price_service.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class TokenPriceRepository {
  TokenPriceRepository({required this.service});

  static const updateThreshold = 60000; // 5 minutes
  final TokenPriceService service;
  int _lastUpdated = 0;
  String _lastUpdatedCurrency = "usd";
  Map<Token, TokenPrice> _data = {};

  Future<void> forceUpdateAndGetTokenPrice(List<Token> tokenList, String currency) async {
    final cgIdentifiers = tokenList
        .map((token) => tokens[token]?.cgIdentifier ?? "").toList();
    final newBalances = await service.getTokenBalance(cgIdentifiers, currency);
    _data = newBalances;
    _lastUpdated = DateTime.now().millisecondsSinceEpoch;
    _lastUpdatedCurrency = currency;
  }

  Future<Map<Token, TokenPrice>> getTokenPrice(List<Token> tokenList, String currency) async {
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    if (_lastUpdated == 0 || currentTimestamp - _lastUpdated > updateThreshold || _lastUpdatedCurrency != currency) {
      logger.d('Cache expired. Update token price');
      await forceUpdateAndGetTokenPrice(tokenList, currency);
    } else {
      logger.d('Cache not expired!');
    }

    return _data;
  }

  Future<TokenPrice?> getSingleTokenPrice(Token token, String currency) async {
    logger.d('getSingleTokenPrice');
    final data = await getTokenPrice(Token.values, currency);
    return data[token];
  }
}