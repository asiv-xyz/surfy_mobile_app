import 'package:solana/solana.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';

abstract class AddressHandler {
  Future<String> getAddress(String privateKey);
}

class EthereumAddressHandler implements AddressHandler {
  @override
  Future<String> getAddress(String privateKey) async {
    final credential = EthPrivateKey.fromHex(privateKey);
    return credential.address.hex;
  }
}

class SolanaAddressHandler implements AddressHandler {
  @override
  Future<String> getAddress(String privateKey) async {
    final hex = hexToBytes(privateKey);
    final k = await Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: hex.take(32).toList());
    return k.address;
  }
}