class Chat {
  List<dynamic> messages;
  String chatName;
  String chatId;
  List<dynamic> members;
  bool individual;

  Chat({
    required this.messages,
    required this.chatName,
    required this.members,
    required this.individual,
    required this.chatId,
  }) {
    this.messages = messages;
    this.chatName = chatName;
    this.members = members;
    this.individual = individual;
  }

  factory Chat.fromMap(Map<String, dynamic> json) => new Chat(
        chatId: json['chatId'],
        messages: json['message'],
        chatName: json['chatName'],
        members: json['members'],
        individual: json['individual'],
      );
}
