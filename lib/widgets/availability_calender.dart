import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:project/pages/booking_page.dart';
import 'package:project/repository/spot_booked_dates_repository.dart';

class AvailabilityCalendar extends StatefulWidget {
  final String spotName;

  const AvailabilityCalendar({super.key, required this.spotName});

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  bool _isCalendarVisible = false;
  bool _isLoading = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedSession;
  Set<DateTime> _unavailableDates = {};

  late final DateTime _firstDay;
  late final DateTime _lastDay;

  @override
  void initState() {
    super.initState();

    _firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    _lastDay = DateTime(
      _focusedDay.month == 12 ? _focusedDay.year + 1 : _focusedDay.year,
      _focusedDay.month == 12 ? 2 : _focusedDay.month + 2,
      0,
    );
  }

  bool get _isProceedEnabled =>
      _selectedDay != null && _selectedSession != null;

  void _toggleCalendar() async {
    if (!_isCalendarVisible) {
      setState(() {
        _isLoading = true;
      });

      await _loadUnavailableDates();

      setState(() {
        _isLoading = false;
        _isCalendarVisible = true;
      });
    } else {
      setState(() {
        _isCalendarVisible = false;
      });
    }
  }

  Future<void> _loadUnavailableDates() async {
    final bookedDates = await SpotBookedDatesRepository()
        .getBookedDatesForSpot(widget.spotName);

    setState(() {
      _unavailableDates = bookedDates
          .map((b) => DateTime(b.date.year, b.date.month, b.date.day))
          .toSet();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedDay = null;
      _selectedSession = null;
    });
  }

  void _navigateToBookingPage() {
    if (_isProceedEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingPage(
            spotName: widget.spotName,
            selectedDate: _selectedDay!,
            session: _selectedSession!,
          ),
        ),
      );
    }
  }

  bool _isDayUnavailable(DateTime day) {
    final formattedDay = DateTime(day.year, day.month, day.day);
    return _unavailableDates.contains(formattedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
          ],
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isCalendarVisible ? (_isLoading ? 80 : 450) : 0,
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _isCalendarVisible
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          TableCalendar(
                            focusedDay: _focusedDay,
                            firstDay: _firstDay,
                            lastDay: _lastDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              if (_isDayUnavailable(selectedDay)) return;
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            onPageChanged: (focusedDay) {
                              if (focusedDay.isBefore(_firstDay)) {
                                setState(() => _focusedDay = _firstDay);
                              } else if (focusedDay.isAfter(_lastDay)) {
                                setState(() => _focusedDay = _lastDay);
                              } else {
                                setState(() => _focusedDay = focusedDay);
                              }
                            },
                            enabledDayPredicate: (day) =>
                                !_isDayUnavailable(day) &&
                                !day.isBefore(_firstDay) &&
                                !day.isAfter(_lastDay),
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              disabledTextStyle:
                                  const TextStyle(color: Colors.red),
                            ),
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                if (_isDayUnavailable(day)) {
                                  return Center(
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${day.day}',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
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
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedSession,
                                    isDense: true,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    hint: const Text("Select Session"),
                                    items: const [
                                      DropdownMenuItem(
                                          value: "Day", child: Text("Day")),
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
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _clearSelection,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("Cancel",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 18),
                              ElevatedButton(
                                onPressed: _isProceedEnabled
                                    ? _navigateToBookingPage
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
                    )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
