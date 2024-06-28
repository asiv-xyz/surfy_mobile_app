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
}