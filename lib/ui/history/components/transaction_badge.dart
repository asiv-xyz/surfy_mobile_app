import 'package:flutter/material.dart';
import 'package:surfy_mobile_app/entity/transaction/transaction.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';

class TransactionBadge extends StatelessWidget {
  const TransactionBadge({super.key, required this.type});

  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    var typeText = "";
    Color color;
    switch (type) {
      case TransactionType.payment:
        typeText = "Payment";
        color = SurfyColor.blue;
        break;
      case TransactionType.transfer:
        typeText = "Transfer";
        color = Colors.green;
        break;
      case TransactionType.receive:
        typeText = "Receive";
        color = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14)
      ),
      child: Center(
        child: Text(typeText, style: Theme.of(context).textTheme.labelSmall)
      ),
    );
  }

}