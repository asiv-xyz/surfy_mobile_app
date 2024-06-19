import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';

class BalanceView extends StatelessWidget {
  const BalanceView({
    super.key,
    required this.fiatBalance,
    required this.cryptoBalance,
  });

  final String fiatBalance;
  final String cryptoBalance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fiatBalance, style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(cryptoBalance, style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 15))
      ],
    );
  }

}