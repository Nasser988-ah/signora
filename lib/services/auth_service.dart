import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/user_types.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(fullName);

      // Store user data in Firestore
      await _createUserDocument(
        uid: result.user!.uid,
        email: email,
        fullName: fullName,
        userType: userType,
      );

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle({required UserType userType}) async {
    try {
      // Sign out first to ensure clean state (avoid checking isSignedIn)
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      GoogleSignInAuthentication? googleAuth;
      try {
        googleAuth = await googleUser.authentication;
        if (googleAuth == null) {
          throw 'Authentication failed';
        }
      } catch (e) {
        print('Error getting Google authentication: $e');
        await _googleSignIn.signOut();
        throw 'Google authentication failed. Please try again.';
      }

      // Validate tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw 'Failed to obtain Google authentication tokens';
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential result = await _auth.signInWithCredential(credential);

      if (result.user == null) {
        throw 'Failed to authenticate with Firebase';
      }

      // Check if this is a new user
      if (result.additionalUserInfo?.isNewUser == true) {
        // Store user data in Firestore for new users
        await _createUserDocument(
          uid: result.user!.uid,
          email: result.user!.email ?? '',
          fullName: result.user!.displayName ?? 'User',
          userType: userType,
        );
      }

      return result;
    } on FirebaseAuthException catch (e) {
      await _googleSignIn.signOut(); // Clean up on error
      throw _handleAuthException(e);
    } catch (e) {
      await _googleSignIn.signOut(); // Clean up on error
      print('Google sign-in error: $e'); // Debug logging
      if (e.toString().contains('network_error')) {
        throw 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('sign_in_canceled')) {
        throw 'Sign-in was cancelled.';
      } else if (e.toString().contains('sign_in_failed')) {
        throw 'Google sign-in failed. Please try again.';
      } else {
        throw 'Google sign-in error: ${e.toString()}';
      }
    }
  }

  // Get user type from Firestore
  Future<UserType?> getUserType(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data is Map<String, dynamic>) {
          String userTypeString = data['userType']?.toString() ?? 'student';
          try {
            return UserType.values.firstWhere(
              (type) => type.toString().split('.').last == userTypeString,
            );
          } catch (e) {
            print('Error parsing user type: $e');
            return UserType.student;
          }
        }
      }
      return UserType.student; // Default to student if no data found
    } catch (e) {
      print('Error getting user type: $e');
      return UserType.student; // Default to student on error
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String fullName,
    required UserType userType,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'userType': userType.toString().split('.').last,
      'createdAt': FieldValue.serverTimestamp(),
      'lastSignIn': FieldValue.serverTimestamp(),
    });
  }

  // Update last sign in time
  Future<void> updateLastSignIn(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastSignIn': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last sign in: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out: $e');
      // Force sign out even if there's an error
      await _auth.signOut();
    }
  }

  // Get current user display name
  String getCurrentUserName() {
    final user = _auth.currentUser;
    if (user != null) {
      return user.displayName ?? user.email?.split('@')[0] ?? 'User';
    }
    return 'User';
  }

  // Get current user photo URL
  String? getCurrentUserPhotoUrl() {
    final user = _auth.currentUser;
    return user?.photoURL;
  }

  // Get current user email
  String getCurrentUserEmail() {
    final user = _auth.currentUser;
    return user?.email ?? '';
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
