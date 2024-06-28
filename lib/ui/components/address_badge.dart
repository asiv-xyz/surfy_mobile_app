import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';

class AddressBadge extends StatelessWidget {

  const AddressBadge({super.key, required this.address, required this.mainAxisAlignment});

  final String address;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(shortAddress(address), style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(width: 4),
        Container(
            width: 14,
            height: 14,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 14,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: address));
              },
              icon: const Icon(Icons.copy_outlined),
            )
        )
      ],
    );
  }

}