import 'package:get/get.dart';
import 'package:surfy_mobile_app/service/qr/qr_service.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/receive/receive_view.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class ReceiveViewModel {

  late ReceiveView _view;

  final Rx<Token?> observableSelectedToken = Rx(null);
  final Rx<Blockchain?> observableSelectedBlockchain = Rx(null);
  final RxString observableUserAddress = "".obs;
  final RxDouble observableAmount = 0.0.obs;
  final RxString observableQrData = "".obs;

  final QRService _qrService = Get.find();

  void setView(ReceiveView view) {
    _view = view;
  }

  Future<void> init(Token token, Blockchain blockchain) async {
    _view.onQRLoading();

    observableSelectedToken.value = token;
    observableSelectedBlockchain.value = blockchain;

    final qr = await _qrService.getQRcode("surfy://com.riverbank.surfy/send/${observableSelectedBlockchain.value?.name}/${observableSelectedToken.value?.name}/${observableUserAddress.value}/${observableAmount.value}");
    observableQrData.value = qr;

    _view.finishQRLoading();
  }

  Future<void> refreshQR() async {
    _view.onQRLoading();
    final qr = await _qrService.getQRcode("surfy://com.riverbank.surfy/send/${observableSelectedBlockchain.value?.name}/${observableSelectedToken.value?.name}/${observableUserAddress.value}/${observableAmount.value}");
    observableQrData.value = qr;
    _view.finishQRLoading();
  }
}