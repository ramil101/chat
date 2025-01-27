import 'package:chat/components/drawer.dart';
import 'package:chat/components/user_tile.dart';
import 'package:chat/services/auth/auth_service.dart';
import 'package:chat/services/auth/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/pages/search_users_page.dart';
import 'package:chat/pages/friend_requests_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  static const messengerBlue = Color(0xFF0084FF);
  static const messengerGrey = Color(0xFFF0F0F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: messengerBlue.withOpacity(0.1),
              child: const Text(
                "C",
                style: TextStyle(
                  color: messengerBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Chats",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchUsersPage(),
                ),
              );
            },
            color: Colors.black87,
          ),
          // Friend requests button with badge
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _chatService.getFriendRequestsStream(),
            builder: (context, snapshot) {
              final hasRequests = snapshot.hasData && snapshot.data!.isNotEmpty;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.people_alt_outlined, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendRequestsPage(),
                        ),
                      );
                    },
                    color: Colors.black87,
                  ),
                  if (hasRequests)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            snapshot.data!.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // New chat button
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchUsersPage(),
                ),
              );
            },
            color: Colors.black87,
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchUsersPage(),
            ),
          );
        },
        backgroundColor: messengerBlue,
        child: const Icon(Icons.chat_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        // Show error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  "Error fetching friends",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Show loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: messengerBlue,
            ),
          );
        }

        // If we have data, show the user list
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final userData = snapshot.data![index];
              return _buildUserTile(userData, context);
            },
          );
        }

        // No friends found
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                "No conversations yet",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Start chatting with your friends",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchUsersPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_rounded),
                label: const Text("Find Friends"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: messengerBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserTile(Map<String, dynamic> userData, BuildContext context) {
    final email = userData["email"] ?? "No email";
    final displayName = userData["displayName"] ?? email.split('@')[0];
    final profileImageUrl = userData["profileImageUrl"];
    final friendshipId = userData["friendshipId"];
    final isOnline = userData["isOnline"] ?? false;
    final lastSeen = userData["lastSeen"] as Timestamp?;
    final lastMessage = userData["lastMessage"] as String?;
    final lastMessageTime = userData["lastMessageTime"] as Timestamp?;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            receiverEmaill: email,
            receiverID: userData["uid"],
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'profile-${userData["uid"]}',
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: profileImageUrl == null
                          ? messengerBlue.withOpacity(0.1)
                          : null,
                      image: profileImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(profileImageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profileImageUrl == null
                        ? Center(
                            child: Text(
                              displayName[0].toUpperCase(),
                              style: const TextStyle(
                                color: messengerBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage ??
                        (!isOnline && lastSeen != null
                            ? _chatService.getLastSeenText(lastSeen)
                            : email),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (lastMessageTime != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  _chatService.getLastSeenText(lastMessageTime),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
