import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/repository/merchant/merchant_repository.dart';
import 'package:surfy_mobile_app/service/merchant/merchant_service.dart';

class GetMerchants {
  GetMerchants({required this.placeService});

  final MerchantService placeService;

  Future<Merchant?> getSingle(String id) async {
    final result = await placeService.getPlace(id);
    return result;
  }
}