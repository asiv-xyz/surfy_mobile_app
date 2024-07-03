import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/ui/history/viewmodel/history_viewmodel.dart';
import 'package:surfy_mobile_app/ui/navigation_controller.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HistoryPageState();
  }
}

abstract class HistoryView {
  void startLoading();
  void finishLoading();
}

class _HistoryPageState extends State<HistoryPage> implements HistoryView {
  final HistoryViewModel _viewModel = HistoryViewModel();
  final RxBool _isLoading = false.obs;
  final Calculator _calculator = Get.find();
  final EventBus _bus = Get.find();

  @override
  void initState() {
    super.initState();
    _bus.addEventListener(_viewModel);
    _viewModel.setView(this);
    _viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(() {
        if (_isLoading.isTrue) {
          return const LoadingWidget(opacity: 0);
        } else {
          return SingleChildScrollView(
            child: Column(
              children: _viewModel.observableTransactionList.value.map((tx) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          TokenIconWithNetwork(blockchain: tx.blockchain, token: tx.token, width: 40, height: 40),
                          const SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx.type.name, style: Theme.of(context).textTheme.displaySmall),
                              Text('to: ${shortAddress(tx.receiverAddress)}', style: Theme.of(context).textTheme.displaySmall),
                              Text(tx.createdAt.toString(), style: Theme.of(context).textTheme.labelSmall)
                            ],
                          ),
                        ],
                      ),
                      Text(formatCrypto(tx.token, _calculator.cryptoToDouble(tx.token, tx.amount)), style: Theme.of(context).textTheme.displaySmall)
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }
      })
    );
  }

  @override
  void finishLoading() {
    _isLoading.value = false;
  }

  @override
  void startLoading() {
    _isLoading.value = true;
  }

}