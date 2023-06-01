import 'dart:convert';

import 'package:utmletgo/constants/enum_constants.dart';

class Message {
  String guid = '',
      message = '',
      messageType = ChatMessageType.text.name,
      senderGuid = '';
  String timeSent = '';
  String readyBy = '';
  Message();
  Message.complete(this.guid, this.message, this.messageType, this.senderGuid,
      this.timeSent, this.readyBy);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'guid': guid,
      'message': message,
      'messageType': messageType,
      'timeSent': timeSent,
      'senderGuid': senderGuid,
      'readyBy': readyBy
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message.complete(
        map['guid'] as String,
        map['message'] as String,
        map['messageType'] as String,
        map['senderGuid'] as String,
        map['timeSent'] as String,
        map['readyBy'] as String);
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);
}
