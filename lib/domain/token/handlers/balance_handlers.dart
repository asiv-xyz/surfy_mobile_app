import 'package:http/http.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';
import 'package:surfy_mobile_app/abi/erc20.g.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:web3dart/web3dart.dart';

abstract class BalanceHandler {
  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address);
}

class EthereumBalanceHandler implements BalanceHandler {
  @override
  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    logger.d('Ethereum balance handler: $address');
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw Exception('Invalid blockchain');
    }

    final httpClient = Client();
    final client = Web3Client(blockchainData.rpc, httpClient);
    final balance = await client.getBalance(EthereumAddress.fromHex(address));
    return UserTokenData(blockchain: blockchain, token: token, amount: balance.getInWei, decimal: 18);
  }
}

class UsdcBalanceHandler implements BalanceHandler {
  @override
  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    const erc20 = Erc20BalanceHandler(token: Token.USDC);
    const spl = SplBalanceHandler(token: Token.USDC);
    switch (blockchain) {
      case Blockchain.SOLANA:
      case Blockchain.SOLANA_DEVNET:
        return await spl.getBalance(token, blockchain, address);
      default:
        return await erc20.getBalance(token, blockchain, address);
    }
  }

}

class Erc20BalanceHandler implements BalanceHandler {
  const Erc20BalanceHandler({required this.token});
  final Token token;

  @override
  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw Exception('Invalid blockchain');
    }

    final tokenData = tokens[token];
    if (tokenData == null) {
      throw Exception('Invalid token');
    }

    final tokenContractAddress = tokenData.tokenContractAddress[blockchain];
    if (tokenContractAddress == null) {
      throw Exception('Invalid token contract address');
    }

    final httpClient = Client();
    final client = Web3Client(blockchainData.rpc, httpClient);
    final erc20 = Erc20(address: EthereumAddress.fromHex(tokenContractAddress), client: client);
    final ownerAddress = EthereumAddress.fromHex(address);
    final balance = await erc20.balanceOf((owner: ownerAddress));
    return UserTokenData(blockchain: blockchain, token: token, amount: balance, decimal: tokenData.decimal);
  }
}

class SolanaBalanceHandler implements BalanceHandler {
  @override
  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    logger.d('Solana balance handler: $address');
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw Exception('Invalid blockchain');
    }

    final tokenData = tokens[Token.SOLANA];
    if (tokenData == null) {
      throw Exception('Invalid token');
    }

    final client = SolanaClient(rpcUrl: Uri.parse(blockchainData.rpc), websocketUrl: Uri.parse(blockchainData.websocket ?? ""));
    final balance = await client.rpcClient.getBalance(address);
    logger.d('Solana balance: ${balance.value}');
    return UserTokenData(blockchain: blockchain, token: token, amount: BigInt.from(balance.value), decimal: tokenData.decimal);
  }
}

class SplBalanceHandler implements BalanceHandler {
  const SplBalanceHandler({required this.token});

  final Token token;

  @override
  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw Exception('Invalid blockchain');
    }

    final tokenData = tokens[token];
    if (tokenData == null) {
      throw Exception('Invalid token');
    }

    final client = SolanaClient(rpcUrl: Uri.parse(blockchainData.rpc), websocketUrl: Uri.parse(blockchainData.websocket ?? ""));
    final balance = await client.getTokenBalance(
      owner: Ed25519HDPublicKey.fromBase58(address),
      mint: Ed25519HDPublicKey.fromBase58(tokenData.tokenContractAddress[blockchain] ?? "")
    );
    return UserTokenData(blockchain: blockchain, token: token, amount: BigInt.parse(balance.amount), decimal: balance.decimals);
  }
}