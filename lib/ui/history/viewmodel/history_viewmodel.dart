import 'package:dartx/dartx.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/transaction/get_transaction_history.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/transaction/transaction.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/ui/history/history_view.dart';

class HistoryViewModel implements EventListener {

  late HistoryView _view;

  final GetTransactionHistory _getTransactionHistoryUseCase = Get.find();
  final GetWalletAddress _getWalletAddress = Get.find();
  final Rx<List<Transaction>> observableTransactionList = Rx([]);

  final KeyService _keyService = Get.find();

  void setView(HistoryView view) {
    _view = view;
  }

  Future<void> init() async {
    _view.startLoading();
    final userId = await _keyService.getKeyHash();

    final addressList = await Future.wait(Blockchain.values.map((blockchain) => _getWalletAddress.getAddress(blockchain)));
    final receivedTx = await _getTransactionHistoryUseCase.getByReceiverAddresses(addressList.toSet().toList());
    final txList = await _getTransactionHistoryUseCase.get(userId);
    txList.addAll(receivedTx);
    txList.mergeSort(comparator: (a, b) {
      if (a.createdAt < b.createdAt) {
         return 1;
      } else if (a.createdAt == b.createdAt) {
        return 0;
      } else {
        return -1;
      }
    });
    observableTransactionList.value = txList;
    _view.finishLoading();
  }

  @override
  Future<void> onEventReceived(GlobalEvent event) async {
    await init();
  }
}