import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/merchant/get_merchants.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/repository/merchant/merchant_repository.dart';
import 'package:surfy_mobile_app/ui/map/map_view.dart';

class MapViewModel {

  final MerchantRepository _merchantRepository = Get.find();

  final Rx<List<Merchant>> observableMerchantList = Rx([]);

  late MapView view;

  Future<void> init() async {
    view.onLoading();

    final merchants = await _merchantRepository.getPlaceList();
    observableMerchantList.value = merchants;

    view.offLoading();
  }

  void setView(MapView view) {
    this.view = view;
  }
}