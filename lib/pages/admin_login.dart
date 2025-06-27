import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/pages/admin_home_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
      begin: const Offset(1, 0),
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

  Future<void> _handleAdminLogin() async {
    setState(() => _isLoading = true);

    String email = _emailController.text.trim();
    String uniqueId = _idController.text.trim();
    String password = _passwordController.text.trim();

    User? user = await _authService.signInWithEmail(email, password);

    if (user != null) {
      DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .doc(user.uid)
          .get();

      if (adminSnapshot.exists && adminSnapshot['id'] == uniqueId) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminHomePage()),
          );
        }
      } else {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid admin credentials. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Login failed. Check email, password, and verification."),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "Admin Portal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    controller: _emailController,
                    hintText: "Admin Email",
                    icon: Icons.email,
                    iconColor: Colors.blue,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _idController,
                    hintText: "Unique ID",
                    icon: Icons.badge,
                    iconColor: Colors.deepOrange,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    icon: Icons.lock,
                    iconColor: Colors.purple,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.purple,
                      ),
                      onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleAdminLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor:
                            const Color.fromARGB(255, 45, 235, 131),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "Admin Log In",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color iconColor,
    bool obscureText = false,
    Widget? suffixIcon,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: iconColor),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }
}
