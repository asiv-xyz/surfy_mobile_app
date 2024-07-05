import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/ui/history/components/transaction_badge.dart';
import 'package:surfy_mobile_app/ui/history/viewmodel/history_viewmodel.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';

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
  
  String _formatDateTime(DateTime time) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    return formatter.format(time);
  }

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
      appBar: AppBar(
        title: const Text('History')
      ),

      body: Stack(
        children: [
          RefreshIndicator(
              onRefresh: () async {
                await _viewModel.init();
              },
              color: SurfyColor.blue,
              child: SingleChildScrollView(
                child: Obx(() => Column(
                  children: _viewModel.observableTransactionList.value.map((tx) {
                    return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: SurfyColor.black,
                            padding: const EdgeInsets.all(0)
                        ),
                        onPressed: () {
                          context.push('/history/detail', extra: tx);
                        }, child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: SurfyColor.lightGrey, width: 0.2))
                      ),
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
                                  // Text(tx.type.name, style: Theme.of(context).textTheme.displaySmall),
                                  TransactionBadge(type: tx.type),
                                  const SizedBox(height: 5),
                                  Text('to: ${shortAddress(tx.receiverAddress)}', style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(height: 5),
                                  Text(_formatDateTime(tx.createdAt), style: Theme.of(context).textTheme.labelSmall)
                                ],
                              ),
                            ],
                          ),
                          Text(formatCrypto(tx.token, _calculator.cryptoToDouble(tx.token, tx.amount)), style: Theme.of(context).textTheme.displaySmall)
                        ],
                      ),
                    ));
                  }).toList(),
                )),
              )
          ),
          Obx(() {
            if (_isLoading.isTrue) {
              return const LoadingWidget(opacity: 0.4);
            } else {
              return const SizedBox();
            }
          })
        ],
      )
    );
  }

  @override
  void finishLoading() {
    print('finishLoading');
    _isLoading.value = false;
  }

  @override
  void startLoading() {
    print('startLoading');
    _isLoading.value = true;
  }

}