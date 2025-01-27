import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/models/message.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final cloudinary = CloudinaryPublic('dft7nuibo', 'chat_preset', cache: false);

  // Update user online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    if (_auth.currentUser == null) return;

    await _firestore.collection("Users").doc(_auth.currentUser!.uid).update({
      'isOnline': isOnline,
      'lastSeen': Timestamp.now(),
    });
  }

  // Format last seen time
  String getLastSeenText(Timestamp? lastSeen) {
    if (lastSeen == null) return 'Offline';

    final now = DateTime.now();
    final lastSeenDate = lastSeen.toDate();
    final difference = now.difference(lastSeenDate);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Get friends stream
  Stream<List<Map<String, dynamic>>> getFriendsStream() {
    final currentUserID = _auth.currentUser!.uid;

    return _firestore
        .collection("Friendships")
        .where('participants', arrayContains: currentUserID)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((friendSnapshot) async {
      List<Map<String, dynamic>> friends = [];

      for (var doc in friendSnapshot.docs) {
        final participants = List<String>.from(doc['participants']);
        final friendID = participants.firstWhere((id) => id != currentUserID);

        // Get friend's user data
        final userData =
            await _firestore.collection("Users").doc(friendID).get();
        if (userData.exists) {
          final friendData = userData.data()!;
          friendData['friendshipId'] = doc.id;
          friends.add(friendData);
        }
      }

      return friends;
    });
  }

  // Get friend requests stream
  Stream<List<Map<String, dynamic>>> getFriendRequestsStream() {
    final currentUserID = _auth.currentUser!.uid;

    return _firestore
        .collection("Friendships")
        .where('receiverId', isEqualTo: currentUserID)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((requestSnapshot) async {
      List<Map<String, dynamic>> requests = [];

      for (var doc in requestSnapshot.docs) {
        final senderId = doc.data()['senderId'];

        // Get sender's user data
        final userData =
            await _firestore.collection("Users").doc(senderId).get();
        if (userData.exists) {
          final senderData = userData.data()!;
          senderData['requestId'] = doc.id;
          requests.add(senderData);
        }
      }

      return requests;
    });
  }

  // Search users
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final currentUserID = _auth.currentUser!.uid;

    // Get all friendships (both pending and accepted)
    final friendshipsSnapshot = await _firestore
        .collection("Friendships")
        .where('participants', arrayContains: currentUserID)
        .get();

    final connectedUserIds = friendshipsSnapshot.docs.map((doc) {
      final participants = List<String>.from(doc['participants']);
      return participants.firstWhere((id) => id != currentUserID);
    }).toList();

    // Search users by display name or email
    final usersSnapshot = await _firestore.collection("Users").get();

    return usersSnapshot.docs.map((doc) => doc.data()).where((userData) {
      final displayName =
          userData['displayName']?.toString().toLowerCase() ?? '';
      final email = userData['email']?.toString().toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();

      return (displayName.contains(searchQuery) ||
              email.contains(searchQuery)) &&
          userData['uid'] != currentUserID &&
          !connectedUserIds.contains(userData['uid']);
    }).toList();
  }

  // Send friend request
  Future<void> sendFriendRequest(String receiverId) async {
    final currentUserID = _auth.currentUser!.uid;

    // Create friendship document with pending status
    await _firestore.collection("Friendships").add({
      'senderId': currentUserID,
      'receiverId': receiverId,
      'participants': [currentUserID, receiverId],
      'status': 'pending',
      'timestamp': Timestamp.now(),
    });
  }

  // Accept friend request
  Future<void> acceptFriendRequest(String requestId) async {
    await _firestore.collection("Friendships").doc(requestId).update({
      'status': 'accepted',
      'acceptedAt': Timestamp.now(),
    });
  }

  // Reject/Cancel friend request
  Future<void> rejectFriendRequest(String requestId) async {
    await _firestore.collection("Friendships").doc(requestId).delete();
  }

  // Remove friend
  Future<void> removeFriend(String friendshipId) async {
    await _firestore.collection("Friendships").doc(friendshipId).delete();
  }

  // Get users stream (now only returns accepted friends)
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return getFriendsStream();
  }

//SEND A MESSAGE
  Future<void> sendMessage(String receiverID, String message,
      {File? imageFile, XFile? webImage}) async {
    // Get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    String? imageUrl;
    String messageType = 'text';

    // Handle image upload for both web and mobile
    if (imageFile != null || webImage != null) {
      try {
        CloudinaryResponse response;
        if (webImage != null) {
          // Handle web image
          response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(webImage.path, folder: 'chat_images'),
          );
        } else {
          // Handle mobile image
          response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(imageFile!.path, folder: 'chat_images'),
          );
        }
        imageUrl = response.secureUrl;
        messageType = 'image';
      } catch (e) {
        print('Error uploading image: $e');
        return;
      }
    }

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
      imageUrl: imageUrl,
      messageType: messageType,
    );

    // Create chat room ID using UIDs instead of emails
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // Sort IDs to ensure same chat room ID regardless of sender/receiver
    String chatRoomId = ids.join("_");

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }

//get message
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    // Create chat room ID using UIDs
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Mark messages as seen
  Future<void> markMessagesAsSeen(String otherUserID) async {
    final String currentUserID = _auth.currentUser!.uid;
    
    // Create chat room ID
    List<String> ids = [currentUserID, otherUserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Get all unseen messages sent by the other user
    final querySnapshot = await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .where("senderID", isEqualTo: otherUserID)
        .where("receiverID", isEqualTo: currentUserID)
        .where("seen", isEqualTo: false)
        .get();

    // Mark all messages as seen
    final batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {"seen": true});
    }
    await batch.commit();
  }

  // Get unread messages count
  Stream<int> getUnreadMessagesCount(String otherUserID) {
    final String currentUserID = _auth.currentUser!.uid;
    
    // Create chat room ID
    List<String> ids = [currentUserID, otherUserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .where("senderID", isEqualTo: otherUserID)
        .where("receiverID", isEqualTo: currentUserID)
        .where("seen", isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Set typing status
  Future<void> setTypingStatus(String receiverID, bool isTyping) async {
    if (_auth.currentUser == null) return;

    List<String> ids = [_auth.currentUser!.uid, receiverID];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore.collection("chat_rooms").doc(chatRoomId).set({
      'typingUsers': {
        _auth.currentUser!.uid: isTyping,
      }
    }, SetOptions(merge: true));
  }

  // Get typing status stream
  Stream<bool> getTypingStatus(String otherUserID) {
    if (_auth.currentUser == null) {
      return Stream.value(false);
    }

    List<String> ids = [_auth.currentUser!.uid, otherUserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return false;
      
      final data = snapshot.data() as Map<String, dynamic>;
      if (!data.containsKey('typingUsers')) return false;
      
      final typingUsers = data['typingUsers'] as Map<String, dynamic>?;
      if (typingUsers == null) return false;
      
      return typingUsers[otherUserID] == true;
    });
  }
}
