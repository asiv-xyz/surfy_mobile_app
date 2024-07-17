import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/ui/components/badge.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/receive/viewmodel/receive_viewmodel.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key, required this.token, required this.blockchain});

  final Token token;
  final Blockchain blockchain;

  @override
  State<StatefulWidget> createState() {
    return _ReceivePageState();
  }
}

abstract class ReceiveView {
  void onQRLoading();
  void finishQRLoading();
}

class _ReceivePageState extends State<ReceivePage> implements ReceiveView {
  final ReceiveViewModel _viewModel = ReceiveViewModel();
  final _textController = TextEditingController();
  final _isQRLoading = false.obs;

  @override
  void onQRLoading() {
    _isQRLoading.value = true;
  }

  @override
  void finishQRLoading() {
    _isQRLoading.value = false;
  }

  @override
  void initState() {
    super.initState();
    _viewModel.setView(this);
    _viewModel.init(widget.token, widget.blockchain);
    _textController.addListener(() {
      _viewModel.observableAmount.value = _textController.value.text.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Receive'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Obx(() {
            if (_viewModel.observableQrData.value.isNullOrEmpty) {
              return const LoadingWidget(opacity: 0);
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    if (_isQRLoading.isTrue) {
                      // return Expanded(child: Center(child: CircularProgressIndicator(color: SurfyColor.blue,)));
                      return const Expanded(child: LoadingWidget(opacity: 0,));
                    } else {
                      return Image.network(_viewModel.observableQrData.value, loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Center(
                          child: CircularProgressIndicator(
                            color: SurfyColor.blue,
                            value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                          ),
                        );
                      },);
                    }
                  }),
                  // const SizedBox(height: 10,),
                  // TextField(
                  //   cursorColor: SurfyColor.black,
                  //   keyboardType: TextInputType.number,
                  //   inputFormatters: <TextInputFormatter>[
                  //     FilteringTextInputFormatter.digitsOnly
                  //   ],
                  //   decoration: InputDecoration(
                  //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  //     label: Text('Amount to receive', style: Theme.of(context).textTheme.bodySmall?.apply(color: SurfyColor.black)),
                  //     focusColor: SurfyColor.blue,
                  //     hoverColor: SurfyColor.blue,
                  //     focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: SurfyColor.blue), borderRadius: BorderRadius.all(Radius.circular(10)))
                  //   ),
                  //   style: Theme.of(context).textTheme.bodySmall,
                  //   controller: _textController
                  // ),
                  const SizedBox(height: 10,),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Token", style: Theme.of(context).textTheme.titleMedium?.apply(color: SurfyColor.black)),
                          TokenBadge(token: _viewModel.observableSelectedToken.value ?? Token.ETHEREUM),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Network", style: Theme.of(context).textTheme.titleMedium?.apply(color: SurfyColor.black)),
                          NetworkBadge(blockchain: _viewModel.observableSelectedBlockchain.value ?? Blockchain.ethereum)
                        ],
                      ),
                    ],
                  )
                  // const SizedBox(height: 10,),
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 60,
                  //   child: Material(
                  //     color: SurfyColor.blue,
                  //     borderRadius: BorderRadius.circular(15),
                  //     child: InkWell(
                  //       onTap: () async {
                  //         await _viewModel.refreshQR();
                  //       },
                  //       child: Center(
                  //         child: Text("Create QR code", style: Theme.of(context).textTheme.titleLarge?.apply(color: Theme.of(context).primaryColorLight)),
                  //       )
                  //     )
                  //   )
                  // )
                ],
              );
            }
          }),
        )
      )
    );
  }
}