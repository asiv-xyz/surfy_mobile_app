import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';

class CurrentPrice extends StatelessWidget {
  const CurrentPrice({super.key,
    required this.crossAxisAlignment,
    required this.tokenName,
    required this.price,
    required this.currency});
  final String tokenName;
  final double price;
  final CurrencyType currency;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('en_US');
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text("1 $tokenName", style: Theme.of(context).textTheme.bodyLarge),
        Text("= ${getCurrencySymbol(currency)} ${formatter.format(price)}", style: Theme.of(context).textTheme.displaySmall)
      ],
    );
  }

}