import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/memo/viewmodel/memo_viewmodel.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/utils/crypto_and_fiat.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';

class MemoPage extends StatefulWidget {
  const MemoPage({
    super.key,
    required this.token,
    required this.blockchain,
    required this.amount,
    this.defaultReceiverAddress,
  });

  final Token token;
  final Blockchain blockchain;
  final BigInt amount;

  final String? defaultReceiverAddress;

  @override
  State<StatefulWidget> createState() {
    return _MemoPageState();
  }
}

abstract class MemoView {

}

class _MemoPageState extends State<MemoPage> implements MemoView {
  final MemoViewModel _viewModel = MemoViewModel();

  final TextEditingController _walletAddressTextController = TextEditingController();
  final TextEditingController _memoTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.setView(this);

    if (widget.defaultReceiverAddress != null) {
      _walletAddressTextController.text = widget.defaultReceiverAddress!;
    }

    _walletAddressTextController.addListener(() {
      _viewModel.observableAddress.value = _walletAddressTextController.text;
    });

    _memoTextController.addListener(() {
      _viewModel.observableMemo.value = _walletAddressTextController.text;
    });
  }

  Widget _buildHistoryView() {
    if (_viewModel.observableRecentSentContacts.value.isEmpty) {
      return Center(
        child: Text('No history', style: Theme.of(context).textTheme.displaySmall),
      );
    }

    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _viewModel.observableRecentSentContacts.value.map((contact) {
              return TextButton(
                  style: TextButton.styleFrom(
                      textStyle: const TextStyle(color: SurfyColor.white),
                      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      )
                  ),
                  onPressed: () {
                    _walletAddressTextController.text = contact.address;
                    if (contact.memo != null) {
                      _memoTextController.text = contact.memo!;
                    }
                  },
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wallet, color: Color(0xFF8895A6), size: 16),
                          const SizedBox(width: 5,),
                          Text(contactAddress(contact.address), style: Theme.of(context).textTheme.bodySmall)
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.article, color: Color(0xFF8895A6), size: 16),
                          const SizedBox(width: 5,),
                          Text(contact.memo ?? "", style: Theme.of(context).textTheme.bodySmall)
                        ],
                      ),
                      const SizedBox(height: 16,),
                      const Divider(height: 1, color: Color(0xFF222222),)
                    ],
                  )
              );
            }).toList(),
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _viewModel.init(widget.blockchain);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
            titleSpacing: 0,
            title: const Text('Enter the address')
        ),
        body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Center(
                          child: Text("You are sending ${formatCrypto(widget.token, cryptoAmountToDecimal(tokens[widget.token]!, widget.amount))}"),
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          children: [
                            Expanded(child: TextField(
                              cursorColor: SurfyColor.darkGrey,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  label: Text('Wallet Address', style: Theme.of(context).textTheme.labelLarge),
                                  focusColor: SurfyColor.blue,
                                  hoverColor: SurfyColor.blue,
                                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: SurfyColor.blue), borderRadius: BorderRadius.all(Radius.circular(10)))
                              ),
                              style: Theme.of(context).textTheme.labelLarge,
                              controller: _walletAddressTextController,
                            )),
                            IconButton(
                                onPressed: () async {
                                  final data = await Clipboard.getData('text/plain');
                                  _walletAddressTextController.text = data?.text ?? "";
                                  Fluttertoast.showToast(msg: "Pasted from clipboard", gravity: ToastGravity.CENTER);
                                },
                                icon: const Icon(Icons.content_paste_outlined)
                            )
                          ],
                        ),
                        const SizedBox(height: 20,),
                        TextField(
                          cursorColor: SurfyColor.darkGrey,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              label: Text('Memo', style: Theme.of(context).textTheme.labelLarge),
                              focusColor: SurfyColor.blue,
                              hoverColor: SurfyColor.blue,
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: SurfyColor.blue), borderRadius: BorderRadius.all(Radius.circular(10)))
                          ),
                          style: Theme.of(context).textTheme.labelLarge,
                          controller: _memoTextController,
                        ),
                      ],
                    )
                ),
                const Divider(color: SurfyColor.greyBg),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text("History", style: Theme.of(context).textTheme.bodySmall)
                ),
                Obx(() => Expanded(
                    child: _buildHistoryView())),
                TextButton(
                    onPressed: () {
                      if (_walletAddressTextController.text.isEmpty) {
                        Fluttertoast.showToast(msg: "Please enter wallet address");
                        return;
                      }
                      if (_memoTextController.text.isNotEmpty) {
                        checkAuthAndPush(context,
                            '/wallet/token/${widget.token.name}/blockchain/${widget.blockchain.name}/send/amount/${widget.amount}/address/${_walletAddressTextController.text}/memo/${_memoTextController.text}');
                      } else {
                        checkAuthAndPush(context,
                            '/wallet/token/${widget.token.name}/blockchain/${widget.blockchain.name}/send/amount/${widget.amount}/address/${_walletAddressTextController.text}');
                      }
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: SurfyColor.blue,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        )
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Center(
                        child: Text('Send', style: Theme.of(context).textTheme.displaySmall?.apply(color: Theme.of(context).primaryColorLight)),
                      ),
                    )
                )
              ],
            )
        ),
      )
    );
  }
}