import 'package:get/get.dart';
import 'package:surfy_mobile_app/service/qr/qr_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/pos/pages/qr/pos_qr_view.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';

class PosQrViewModel {
  late PosQrView _view;
  final QRService _qrService = Get.find();
  final RxString observableQrData = "".obs;

  void setView(PosQrView view) {
    _view = view;
  }

  Future<void> init(String storeId, double wantToReceiveAmount, CurrencyType receivedCurrencyType) async {
    _view.startLoading();
    final result = await _qrService.getQRcode("https://store.surfy.network/pos/payment/$storeId/$wantToReceiveAmount/${receivedCurrencyType.name}");
    observableQrData.value = result;
    _view.finishLoading();
  }
}