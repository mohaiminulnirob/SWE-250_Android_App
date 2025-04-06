import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/widgets/bottom_nav_bar.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/widgets/spot_list.dart';
import 'package:project/widgets/event_list.dart';
import 'package:project/repositories/event_repository.dart';
import 'package:project/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  final String uid;

  const HomePage({super.key, required this.uid});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final EventRepository _eventRepository = EventRepository();
  String _userName = "";
  bool _isLoading = true;

  final List<String> _spotImages = [
    'assets/images/sust_audi2.jpg',
    'assets/images/central_field.jpg',
    'assets/images/basketball_ground.jpg',
    'assets/images/handball_ground.jpg',
    'assets/images/mini_audi.jpg',
  ];

  final List<String> _spotNames = [
    "Auditorium",
    "Central Field",
    "Basketball Ground",
    "Handball Ground",
    "Mini Auditorium",
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['username'];
        });
      } else {
        setState(() {
          _userName = "User";
        });
      }
    } catch (e) {
      setState(() {
        _userName = "User";
      });
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/notifications');
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(uid: widget.uid),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "SpotEase SUST", showBackButton: true),
      body: _isLoading ? _buildLoadingUI() : _buildHomeContent(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildLoadingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/loading_animation.gif',
            width: 130,
          ),
          const SizedBox(height: 20),
          const Text(
            "Fetching your profile...",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
                color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Welcome, $_userName!",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
                color: Color.fromARGB(255, 12, 50, 201),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Choose Your Preferred Spot",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist'),
            ),
          ),
          const SizedBox(height: 10),
          SpotList(
            spotImages: _spotImages,
            spotNames: _spotNames,
            uid: widget.uid,
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Upcoming Events",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist'),
            ),
          ),
          const SizedBox(height: 10),
          EventList(events: _eventRepository.events),
        ],
      ),
    );
  }
}
