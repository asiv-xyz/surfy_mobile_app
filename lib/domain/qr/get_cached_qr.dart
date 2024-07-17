import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/service/qr/qr_service.dart';

class GetCachedQr {
  GetCachedQr({required this.service});

  final QRService service;

  Future<String?> getWalletQR(Token token, Blockchain blockchain, String address) async {
    return await service.getCachedWalletQR(token, blockchain, address);
  }

  Future<String?> getMerchantQR(String merchantId) async {
    return await service.getCachedMerchantQR(merchantId);
  }

  Future<void> setWalletQR(Token token, Blockchain blockchain, String address, String qrUrl) async {
    await service.setWalletQR(token, blockchain, address, qrUrl);
  }

  Future<void> setMerchantQR(String merchantId, String qrUrl) async {
    await service.setMerchantQR(merchantId, qrUrl);
  }
}