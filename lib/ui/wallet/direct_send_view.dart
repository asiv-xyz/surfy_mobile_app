import 'package:flutter/material.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class DirectSendPage extends StatefulWidget {
  const DirectSendPage({
    super.key,
    required this.token,
    required this.blockchain,
    required this.recipient,
    required this.amount,
  });

  final Token token;
  final Blockchain blockchain;
  final String recipient;
  final int amount;

  @override
  State<StatefulWidget> createState() {
    return _DirectSendPageState();
  }

}

class _DirectSendPageState extends State<DirectSendPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Text(widget.token.name),
            Text(widget.blockchain.name),
            Text(widget.recipient),
            Text(widget.amount.toString()),
          ],
        )
      )
    );
  }

}