import 'dart:math';
import 'dart:typed_data';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:decimal/decimal.dart';
import 'package:on_chain/on_chain.dart' as tron;
import 'package:solana/encoder.dart' as solana_encoder;
import 'package:solana/solana.dart' as solana;
import 'package:surfy_mobile_app/abi/erc1559.g.dart';
import 'package:surfy_mobile_app/abi/erc20.dart';
import 'package:surfy_mobile_app/abi/erc20.g.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/service/blockchain//exceptions/exceptions.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/utils/bitcoin_explorer_service.dart';
import 'package:surfy_mobile_app/utils/tron_http_service.dart';
import 'package:surfy_mobile_app/utils/xrpl_http_service.dart';
import 'package:web3dart/crypto.dart';
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
  final BigInt sentAmount;
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
  Future<SendTokenResponse> send(Blockchain blockchain, String to, BigInt amount);
  Future<BigInt> estimateFee(Blockchain blockchain, String to, BigInt amount);
}

class SendEthereumHandler implements SendTokenHandler {
  SendEthereumHandler({required this.keyService});

  final KeyService keyService;

  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, BigInt amount) async {
    logger.i('Send: $blockchain, $to, $amount');
    final blockchainData = blockchains[blockchain];
    final client = Web3Client(blockchainData?.rpc ?? "", http.Client());
    final secp256K1 = (await keyService.getKey()).first;
    final credential = EthPrivateKey.fromHex(secp256K1);
    final gasPrice = await client.getGasPrice();

    final tx = Transaction(
      from: credential.address,
      to: EthereumAddress.fromHex(to),
      value: EtherAmount.fromBigInt(EtherUnit.wei, amount),
      gasPrice: gasPrice,
      maxGas: 50000,
    );
    final result = await client.sendTransaction(credential, tx, chainId: blockchainData?.chainId);
    return SendTokenResponse(token: Token.ETHEREUM, blockchain: blockchain, sentAmount: amount, transactionHash: result);
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, BigInt amount) async {
    final blockchainData = blockchains[blockchain];
    final client = Web3Client(blockchainData?.rpc ?? "", http.Client());
    final secp256K1 = (await keyService.getKey()).first;
    final credential = EthPrivateKey.fromHex(secp256K1);
    final result = await client.estimateGas(
      sender: credential.address,
      to: EthereumAddress.fromHex(to),
      value: EtherAmount.fromBigInt(EtherUnit.wei, amount),

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
  Future<SendTokenResponse> send(Blockchain blockchain, String to, BigInt amount) async {
    switch (blockchain) {
      case Blockchain.solana:
      case Blockchain.solana_devnet:
        return await splHandler.send(blockchain, to, amount);
      case Blockchain.ethereum:
      case Blockchain.arbitrum:
      case Blockchain.optimism:
      case Blockchain.base:
      case Blockchain.ethereum_sepolia:
      case Blockchain.arbitrum_sepolia:
      case Blockchain.optimism_sepolia:
      case Blockchain.base_sepolia:
        return await erc20Handler.send(blockchain, to, amount);
      default:
        throw NoBlockchainException(blockchain: blockchain);
    }
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, BigInt amount) async {
    switch (blockchain) {
      case Blockchain.solana:
      case Blockchain.solana_devnet:
        return await splHandler.estimateFee(blockchain, to, amount);
      case Blockchain.ethereum:
      case Blockchain.arbitrum:
      case Blockchain.optimism:
      case Blockchain.base:
      case Blockchain.ethereum_sepolia:
      case Blockchain.arbitrum_sepolia:
      case Blockchain.optimism_sepolia:
      case Blockchain.base_sepolia:
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
  Future<SendTokenResponse> send(Blockchain blockchain, String to, BigInt amount) async {
    logger.i('Send $token, network=$blockchain, to=$to, amount=$amount');
    final tokenData = tokens[token];
    final blockchainData = blockchains[blockchain];
    final contractAddress = tokenData?.tokenContractAddress[blockchain];
    final client = Web3Client(blockchainData?.rpc ?? "", http.Client());
    final erc20 = Erc20(address: EthereumAddress.fromHex(contractAddress ?? "0x0"), client: client, chainId: blockchainData?.chainId);
    final secp256K1 = (await keyService.getKey()).first;
    final credential = EthPrivateKey.fromHex(secp256K1);

    final gasPrice = await client.getGasPrice();
    final result = await erc20.transfer(
      (to: EthereumAddress.fromHex(to), value: amount),
      credentials: credential,
      transaction: Transaction(
        gasPrice: gasPrice,
        maxGas: 100000,
      )
    );
    return SendTokenResponse(token: token, blockchain: blockchain, sentAmount: amount, transactionHash: result);
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, BigInt amount) async {
    print('estimateFee: $blockchain, $to, $amount');
    final tokenData = tokens[token];
    final blockchainData = blockchains[blockchain];
    final contractAddress = tokenData?.tokenContractAddress[blockchain];
    final client = Web3Client(blockchainData?.rpc ?? "", http.Client());

    final erc1559 = Erc1559(address: EthereumAddress.fromHex(contractAddress ?? "0x0"), chainId: blockchainData?.chainId, client: client);
    final erc20 = Erc20(address: EthereumAddress.fromHex(contractAddress ?? "0x0"), chainId: blockchainData?.chainId, client: client);
    final secp256K1 = (await keyService.getKey()).first;
    final credential = EthPrivateKey.fromHex(secp256K1);
    final gasPrice = await client.getGasPrice();
    final tx = Transaction.callContract(
        contract: erc1559.self,
        function: erc1559.self.function('transfer'),
        parameters: [EthereumAddress.fromHex(to), amount],
    );
    final result = await client.estimateGas(
        sender: credential.address,
        to: EthereumAddress.fromHex(to),
        data: tx.data,
        gasPrice: gasPrice
    );
    final correction = BigInt.from(result.toDouble() * 2);
    return gasPrice.getInWei * correction;
  }
}

class SendSolanaHandler implements SendTokenHandler {
  SendSolanaHandler({required this.keyService});
  final KeyService keyService;

  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, BigInt amount) async {
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw NoBlockchainException(blockchain: blockchain);
    }

    final tokenData = tokens[Token.SOLANA];
    if (tokenData == null) {
      throw NoTokenException(token: Token.SOLANA);
    }

    final client = solana.SolanaClient(rpcUrl: Uri.parse(blockchainData.rpc), websocketUrl: Uri.parse(blockchainData.websocket ?? ""));
    final key = await keyService.getKey();
    final keyHex = hexToBytes(key.second);
    final userWallet = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: keyHex.take(32).toList());

    final instructions = [];
    final transferInstruction = solana.SystemInstruction.transfer(
        fundingAccount: userWallet.publicKey,
        recipientAccount: solana.Ed25519HDPublicKey.fromBase58(to),
        lamports: amount.toInt());
    instructions.add(transferInstruction);

    // TODO: add memo
    var memo = null;
    final message = solana_encoder.Message(
        instructions: [
          if (memo != null) solana.MemoInstruction(signers: const [], memo: memo),
          ...instructions,
        ]
    );

    final signedMsg = await client.rpcClient.signMessage(message, [userWallet]);
    final result = await client.rpcClient.sendTransaction(
      signedMsg.encode(),
      skipPreflight: true,
    );

    return SendTokenResponse(
        token: Token.SOLANA,
        blockchain: blockchain,
        sentAmount: amount,
        transactionHash: result
    );
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, BigInt amount) async {
    // print('solana pay: $blockchain $to $amount');
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw NoBlockchainException(blockchain: blockchain);
    }

    final tokenData = tokens[Token.SOLANA];
    if (tokenData == null) {
      throw NoTokenException(token: Token.SOLANA);
    }

    final client = solana.SolanaClient(rpcUrl: Uri.parse(blockchainData.rpc), websocketUrl: Uri.parse(blockchainData.websocket ?? ""));

    final receiverInfo = await client.rpcClient.getAccountInfo(to);
    if (receiverInfo.value == null) {
      return BigInt.from(2000000);
    }
    return BigInt.from(5000);
  }

}

class SendSplHandler implements SendTokenHandler {
  SendSplHandler({required this.token, required this.keyService});

  final Token token;
  final KeyService keyService;

  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, BigInt amount) async{
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw NoBlockchainException(blockchain: blockchain);
    }

    final tokenData = tokens[Token.SOLANA];
    if (tokenData == null) {
      throw NoTokenException(token: Token.SOLANA);
    }

    final client = solana.SolanaClient(rpcUrl: Uri.parse(blockchainData.rpc), websocketUrl: Uri.parse(blockchainData.websocket ?? ""));
    final key = await keyService.getKey();
    final keyHex = hexToBytes(key.second);
    final userWallet = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: keyHex.take(32).toList());

    final tokenContractAddress = tokens[token]?.tokenContractAddress[Blockchain.solana];

    final solAmount = amount / BigInt.from(pow(10, tokens[token]?.decimal ?? 0));

    final mint = await client.getMint(address: solana.Ed25519HDPublicKey.fromBase58(tokenContractAddress ?? ""));
    final value = Decimal.parse(solAmount.toString()).shift(mint.decimals).toBigInt().toInt();
    final payerAccount = await client.getAssociatedTokenAccount(
        owner: userWallet.publicKey,
        mint: mint.address);

    var instructions = [];
    final derivedAddress = await solana.Ed25519HDPublicKey.findProgramAddress(
      seeds: [
        solana.Ed25519HDPublicKey.fromBase58(to).bytes,
        solana.TokenProgram.id.toByteArray(),
        mint.address.bytes
      ],
      programId: solana.AssociatedTokenAccountProgram.id,
    );

    final setComputeUnitPrice = solana.ComputeBudgetInstruction.setComputeUnitPrice(
        microLamports: 20000000
    );
    instructions.add(setComputeUnitPrice);

    final setComputeUnitLimit = solana.ComputeBudgetInstruction.setComputeUnitLimit(
        units: 200000
    );
    instructions.add(setComputeUnitLimit);


    var recipientTokenAccount = await client.getAssociatedTokenAccount(
        owner: solana.Ed25519HDPublicKey.fromBase58(to),
        mint: mint.address);

    if (recipientTokenAccount == null) {
      print('not exist...');
      final instruction = solana.AssociatedTokenAccountInstruction.createAccount(
          funder: userWallet.publicKey,
          address: derivedAddress,
          owner: solana.Ed25519HDPublicKey.fromBase58(to),
          mint: mint.address);
      instructions.add(instruction);

      final transferInstruction = solana.TokenInstruction.transferChecked(
          amount: value,
          decimals: mint.decimals,
          source: solana.Ed25519HDPublicKey.fromBase58(payerAccount?.pubkey ?? ""),
          mint: mint.address,
          destination: derivedAddress,
          owner: userWallet.publicKey);
      instructions.add(transferInstruction);
    } else {
      print('existing address...');
      final instruction = solana.TokenInstruction.transferChecked(
          amount: value,
          decimals: mint.decimals,
          source: solana.Ed25519HDPublicKey.fromBase58(payerAccount?.pubkey ?? ""),
          mint: mint.address,
          destination: derivedAddress,
          owner: userWallet.publicKey);
      instructions.add(instruction);
    }

    // TODO: add memo
    var memo = null;
    final message = solana_encoder.Message(
        instructions: [
          if (memo != null) solana.MemoInstruction(signers: const [], memo: memo),
          ...instructions,
        ]
    );

    final signedMsg = await client.rpcClient.signMessage(message, [userWallet]);
    final result = await client.rpcClient.sendTransaction(
      signedMsg.encode(),
      skipPreflight: true,
    );

    return SendTokenResponse(
        token: token,
        blockchain: blockchain,
        sentAmount: amount,
        transactionHash: result
    );
  }

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, BigInt amount) async {
    final blockchainData = blockchains[blockchain];
    if (blockchainData == null) {
      throw NoBlockchainException(blockchain: blockchain);
    }

    final tokenData = tokens[Token.SOLANA];
    if (tokenData == null) {
      throw NoTokenException(token: Token.SOLANA);
    }

    final client = solana.SolanaClient(rpcUrl: Uri.parse(blockchainData.rpc), websocketUrl: Uri.parse(blockchainData.websocket ?? ""));

    final receiverInfo = await client.rpcClient.getAccountInfo(to);
    if (receiverInfo.value == null) {
      return BigInt.from(2000000);
    }
    return BigInt.from(5000);
  }
}

class SendXrpHandler implements SendTokenHandler {
  SendXrpHandler({required this.keyService});
  final KeyService keyService;
  
  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, BigInt amount) async {
    final syncRpc = XRPLRpc(RPCHttpService(RPCConst.mainetUri, http.Client()));
    final fee = await syncRpc.request(RPCFee());
    return BigInt.from(fee.calculateFeeDynamically());
  }

  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, BigInt amount) async {
    final key = await keyService.getKey();
    var wallet = XRPPrivateKey.fromHex(key.first, algorithm: XRPKeyAlgorithm.secp256k1);
    final syncRpc = XRPLRpc(RPCHttpService(RPCConst.mainetUri, http.Client()));
    final fee = await syncRpc.request(RPCFee());
    final payment = Payment(
      amount: CurrencyAmount.xrp(amount),
      destination: to,
      account: wallet.getPublic().toAddress().address,
      fee: BigInt.from(fee.calculateFeeDynamically()),
      signer: XRPLSignature.signer(wallet.getPublic().toHex()),
    );
    print('xrp payment: ${payment.amount}');
    await XRPHelper.autoFill(syncRpc, payment);
    final sig = wallet.sign(payment.toBlob());
    payment.setSignature(sig);
    final paymentBlob = payment.toBlob(forSigning: false);
    final result = await syncRpc.request(RPCSubmitOnly(txBlob: paymentBlob));
    if (!result.isSuccess) {
      throw TransactionFailedException(token: Token.XRP, blockchain: blockchain, message: result.engineResultMessage);
    }

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
  Future<BigInt> estimateFee(Blockchain blockchain, String to, BigInt amount) async {
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
      amount: amount,
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
  Future<SendTokenResponse> send(Blockchain blockchain, String to, BigInt amount) async {
    final key = await keyService.getKey();

    final blockchainData = blockchains[blockchain];
    final rpc = tron.TronProvider(TronHTTPProvider(url: blockchainData?.rpc ?? ""));
    final seed = BytesUtils.fromHexString(key.second);
    final bip44 = Bip44.fromSeed(seed, Bip44Coins.tron);
    final pk = tron.TronPrivateKey.fromBytes(bip44.privateKey.raw);

    final transferContract = tron.TransferContract(
      amount: amount,
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
  Future<BigInt> estimateFee(Blockchain blockchain, String to, BigInt amount) async {
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

    final transferParams = [tron.TronAddress(to), amount];
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
  Future<SendTokenResponse> send(Blockchain blockchain, String to, BigInt amount) async {
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

    final transferParams = [tron.TronAddress(to), amount];
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

class SendDogeHandler implements SendTokenHandler {
  SendDogeHandler({required this.keyService});

  final KeyService keyService;

  @override
  Future<BigInt> estimateFee(Blockchain blockchain, String to, BigInt amount) async {
    final service = BitcoinApiService();
    final api = ApiProvider.fromBlocCypher(DogecoinNetwork.mainnet, service);
    final fee = await api.getNetworkFeeRate();
    final result = (fee.high + fee.medium) / BigInt.from(2);
    final b = BigInt.from(result);
    return b;
  }

  @override
  Future<SendTokenResponse> send(Blockchain blockchain, String to, BigInt amount) async {
    final keys = await keyService.getKey();
    final privateKey = keys.first;
    final ecPrivate = ECPrivate.fromBytes(BytesUtils.fromHexString(privateKey));
    final pubKey = ecPrivate.getPublic();
    final p2pkhAddress = DogeAddress.fromBaseAddress(pubKey.toAddress());

    final service = BitcoinApiService();
    final api = ApiProvider.fromBlocCypher(DogecoinNetwork.mainnet, service);
    final receiver = P2pkhAddress.fromAddress(address: to, network: DogecoinNetwork.mainnet);

    final utxos = await api.getAccountUtxo(
        UtxoAddressDetails(
            publicKey: pubKey.toString(),
            address: p2pkhAddress.baseAddress
        )
    );

    final utxoList = <UtxoWithAddress>[];
    for (var utxo in utxos) {
      final detail = UtxoAddressDetails(publicKey: pubKey.toHex(), address: pubKey.toAddress());
      final utxoWithAddress = UtxoWithAddress(utxo: utxo.utxo, ownerDetails: detail);
      utxoList.add(utxoWithAddress);
    }
    final totalBalance = utxos.sumOfUtxosValue();
    final fee = BtcUtils.toSatoshi("0.1");
    final builder = BitcoinTransactionBuilder(
        outPuts: [
          BitcoinOutput(address: receiver, value: amount),
          BitcoinOutput(address: pubKey.toAddress(), value: totalBalance - amount - fee)
        ],
        fee: fee,
        network: DogecoinNetwork.mainnet,
        utxos: utxoList,
    );
    final tr = builder.buildTransaction((trDigest, utxo, publicKey, sigHash) {
      return ecPrivate.signInput(trDigest, sigHash: sigHash);
    });

    final result = await api.sendRawTransaction(tr.serialize());
    return SendTokenResponse(
        token: Token.DOGE,
        blockchain: blockchain,
        sentAmount: amount,
        transactionHash: result
    );
  }
}