import 'package:flutter/material.dart';
import 'package:project/repositories/booked_dates_repository.dart';
import 'package:project/repositories/spot_booked_dates_repository.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/models/event_model.dart';
import 'package:project/models/booked_date_model.dart';
import 'package:project/repositories/event_repository.dart';
import 'package:project/services/storage_service.dart';
import 'package:project/services/notification_service.dart';

class BookingPage extends StatefulWidget {
  final String uid;
  final String spotName;
  final DateTime selectedDate;
  final String session;

  const BookingPage({
    super.key,
    required this.uid,
    required this.spotName,
    required this.selectedDate,
    required this.session,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  String? _organizationType;
  String? _organizationName;
  String? _officialEmail;
  String? _eventTitle;
  String? _eventDescription;
  String _applicationImageUrl = "";
  bool _acceptedTerms = false;
  final StorageService _profileStorageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _acceptedTerms &&
        _applicationImageUrl.isNotEmpty) {
      _formKey.currentState!.save();

      final newEvent = Event(
        uid: widget.uid,
        spotName: widget.spotName,
        title: _eventTitle!,
        organizationName: _organizationName!,
        date: widget.selectedDate,
        session: widget.session,
        description: _eventDescription!,
        applicationImageUrl: _applicationImageUrl,
      );

      final newBookedDate = BookedDate(
        spotName: widget.spotName,
        date: widget.selectedDate,
        session: widget.session,
      );

      await EventRepository().addEvent(newEvent);
      await BookedDatesRepository().addBookedDate(newBookedDate);

      await BookedDatesRepository().refreshBookedDates();
      await SpotBookedDatesRepository().refresh();
      await EventRepository().refreshEvents();
      final userData = await _profileStorageService.fetchUserData();
      if (userData != null) {
        await _notificationService.sendBookingConfirmationEmail(
          toEmail: userData['email'],
          username: userData['username'],
          spotName: widget.spotName,
          date:
              "${widget.selectedDate.day}-${widget.selectedDate.month}-${widget.selectedDate.year}",
          session: widget.session,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request Submitted Successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form.')),
      );
    }
  }

  Future<void> _uploadApplicationImage() async {
    String? imageUrl = await _profileStorageService.uploadApplicationImage();
    if (imageUrl != null) {
      setState(() {
        _applicationImageUrl = imageUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Application image uploaded successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload application image.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "SpotEase SUST", showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Complete Your Booking Request",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist'),
              ),
              const SizedBox(height: 24),
              _buildReadOnlyField("Spot Name", widget.spotName),
              _buildReadOnlyField(
                "Selected Date",
                "${widget.selectedDate.day}-${widget.selectedDate.month}-${widget.selectedDate.year}",
              ),
              _buildReadOnlyField("Session", widget.session),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Organization/Department",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: "Organization", child: Text("Organization")),
                  DropdownMenuItem(
                      value: "Department", child: Text("Department")),
                ],
                onChanged: (value) => setState(() => _organizationType = value),
                validator: (value) =>
                    value == null ? "Please select an option" : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                  "Organization/Department Name",
                  "Enter organization/department name",
                  (value) => _organizationName = value),
              const SizedBox(height: 20),
              _buildTextField("Event Title", "Enter event title",
                  (value) => _eventTitle = value),
              const SizedBox(height: 20),
              _buildTextField(
                  "Event Description",
                  "Enter event details (Max 100 words)",
                  (value) => _eventDescription = value,
                  TextInputType.multiline,
                  100),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _uploadApplicationImage,
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload Booking Application Image"),
              ),
              if (_applicationImageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.network(
                    _applicationImageUrl,
                    height: 100,
                  ),
                ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text(
                  "I agree to follow the guidelines for using this spot responsibly.",
                ),
                value: _acceptedTerms,
                onChanged: (value) =>
                    setState(() => _acceptedTerms = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text(
                      "Submit Request",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    Function(String) onSaved, [
    TextInputType keyboardType = TextInputType.text,
    int? maxWords,
  ]) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) return "This field is required";
        if (maxWords != null && value.split(' ').length > maxWords) {
          return "Maximum $maxWords words allowed";
        }
        return null;
      },
      onSaved: (value) => onSaved(value!),
    );
  }
}
