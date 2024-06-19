import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/repository/token/token_price_repository.dart';
import 'package:surfy_mobile_app/service/token/token_price_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

void main() {
  test('token price test', () async {
    final usecase = GetTokenPrice(repository: TokenPriceRepository(service: TokenPriceService()));
    final result = await usecase.getTokenPrice([Token.ETHEREUM, Token.USDC, Token.SOLANA], CurrencyType.krw);
    print(result);
  });

  test('formatting test', () {
    final formatter = NumberFormat.decimalPattern('en_US');
    final testData = 123456.789;
    print(formatter.format(testData));
  });
}