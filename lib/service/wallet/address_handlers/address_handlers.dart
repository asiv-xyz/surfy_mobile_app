import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:solana/solana.dart';
import 'package:surfy_mobile_app/cache/wallet/wallet_cache.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

abstract class AddressHandler {
  Future<String> getAddress(String privateKey);
}

class EthereumAddressHandler implements AddressHandler {
  EthereumAddressHandler({required this.walletCache});
  final WalletCache walletCache;

  @override
  Future<String> getAddress(String privateKey) async {
    final cacheValue = await walletCache.getWalletAddress(Blockchain.ethereum);
    if (cacheValue != "") {
      return cacheValue;
    }

    final credential = EthPrivateKey.fromHex(privateKey);
    final address = credential.address.hex;
    await walletCache.saveWalletAddress(Blockchain.ethereum, address);
    return address;
  }
}

class SolanaAddressHandler implements AddressHandler {
  SolanaAddressHandler({required this.walletCache});
  final WalletCache walletCache;

  @override
  Future<String> getAddress(String privateKey) async {
    final cacheValue = await walletCache.getWalletAddress(Blockchain.solana);
    if (cacheValue != "") {
      return cacheValue;
    }

    final hex = hexToBytes(privateKey);
    final k = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: hex.take(32).toList());
    final address = k.address;
    await walletCache.saveWalletAddress(Blockchain.solana, address);
    return address;
  }
}

class XrplAddressHandler implements AddressHandler {
  XrplAddressHandler({required this.walletCache});
  final WalletCache walletCache;

  @override
  Future<String> getAddress(String privateKey) async {
    final cacheValue = await walletCache.getWalletAddress(Blockchain.xrpl);
    if (cacheValue != "") {
      return cacheValue;
    }

    final wallet = XRPPrivateKey.fromHex(privateKey, algorithm: XRPKeyAlgorithm.secp256k1);
    final address = wallet.getPublic().toAddress().address;
    await walletCache.saveWalletAddress(Blockchain.xrpl, address);
    return address;
  }
}

class TronAddressHandler implements AddressHandler {
  TronAddressHandler({required this.walletCache});
  final WalletCache walletCache;

  @override
  Future<String> getAddress(String privateKey) async {
    final cacheValue = await walletCache.getWalletAddress(Blockchain.tron);
    if (cacheValue != "") {
      return cacheValue;
    }

    final seed = BytesUtils.fromHexString(privateKey);
    final bip44 = Bip44.fromSeed(seed, Bip44Coins.tron);
    final pk = TronPrivateKey.fromBytes(bip44.privateKey.raw);
    final pubKey = pk.publicKey();
    final address = pubKey.toAddress().toAddress();
    await walletCache.saveWalletAddress(Blockchain.tron, address);
    return address;
  }
}

class DogeAddressHandler implements AddressHandler {
  DogeAddressHandler({required this.walletCache});
  final WalletCache walletCache;

  @override
  Future<String> getAddress(String privateKey) async {
    final cacheValue = await walletCache.getWalletAddress(Blockchain.dogechain);
    if (cacheValue != "") {
      return cacheValue;
    }

    final ecPrivate = ECPrivate.fromBytes(BytesUtils.fromHexString(privateKey));
    final pubKey = ecPrivate.getPublic();
    final p2pkhAddress = DogeAddress.fromBaseAddress(pubKey.toAddress());
    final address = p2pkhAddress.address;
    await walletCache.saveWalletAddress(Blockchain.dogechain, address);
    return address;
  }

}