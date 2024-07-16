import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/entity/transaction/transaction.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/ui/history/components/transaction_badge.dart';
import 'package:surfy_mobile_app/ui/history/viewmodel/history_viewmodel.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/utils/crypto_and_fiat.dart';
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
              child: Obx(() {
                if (_isLoading.isFalse && _viewModel.observableTransactionList.value.isEmpty) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Text('No History', style: Theme.of(context).textTheme.displaySmall,)
                    )
                  );
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      children: _viewModel.observableTransactionList.value.map((tx) {
                        return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: SurfyColor.black,
                                padding: const EdgeInsets.all(0)
                            ),
                            onPressed: () {
                              checkAuthAndPush(context, '/history/detail', extra: tx);
                            }, child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          width: double.infinity,
                          decoration: const BoxDecoration(
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
                                      if (tx.type == TransactionType.transfer)Text('To ${shortAddress(tx.receiverAddress)}', style: Theme.of(context).textTheme.bodyMedium),
                                      if (tx.type == TransactionType.payment)Text('To ${shortAddress(tx.receiverAddress)}', style: Theme.of(context).textTheme.bodyMedium),
                                      if (tx.type == TransactionType.receive)Text('From ${shortAddress(tx.receiverAddress)}', style: Theme.of(context).textTheme.bodyMedium),
                                      const SizedBox(height: 5),
                                      Text(_formatDateTime(tx.createdAt), style: Theme.of(context).textTheme.labelSmall)
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(formatCrypto(
                                      tx.token,
                                      cryptoAmountToDecimal(tokens[tx.token]!, tx.amount)),
                                      style: Theme.of(context).textTheme.displaySmall),
                                  if (tx.fiat != null && tx.currencyType != null) Text(formatFiat(tx.fiat!, tx.currencyType!), style: Theme.of(context).textTheme.labelMedium),
                                ],
                              )
                            ],
                          ),
                        ));
                      }).toList(),
                    )
                  );
                }
              }),

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