import 'package:get/get.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/service/merchant/merchant_service.dart';

class IsMerchant {
  IsMerchant({required this.service});
  final MerchantService service;
  final Rx<Merchant?> userMerchantInfo = Rx(null);

  Future<bool> isMerchant() async {
    return true;
  }

  Future<String> getMyMerchantId() async {
    return "testStore";
  }

  Future<Merchant?> getMyMerchantData() async {
    return await service.getPlace('testStore');
  }
}