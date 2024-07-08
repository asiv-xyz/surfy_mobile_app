import 'package:surfy_mobile_app/entity/token/token.dart';

abstract class TokenProvider {
  TokenData get(Token token);
}

class TokenProviderImpl implements TokenProvider {
  @override
  TokenData get(Token token) {
    if (tokens[token] == null) {
      throw Exception('Unsupported token: ${token.name}');
    }

    return tokens[token]!;
  }

}