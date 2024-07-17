import 'package:hive/hive.dart';
part 'contact.g.dart';

@HiveType(typeId: 1)
class Contact extends HiveObject {
  Contact(this.blockchain, this.address, this.memo);

  @HiveField(0)
  String blockchain;

  @HiveField(1)
  String address;

  @HiveField(2)
  String? memo;

  @override
  String toString() {
    return {
      "blockchain": blockchain,
      "address": address,
      "memo": memo,
    }.toString();
  }
}