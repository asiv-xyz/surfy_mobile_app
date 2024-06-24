import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class TokenBadge extends StatelessWidget {
  const TokenBadge({super.key, required this.token});
  final Token token;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: SurfyColor.greyBg,
            borderRadius: BorderRadius.circular(15)
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child : Row(
          children: [
            Image.asset(tokens[token]?.iconAsset ?? "", width: 24, height: 24,),
            const SizedBox(width: 5),
            Text(tokens[token]?.name ?? "", style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 16)),
          ],
        )
    );
  }
}

class NetworkBadge extends StatelessWidget {
  const NetworkBadge({super.key, required this.blockchain});
  final Blockchain blockchain;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: SurfyColor.greyBg,
            borderRadius: BorderRadius.circular(15)
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child : Row(
          children: [
            Image.asset(blockchains[blockchain]?.icon ?? "", width: 24, height: 24,),
            const SizedBox(width: 5),
            Text(blockchains[blockchain]?.name ?? "", style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 16)),
          ],
        )
    );
  }
}
