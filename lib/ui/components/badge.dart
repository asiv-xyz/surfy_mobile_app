import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class TokenBadge extends StatelessWidget {
  const TokenBadge({super.key, required this.token});
  final Token token;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15)
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child : Row(
          children: [
            Image.asset(tokens[token]?.iconAsset ?? "", width: 24, height: 24,),
            const SizedBox(width: 10),
            Text(tokens[token]?.name ?? "", style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(width: 1,)
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
            borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).cardColor
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child : Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(blockchains[blockchain]?.icon ?? "", width: 24, height: 24,),
            const SizedBox(width: 10),
            Text(blockchains[blockchain]?.name ?? "", style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(width: 1,)
          ],
        )
    );
  }
}
