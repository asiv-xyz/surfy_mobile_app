import 'package:surfy_mobile_app/service/wallet/wallet_service.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';

class GetWalletAddress {
  GetWalletAddress({required this.service});

  final WalletService service;

  Future<String> getAddress(Blockchain blockchain, String privateKey) async {
    return await service.getWalletAddress(blockchain, privateKey);
  }
}