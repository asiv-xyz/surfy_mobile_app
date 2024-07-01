import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/merchant/is_merchant.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/ui/pos/pages/pos/pos_view.dart';

class PosViewModel {
  late PosView view;

  final Rx<Merchant?> observableMerchant = Rx(null);
  final RxBool observableIsMerchant = false.obs;
  final IsMerchant _isMerchantUseCase = Get.find();

  void setView(PosView view) {
    this.view = view;
  }

  Future<void> init() async {
    view.onLoading();
    final isMerchant = await _isMerchantUseCase.isMerchant();
    observableIsMerchant.value = isMerchant;
    final me = await _isMerchantUseCase.getMyMerchantData();
    observableMerchant.value = me;
    view.offLoading();
  }
}