import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:solana/solana.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

abstract class AddressHandler {
  Future<String> getAddress(String privateKey);
}

class EthereumAddressHandler implements AddressHandler {
  static final EthereumAddressHandler _singleton = EthereumAddressHandler._internal();

  factory EthereumAddressHandler() {
    return _singleton;
  }

  EthereumAddressHandler._internal();
  String? address;

  @override
  Future<String> getAddress(String privateKey) async {
    if (address == null) {
      final credential = EthPrivateKey.fromHex(privateKey);
      address = credential.address.hex;
    }
    return address!;
  }
}

class SolanaAddressHandler implements AddressHandler {
  static final SolanaAddressHandler _singleton = SolanaAddressHandler._internal();

  factory SolanaAddressHandler() {
    return _singleton;
  }

  SolanaAddressHandler._internal();

  String? address;

  @override
  Future<String> getAddress(String privateKey) async {
    if (address == null) {
      final hex = hexToBytes(privateKey);
      final k = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: hex.take(32).toList());
      address = k.address;
    }
    return address!;
  }
}

class XrplAddressHandler implements AddressHandler {
  static final XrplAddressHandler _singleton = XrplAddressHandler._internal();

  factory XrplAddressHandler() {
    return _singleton;
  }

  XrplAddressHandler._internal();

  String? address;

  @override
  Future<String> getAddress(String privateKey) async {
    if (address == null) {
      var wallet = XRPPrivateKey.fromHex(privateKey, algorithm: XRPKeyAlgorithm.secp256k1);
      address = wallet.getPublic().toAddress().address;
    }

    return address!;
  }
}

class TronAddressHandler implements AddressHandler {
  static final TronAddressHandler _singleton = TronAddressHandler._internal();

  factory TronAddressHandler() {
    return _singleton;
  }

  TronAddressHandler._internal();

  String? address;

  @override
  Future<String> getAddress(String privateKey) async {
    if (address == null) {
      final seed = BytesUtils.fromHexString(privateKey);
      final bip44 = Bip44.fromSeed(seed, Bip44Coins.tron);
      final pk = TronPrivateKey.fromBytes(bip44.privateKey.raw);
      final pubkey = pk.publicKey();
      address = pubkey.toAddress().toAddress();
    }

    return address!;
  }
}

class DogeAddressHandler implements AddressHandler {
  @override
  Future<String> getAddress(String privateKey) async {
    final ecPrivate = ECPrivate.fromBytes(BytesUtils.fromHexString(privateKey));
    final pubKey = ecPrivate.getPublic();
    final p2pkhAddress = DogeAddress.fromBaseAddress(pubKey.toAddress());
    return p2pkhAddress.address;
  }

}