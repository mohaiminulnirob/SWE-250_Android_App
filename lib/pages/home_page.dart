import 'package:flutter/material.dart';
import 'package:project/widgets/bottom_nav_bar.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/widgets/spot_list.dart';
import 'package:project/widgets/event_list.dart';
import 'package:project/repository/event_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final EventRepository _eventRepository = EventRepository();

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
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "SpotEase SUST", showBackButton: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Choose Your Preferred Spot",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            SpotList(spotImages: _spotImages, spotNames: _spotNames),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Upcoming Events",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            EventList(events: _eventRepository.events),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
