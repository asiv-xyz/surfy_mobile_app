import 'package:dio/dio.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/utils/dio_utils.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class TokenPriceService {
  Future<dynamic> getTokenBalance(List<String> cgIdentifierList, String currency) async {
    final result = await dioObject.get(
      'https://slq250cw87.execute-api.ap-northeast-2.amazonaws.com/Prod/price?ids=${cgIdentifierList.join(',')}&vs_currency=$currency',
      options: Options(responseType: ResponseType.json),
    );

    final Map<Token, TokenPrice> ret = {};
    result.data.forEach((cgIdentifier, balanceData) {
      final tokenData = tokens.values.toList().firstWhere((tokenData) => tokenData.cgIdentifier == cgIdentifier);
      final tokenPrice = TokenPrice(
        token: tokenData.token,
        currency: currency,
        price: balanceData[currency].toDouble(),
      );

      ret[tokenData.token] = tokenPrice;
    });

    return ret;
  }
}