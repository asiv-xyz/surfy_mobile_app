import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/service/wallet/wallet_service.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';

class GetWalletAddress {
  GetWalletAddress({required this.service, required this.keyService});

  final WalletService service;
  final KeyService keyService;

  Future<String> getAddress(Blockchain blockchain) async {
    final key = await keyService.getKey();
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw Exception('No blockchain');
    }
    var chainKey = blockchainData.curve == EllipticCurve.SECP256K1 ? key.first : key.second;
    return await service.getWalletAddress(blockchain, chainKey);
  }
}