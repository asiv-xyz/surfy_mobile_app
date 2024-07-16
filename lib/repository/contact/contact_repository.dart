import 'package:surfy_mobile_app/cache/contact/contact_cache.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/entity/contact/contact.dart';

class ContactRepository {
  ContactRepository({
    required this.cache,
  });

  final ContactCache cache;

  Future<List<Contact>> getRecentSentContacts(Blockchain blockchain) async {
    return await cache.getRecentSentContacts(blockchain);
  }
}