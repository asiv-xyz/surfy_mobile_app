import 'package:crypto/crypto.dart';
import 'package:dartx/dartx.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

typedef Ed25519 = String;
typedef Secp256k1 = String;

class KeyService {
  Future<Pair<Secp256k1, Ed25519>> getKey() async {
    final secp256k1 = await Web3AuthFlutter.getPrivKey();
    final ed25519 = await Web3AuthFlutter.getEd25519PrivKey();
    return Pair(secp256k1, ed25519);
  }

  Future<String> getKeyHash() async {
    final hashedSecp256K1 = sha1.convert((await Web3AuthFlutter.getPrivKey()).codeUnits);
    final hashedEd25519 = sha1.convert((await Web3AuthFlutter.getEd25519PrivKey()).codeUnits);
    final sum = "${hashedSecp256K1.toString()}${hashedEd25519.toString()}";
    return sha1.convert(sum.codeUnits).toString();
  }
}