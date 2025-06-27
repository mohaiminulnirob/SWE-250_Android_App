import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/pages/user_booking_history.dart';
import 'package:project/services/storage_service.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/widgets/profile_picture.dart';
import 'package:project/widgets/bottom_nav_bar.dart';
import 'package:project/widgets/logout_confirmation_dialog.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final StorageService _profileStorageService = StorageService();

  User? _user;
  String _username = "";
  String _email = "";
  String _registration = "";
  String _profileImageUrl = "";
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
    _fetchUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final userData = await _profileStorageService.fetchUserData();
    if (!mounted) return;
    if (userData != null) {
      setState(() {
        _username = userData["username"];
        _email = userData["email"];
        _registration = userData["registration"];
        _profileImageUrl = userData["profileImageUrl"];
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadProfilePicture() async {
    String? imageUrl = await _profileStorageService.uploadProfilePicture();
    if (!mounted) return;
    if (imageUrl != null) {
      setState(() {
        _profileImageUrl = imageUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload image")),
      );
    }
  }

  void _showEditProfileDialog() {
    final usernameController = TextEditingController(text: _username);
    final regController = TextEditingController(text: _registration);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Profile Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                ),
                TextField(
                  controller: regController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Registration No',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.white70)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        String newName = usernameController.text.trim();
                        String newReg = regController.text.trim();
                        if (newName.isNotEmpty && newName != _username) {
                          await _profileStorageService.updateUsername(newName);
                        }
                        if (newReg.isNotEmpty && newReg != _registration) {
                          await _profileStorageService
                              .updateRegistration(newReg);
                        }
                        await _fetchUserData();
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Profile updated successfully!")),
                          );
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change Password',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                      color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                ),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                ),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.white70)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final currentPassword =
                            currentPasswordController.text.trim();
                        final newPassword = newPasswordController.text.trim();
                        final confirmPassword =
                            confirmPasswordController.text.trim();

                        if (newPassword != confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Passwords do not match.")),
                          );
                          return;
                        }

                        if (newPassword.length < 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "New password must be at least 8 characters.")),
                          );
                          return;
                        }

                        try {
                          await _authService.changePassword(
                              currentPassword, newPassword);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Password updated successfully!")),
                          );
                        } on FirebaseAuthException catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: ${e.message}")),
                          );
                        }
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: false,
        appBar:
            const CustomAppBar(title: "SpotEase SUST", showBackButton: true),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 20, 24, 35),
                Color.fromARGB(255, 34, 40, 58),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ProfilePictureWidget(
                        imageUrl: _profileImageUrl,
                        onUpload: _uploadProfilePicture,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _username,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoTile("Registration No", _registration),
                      const SizedBox(height: 20),
                      _buildActionButton(Icons.upload, "Upload Profile Picture",
                          _uploadProfilePicture),
                      _buildActionButton(Icons.edit, "Edit Profile Details",
                          _showEditProfileDialog),
                      _buildActionButton(Icons.lock, "Change Password",
                          _showChangePasswordDialog),
                      _buildActionButton(Icons.history, "Booking History", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UserBookingHistoryPage(uid: widget.uid),
                          ),
                        );
                      }),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => LogoutConfirmationDialog(
                                onConfirm: _handleLogout),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text("Logout",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'Urbanist')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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

  Widget _buildInfoTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Urbanist',
                color: Colors.white70,
              )),
          Text(value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
                color: Colors.white,
              )),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(label,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Urbanist',
            color: Colors.white,
          )),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tileColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }
}
