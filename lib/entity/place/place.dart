import 'package:surfy_mobile_app/settings/settings_preference.dart';

class Place {
  const Place({
    required this.storeName,
    required this.owner,
    required this.latitude,
    required this.longitude,
    required this.thumbnail,
    required this.address,
    required this.phone,
    required this.email,
    required this.category,
    required this.nation,
    required this.sns,
  });

  final String storeName;
  final String owner;
  final double latitude;
  final double longitude;
  final String thumbnail;
  final String address;
  final String phone;
  final String email;
  final String category;
  final String nation;
  final List<MerchantSns> sns;

  @override
  String toString() {
    return {
      "storeName": storeName,
      "owner": owner,
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
      "thumbnail": thumbnail,
      "phone": phone,
      "email": email,
      "category": category,
      "nation": nation,
      "sns": sns
    }.toString();
  }
}

class MerchantWallet {
  const MerchantWallet({
    required this.walletAddress,
    required this.walletCategory,
    required this.blockchain,
  });

  final String walletAddress;
  final String walletCategory;
  final String blockchain;

  @override
  String toString() {
    return {
      "walletAddress": walletAddress,
      "walletCategory": walletCategory,
      "blockchain": blockchain,
    }.toString();
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
}