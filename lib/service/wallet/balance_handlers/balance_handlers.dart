import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:http/http.dart';
import 'package:on_chain/on_chain.dart';
import 'package:solana/solana.dart';
import 'package:surfy_mobile_app/abi/erc20.dart';
import 'package:surfy_mobile_app/abi/erc20.g.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/utils/bitcoin_explorer_service.dart';
import 'package:surfy_mobile_app/utils/tron_http_service.dart';
import 'package:surfy_mobile_app/utils/xrpl_http_service.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:web3dart/web3dart.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:http/http.dart' as http;

abstract class BalanceHandler {
  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address);
}

class EthereumBalanceHandler implements BalanceHandler {
  static final EthereumBalanceHandler _singleton = EthereumBalanceHandler._internal();

  factory EthereumBalanceHandler() {
    return _singleton;
  }

  EthereumBalanceHandler._internal();

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
    return UserTokenData(blockchain: blockchain, token: token, amount: balance.getInWei, decimal: 18, address: address);
  }
}

class UsdcBalanceHandler implements BalanceHandler {
  static final UsdcBalanceHandler _singleton = UsdcBalanceHandler._internal();

  factory UsdcBalanceHandler() {
    return _singleton;
  }

  UsdcBalanceHandler._internal();

  @override
  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    const erc20 = Erc20BalanceHandler(token: Token.USDC);
    const spl = SplBalanceHandler(token: Token.USDC);
    switch (blockchain) {
      case Blockchain.solana:
      case Blockchain.solana_devnet:
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
    return UserTokenData(blockchain: blockchain, token: token, amount: balance, decimal: tokenData.decimal, address: address);
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
    return UserTokenData(blockchain: blockchain, token: token, amount: BigInt.from(balance.value), decimal: tokenData.decimal, address: address);
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
    return UserTokenData(blockchain: blockchain, token: token, amount: BigInt.parse(balance.amount), decimal: balance.decimals, address: address);
  }
}

class XrpBalanceHandler implements BalanceHandler {
  static final XrpBalanceHandler _singleton = XrpBalanceHandler._internal();

  factory XrpBalanceHandler() {
    return _singleton;
  }

  XrpBalanceHandler._internal();

  @override
  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    final syncRpc = XRPLRpc(RPCHttpService(RPCConst.mainetUri, http.Client()));
    final result = await syncRpc.request(RPCAccountInfo(account: address));

    return UserTokenData(blockchain: blockchain,
        token: token,
        amount: BigInt.parse(result.accountData.balance),
        decimal: 6,
        address: address
    );
  }
}

class TronRequestGetAccountBalance
    extends TVMRequestParam<String, Map<String, dynamic>> {
  TronRequestGetAccountBalance({required this.address, this.visible = true});

  /// address
  final TronAddress address;
  @override
  final bool visible;

  @override
  TronHTTPMethods get method => TronHTTPMethods.getaccount;

  @override
  Map<String, dynamic> toJson() {
    return {"address": address, "visible": visible};
  }

  @override
  String onResonse(result) {
    if (result.isEmpty) return "0.0";
    if (!result.containsKey("balance")) return "0.0";

    return BigInt.from(result["balance"]).toString();
  }
}

class TronBalanceHandler implements BalanceHandler {
  static final TronBalanceHandler _singleton = TronBalanceHandler._internal();

  factory TronBalanceHandler() {
    return _singleton;
  }

  TronBalanceHandler._internal();

  @override
  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    final blockchainData = blockchains[blockchain];
    final rpc = TronProvider(TronHTTPProvider(url: blockchainData?.rpc ?? ""));
    final userAddress = TronAddress(address);
    final result = await rpc.request(TronRequestGetAccountBalance(address: userAddress));
    return UserTokenData(blockchain: blockchain, token: token, amount: BigInt.parse(result), decimal: 6, address: address);
  }
}

class TrcBalanceHandler implements BalanceHandler {
  static final TrcBalanceHandler _singleton = TrcBalanceHandler._internal();

  factory TrcBalanceHandler() {
    return _singleton;
  }

  TrcBalanceHandler._internal();

  @override
  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    final tokenData = tokens[token];
    if (tokenData == null) {
      throw Exception('No token data, $token, $blockchain');
    }

    final contractAddress = tokens[token]?.tokenContractAddress[blockchain];
    if (contractAddress == null) {
      throw Exception('No contract address, $token, $blockchain');
    }

    final rpc = TronProvider(TronHTTPProvider(url: "https://api.trongrid.io"));
    final contract = ContractABI.fromJson(erc20Abi, isTron: true);
    final response = await rpc.request(
      TronRequestTriggerConstantContract.fromMethod(
          ownerAddress: TronAddress(address),
          contractAddress: TronAddress(contractAddress),
          function: contract.functionFromName("balanceOf"),
          params: [TronAddress(address)]
      ),
    );

    return UserTokenData(blockchain: blockchain, token: token, amount: response.outputResult?[0], decimal: tokenData.decimal, address: address);
  }

}

class DogeBalanceHandler implements BalanceHandler {
  @override
  Future<UserTokenData> getBalance(Token token, Blockchain blockchain, String address) async {
    final service = BitcoinApiService();
    final api = ApiProvider.fromBlocCypher(DogecoinNetwork.mainnet, service);
    final pubKey = P2pkhAddress.fromAddress(address: address, network: DogecoinNetwork.mainnet);
    final dogeAddress = DogeAddress.fromBaseAddress(pubKey);
    final utxo = await api.getAccountUtxo(
      UtxoAddressDetails(publicKey: pubKey.toString(), address: dogeAddress.baseAddress)
    );
    BigInt balance = BigInt.zero;
    for (var item in utxo) {
      balance += item.utxo.value;
    }

    return UserTokenData(blockchain: blockchain, token: token, amount: balance, decimal: 8, address: address);
  }

}
