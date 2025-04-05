import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfileStorageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _clientId = '730a82687c5c3ca';

  Future<void> saveUserToFirestore(
      String username, String email, String registration) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection("users").doc(user.uid).set({
        "username": username,
        "email": email,
        "registration": registration,
        "uid": user.uid,
        "profileImageUrl": "",
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  Future<Map<String, dynamic>?> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();
      if (userDoc.exists) {
        return {
          "username": userDoc['username'],
          "email": userDoc['email'],
          "registration": userDoc['registration'],
          "profileImageUrl": userDoc['profileImageUrl'] ?? "",
        };
      }
    }
    return null;
  }

  Future<void> updateUsername(String newUsername) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection("users").doc(user.uid).update({
        "username": newUsername,
      });
    }
  }

  Future<void> updateRegistration(String newRegistration) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection("users").doc(user.uid).update({
        "registration": newRegistration,
      });
    }
  }

  Future<String?> uploadProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      try {
        String? imageUrl = await _uploadToImgur(file);
        if (imageUrl != null) {
          await _firestore
              .collection("users")
              .doc(_auth.currentUser!.uid)
              .update({
            "profileImageUrl": imageUrl,
          });
          return imageUrl;
        }
      } catch (e) {
        print("Failed to upload image: $e");
      }
    }
    return null;
  }

  Future<String?> _uploadToImgur(File imageFile) async {
    final Uri url = Uri.parse('https://api.imgur.com/3/upload');
    final bytes = await imageFile.readAsBytes();
    final String base64Image = base64Encode(bytes);

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Client-ID $_clientId',
      },
      body: {
        'image': base64Image,
        'type': 'base64',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['link'];
    } else {
      print('Failed to upload image: ${response.body}');
      return null;
    }
  }
}
