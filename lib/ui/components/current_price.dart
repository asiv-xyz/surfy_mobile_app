import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';

class CurrentPrice extends StatelessWidget {
  const CurrentPrice({super.key,
    required this.mainAxisAlignment,
    required this.tokenName,
    required this.price,
    required this.currency});
  final String tokenName;
  final double price;
  final CurrencyType currency;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('en_US');
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("1 $tokenName = ", style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 15)),
        Text("${getCurrencySymbol(currency)} ${formatter.format(price)}", style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 20))
      ],
    );
  }

}