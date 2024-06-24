import 'package:surfy_mobile_app/utils/rpc.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

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

  TRON,
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
    required this.isTestnet,
    required this.icon,
    required this.rpc,
    required this.websocket,
    required this.curve,
    required this.feeCoin,
    required this.getScanUrl,
  });

  final String name;
  final String icon;
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
      name: 'Ethereum',
      icon: "assets/images/tokens/ic_ethereum.png",
      isTestnet: false,
      rpc: RPC.ethereumMainnet,
      websocket: null,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://etherscan.io/tx/$tx",
  ),
  Blockchain.ETHEREUM_SEPOLIA: BlockchainData(
      name: 'Ethereum Sepolia',
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
      name: 'Optimism',
      icon: "assets/images/tokens/ic_optimism.png",
      isTestnet: false,
      rpc: RPC.optimismMainnet,
      websocket: null,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://optimistic.etherscan.io/tx/$tx",
  ),
  Blockchain.OPTIMISM_SEPOLIA: BlockchainData(
      name: 'Optimism Sepolia',
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
      name: 'Arbitrum Sepolia',
      icon: "assets/images/tokens/ic_arbitrum.png",
      isTestnet: false,
      rpc: RPC.arbitrumMainnet,
      websocket: null,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://arbiscan.io/tx/$tx"
  ),
  Blockchain.ARBITRUM_SEPOLIA: BlockchainData(
      name: 'Arbitrum',
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
      name: 'Base',
      icon: "assets/images/tokens/ic_base.png",
      isTestnet: false,
      rpc: RPC.baseMainnet,
      websocket: null,
      curve: EllipticCurve.SECP256K1,
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://basescan.org/tx/$tx"
  ),
  Blockchain.BASE_SEPOLIA: BlockchainData(
      name: 'Base Sepolia',
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
      name: 'Solana',
      icon: "assets/images/tokens/ic_solana.png",
      isTestnet: false,
      rpc: RPC.solanaMainnet,
      websocket: RPC.wcSolanaMainnet,
      curve: EllipticCurve.ED25519,
      feeCoin: Token.SOLANA,
      getScanUrl: (String tx) => "https://explorer.solana.com/tx/$tx"
  ),
  Blockchain.SOLANA_DEVNET: BlockchainData(
      name: 'Solana Devnet',
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
      name: 'Binance Smart Chain',
      icon: "assets/images/tokens/ic_bsc.png",
      isTestnet: false,
      rpc: '',
      websocket: null,
      curve: EllipticCurve.SECP256K1,
    // TODO : fix feecoin
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://bscscan.com/tx/$tx"
  ),

  // TRON
  Blockchain.TRON: BlockchainData(
      name: 'Tron',
      icon: "assets/images/tokens/ic_tron.png",
      isTestnet: false,
      rpc: '',
      websocket: null,
      curve: EllipticCurve.SECP256K1,
      // TODO : fix feecoin
      feeCoin: Token.ETHEREUM,
      getScanUrl: (String tx) => "https://tronscan.org/#/transaction/$tx"
  )
};
