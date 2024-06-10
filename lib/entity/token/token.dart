abstract class DigitalAsset {
  const DigitalAsset({required this.name, required this.network, required this.decimal});

  final String name;
  final String network;
  final int decimal;
}

class FungibleToken extends DigitalAsset {
  const FungibleToken({name, network, decimal, required this.contractAddress}): super(name: name, network: network, decimal: decimal);

  final String contractAddress;
}

class Coin extends DigitalAsset {
  const Coin({name, network, decimal}): super(name: name, network: network, decimal: decimal);
}