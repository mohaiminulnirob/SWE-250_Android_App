import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/booked_date_model.dart';
import 'package:project/repositories/booked_dates_repository.dart';
import 'package:project/widgets/custom_app_bar.dart';

class SpotManagementPage extends StatefulWidget {
  const SpotManagementPage({super.key});

  @override
  State<SpotManagementPage> createState() => _SpotManagementPageState();
}

class _SpotManagementPageState extends State<SpotManagementPage> {
  final List<String> spots = [
    'Auditorium',
    'Central Field',
    'Mini Auditorium',
    'Basketball Ground',
    'Handball Ground',
  ];
  final List<String> sessions = ['Day', 'Night'];
  final BookedDatesRepository _repo = BookedDatesRepository();
  final Map<String, bool> _expandedSpots = {};

  @override
  void initState() {
    super.initState();
    _loadBookedDates();
  }

  Future<void> _loadBookedDates() async {
    await _repo.refreshBookedDates();
    setState(() {});
  }

  Future<void> _reserveSpotDialog() async {
    String? selectedSpot;
    DateTime? selectedDate;
    String? selectedSession;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text("Reserve a Spot",
                  style:
                      TextStyle(fontFamily: 'Urbanist', color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[850],
                      decoration: const InputDecoration(
                        labelText: 'Select Spot',
                        labelStyle: TextStyle(
                            fontFamily: 'Urbanist', color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: spots
                          .map((spot) => DropdownMenuItem(
                                value: spot,
                                child: Text(spot,
                                    style: const TextStyle(
                                        fontFamily: 'Urbanist',
                                        color: Colors.white)),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedSpot = value),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark(),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          setState(() => selectedDate = pickedDate);
                        }
                      },
                      child: Text(
                        selectedDate == null
                            ? 'Select Date'
                            : DateFormat('dd-MM-yyyy').format(selectedDate!),
                        style: const TextStyle(fontFamily: 'Urbanist'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[850],
                      decoration: const InputDecoration(
                        labelText: 'Select Session',
                        labelStyle: TextStyle(
                            fontFamily: 'Urbanist', color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: sessions
                          .map((session) => DropdownMenuItem(
                                value: session,
                                child: Text(session,
                                    style: const TextStyle(
                                        fontFamily: 'Urbanist',
                                        color: Colors.white)),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedSession = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel",
                      style: TextStyle(
                          fontFamily: 'Urbanist', color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: selectedSpot != null &&
                          selectedDate != null &&
                          selectedSession != null
                      ? () async {
                          await _repo.addBookedDate(BookedDate(
                            spotName: selectedSpot!,
                            date: selectedDate!,
                            session: selectedSession!,
                          ));
                          Navigator.of(context).pop();
                          _loadBookedDates();
                        }
                      : null,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Reserve",
                      style: TextStyle(fontFamily: 'Urbanist')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _removePastDates() async {
    await _repo.removePastDates();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Past dates removed successfully.',
          style: TextStyle(fontFamily: 'Urbanist'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<BookedDate>> grouped = {
      for (final spot in spots) spot: [],
    };
    for (final booked in _repo.bookedDates) {
      grouped[booked.spotName]!.add(booked);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(title: "Spot Management", showBackButton: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _reserveSpotDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text("Reserve a Spot",
                  style:
                      TextStyle(fontFamily: 'Urbanist', color: Colors.white)),
            ),
          ),
          Expanded(
            child: ListView(
              children: grouped.entries.map((entry) {
                final spot = entry.key;
                final dates = entry.value;
                final isExpanded = _expandedSpots[spot] ?? false;

                return Theme(
                  data: ThemeData.dark(),
                  child: ExpansionTile(
                    backgroundColor: Colors.grey[850],
                    collapsedBackgroundColor: Colors.grey[900],
                    title: Text(
                      spot,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    initiallyExpanded: isExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() => _expandedSpots[spot] = expanded);
                    },
                    children: dates.isEmpty
                        ? [
                            const ListTile(
                              title: Text(
                                "No booked dates found.",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Urbanist',
                                  color: Colors.white70,
                                ),
                              ),
                            )
                          ]
                        : dates
                            .map((b) => ListTile(
                                  title: Text(
                                    "${DateFormat('dd-MM-yyyy').format(b.date)} | ${b.session}",
                                    style: const TextStyle(
                                        fontFamily: 'Urbanist',
                                        color: Colors.white),
                                  ),
                                ))
                            .toList(),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _removePastDates,
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text(
                "Remove Past Dates",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'Urbanist',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
