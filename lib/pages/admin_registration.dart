import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/services/storage_service.dart';

class AdminRegistrationPage extends StatefulWidget {
  const AdminRegistrationPage({super.key});

  @override
  State<AdminRegistrationPage> createState() => _AdminRegistrationPageState();
}

class _AdminRegistrationPageState extends State<AdminRegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _registerAdmin() async {
    String name = _nameController.text.trim();
    String id = _idController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        id.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError("All fields are required!");
      return;
    }
    if (password.length < 8) {
      _showError("Password must be at least 8 characters long!");
      return;
    }
    if (password != confirmPassword) {
      _showError("Passwords do not match!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool isIdValid = await _storageService.isAdminIdValid(id);
      if (!isIdValid) {
        _showError("ID does not exist in adminID repository.");
        return;
      }

      bool isIdUsed = await _storageService.isAdminIdAlreadyUsed(id);
      if (isIdUsed) {
        _showError("This ID is already registered with another email.");
        return;
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _showVerificationDialog(user, name, id, email);
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "An error occurred.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showVerificationDialog(
      User user, String name, String id, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Verification Email Sent"),
        content: Text("Email sent to $email. Please verify."),
        actions: [
          TextButton(
            onPressed: () async {
              await user.reload();
              user = _auth.currentUser!;
              if (user.emailVerified) {
                await _storageService.addAdminInfo(user.uid, name, id, email);
                if (mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Admin registered successfully!")),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Email not verified yet."),
                      backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Verify"),
          ),
          TextButton(
            onPressed: () async {
              await user.sendEmailVerification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Verification email resent.")),
              );
            },
            child: const Text("Resend Email"),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          const CustomAppBar(title: "Admin Registration", showBackButton: true),
      backgroundColor: const Color.fromARGB(255, 235, 233, 240),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              const Text("Admin Sign Up",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                      color: Color.fromARGB(255, 104, 61, 222))),
              const SizedBox(height: 20),
              _buildTextField("Name", _nameController),
              const SizedBox(height: 10),
              _buildTextField("ID", _idController),
              const SizedBox(height: 10),
              _buildTextField("Email", _emailController),
              const SizedBox(height: 10),
              _buildTextField("Password", _passwordController,
                  obscureText: !_isPasswordVisible,
                  isPassword: true,
                  toggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible)),
              const SizedBox(height: 10),
              _buildTextField("Confirm Password", _confirmPasswordController,
                  obscureText: !_isPasswordVisible,
                  isPassword: true,
                  toggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible)),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _registerAdmin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text("Register",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool obscureText = false,
      bool isPassword = false,
      VoidCallback? toggleVisibility}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: isPassword
            ? IconButton(
                icon:
                    Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleVisibility,
              )
            : null,
      ),
    );
  }
}
