import 'package:flutter_test/flutter_test.dart';
import 'package:surfy_mobile_app/domain/merchant/get_merchants.dart';
import 'package:surfy_mobile_app/repository/merchant/merchant_repository.dart';
import 'package:surfy_mobile_app/service/merchant/merchant_service.dart';

void main() {
  test('domain test', () async {
    final domain = GetMerchants(service: MerchantService());
    print(await domain.getSingle('testStore'));
  });
}