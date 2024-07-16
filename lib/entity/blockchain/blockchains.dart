import 'package:dartx/dartx.dart';
import 'package:surfy_mobile_app/utils/rpc.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

enum EllipticCurve {
  SECP256K1,
  ED25519,
}

enum Blockchain {
  ethereum,
  ethereum_sepolia,

  optimism,
  optimism_sepolia,

  arbitrum,
  arbitrum_sepolia,

  base,
  base_sepolia,

  solana,
  solana_devnet,

  bsc,
  opbnb,

  tron,

  xrpl,

  dogechain,
}

Blockchain findBlockchainByName(String name) {
  final list = Blockchain.values.where((b) => b.name.toLowerCase() == name.toLowerCase());
  if (list.isEmpty) {
    throw Exception('No blockchain');
  }

  return list.first;
}

BlockchainData findBlockchainByChainId(int chainId) {
  final list = blockchains.filter((b) => b.value.chainId == chainId);
  if (list.isEmpty) {
    throw Exception('No blockchain for id: $chainId');
  }

  return list.values.first;
}

class BlockchainData {
  const BlockchainData({
    required this.blockchain,
    required this.name,
    required this.category,
    required this.isTestnet,
    required this.icon,
    required this.rpc,
    required this.websocket,
    required this.curve,
    required this.feeCoin,
    required this.getScanUrl,
    required this.chainId,
  });

  final Blockchain blockchain;
  final int? chainId;
  final String name;
  final String icon;
  final String? category;
  final bool isTestnet;
  final String rpc;
  final String? websocket;
  final EllipticCurve curve;
  final Token feeCoin;
  final Function getScanUrl;
}

final Map<Blockchain, BlockchainData> blockchains = {
  // ETHEREUM
  Blockchain.ethereum: BlockchainData(
      blockchain: Blockchain.ethereum,
      chainId: 1,
      name: 'Ethereum',
      category: 'evm',
      icon: "assets/images/tokens/ic_ethereum.png",
      isTestnet: false,
      rpc: RPC.ethereumMainnet,
      websocket: WebSocket.ethereumMainnet,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://etherscan.io/tx/$tx",
  ),
  Blockchain.ethereum_sepolia: BlockchainData(
      blockchain: Blockchain.ethereum_sepolia,
      chainId: 11155111,
      name: 'Ethereum Sepolia',
      category: 'evm',
      icon: "assets/images/tokens/ic_ethereum.png",
      isTestnet: true,
      rpc: RPC.ethereumSepolia,
      websocket: WebSocket.ethereumSepolia,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://sepolia.etherscan.io/tx/$tx",
  ),

  // OPTIMISM
  Blockchain.optimism: BlockchainData(
      blockchain: Blockchain.optimism,
      chainId: 10,
      name: 'Optimism',
      category: 'evm',
      icon: "assets/images/tokens/ic_optimism.png",
      isTestnet: false,
      rpc: RPC.optimismMainnet,
      websocket: WebSocket.optimismMainnet,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://optimistic.etherscan.io/tx/$tx",
  ),
  Blockchain.optimism_sepolia: BlockchainData(
      blockchain: Blockchain.optimism_sepolia,
      chainId: 11155420,
      name: 'Optimism Sepolia',
      category: 'evm',
      isTestnet: true,
      icon: "assets/images/tokens/ic_optimism.png",
      rpc: RPC.optimismSepolia,
      websocket: WebSocket.optimismSepolia,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://sepolia-optimistic.etherscan.io/tx/$tx"
  ),

  // ARBITRUM
  Blockchain.arbitrum: BlockchainData(
      blockchain: Blockchain.arbitrum,
      chainId: 42161,
      name: 'Arbitrum Sepolia',
      category: 'evm',
      icon: "assets/images/tokens/ic_arbitrum.png",
      isTestnet: false,
      rpc: RPC.arbitrumMainnet,
      websocket: WebSocket.arbitrumMainnet,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://arbiscan.io/tx/$tx"
  ),
  Blockchain.arbitrum_sepolia: BlockchainData(
      blockchain: Blockchain.arbitrum_sepolia,
      chainId: 421614,
      name: 'Arbitrum',
      category: 'evm',
      icon: "assets/images/tokens/ic_arbitrum.png",
      isTestnet: false,
      rpc: RPC.arbitrumSepolia,
      websocket: WebSocket.arbitrumSepolia,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://sepolia.arbiscan.io/tx/$tx"
  ),

  // BASE
  Blockchain.base: BlockchainData(
      blockchain: Blockchain.base,
      chainId: 8453,
      name: 'Base',
      category: 'evm',
      icon: "assets/images/tokens/ic_base.png",
      isTestnet: false,
      rpc: RPC.baseMainnet,
      websocket: WebSocket.baseMainnet,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://basescan.org/tx/$tx"
  ),
  Blockchain.base_sepolia: BlockchainData(
      blockchain: Blockchain.base_sepolia,
      chainId: 84532,
      name: 'Base Sepolia',
      category: 'evm',
      icon: "assets/images/tokens/ic_base.png",
      isTestnet: true,
      rpc: RPC.baseSepolia,
      websocket: WebSocket.baseSepolia,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://sepolia.basescan.org/tx/$tx"
  ),

  // SOLANA
  Blockchain.solana: BlockchainData(
      blockchain: Blockchain.solana,
      chainId: null,
      name: 'Solana',
      category: 'solana',
      icon: "assets/images/tokens/ic_solana.png",
      isTestnet: false,
      rpc: RPC.solanaMainnet,
      websocket: RPC.wcSolanaMainnet,
      curve: EllipticCurve.ED25519,
      feeCoin: Token.SOLANA,
      getScanUrl: (String tx) => "https://solscan.io/tx/$tx"
  ),
  Blockchain.solana_devnet: BlockchainData(
      blockchain: Blockchain.solana_devnet,
      chainId: null,
      name: 'Solana Devnet',
      category: 'solana',
      icon: "assets/images/tokens/ic_solana.png",
      isTestnet: true,
      rpc: RPC.solanaDevnet,
      websocket: RPC.wcSolanaDevnet,
      curve: EllipticCurve.ED25519,
      feeCoin: Token.SOLANA,
      getScanUrl: (String tx) => "https://explorer.solana.com/tx/$tx?cluster=devnet"
  ),

  // BSC
  Blockchain.bsc: BlockchainData(
      blockchain: Blockchain.bsc,
      chainId: 56,
      name: 'Binance Smart Chain',
      category: 'evm',
      icon: "assets/images/tokens/ic_bsc.png",
      isTestnet: false,
      rpc: 'https://bsc-dataseed1.binance.org/',
      websocket: null,
      curve: EllipticCurve.SECP256K1,
    // TODO : fix feecoin
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://bscscan.com/tx/$tx"
  ),

  // OP_BNB
  Blockchain.opbnb: BlockchainData(
    blockchain: Blockchain.opbnb,
    chainId: 204,
    name: 'opBNB',
    category: 'evm',
    icon: "assets/images/tokens/ic_bsc.png",
    isTestnet: false,
    rpc: "https://opbnb-rpc.publicnode.com",
    websocket: null,
    curve: EllipticCurve.SECP256K1,
    feeCoin: Token.BNB,
    getScanUrl: (String tx) => "https://opbnb.bscscan.com/tx/$tx",
  ),


  // TRON
  Blockchain.tron: BlockchainData(
      blockchain: Blockchain.tron,
      chainId: null,
      name: 'Tron',
      category: 'tron',
      icon: "assets/images/tokens/ic_tron.png",
      isTestnet: false,
      rpc: 'https://api.trongrid.io',
      websocket: null,
      curve: EllipticCurve.ED25519,
      feeCoin: Token.TRON,
      getScanUrl: (String tx) => "https://tronscan.org/#/transaction/$tx"
  ),

  // XRPL
  Blockchain.xrpl: BlockchainData(
    blockchain: Blockchain.xrpl,
    chainId: null,
    name: 'XRPL',
    category: 'xrpl',
    icon: 'assets/images/tokens/ic_xrpl.png',
    isTestnet: false,
    rpc: RPCConst.mainetUri,
    websocket: null,
    curve: EllipticCurve.SECP256K1,
    feeCoin: Token.XRP,
    getScanUrl: (String tx) => "https://xrpscan.com/tx/$tx",
  ),

  // DOGECHAIN
  Blockchain.dogechain: BlockchainData(
    blockchain: Blockchain.dogechain,
    chainId: null,
    name: 'DogeChain',
    category: 'dogechain',
    icon: 'assets/images/tokens/ic_dogecoin.png',
    isTestnet: false,
    rpc: '',
    websocket: null,
    curve: EllipticCurve.SECP256K1,
    feeCoin: Token.DOGE,
    getScanUrl: (String tx) => "https://dogechain.info/tx/$tx",
  )
};