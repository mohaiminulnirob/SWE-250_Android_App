import 'package:flutter/material.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/widgets/spot_description.dart';
import 'package:project/widgets/spot_location.dart';
import 'package:project/widgets/spot_upcoming_events.dart';
import 'package:project/widgets/availability_calender.dart';
import 'package:project/repositories/spot_event_repository.dart';
import 'package:project/widgets/spot_helpline.dart';

class CentralFieldPage extends StatefulWidget {
  final String uid;
  const CentralFieldPage({super.key, required this.uid});

  @override
  State<CentralFieldPage> createState() => _CentralFieldPageState();
}

class _CentralFieldPageState extends State<CentralFieldPage> {
  final SpotEventRepository spotEventRepository = SpotEventRepository();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      appBar: const CustomAppBar(title: "SpotEase SUST", showBackButton: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/central_field.jpg',
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Central Field",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AvailabilityCalendar(spotName: "Central Field", uid: widget.uid),
            SpotDescription(
              title: "Description",
              content: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "The Central Field is the heart of outdoor sports at SUST. It is used for football, cricket, and athletics.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SpotHelpline(
              contacts: [
                {"name": "Campus Security", "phone": "01700000001"},
                {"name": "Field Manager", "phone": "01700000002"},
                {"name": "Emergency Hotline", "phone": "999"},
              ],
            ),
            const SpotLocation(spotName: 'Central Field'),
            SpotUpcomingEvents(
                events: spotEventRepository.getEventsForSpot("Central Field")),
          ],
        ),
      ),
    );
  }
}
