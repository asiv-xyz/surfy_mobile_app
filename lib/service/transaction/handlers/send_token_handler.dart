import 'dart:math';
import 'dart:typed_data';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/on_chain.dart' as tron;
import 'package:solana/solana.dart';
import 'package:surfy_mobile_app/abi/erc20.dart';
import 'package:surfy_mobile_app/abi/erc20.g.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/service/transaction/exceptions/exceptions.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:surfy_mobile_app/utils/tron_http_service.dart';
import 'package:surfy_mobile_app/utils/xrpl_http_service.dart';
import 'package:web3dart/web3dart.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:http/http.dart' as http;

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

  @override
  String toString() {
    return {
      "token": token.name,
      "blockchain": blockchain.name,
      "sentAmount": sentAmount,
      "transactionHash": transactionHash,
    }.toString();
  }
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
    final blockchainData = blockchains[blockchain];
    final client = Web3Client(blockchainData?.rpc ?? "", http.Client());
    final secp256K1 = (await keyService.getKey()).first;
    final credential = EthPrivateKey.fromHex(secp256K1);
    final weiValue = amount * pow(10, tokens[Token.ETHEREUM]?.decimal ?? 0);
    final gasPrice = await client.getGasPrice();

    final tx = Transaction(
      from: credential.address,
      to: EthereumAddress.fromHex(to),
      value: EtherAmount.fromBigInt(EtherUnit.wei, BigInt.from(weiValue)),
      gasPrice: gasPrice,
      maxGas: 200000,
    );
    print('chaindId: ${blockchainData?.chainId}');
    final result = await client.sendTransaction(credential, tx, chainId: blockchainData?.chainId);
    return SendTokenResponse(token: Token.ETHEREUM, blockchain: blockchain, sentAmount: amount, transactionHash: result);
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, double amount) async {
    final blockchainData = blockchains[blockchain];
    final client = Web3Client(blockchainData?.rpc ?? "", http.Client());
    print('chainId: ${await client.getChainId()}');
    final secp256K1 = (await keyService.getKey()).first;
    final credential = EthPrivateKey.fromHex(secp256K1);
    final gweiValue = amount * pow(10, tokens[Token.ETHEREUM]?.decimal ?? 0);
    final result = await client.estimateGas(
      sender: credential.address,
      to: EthereumAddress.fromHex(to),
      // value: EtherAmount.fromBigInt(EtherUnit.wei, BigInt.from(gweiValue)),
      value: EtherAmount.zero()

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
        throw NoBlockchainException(blockchain: blockchain);
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
        throw NoBlockchainException(blockchain: blockchain);
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
    print('contract: $contractAddress');
    final client = Web3Client(blockchainData?.rpc ?? "", http.Client());
    final erc20 = Erc20(address: EthereumAddress.fromHex(contractAddress ?? "0x0"), client: client, chainId: blockchainData?.chainId);
    final secp256K1 = (await keyService.getKey()).first;
    final credential = EthPrivateKey.fromHex(secp256K1);
    final amountWithDecimal = amount * pow(10, tokenData?.decimal ?? 0);
    print('amountWithDecimal: ${BigInt.from(amountWithDecimal)}');

    final gasPrice = await client.getGasPrice();
    final result = await erc20.transfer(
      (to: EthereumAddress.fromHex(to), value: BigInt.from(amountWithDecimal)),
      credentials: credential,
      transaction: Transaction(
        gasPrice: gasPrice,
        maxGas: 200000,
      )
    );
    return SendTokenResponse(token: token, blockchain: blockchain, sentAmount: amount, transactionHash: result);
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, double amount) async {
    final tokenData = tokens[token];
    final blockchainData = blockchains[blockchain];
    final contractAddress = tokenData?.tokenContractAddress[blockchain];
    final client = Web3Client(blockchainData?.rpc ?? "", http.Client());
    final erc20 = Erc20(address: EthereumAddress.fromHex(contractAddress ?? "0x0"), client: client);
    final secp256K1 = (await keyService.getKey()).first;
    final credential = EthPrivateKey.fromHex(secp256K1);
    final amountWithDecimal = amount * pow(10, tokenData?.decimal ?? 0);
    final encodedData = erc20.self.function('transfer').encodeCall([
      erc20.self.address, BigInt.from(amountWithDecimal)
    ]);
    final result = await client.estimateGas(sender: credential.address, to: EthereumAddress.fromHex(to), data: encodedData);
    final gasPrice = await client.getGasPrice();
    return gasPrice.getInWei * result;
  }
}

class SendSolanaHandler implements SendTokenHandler {
  SendSolanaHandler({required this.keyService});
  final KeyService keyService;

  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, double amount) async {
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw NoBlockchainException(blockchain: blockchain);
    }

    final tokenData = tokens[Token.SOLANA];
    if (tokenData == null) {
      throw NoTokenException(token: Token.SOLANA);
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
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw NoBlockchainException(blockchain: blockchain);
    }

    final tokenData = tokens[Token.SOLANA];
    if (tokenData == null) {
      throw NoTokenException(token: Token.SOLANA);
    }

    final client = SolanaClient(rpcUrl: Uri.parse(blockchainData.rpc), websocketUrl: Uri.parse(blockchainData.websocket ?? ""));
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
      throw NoBlockchainException(blockchain: blockchain);
    }

    final tokenData = tokens[Token.SOLANA];
    if (tokenData == null) {
      throw NoTokenException(token: Token.SOLANA);
    }

    return SendTokenResponse(token: token, blockchain: blockchain, sentAmount: 0, transactionHash: "");
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, double amount) async {
    return BigInt.zero;
  }
}

class SendXrpHandler implements SendTokenHandler {
  SendXrpHandler({required this.keyService});
  final KeyService keyService;
  
  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, double amount) async {
    final syncRpc = XRPLRpc(RPCHttpService(RPCConst.mainetUri, http.Client()));
    final fee = await syncRpc.request(RPCFee());
    return BigInt.from(fee.calculateFeeDynamically());
  }

  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, double amount) async {
    final key = await keyService.getKey();
    var wallet = XRPPrivateKey.fromHex(key.first, algorithm: XRPKeyAlgorithm.secp256k1);
    final syncRpc = XRPLRpc(RPCHttpService(RPCConst.mainetUri, http.Client()));
    final fee = await syncRpc.request(RPCFee());
    print('amount: $amount');
    print('amount2: ${XRPHelper.xrpDecimalToDrop(amount.toString())}');
    final payment = Payment(
      amount: CurrencyAmount.xrp(XRPHelper.xrpDecimalToDrop(amount.toString())),
      destination: to,
      account: wallet.getPublic().toAddress().address,
      fee: BigInt.from(fee.calculateFeeDynamically()),
      signer: XRPLSignature.signer(wallet.getPublic().toHex()),
      sequence: 0
    );
    await XRPHelper.autoFill(syncRpc, payment);
    final sig = wallet.sign(payment.toBlob());
    payment.setSignature(sig);
    final paymentBlob = payment.toBlob(forSigning: false);
    final result = await syncRpc.request(RPCSubmitOnly(txBlob: paymentBlob));
    if (!result.isSuccess) {
      throw TransactionFailedException(token: Token.XRP, blockchain: blockchain, message: result.engineResultMessage);
    }
    print('engine result: ${result.engineResult}');
    print('engine result msg: ${result.engineResultMessage}');
    print('is success: ${result.isSuccess}');
    return SendTokenResponse(
      token: Token.XRP,
      blockchain: blockchain,
      sentAmount: amount,
      transactionHash: result.txJson.hash,
    );
  }
}

class SendTronHandler implements SendTokenHandler {
  SendTronHandler({required this.keyService});
  final KeyService keyService;

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, double amount) async {
    final key = await keyService.getKey();

    final blockchainData = blockchains[blockchain];
    final rpc = tron.TronProvider(TronHTTPProvider(url: blockchainData?.rpc ?? ""));
    final seed = BytesUtils.fromHexString(key.second);
    final bip44 = Bip44.fromSeed(seed, Bip44Coins.tron);
    final pk = tron.TronPrivateKey.fromBytes(bip44.privateKey.raw);
    final chainParameters = await rpc.request(tron.TronRequestGetChainParameters());
    final bandWidthInSun = chainParameters.getTransactionFee!;
    int bandWidthNeed = 0;

    final userAccountResource = await rpc.request(tron.TronRequestGetAccountResource(address: pk.publicKey().toAddress()));
    final transferContract = tron.TransferContract(
      amount: tron.TronHelper.toSun(amount.toString()),
      ownerAddress: pk.publicKey().toAddress(),
      toAddress: tron.TronAddress(to),
    );

    final request = await rpc.request(tron.TronRequestCreateTransaction.fromContract(
        transferContract,
        visible: false)
    );

    final fakeTr = tron.Transaction(rawData: request.transactionRaw!, signature: [Uint8List(65)]);
    final trSize = fakeTr.length + 64;
    bandWidthNeed += trSize;

    final bandWidthBurn = bandWidthNeed * bandWidthInSun;
    final enableBandWidth = userAccountResource.totalBandWith - userAccountResource.totalBandWithUsed;
    if (enableBandWidth < BigInt.from(bandWidthNeed)) {
      return BigInt.from(bandWidthBurn);
    }

    return BigInt.zero;
  }

  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, double amount) async {
    final key = await keyService.getKey();

    final blockchainData = blockchains[blockchain];
    final rpc = tron.TronProvider(TronHTTPProvider(url: blockchainData?.rpc ?? ""));
    final seed = BytesUtils.fromHexString(key.second);
    final bip44 = Bip44.fromSeed(seed, Bip44Coins.tron);
    final pk = tron.TronPrivateKey.fromBytes(bip44.privateKey.raw);

    final transferContract = tron.TransferContract(
      amount: tron.TronHelper.toSun(amount.toString()),
      ownerAddress: pk.publicKey().toAddress(),
      toAddress: tron.TronAddress(to),
    );

    final request = await rpc.request(tron.TronRequestCreateTransaction.fromContract(
      transferContract,
      visible: false)
    );

    if (!request.isSuccess) {
      throw TransactionFailedException(token: Token.TRON, blockchain: blockchain, message: request.error);
    }

    final rawTr = request.transactionRaw!.copyWith(feeLimit: BigInt.from(10000000));
    final _ = rawTr.txID;
    final sign = pk.sign(rawTr.toBuffer());
    final transaction = tron.Transaction(rawData: rawTr, signature: [sign]);
    final raw = BytesUtils.toHexString(transaction.toBuffer());
    final result = await rpc.request(tron.TronRequestBroadcastHex(transaction: raw));

    return SendTokenResponse(token: Token.TRON,
        blockchain: blockchain,
        sentAmount: amount, transactionHash: result.txId ?? "unknown_txhash");
  }
}

class SendTrcHandler implements SendTokenHandler {
  SendTrcHandler({required this.keyService, required this.token});
  final KeyService keyService;
  final Token token;

  Future<tron.TronPrivateKey> _getPrivateKey() async {
    final key = await keyService.getKey();
    final seed = BytesUtils.fromHexString(key.second);
    final bip44 = Bip44.fromSeed(seed, Bip44Coins.tron);
    final pk = tron.TronPrivateKey.fromBytes(bip44.privateKey.raw);
    return pk;
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, double amount) async {
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw NoBlockchainException(blockchain: blockchain);
    }

    final tokenData = tokens[token];
    if (tokenData == null) {
      throw NoTokenException(token: token);
    }

    final rpc = tron.TronProvider(TronHTTPProvider(url: blockchainData.rpc ?? ""));
    final privateKey = await _getPrivateKey();
    final contractAddress = tokenData.tokenContractAddress[blockchain];
    if (contractAddress == null) {
      throw NoTokenContractException(token: token, blockchain: blockchain);
    }

    final contract = tron.ContractABI.fromJson(erc20Abi, isTron: true);
    final function = contract.functionFromName("transfer");

    final transferParams = [tron.TronAddress(to), BigInt.from(amount)];
    int bandWidthNeed = 0;
    int energyNeed = 0;

    final chainParameters = await rpc.request(tron.TronRequestGetChainParameters());
    final bandWidthInSun = chainParameters.getTransactionFee ?? 0;
    final energyInSun = chainParameters.getEnergyFee ?? 0;

    final userAccountInfo = await rpc.request(tron.TronRequestGetAccount(address: privateKey.publicKey().toAddress()));
    if (userAccountInfo == null) {
      throw NotActivatedAccountException();
    }

    final request = await rpc.request(
      tron.TronRequestTriggerConstantContract(
        ownerAddress: privateKey.publicKey().toAddress(),
        contractAddress: tron.TronAddress(contractAddress),
        data: function.encodeHex(transferParams),

        callValue: null,

        callTokenValue: null,
        tokenId: null,
      ),
    );

    energyNeed = request.energyUsed ?? 0;
    tron.TransactionRaw? rawTx = request.transactionRaw;

    final accountResource = await rpc.request(tron.TronRequestGetAccountResource(address: privateKey.publicKey().toAddress()));
    energyNeed -= accountResource.howManyEnergy.toInt();

    if (accountResource.howManyBandwIth > BigInt.from(bandWidthNeed)) {
      bandWidthNeed = 0;
    }

    if (energyNeed < 0) {
      energyNeed = 0;
    }

    final energyBurn = energyNeed * energyInSun.toInt();
    final bandWidthBurn = bandWidthNeed * bandWidthInSun;
    int totalBurn = energyBurn + bandWidthBurn;
    totalBurn += chainParameters.getMemoFee ?? 0;

    final receiverAccountInfo = await rpc.request(tron.TronRequestGetAccount(address: tron.TronAddress(to)));
    if (receiverAccountInfo == null) {
      totalBurn += chainParameters.getCreateNewAccountFeeInSystemContract!;
      totalBurn += (chainParameters.getCreateAccountFee! * bandWidthInSun);
    }

    return BigInt.from(totalBurn);
  }

  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, double amount) async {
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw NoBlockchainException(blockchain: blockchain);
    }

    final tokenData = tokens[token];
    if (tokenData == null) {
      throw NoTokenException(token: token);
    }

    final rpc = tron.TronProvider(TronHTTPProvider(url: blockchainData.rpc ?? ""));
    final privateKey = await _getPrivateKey();
    final contractAddress = tokenData.tokenContractAddress[blockchain];
    if (contractAddress == null) {
      throw NoTokenContractException(token: token, blockchain: blockchain);
    }

    final contract = tron.ContractABI.fromJson(erc20Abi, isTron: true);
    final function = contract.functionFromName("transfer");

    final transferParams = [tron.TronAddress(to), BigInt.from(amount)];
    final request = await rpc.request(
      tron.TronRequestTriggerConstantContract(
        ownerAddress: privateKey.publicKey().toAddress(),
        contractAddress: tron.TronAddress(contractAddress),
        data: function.encodeHex(transferParams),

        callValue: null,

        callTokenValue: null,
        tokenId: null,
      ),
    );

    if (!request.isSuccess) {
      throw TransactionFailedException(token: token, blockchain: blockchain, message: request.error);
    }

    final rawTr = request.transactionRaw!.copyWith(feeLimit: BigInt.from(10000000));
    final _ = rawTr.txID;
    final sign = privateKey.sign(rawTr.toBuffer());
    final transaction = tron.Transaction(rawData: rawTr, signature: [sign]);
    final raw = BytesUtils.toHexString(transaction.toBuffer());
    final result = await rpc.request(tron.TronRequestBroadcastHex(transaction: raw));

    return SendTokenResponse(token: Token.TRON,
        blockchain: blockchain,
        sentAmount: amount, transactionHash: result.txId ?? "");
  }

}