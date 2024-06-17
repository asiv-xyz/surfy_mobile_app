import 'package:surfy_mobile_app/domain/wallet/handlers/address_handlers.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';

class GetWalletAddress {
  Map<Blockchain, AddressHandler> handlers = {
    // TODO : fix each handler to singleton
    Blockchain.ETHEREUM: EthereumAddressHandler(),
    Blockchain.ETHEREUM_SEPOLIA: EthereumAddressHandler(),
    Blockchain.BASE: EthereumAddressHandler(),
    Blockchain.BASE_SEPOLIA: EthereumAddressHandler(),
    Blockchain.OPTIMISM: EthereumAddressHandler(),
    Blockchain.OPTIMISM_SEPOLIA: EthereumAddressHandler(),
    Blockchain.ARBITRUM: EthereumAddressHandler(),
    Blockchain.ARBITRUM_SEPOLIA: EthereumAddressHandler(),
    Blockchain.BSC: EthereumAddressHandler(),
    Blockchain.SOLANA: SolanaAddressHandler(),
    Blockchain.SOLANA_DEVNET: SolanaAddressHandler(),
  };

  Future<String> getAddress(Blockchain blockchain, String privateKey) async {
    final handler = handlers[blockchain];
    if (handler == null) {
      throw Exception('Invalid blockchain: $blockchain');
    }

    return await handler.getAddress(privateKey);
  }
}