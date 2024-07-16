String shortAddress(String address) {
  return "${address.substring(0, 6)}...${address.substring(address.length - 5, address.length)}";
}

String contactAddress(String address) {
  return "${address.substring(0, 9)}...${address.substring(address.length - 9, address.length)}";
}