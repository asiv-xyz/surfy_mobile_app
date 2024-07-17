import 'dart:io';

import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/qr/get_cached_qr.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/service/qr/qr_service.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/receive/receive_view.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/utils/crypto_and_fiat.dart';
import 'package:surfy_mobile_app/platform/deeplink.dart';

class ReceiveViewModel {

  late ReceiveView _view;

  final Rx<Token?> observableSelectedToken = Rx(null);
  final Rx<Blockchain?> observableSelectedBlockchain = Rx(null);
  final RxString observableUserAddress = "".obs;
  final RxDouble observableAmount = 0.0.obs;
  final RxString observableQrData = "".obs;

  final QRService _qrService = Get.find();
  final GetWalletAddress _getWalletAddressUseCase = Get.find();
  final GetCachedQr _getCachedQrUseCase = Get.find();

  void setView(ReceiveView view) {
    _view = view;
  }

  Future<void> init(Token token, Blockchain blockchain) async {
    _view.onQRLoading();
    observableSelectedToken.value = token;
    observableSelectedBlockchain.value = blockchain;
    observableUserAddress.value = await _getWalletAddressUseCase.getAddress(blockchain);
    final cachedQr = await _getCachedQrUseCase.getWalletQR(token, blockchain, observableUserAddress.value);
    if (cachedQr == null) {
      observableQrData.value = await _qrService.getQRcode(DeepLink.createDeepLink(blockchain, token, observableUserAddress.value));
      await _qrService.setWalletQR(token, blockchain, observableUserAddress.value, observableQrData.value);
    } else {
      observableQrData.value = cachedQr;
    }
    _view.finishQRLoading();
  }

  Future<void> refreshQR() async {
    _view.onQRLoading();
    final amount = cryptoDecimalToBigInt(tokens[observableSelectedToken.value]!, observableAmount.value);
    observableQrData.value = await _qrService.getQRcode(DeepLink.createDeepLink(
        observableSelectedBlockchain.value!,
        observableSelectedToken.value!,
        observableUserAddress.value,
        amount: amount));
    _view.finishQRLoading();
  }
}