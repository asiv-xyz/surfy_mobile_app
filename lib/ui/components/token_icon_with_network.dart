import 'package:flutter/material.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class TokenIconWithNetwork extends StatelessWidget {
  const TokenIconWithNetwork({
    super.key,
    required this.blockchain,
    required this.token,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;
  final Blockchain? blockchain;
  final Token? token;

  @override
  Widget build(BuildContext context) {
    final blockchainData = blockchains[blockchain];
    final tokenData = tokens[token];
    if (blockchainData == null || tokenData == null) {
      return Container(
        child: Text('No data'),
      );
    }

    return Stack(
       children: [
         Container(
           width: width,
           height: height,
           child: ClipRRect(
             borderRadius: BorderRadius.circular(100),
             child: Image.asset(tokenData.iconAsset, width: width, height: height)
           )
         ),
         Positioned.fill(
           child: Align(
               alignment: Alignment.bottomRight,
               child: Container(
                   width: width / 2,
                   height: height / 2,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(100),
                     border: Border.all(color: Colors.white),
                     color: Colors.white,
                   ),
                   child: ClipRRect(
                       borderRadius: BorderRadius.circular(100),
                       child: Image.asset(blockchainData.icon, width: width / 2, height: height / 2)
                   )
               )
           )
         )
       ],
    );
  }

}