import 'package:surfy_mobile_app/utils/rpc.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

enum EllipticCurve {
  SECP256K1,
  ED25519,
}

enum Blockchain {
  ETHEREUM,
  ETHEREUM_SEPOLIA,

  OPTIMISM,
  OPTIMISM_SEPOLIA,

  ARBITRUM,
  ARBITRUM_SEPOLIA,

  BASE,
  BASE_SEPOLIA,

  SOLANA,
  SOLANA_DEVNET,

  BSC,
  OP_BNB,

  TRON,

  XRPL,
}

Blockchain findBlockchainByName(String name) {
  final list = Blockchain.values.where((b) => b.name.toLowerCase() == name.toLowerCase());
  if (list.isEmpty) {
    throw Exception('No blockchain');
  }

  return list.first;
}

class BlockchainData {
  const BlockchainData({
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
  Blockchain.ETHEREUM: BlockchainData(
      chainId: 1,
      name: 'Ethereum',
      category: 'evm',
      icon: "assets/images/tokens/ic_ethereum.png",
      isTestnet: false,
      rpc: RPC.ethereumMainnet,
      websocket: null,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://etherscan.io/tx/$tx",
  ),
  Blockchain.ETHEREUM_SEPOLIA: BlockchainData(
      chainId: 11155111,
      name: 'Ethereum Sepolia',
      category: 'evm',
      icon: "assets/images/tokens/ic_ethereum.png",
      isTestnet: true,
      rpc: RPC.ethereumSepolia,
      websocket: null,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://sepolia.etherscan.io/tx/$tx",
  ),

  // OPTIMISM
  Blockchain.OPTIMISM: BlockchainData(
      chainId: 10,
      name: 'Optimism',
      category: 'evm',
      icon: "assets/images/tokens/ic_optimism.png",
      isTestnet: false,
      rpc: RPC.optimismMainnet,
      websocket: null,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://optimistic.etherscan.io/tx/$tx",
  ),
  Blockchain.OPTIMISM_SEPOLIA: BlockchainData(
      chainId: 11155420,
      name: 'Optimism Sepolia',
      category: 'evm',
      isTestnet: true,
      icon: "assets/images/tokens/ic_optimism.png",
      rpc: RPC.optimismSepolia,
      websocket: null,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://sepolia-optimistic.etherscan.io/tx/$tx"
  ),

  // ARBITRUM
  Blockchain.ARBITRUM: BlockchainData(
      chainId: 42161,
      name: 'Arbitrum Sepolia',
      category: 'evm',
      icon: "assets/images/tokens/ic_arbitrum.png",
      isTestnet: false,
      rpc: RPC.arbitrumMainnet,
      websocket: null,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://arbiscan.io/tx/$tx"
  ),
  Blockchain.ARBITRUM_SEPOLIA: BlockchainData(
      chainId: 421614,
      name: 'Arbitrum',
      category: 'evm',
      icon: "assets/images/tokens/ic_arbitrum.png",
      isTestnet: false,
      rpc: RPC.arbitrumSepolia,
      websocket: null,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://sepolia.arbiscan.io/tx/$tx"
  ),

  // BASE
  Blockchain.BASE: BlockchainData(
      chainId: 8453,
      name: 'Base',
      category: 'evm',
      icon: "assets/images/tokens/ic_base.png",
      isTestnet: false,
      rpc: RPC.baseMainnet,
      websocket: null,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://basescan.org/tx/$tx"
  ),
  Blockchain.BASE_SEPOLIA: BlockchainData(
      chainId: 84532,
      name: 'Base Sepolia',
      category: 'evm',
      icon: "assets/images/tokens/ic_base.png",
      isTestnet: true,
      rpc: RPC.baseSepolia,
      websocket: null,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://sepolia.basescan.org/tx/$tx"
  ),

  // SOLANA
  Blockchain.SOLANA: BlockchainData(
      chainId: null,
      name: 'Solana',
      category: 'solana',
      icon: "assets/images/tokens/ic_solana.png",
      isTestnet: false,
      rpc: RPC.solanaMainnet,
      websocket: RPC.wcSolanaMainnet,
      curve: EllipticCurve.ED25519,
      feeCoin: Token.SOLANA,
      getScanUrl: (String tx) => "https://explorer.solana.com/tx/$tx"
  ),
  Blockchain.SOLANA_DEVNET: BlockchainData(
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
  Blockchain.BSC: BlockchainData(
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
  Blockchain.OP_BNB: BlockchainData(
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
  Blockchain.TRON: BlockchainData(
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
  Blockchain.XRPL: BlockchainData(
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
  )
};