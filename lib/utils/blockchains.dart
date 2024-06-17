import 'package:surfy_mobile_app/utils/rpc.dart';

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

class BlockchainData {
  const BlockchainData({
    required this.name,
    required this.isTestnet,
    required this.icon,
    required this.rpc,
    required this.websocket,
    required this.curve,
  });

  final String name;
  final String icon;
  final bool isTestnet;
  final String rpc;
  final String? websocket;
  final EllipticCurve curve;
}

final Map<Blockchain, BlockchainData> blockchains = {
  // ETHEREUM
  Blockchain.ETHEREUM: const BlockchainData(
      name: 'Ethereum',
      icon: "assets/images/tokens/ic_ethereum.png",
      isTestnet: false,
      rpc: RPC.ethereumMainnet,
      websocket: null,
      curve: EllipticCurve.SECP256K1,
  ),
  Blockchain.ETHEREUM_SEPOLIA: const BlockchainData(
      name: 'Ethereum Sepolia',
      icon: "assets/images/tokens/ic_ethereum.png",
      isTestnet: true,
      rpc: RPC.ethereumSepolia,
      websocket: null,
      curve: EllipticCurve.SECP256K1),

  // OPTIMISM
  Blockchain.OPTIMISM: const BlockchainData(
      name: 'Optimism',
      icon: "assets/images/tokens/ic_optimism.png",
      isTestnet: false,
      rpc: RPC.optimismMainnet,
      websocket: null,
      curve: EllipticCurve.SECP256K1),
  Blockchain.OPTIMISM_SEPOLIA: const BlockchainData(
      name: 'Optimism Sepolia',
      isTestnet: true,
      icon: "assets/images/tokens/ic_optimism.png",
      rpc: RPC.optimismSepolia,
      websocket: null,
      curve: EllipticCurve.SECP256K1),

  // ARBITRUM
  Blockchain.ARBITRUM: const BlockchainData(
      name: 'Arbitrum Sepolia',
      icon: "assets/images/tokens/ic_arbitrum.png",
      isTestnet: false,
      rpc: RPC.arbitrumMainnet,
      websocket: null,
      curve: EllipticCurve.SECP256K1),
  Blockchain.ARBITRUM_SEPOLIA: const BlockchainData(
      name: 'Arbitrum',
      icon: "assets/images/tokens/ic_arbitrum.png",
      isTestnet: false,
      rpc: RPC.arbitrumSepolia,
      websocket: null,
      curve: EllipticCurve.SECP256K1),

  // BASE
  Blockchain.BASE: const BlockchainData(
      name: 'Base',
      icon: "assets/images/tokens/ic_base.png",
      isTestnet: false,
      rpc: RPC.baseMainnet,
      websocket: null,
      curve: EllipticCurve.SECP256K1),
  Blockchain.BASE_SEPOLIA: const BlockchainData(
      name: 'Base Sepolia',
      icon: "assets/images/tokens/ic_base.png",
      isTestnet: true,
      rpc: RPC.baseSepolia,
      websocket: null,
      curve: EllipticCurve.SECP256K1),

  // SOLANA
  Blockchain.SOLANA: const BlockchainData(
      name: 'Solana',
      icon: "assets/images/tokens/ic_solana.png",
      isTestnet: false,
      rpc: RPC.solanaMainnet,
      websocket: RPC.wcSolanaMainnet,
      curve: EllipticCurve.ED25519),
  Blockchain.SOLANA_DEVNET: const BlockchainData(
      name: 'Solana Devnet',
      icon: "assets/images/tokens/ic_solana.png",
      isTestnet: true,
      rpc: RPC.solanaDevnet,
      websocket: RPC.wcSolanaDevnet,
      curve: EllipticCurve.ED25519),

  // BSC
  Blockchain.BSC: const BlockchainData(
      name: 'Binance Smart Chain',
      icon: "assets/images/tokens/ic_bsc.png",
      isTestnet: false,
      rpc: '',
      websocket: null,
      curve: EllipticCurve.SECP256K1),

  // TRON
  Blockchain.TRON: const BlockchainData(
      name: 'Tron',
      icon: "assets/images/tokens/ic_tron.png",
      isTestnet: false,
      rpc: '',
      websocket: null,
      curve: EllipticCurve.SECP256K1)
};
