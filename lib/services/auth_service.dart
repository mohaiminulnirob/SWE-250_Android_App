import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Sign Up with Email & Password and Send Verification Email
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      return userCredential.user;
    } catch (e) {
      print("Sign Up Error: $e");
      return null;
    }
  }

  // 🔹 Save Verified User Data in Firestore
  Future<bool> saveUserDataAfterVerification(
      String username, String email, String registration) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection("users").doc(user.uid).set({
        "username": username,
        "email": email,
        "registration": registration,
        "uid": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });
      return true;
    }
    return false;
  }

  // 🔹 Check if User is Verified
  Future<bool> isUserVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // 🔹 Login with Email & Password (Only if Verified)
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null && userCredential.user!.emailVerified) {
        return userCredential.user;
      } else {
        print("Email not verified.");
        return null;
      }
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // 🔹 Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent.");
    } catch (e) {
      print("Password Reset Error: $e");
    }
  }

  // 🔹 Resend Verification Email
  Future<void> resendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print("Verification email sent again.");
    }
  }

  // 🔹 Logout User
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 🔹 Get Current Logged-in User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
