import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class BalanceView extends StatelessWidget {
  const BalanceView({
    super.key,
    required this.token,
    required this.currencyType,
    required this.fiatBalance,
    required this.cryptoBalance,
  });

  final Token token;
  final CurrencyType currencyType;
  final double fiatBalance;
  final double cryptoBalance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatFiat(fiatBalance, currencyType), style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 10),
        Text(formatCrypto(token, cryptoBalance), style: Theme.of(context).textTheme.labelLarge)
      ],
    );
  }

}