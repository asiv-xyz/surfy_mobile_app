import 'package:get/get.dart';
import 'package:surfy_mobile_app/cache/token/token_price_cache.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/token/token_price_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class TokenPriceRepository {
  TokenPriceRepository({required this.service, required this.tokenPriceCache});

  final TokenPriceCache tokenPriceCache;
  final TokenPriceService service;

  Future<Map<Token, TokenPrice>> getTokenPriceList(List<Token> tokenList, CurrencyType currencyType) async {

    final List<String> cgIdentifierList = [];
    final getBalanceFromCache = tokenList.map((token) async {
      final needToUpdate = await tokenPriceCache.needToUpdate(token, currencyType);
      if (needToUpdate) {
        // from remote
        print('token: $token need to get remote');
        cgIdentifierList.add(tokens[token]?.cgIdentifier ?? "");
        return TokenPrice(token: token, price: -1, currency: currencyType.name );
      } else {
        // from  cache
        print('token: $token is from cache!');
        final result = await tokenPriceCache.getTokenPrice(token, currencyType);
        return TokenPrice(token: token, price: result, currency: currencyType.name);
      }
    });
    final result1 = await Future.wait(getBalanceFromCache);

    final balances = await service.getTokenBalance(cgIdentifierList, currencyType);
    final job = balances.entries.map((item) async {
      await tokenPriceCache.saveTokenPrice(item.key, item.value.price, currencyType);
      return item.value;
    }).toList();
    final result2 = await Future.wait(job);

    final ret = <Token, TokenPrice>{};
    for (var item in result1) {
      if (item.price != -1) {
        ret[item.token] = item;
      }
    }
    for (var item in result2) {
      ret[item.token] = item;
    }
    return ret;
  }

  Future<TokenPrice?> getSingleTokenPrice(Token token, CurrencyType currencyType) async {
    final needToUpdate = await tokenPriceCache.needToUpdate(token, currencyType);
    if (needToUpdate) {
      final price = await getTokenPriceList([token], currencyType);
      return TokenPrice(token: token, price: price[token]?.price ?? 0.0, currency: currencyType.name.toLowerCase());
    }

    final item = await tokenPriceCache.getTokenPrice(token, currencyType);
    return TokenPrice(token: token, price: item, currency: currencyType.name.toLowerCase());
  }
}