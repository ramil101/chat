import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String? imageUrl;
  final String messageType; // 'text' or 'image'
  final bool seen; // Whether the message has been seen by the receiver

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.imageUrl,
    this.messageType = 'text',
    this.seen = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'messageType': messageType,
      'seen': seen,
    };
  }
}
