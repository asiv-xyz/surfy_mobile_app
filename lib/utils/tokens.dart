import 'package:surfy_mobile_app/utils/blockchains.dart';

enum Token {
  ETHEREUM,
  SOLANA,
  USDC,
  USDT,
  DOGE,
  DEGEN,
  // TON,
  BNB,
  XRP,
  TRON,
}

Token findTokenByName(String name) {
  final list = tokens.entries.where((tokenData) {
    final item = tokenData.value;
    if (name.toLowerCase() == item.name.toLowerCase()) {
      return true;
    }

    return false;
  }).toList();

  if (list.isEmpty) {
    throw Exception('No token: $name');
  }

  return list.first.key;
}

class TokenData {
  const TokenData({
    required this.token,
    required this.name,
    required this.symbol,
    required this.supportedBlockchain,
    required this.iconAsset,
    required this.isToken,
    required this.tokenContractAddress,
    required this.decimal,
    required this.cgIdentifier,
    required this.fixedDecimal,
  });

  final Token token;
  final String name;
  final String symbol;
  final List<Blockchain> supportedBlockchain;
  final String iconAsset;
  final bool isToken;
  final Map<Blockchain, String> tokenContractAddress;
  final int decimal;
  final String cgIdentifier;
  final int fixedDecimal;
}

const Map<Token, TokenData> tokens = {
  Token.ETHEREUM: TokenData(
    token: Token.ETHEREUM,
    name: "Ethereum",
    symbol: "ETH",
    supportedBlockchain: [
      Blockchain.ETHEREUM,
      Blockchain.ETHEREUM_SEPOLIA,
      // Blockchain.OPTIMISM,
      // Blockchain.ARBITRUM,
      Blockchain.BASE,
      Blockchain.BASE_SEPOLIA,
    ],
    iconAsset: "assets/images/tokens/ic_ethereum.png",
    isToken: false,
    tokenContractAddress: {},
    decimal: 18,
    cgIdentifier: "ethereum",
    fixedDecimal: 5,
  ),
  Token.USDC: TokenData(
    token: Token.USDC,
    name: "USDC",
    symbol: "USDC",
    supportedBlockchain: [
      Blockchain.ETHEREUM,
      Blockchain.ETHEREUM_SEPOLIA,
      Blockchain.BASE,
      Blockchain.BASE_SEPOLIA,
      Blockchain.SOLANA,
      Blockchain.SOLANA_DEVNET
    ],
    iconAsset: "assets/images/tokens/ic_usdc.png",
    isToken: true,
    tokenContractAddress: {
      Blockchain.ETHEREUM: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
      Blockchain.ETHEREUM_SEPOLIA: "0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238",
      Blockchain.BASE: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
      Blockchain.BASE_SEPOLIA: "0x036CbD53842c5426634e7929541eC2318f3dCF7e",
      Blockchain.SOLANA: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
      Blockchain.SOLANA_DEVNET: "4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU",
    },
    decimal: 6,
    cgIdentifier: "usd-coin",
    fixedDecimal: 2,
  ),
  Token.USDT: TokenData(
    token: Token.USDT,
    name: "Tether",
    symbol: "Tether",
    supportedBlockchain: [
      Blockchain.ETHEREUM,
      Blockchain.SOLANA,
      Blockchain.TRON,
    ],
    iconAsset: "assets/images/tokens/ic_tether.png",
    isToken: true,
    tokenContractAddress: {
      Blockchain.ETHEREUM: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
      // Blockchain.ETHEREUM_SEPOLIA: "",
      Blockchain.SOLANA: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB",
      // Blockchain.SOLANA_DEVNET: "",
      Blockchain.TRON: "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t"
    },
    decimal: 6,
    cgIdentifier: "tether",
    fixedDecimal: 2,
  ),
  Token.SOLANA: TokenData(
    token: Token.SOLANA,
    name: "Solana",
    symbol: "SOL",
    supportedBlockchain: [
      Blockchain.SOLANA,
      Blockchain.SOLANA_DEVNET
    ],
    iconAsset: "assets/images/tokens/ic_solana.png",
    isToken: false,
    tokenContractAddress: {},
    decimal: 9,
    cgIdentifier: "solana",
    fixedDecimal: 2,
  ),
  Token.DEGEN: TokenData(
    token: Token.DEGEN,
    name: "Degen",
    symbol: "DEGEN",
    supportedBlockchain: [Blockchain.BASE],
    iconAsset: "assets/images/tokens/ic_degen.png",
    isToken: true,
    tokenContractAddress: {
      Blockchain.BASE: "0x4ed4E862860beD51a9570b96d89aF5E1B0Efefed",
      // Blockchain.BASE_SEPOLIA: "",
    },
    decimal: 18,
    cgIdentifier: "degen-base",
    fixedDecimal: 2,
  ),
  Token.DOGE: TokenData(
    token: Token.DOGE,
    name: "Dogecoin",
    symbol: "DOGE",
    supportedBlockchain: [
      Blockchain.BSC
    ],
    iconAsset: "assets/images/tokens/ic_dogecoin.png",
    isToken: true,
    tokenContractAddress: {
      Blockchain.BSC: "0xbA2aE424d960c26247Dd6c32edC70B295c744C43",
    },
    decimal: 8,
    cgIdentifier: "dogecoin",
    fixedDecimal: 2,
  ),
  Token.XRP: TokenData(
    token: Token.XRP,
    name: "XRP",
    symbol: "XRP",
    supportedBlockchain: [Blockchain.XRPL],
    iconAsset: "assets/images/tokens/ic_xrpl.png",
    isToken: false,
    tokenContractAddress: {},
    decimal: 6,
    cgIdentifier: "ripple",
    fixedDecimal: 4,
  ),

  Token.BNB: TokenData(
    token: Token.BNB,
    name: "BNB",
    symbol: "BNB",
    supportedBlockchain: [Blockchain.BSC, Blockchain.OP_BNB],
    iconAsset: "assets/images/tokens/ic_bnb.png",
    isToken: false,
    tokenContractAddress: {
      Blockchain.OP_BNB: "0x4200000000000000000000000000000000000006",
    },
    decimal: 6,
    cgIdentifier: "binancecoin",
    fixedDecimal: 3
  ),

  Token.TRON: TokenData(
    token: Token.TRON,
    name: "Tron",
    symbol: "Tron",
    supportedBlockchain: [Blockchain.TRON],
    iconAsset: "assets/images/tokens/ic_tron.png",
    isToken: false,
    tokenContractAddress: {},
    decimal: 6,
    cgIdentifier: "tron",
    fixedDecimal: 4
  )
};
