import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
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
  final GetWalletAddress _getWalletAddressUseCase = Get.find();

  void setView(ReceiveView view) {
    _view = view;
  }

  Future<void> init(Token token, Blockchain blockchain) async {
    _view.onQRLoading();

    observableSelectedToken.value = token;
    observableSelectedBlockchain.value = blockchain;
    observableUserAddress.value = await _getWalletAddressUseCase.getAddress(blockchain);

    // TODO : fix it!!!
    final qr = await _qrService.getQRcode("surfy://com.riverbank.surfy/wallet/${observableSelectedToken.value?.name.toLowerCase()}/${observableSelectedBlockchain.value?.name.toLowerCase()}/send/${observableUserAddress.value}/${observableAmount.value}");
    observableQrData.value = qr;

    _view.finishQRLoading();
  }

  Future<void> refreshQR() async {
    _view.onQRLoading();

    // TODO : fix it!!!
    final qr = await _qrService.getQRcode("surfy://com.riverbank.surfy/wallet/${observableSelectedToken.value?.name.toLowerCase()}/${observableSelectedBlockchain.value?.name.toLowerCase()}/send/${observableUserAddress.value}/${observableAmount.value}");
    observableQrData.value = qr;
    _view.finishQRLoading();
  }
}