import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/services/storage_service.dart';

class AdminRegistrationPage extends StatefulWidget {
  const AdminRegistrationPage({super.key});

  @override
  State<AdminRegistrationPage> createState() => _AdminRegistrationPageState();
}

class _AdminRegistrationPageState extends State<AdminRegistrationPage>
    with SingleTickerProviderStateMixin {
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

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
        email: email,
        password: password,
      );
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
                    backgroundColor: Colors.red,
                  ),
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
    return SlideTransition(
      position: _slideAnimation,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.85),
        appBar:
            const CustomAppBar(title: "SpotEase SUST", showBackButton: true),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                const Text(
                  "Admin Sign Up",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField("Name", _nameController, icon: Icons.person),
                const SizedBox(height: 10),
                _buildTextField("ID", _idController, icon: Icons.badge),
                const SizedBox(height: 10),
                _buildTextField("Email", _emailController, icon: Icons.email),
                const SizedBox(height: 10),
                _buildTextField(
                  "Password",
                  _passwordController,
                  obscureText: !_isPasswordVisible,
                  isPassword: true,
                  icon: Icons.lock,
                  toggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  "Confirm Password",
                  _confirmPasswordController,
                  obscureText: !_isPasswordVisible,
                  isPassword: true,
                  icon: Icons.lock_outline,
                  toggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
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
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hintText,
    TextEditingController controller, {
    bool obscureText = false,
    bool isPassword = false,
    IconData? icon,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontFamily: 'Urbanist'),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[900],
        hintText: hintText,
        hintStyle:
            const TextStyle(color: Colors.white70, fontFamily: 'Urbanist'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70),
                onPressed: toggleVisibility,
              )
            : null,
      ),
    );
  }
}
