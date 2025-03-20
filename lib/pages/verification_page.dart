import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/widgets/custom_app_bar.dart';

class VerificationPage extends StatefulWidget {
  final String username;
  final String email;
  final String registration;
  final String password;

  const VerificationPage({
    super.key,
    required this.username,
    required this.email,
    required this.registration,
    required this.password,
  });

  @override
  VerificationPageState createState() => VerificationPageState();
}

class VerificationPageState extends State<VerificationPage> {
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);

    await _auth.currentUser?.reload();
    if (_auth.currentUser!.emailVerified) {
      await _saveUserToFirestore();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Email verified! You can now log in."),
              backgroundColor: Colors.green),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Email not verified yet!"),
            backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveUserToFirestore() async {
    await _firestore.collection("users").doc(_auth.currentUser!.uid).set({
      "username": widget.username,
      "email": widget.email,
      "registration": widget.registration,
      "uid": _auth.currentUser!.uid,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isLoading = true);

    await _auth.currentUser?.sendEmailVerification();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Verification email resent!"),
          backgroundColor: Colors.blue),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: const CustomAppBar(title: "SpotEase SUST", showBackButton: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read,
                  size: 100, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                "Check Your Email",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.blueAccent)
                  : Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _checkVerification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Verify",
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _resendVerificationEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Resend Verification Email",
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
