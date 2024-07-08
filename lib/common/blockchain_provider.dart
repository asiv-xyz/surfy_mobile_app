import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';

abstract class BlockchainProvider {
  BlockchainData get(Blockchain token);
}

class BlockchainProviderImpl implements BlockchainProvider {
  @override
  BlockchainData get(Blockchain blockchain) {
    if (blockchains[blockchain] == null) {
      throw Exception('Unsupported blockchain: ${blockchain.name}');
    }

    return blockchains[blockchain]!;
  }
}