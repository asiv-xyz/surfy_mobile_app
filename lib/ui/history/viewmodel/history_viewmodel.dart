import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/transaction/get_transaction_history.dart';
import 'package:surfy_mobile_app/entity/transaction/transaction.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/ui/history/history_view.dart';

class HistoryViewModel implements EventListener {

  late HistoryView _view;

  final GetTransactionHistory _getTransactionHistoryUseCase = Get.find();
  final Rx<List<Transaction>> observableTransactionList = Rx([]);

  final KeyService _keyService = Get.find();

  void setView(HistoryView view) {
    _view = view;
  }

  Future<void> init() async {
    _view.startLoading();
    final userId = await _keyService.getKeyHash();
    final txList = await _getTransactionHistoryUseCase.get(userId);
    observableTransactionList.value = txList;
    _view.finishLoading();
  }

  @override
  Future<void> onEventReceived(GlobalEvent event) async {
    await init();
  }
}