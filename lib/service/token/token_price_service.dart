import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/dio_utils.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class TokenPriceService {
  Future<Map<Token, TokenPrice>> getTokenBalance(List<String> cgIdentifierList, CurrencyType currencyType) async {
    final result = await dioObject.get(
      'https://wgs0z4xv93.execute-api.ap-northeast-2.amazonaws.com/Prod/price?ids=${cgIdentifierList.join(',')}&vs_currency=${currencyType.name.toLowerCase()}',
      options: Options(responseType: ResponseType.json),
    );

    final Map<Token, TokenPrice> ret = {};
    result.data.forEach((cgIdentifier, balanceData) {
      final tokenData = tokens.values.toList().firstWhere((tokenData) => tokenData.cgIdentifier == cgIdentifier);
      final tokenPrice = TokenPrice(
        token: tokenData.token,
        currency: currencyType.name.toLowerCase(),
        price: balanceData[currencyType.name.toLowerCase()].toDouble(),
      );

      ret[tokenData.token] = tokenPrice;
    });

    return ret;
  }
}