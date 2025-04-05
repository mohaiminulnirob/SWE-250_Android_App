import 'package:flutter/material.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/widgets/spot_description.dart';
import 'package:project/widgets/spot_location.dart';
import 'package:project/widgets/spot_upcoming_events.dart';
import 'package:project/widgets/availability_calender.dart';
import 'package:project/repositories/spot_event_repository.dart';

class CentralFieldPage extends StatefulWidget {
  const CentralFieldPage({super.key});

  @override
  State<CentralFieldPage> createState() => _CentralFieldPageState();
}

class _CentralFieldPageState extends State<CentralFieldPage> {
  final SpotEventRepository spotEventRepository = SpotEventRepository();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const AvailabilityCalendar(spotName: "Central Field"),
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
            const SpotLocation(),
            SpotUpcomingEvents(
                events: spotEventRepository.getEventsForSpot("Central Field")),
          ],
        ),
      ),
    );
  }
}
