import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/pages/verification_page.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/widgets/custom_app_bar.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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

  Future<void> _signUp() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String registration = _registrationController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        registration.isEmpty ||
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
      User? user = await _authService.signUpWithEmail(email, password);
      if (user != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationPage(
              username: username,
              email: email,
              registration: registration,
              password: password,
            ),
          ),
        );
      } else {
        _showError("Sign-up failed. Please try again.");
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
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
                  "Sign up",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                      color: Colors.white),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Create an account. It's free",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: 'Urbanist'),
                ),
                const SizedBox(height: 20),
                _buildTextField("Username",
                    controller: _usernameController, icon: Icons.person),
                const SizedBox(height: 10),
                _buildTextField("Email",
                    controller: _emailController, icon: Icons.email),
                const SizedBox(height: 10),
                _buildTextField("Registration",
                    controller: _registrationController, icon: Icons.badge),
                const SizedBox(height: 10),
                _buildTextField("Password",
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    isPassword: true,
                    icon: Icons.lock,
                    toggleVisibility: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible)),
                const SizedBox(height: 10),
                _buildTextField("Confirm Password",
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    isPassword: true,
                    icon: Icons.lock_outline,
                    toggleVisibility: () => setState(() =>
                        _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible)),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText,
      {TextEditingController? controller,
      bool obscureText = false,
      bool isPassword = false,
      IconData? icon,
      VoidCallback? toggleVisibility}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontFamily: 'Urbanist'),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[900],
        hintText: hintText,
        hintStyle:
            const TextStyle(color: Colors.white60, fontFamily: 'Urbanist'),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: toggleVisibility,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.purpleAccent),
        ),
      ),
    );
  }
}
