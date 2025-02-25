import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AvailabilityCalendar extends StatefulWidget {
  const AvailabilityCalendar({super.key});

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  bool _isCalendarVisible = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedSession;

  void _toggleCalendar() {
    setState(() {
      _isCalendarVisible = !_isCalendarVisible;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedDay = null;
      _selectedSession = null;
    });
  }

  bool get _isProceedEnabled =>
      _selectedDay != null && _selectedSession != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 180,
          height: 40,
          child: ElevatedButton(
            onPressed: _toggleCalendar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 4, 111, 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Check Availability",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isCalendarVisible ? 500 : 0,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _selectedDay == null
                              ? "Select Date"
                              : "${_selectedDay!.day}-${_selectedDay!.month}-${_selectedDay!.year}",
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(height: 3),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSession,
                          isDense: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          hint: const Text("Select Session"),
                          items: const [
                            DropdownMenuItem(value: "Day", child: Text("Day")),
                            DropdownMenuItem(
                                value: "Night", child: Text("Night")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSession = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _clearSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 18),
                    const SizedBox(height: 3),
                    ElevatedButton(
                      onPressed: _isProceedEnabled
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Proceeding with Date: ${_selectedDay!.day}-${_selectedDay!.month}-${_selectedDay!.year}, Session: $_selectedSession"),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Proceed",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
