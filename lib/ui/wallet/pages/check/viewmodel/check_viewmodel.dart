import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/check/check_view.dart';

class CheckViewModel {
  late CheckViewInterface view;

  final SendP2pToken _sendP2pToken = Get.find();
  final RxString observableTransactionHash = "".obs;

  void setView(CheckViewInterface view) {
    this.view = view;
  }

  Stream getTransactionSubscription(Token token, Blockchain blockchain, String transactionHash) {
    return _sendP2pToken.subscribeTransaction(token, blockchain, transactionHash);
  }
}