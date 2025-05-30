import 'package:flutter/material.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/widgets/spot_description.dart';
import 'package:project/widgets/spot_location.dart';
import 'package:project/widgets/spot_upcoming_events.dart';
import 'package:project/widgets/availability_calender.dart';
import 'package:project/repositories/spot_event_repository.dart';

class HandballGroundPage extends StatefulWidget {
  final String uid;
  const HandballGroundPage({super.key, required this.uid});

  @override
  State<HandballGroundPage> createState() => _HandballGroundPageState();
}

class _HandballGroundPageState extends State<HandballGroundPage> {
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
                  'assets/images/handball_ground.jpg',
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
                      "Handball Ground",
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
            AvailabilityCalendar(
              spotName: "Handball Ground",
              uid: widget.uid,
            ),
            SpotDescription(
              title: "Description",
              content: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "The Handball Ground of SUST is a dedicated space for training, friendly matches, and university handball tournaments.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SpotLocation(spotName: 'Handball Ground'),
            SpotUpcomingEvents(
                events:
                    spotEventRepository.getEventsForSpot("Handball Ground")),
          ],
        ),
      ),
    );
  }
}
