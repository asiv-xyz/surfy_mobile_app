import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import 'package:surfy_mobile_app/abi/erc20.g.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:web3dart/web3dart.dart';

class SendTokenResponse {
  SendTokenResponse({
    required this.token,
    required this.blockchain,
    required this.sentAmount,
    required this.transactionHash,
  });
  final Token token;
  final Blockchain blockchain;
  final double sentAmount;
  final String transactionHash;
}

abstract class SendTokenHandler {
  Future<SendTokenResponse> send(Blockchain blockchain, String to, double amount);
  Future<BigInt> estimateFee(Blockchain blockchain, String to, double amount);
}

class SendEthereumHandler implements SendTokenHandler {
  SendEthereumHandler({required this.keyService});

  final KeyService keyService;

  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, double amount) async {
    logger.i('Send ETH, network=$blockchain, to=$to, amount=$amount');
    final blockchainData = blockchains[blockchain];
    final client = Web3Client(blockchainData?.rpc ?? "", Client());
    final secp256K1 = (await keyService.getKey()).first;
    final credential = EthPrivateKey.fromHex(secp256K1);
    final gweiValue = amount * pow(10, tokens[Token.ETHEREUM]?.decimal ?? 0);

    final tx = Transaction(
      from: credential.address,
      to: EthereumAddress.fromHex(to),
      value: EtherAmount.fromBigInt(EtherUnit.gwei, BigInt.from(gweiValue)),
    );
    final result = await client.sendTransaction(credential, tx);
    return SendTokenResponse(token: Token.ETHEREUM, blockchain: blockchain, sentAmount: amount, transactionHash: result);
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, double amount) async {
    final blockchainData = blockchains[blockchain];
    final client = Web3Client(blockchainData?.rpc ?? "", Client());
    final secp256K1 = (await keyService.getKey()).first;
    final credential = EthPrivateKey.fromHex(secp256K1);
    final gweiValue = amount * pow(10, tokens[Token.ETHEREUM]?.decimal ?? 0);
    final result = await client.estimateGas(
      sender: credential.address,
      to: EthereumAddress.fromHex(to),
      value: EtherAmount.fromBigInt(EtherUnit.wei, BigInt.from(gweiValue))
    );
    final gasPrice = await client.getGasPrice();

    return result * gasPrice.getInWei;
  }

}

class SendUsdcHandler implements SendTokenHandler {
  SendUsdcHandler({required this.erc20Handler, required this.splHandler});

  final SendErc20Handler erc20Handler;
  final SendSplHandler splHandler;
  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, double amount) async {
    switch (blockchain) {
      case Blockchain.SOLANA:
      case Blockchain.SOLANA_DEVNET:
        return await splHandler.send(blockchain, to, amount);
      case Blockchain.ETHEREUM:
      case Blockchain.ARBITRUM:
      case Blockchain.OPTIMISM:
      case Blockchain.BASE:
      case Blockchain.ETHEREUM_SEPOLIA:
      case Blockchain.ARBITRUM_SEPOLIA:
      case Blockchain.OPTIMISM_SEPOLIA:
      case Blockchain.BASE_SEPOLIA:
        return await erc20Handler.send(blockchain, to, amount);
      default:
        throw Exception("Invalid blockchain: $blockchain");
    }
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, double amount) async {
    switch (blockchain) {
      case Blockchain.SOLANA:
      case Blockchain.SOLANA_DEVNET:
        return await splHandler.estimateFee(blockchain, to, amount);
      case Blockchain.ETHEREUM:
      case Blockchain.ARBITRUM:
      case Blockchain.OPTIMISM:
      case Blockchain.BASE:
      case Blockchain.ETHEREUM_SEPOLIA:
      case Blockchain.ARBITRUM_SEPOLIA:
      case Blockchain.OPTIMISM_SEPOLIA:
      case Blockchain.BASE_SEPOLIA:
        return await erc20Handler.estimateFee(blockchain, to, amount);
      default:
        throw Exception("Invalid blockchain: $blockchain");
    }
  }

}

class SendErc20Handler implements SendTokenHandler {
  SendErc20Handler({required this.token, required this.keyService});

  final Token token;
  final KeyService keyService;

  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, double amount) async {
    logger.i('Send $token, network=$blockchain, to=$to, amount=$amount');
    final tokenData = tokens[token];
    final blockchainData = blockchains[blockchain];
    final contractAddress = tokenData?.tokenContractAddress[blockchain];
    final client = Web3Client(blockchainData?.rpc ?? "", Client());
    final erc20 = Erc20(address: EthereumAddress.fromHex(contractAddress ?? "0x0"), client: client);
    final secp256K1 = (await keyService.getKey()).first;
    final credential = EthPrivateKey.fromHex(secp256K1);
    final amountWithDecimal = amount * pow(10, tokenData?.decimal ?? 0);

    final result = await erc20.transfer((to: EthereumAddress.fromHex(to), value: BigInt.from(amountWithDecimal)), credentials: credential);
    return SendTokenResponse(token: token, blockchain: blockchain, sentAmount: amount, transactionHash: result);
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, double amount) async {
    final tokenData = tokens[token];
    final blockchainData = blockchains[blockchain];
    final contractAddress = tokenData?.tokenContractAddress[blockchain];
    final client = Web3Client(blockchainData?.rpc ?? "", Client());
    final erc20 = Erc20(address: EthereumAddress.fromHex(contractAddress ?? "0x0"), client: client);
    final secp256K1 = (await keyService.getKey()).first;
    final credential = EthPrivateKey.fromHex(secp256K1);
    final amountWithDecimal = amount * pow(10, tokenData?.decimal ?? 0);
    final encodedData = erc20.self.function('transfer').encodeCall([
      erc20.self.address, BigInt.from(amountWithDecimal)
    ]);
    final result = await client.estimateGas(sender: credential.address, to: EthereumAddress.fromHex(to), data: encodedData);
    return result;
  }
}

class SendSolanaHandler implements SendTokenHandler {
  SendSolanaHandler({required this.keyService});
  final KeyService keyService;

  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, double amount) async {
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw Exception('Invalid blockchain');
    }

    final tokenData = tokens[Token.SOLANA];
    if (tokenData == null) {
      throw Exception('Invalid token');
    }

    final client = SolanaClient(rpcUrl: Uri.parse(blockchainData.rpc), websocketUrl: Uri.parse(blockchainData.websocket ?? ""));
    final key = await keyService.getKey();
    final userWallet = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: key.second.codeUnits);
    final lamports = amount * pow(10, tokenData.decimal ?? 0);
    final result = await client.transferLamports(source: userWallet,
      destination: Ed25519HDPublicKey.fromBase58(to),
      lamports: lamports.toInt(),
      commitment: Commitment.confirmed
    );

    return SendTokenResponse(token: Token.SOLANA, blockchain: blockchain, sentAmount: amount, transactionHash: result);
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, double amount) async {
    return BigInt.zero;
  }

}

class SendSplHandler implements SendTokenHandler {
  SendSplHandler({required this.token, required this.keyService});

  final Token token;
  final KeyService keyService;

  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, double amount) async{
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw Exception('Invalid blockchain');
    }

    final tokenData = tokens[Token.SOLANA];
    if (tokenData == null) {
      throw Exception('Invalid token');
    }

    return SendTokenResponse(token: token, blockchain: blockchain, sentAmount: 0, transactionHash: "");
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, double amount) async {
    return BigInt.zero;
  }

}