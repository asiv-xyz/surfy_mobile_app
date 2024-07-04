import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/repository/merchant/merchant_repository.dart';
import 'package:surfy_mobile_app/service/merchant/merchant_service.dart';

class GetMerchants {
  GetMerchants({required this.service});

  final MerchantService service;

  Future<Merchant?> getSingle(String id) async {
    final result = await service.getPlace(id);
    return result;
  }
}