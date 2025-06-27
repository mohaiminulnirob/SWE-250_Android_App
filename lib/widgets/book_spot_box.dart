import 'package:flutter/material.dart';

class BookSpotBox extends StatelessWidget {
  final List<String> spotNames;
  final String? selectedSpot;
  final DateTime? selectedDate;
  final String? selectedSession;
  final Function(String?) onSpotChanged;
  final Function(DateTime) onDatePicked;
  final Function(String?) onSessionChanged;
  final VoidCallback onCheckAvailability;

  const BookSpotBox({
    super.key,
    required this.spotNames,
    required this.selectedSpot,
    required this.selectedDate,
    required this.selectedSession,
    required this.onSpotChanged,
    required this.onDatePicked,
    required this.onSessionChanged,
    required this.onCheckAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.event_available, color: Colors.white, size: 18),
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
                decoration: _dropdownDecoration("Spot Name", dense: true),
                dropdownColor: const Color.fromARGB(255, 130, 184, 191),
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 13,
                  color: Colors.black,
                ),
                value: selectedSpot,
                items: spotNames.map((String spot) {
                  return DropdownMenuItem<String>(
                    value: spot,
                    child: Text(spot),
                  );
                }).toList(),
                onChanged: onSpotChanged,
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
                                  onPrimary: Colors.black,
                                  surface: Colors.black,
                                  onSurface: Colors.white,
                                ),
                                dialogBackgroundColor: Colors.black,
                                textTheme: const TextTheme(
                                  bodyLarge: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Urbanist'),
                                  bodyMedium: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Urbanist'),
                                  titleLarge: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) onDatePicked(picked);
                      },
                      decoration: _dropdownDecoration("Date", dense: true),
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 13,
                      ),
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
                      decoration: _dropdownDecoration("Session", dense: true),
                      dropdownColor: const Color.fromARGB(255, 130, 184, 191),
                      style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 13,
                          color: Colors.black),
                      value: selectedSession,
                      items: ["Day", "Night"].map((String session) {
                        return DropdownMenuItem<String>(
                          value: session,
                          child: Text(session),
                        );
                      }).toList(),
                      onChanged: onSessionChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: onCheckAvailability,
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
            ],
          ),
        );
      },
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
