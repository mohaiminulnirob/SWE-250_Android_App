import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/widgets/bottom_nav_bar.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/widgets/spot_list.dart';
import 'package:project/widgets/event_list.dart';
import 'package:project/repositories/event_repository.dart';
import 'package:project/repositories/booked_dates_repository.dart';
import 'package:project/pages/profile_page.dart';
import 'package:project/pages/past_events_page.dart';
import 'package:project/pages/booking_page.dart';
import 'package:project/widgets/spot_map.dart';

class HomePage extends StatefulWidget {
  final String uid;

  const HomePage({super.key, required this.uid});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final EventRepository _eventRepository = EventRepository();
  final BookedDatesRepository _bookedDatesRepo = BookedDatesRepository();
  String _userName = "";
  bool _isLoading = true;

  String? selectedSpot;
  String? selectedSession;
  DateTime? selectedDate;

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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PastEventsPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(uid: widget.uid),
          ),
        );
        break;
    }
  }

  void _showLoadingDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
            color: Color.fromARGB(255, 183, 196, 206)),
      ),
    );
  }

  void _showResultDialog({
    required bool isAvailable,
    required String selectedSpot,
    required DateTime selectedDate,
    required String selectedSession,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            Icon(
              isAvailable ? Icons.check_circle : Icons.cancel,
              color: isAvailable ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              isAvailable ? "Available" : "Unavailable",
              style:
                  const TextStyle(fontFamily: 'Urbanist', color: Colors.white),
            ),
          ],
        ),
        content: Text(
          isAvailable
              ? "This spot is available for your selected date and session."
              : "This spot is already booked for this date.",
          style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white),
        ),
        actions: isAvailable
            ? [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingPage(
                          uid: widget.uid,
                          spotName: selectedSpot,
                          selectedDate: selectedDate,
                          session: selectedSession,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Book",
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "SpotEase SUST", showBackButton: true),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 172, 201, 209),
              Color.fromARGB(255, 144, 187, 196),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading ? _buildLoadingUI() : _buildHomeContent(),
      ),
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
          Image.asset('assets/images/loading_animation.gif', width: 130),
          const SizedBox(height: 20),
          const Text(
            "Fetching your profile...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Urbanist',
              color: Colors.blueGrey,
            ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 15, 127, 152),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.event_available,
                              color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            "Book Spot",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isDense: true,
                        decoration:
                            _dropdownDecoration("Spot Name", dense: true),
                        dropdownColor: const Color.fromARGB(255, 130, 184, 191),
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        items: _spotNames.map((String spot) {
                          return DropdownMenuItem<String>(
                            value: spot,
                            child: Text(
                              spot,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => selectedSpot = value),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.dark().copyWith(
                                        primaryColor: Colors.tealAccent,
                                        colorScheme: const ColorScheme.dark(
                                          primary: Colors.tealAccent,
                                          surface: Colors.black,
                                          onSurface: Colors.white,
                                        ),
                                        dialogBackgroundColor: Colors.black,
                                        textTheme: const TextTheme(
                                          bodyLarge: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14),
                                          bodyMedium: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14),
                                          titleLarge: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() => selectedDate = picked);
                                }
                              },
                              decoration:
                                  _dropdownDecoration("Date", dense: true),
                              style: const TextStyle(
                                  fontFamily: 'Urbanist', fontSize: 13),
                              controller: TextEditingController(
                                text: selectedDate == null
                                    ? ''
                                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isDense: true,
                              decoration:
                                  _dropdownDecoration("Session", dense: true),
                              dropdownColor: Color.fromARGB(255, 130, 184, 191),
                              style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 13,
                                  color: Colors.black),
                              items: ["Day", "Night"].map((String session) {
                                return DropdownMenuItem<String>(
                                  value: session,
                                  child: Text(session,
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black)),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => selectedSession = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () async {
                              if (selectedSpot != null &&
                                  selectedDate != null &&
                                  selectedSession != null) {
                                _showLoadingDialog();
                                await _bookedDatesRepo.refreshBookedDates();
                                final isBooked = _bookedDatesRepo.bookedDates
                                    .any((b) =>
                                        b.spotName == selectedSpot &&
                                        b.session == selectedSession &&
                                        b.date.year == selectedDate!.year &&
                                        b.date.month == selectedDate!.month &&
                                        b.date.day == selectedDate!.day);
                                Navigator.of(context).pop();
                                _showResultDialog(
                                  isAvailable: !isBooked,
                                  selectedSpot: selectedSpot!,
                                  selectedDate: selectedDate!,
                                  selectedSession: selectedSession!,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Please fill all fields")),
                                );
                              }
                            },
                            child: const Text(
                              "Check Availability",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.map_outlined, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  "Choose Your Preferred Spot",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SpotList(
              spotImages: _spotImages, spotNames: _spotNames, uid: widget.uid),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SpotMapPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[700],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      "View Spots on Map",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  "Upcoming Events",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          EventList(events: _eventRepository.events),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label, {bool dense = false}) {
    return InputDecoration(
      isDense: dense,
      contentPadding: dense
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
          : null,
      labelText: label,
      labelStyle: const TextStyle(
        color: Color.fromARGB(255, 6, 10, 0),
        fontFamily: 'Urbanist',
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      filled: true,
      fillColor: const Color.fromARGB(255, 174, 229, 247),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class DelayedAnimatedItem extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const DelayedAnimatedItem(
      {super.key, required this.child, required this.delay});

  @override
  State<DelayedAnimatedItem> createState() => _DelayedAnimatedItemState();
}

class _DelayedAnimatedItemState extends State<DelayedAnimatedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide =
        Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
