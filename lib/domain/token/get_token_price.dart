import 'package:get/get.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/repository/token/token_price_repository.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class GetTokenPrice {
  GetTokenPrice({required this.repository});

  final TokenPriceRepository repository;


  Future<Map<Token, Map<CurrencyType, TokenPrice>>> getTokenPrice(List<Token> tokenList, CurrencyType currency) async {
    logger.i('getTokenPrice: token=$tokenList, currency=$currency');
    final result = await repository.getTokenPriceList(tokenList, currency);
    return result;
  }

  Future<TokenPrice?> getSingleTokenPrice(Token token, CurrencyType currency) async {
    logger.i('getSingleTokenPrice: token=$token, currency=$currency');
    return await repository.getSingleTokenPrice(token, currency);
  }
}