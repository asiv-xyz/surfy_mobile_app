import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/badge.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class CheckViewProps {
  CheckViewProps({
    required this.token,
    required this.blockchain,
    required this.transactionHash,
    required this.receiver,
    required this.crypto,
    required this.fiat,
    required this.currency,
  });

  final Token token;
  final Blockchain blockchain;
  final String transactionHash;
  final String receiver;
  final double crypto;
  final double fiat;
  final String currency;
}

class CheckView extends StatefulWidget {
  const CheckView({super.key,
    required this.token,
    required this.blockchain,
    required this.transactionHash,
    required this.receiver,
    required this.crypto,
    required this.fiat,
    required this.currency,
  });

  final Token token;
  final Blockchain blockchain;
  final String transactionHash;
  final String receiver;
  final double crypto;
  final double fiat;
  final String currency;

  @override
  State<StatefulWidget> createState() {
    return _CheckViewState();
  }
}

class _CheckViewState extends State<CheckView> with SingleTickerProviderStateMixin {
  
  late AnimationController controller;
  late Animation<int> alpha;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(seconds: 1), vsync: this);
    alpha = IntTween(begin: 0, end: 255).animate(controller);
    animation = Tween<double>(begin: 0, end: 300).animate(controller)..addListener(() {
      setState(() {

      });
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.black,
        )
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: SurfyColor.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(
                  height: animation.value,
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/ic_blue_check.png", width: 40, height: 40),
                      const SizedBox(width: 10),
                      Text('Check please!', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 28),)
                    ],
                  ),
                ),
                Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tx Hash', style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 16),),
                            Text(shortAddress(widget.transactionHash), style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 12)),
                          ],
                        )
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: 60,
              child: Material(
                color: SurfyColor.blue,
                child: InkWell(
                  onTap: () {
                    if (mounted) {
                      context.go('/wallet');
                    }
                  },
                  child: Center(
                    child: Text('Click to home', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 18))
                  )
                )
              )
            )
          ],
        )
      )
    );
  }

}