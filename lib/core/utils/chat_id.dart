/// Builds a deterministic chat document id from two user ids.
String buildChatId(String userIdA, String userIdB) {
  final ids = [userIdA, userIdB]..sort();
  return '${ids[0]}_${ids[1]}';
}
