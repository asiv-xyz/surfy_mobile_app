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
    final cgIdentifiers = tokenList.map((token) => tokens[token]?.cgIdentifier ?? "").toList();
    final balances = await service.getTokenBalance(cgIdentifiers, currencyType);

    final job = balances.entries.map((item) async {
      await tokenPriceCache.saveTokenPrice(item.key, item.value.price, currencyType);
    }).toList();
    await Future.wait(job);

    return balances;
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