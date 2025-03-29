import 'package:flutter/material.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/services/profile_storage_service.dart';

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
  final AuthService _authService = AuthService();
  final ProfileStorageService _profileStorageService = ProfileStorageService();

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);

    bool isVerified = await _authService.isUserVerified();
    if (isVerified) {
      await _profileStorageService.saveUserToFirestore(
          widget.username, widget.email, widget.registration);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Email verified! You can now log in."),
              backgroundColor: Colors.green),
        );
        Navigator.pushNamedAndRemoveUntil(
            context, '/welcome', (route) => false);
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
                              backgroundColor:
                                  const Color.fromARGB(255, 23, 203, 53),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Verify",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(255, 2, 4, 15),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              await _authService.resendVerificationEmail();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Verification email resent!"),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                              setState(() => _isLoading = false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 12, 114, 162),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Resend Verification Email",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(255, 2, 4, 15),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
