import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/services/auth/chat/chat_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

//login
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user document exists before setting
      final userDoc = await _firestore
          .collection("Users")
          .doc(userCredential.user!.uid)
          .get();
      if (!userDoc.exists) {
        // Only create document if it doesn't exist
        await _firestore.collection("Users").doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'displayName': email.split('@')[0], // Default display name
          'bio': 'Hey there! I am using Chat App',
        });
      }

      // Update online status after signing in
      final chatService = ChatService();
      await chatService.updateOnlineStatus(true);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email');
        case 'wrong-password':
          throw Exception('Wrong password');
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'user-disabled':
          throw Exception('This user has been disabled');
        default:
          throw Exception(e.message ?? 'An error occurred during login');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  //signup
  Future<UserCredential> signUpWithEmailPassword(
      String email, String password, String displayName) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'displayName': displayName,
        'isOnline': true,
        'lastSeen': Timestamp.now(),
      });

      // Verify the user was created
      if (userCredential.user != null) {
        return userCredential;
      } else {
        throw Exception('Failed to create user');
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('This email is already registered');
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'weak-password':
          throw Exception('Password is too weak');
        default:
          throw Exception(e.message ?? 'An error occurred during registration');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

//logout
  Future<void> signOut() async {
    // Update online status before signing out
    final chatService = ChatService();
    await chatService.updateOnlineStatus(false);
    return await _auth.signOut();
  }
}
