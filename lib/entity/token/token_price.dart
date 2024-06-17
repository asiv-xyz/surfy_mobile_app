import 'package:surfy_mobile_app/utils/tokens.dart';

class TokenPrice {
  TokenPrice({required this.token, required this.price, required this.currency});
  
  final Token token;
  final double price;
  final String currency;

  @override
  String toString() {
    return {
      "token": token,
      "price": price,
      "currency": currency,
    }.toString();
  }
}