import 'package:flutter/material.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/widgets/spot_description.dart';
import 'package:project/widgets/spot_location.dart';
import 'package:project/widgets/spot_upcoming_events.dart';
import 'package:project/widgets/availability_calender.dart';
import 'package:project/pages/booking_page.dart';
import 'package:project/repository/spot_event_repository.dart';

class AuditoriumPage extends StatefulWidget {
  const AuditoriumPage({super.key});

  @override
  State<AuditoriumPage> createState() => _AuditoriumPageState();
}

class _AuditoriumPageState extends State<AuditoriumPage> {
  final SpotEventRepository spotEventRepository = SpotEventRepository();

  void navigateToBookingPage(DateTime selectedDate, String session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage(
          spotName: "Auditorium",
          selectedDate: selectedDate,
          session: session,
        ),
      ),
    );
  }

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
                  'assets/images/sust_audi.jpg',
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
                      "Auditorium",
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
            AvailabilityCalendar(
              spotName: "Auditorium",
            ),
            SpotDescription(
              title: "Description",
              content: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "The SUST Auditorium is a modern event venue located inside the university campus. It hosts seminars, cultural programs, and academic events.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SpotLocation(),
            SpotUpcomingEvents(
              events: SpotEventRepository().getEventsForSpot("Auditorium"),
            ),
          ],
        ),
      ),
    );
  }
}
