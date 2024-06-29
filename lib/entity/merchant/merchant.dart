class Merchant {
  const Merchant({
    required this.id,
    required this.storeName,
    required this.owner,
    required this.latitude,
    required this.longitude,
    required this.thumbnail,
    required this.address,
    required this.phone,
    required this.email,
    required this.category,
    required this.currency,
    required this.nation,
    required this.sns,
    required this.wallets,
  });

  final String id;
  final String storeName;
  final String owner;
  final double latitude;
  final double longitude;
  final String thumbnail;
  final String address;
  final String currency;
  final String phone;
  final String email;
  final String category;
  final String nation;
  final List<MerchantSns> sns;
  final List<MerchantWallet>? wallets;

  @override
  String toString() {
    return {
      "id": id,
      "storeName": storeName,
      "owner": owner,
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
      "thumbnail": thumbnail,
      "phone": phone,
      "email": email,
      "category": category,
      "currency": currency,
      "nation": nation,
      "sns": sns,
      "wallets": wallets,
    }.toString();
  }

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] ?? "",
      storeName: json['storeName'] ?? "",
      owner: json['owner'] ?? "",
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      thumbnail: json['thumbnail'] ?? "",
      address: json['address'] ?? "",
      phone: json['phone'] ?? "",
      email: json['email'] ?? "",
      category: json['category'] ?? "",
      currency: json['currency'] ?? "",
      nation: json['nation'] ?? "",
      sns: json['sns']?.map<MerchantSns>((item) => MerchantSns.fromJson(item)).toList() ?? [],
      wallets: json['wallets']?.map<MerchantWallet>((item) => MerchantWallet.fromJson(item)).toList() ?? [],
    );
  }
}

class MerchantWallet {
  const MerchantWallet({
    required this.walletAddress,
    required this.walletCategory,
    required this.blockchain,
  });

  final String? walletAddress;
  final String? walletCategory;
  final String? blockchain;

  @override
  String toString() {
    return {
      "walletAddress": walletAddress,
      "walletCategory": walletCategory,
      "blockchain": blockchain,
    }.toString();
  }

  factory MerchantWallet.fromJson(Map<String, dynamic> json) {
    return MerchantWallet(
        walletAddress: json['walletAddress'],
        walletCategory: json['walletCategory'] ?? "",
        blockchain: json['blockchain']
    );
  }
}

class MerchantSns {
  const MerchantSns({
    required this.type,
    required this.url,
  });

  final String type;
  final String url;

  @override
  String toString() {
    return {
      "type": type,
      "url": url,
    }.toString();
  }

  factory MerchantSns.fromJson(Map<String, dynamic> json) {
    return MerchantSns(type: json['type'], url: json['url']);
  }
}