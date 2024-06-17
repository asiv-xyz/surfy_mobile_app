import 'package:dio/dio.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/repository/token/token_price_repository.dart';
import 'package:surfy_mobile_app/utils/dio_utils.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class GetTokenPrice {
  GetTokenPrice({required this.repository});
  final TokenPriceRepository repository;

  Future<Map<Token, TokenPrice>> getTokenPrice(List<Token> tokenList, String currency) async {
    return await repository.getTokenPrice(tokenList, currency);
  }
}