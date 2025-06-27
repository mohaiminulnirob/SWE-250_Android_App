import 'package:flutter/material.dart';
import 'package:project/repositories/booked_dates_repository.dart';
import 'package:project/repositories/spot_booked_dates_repository.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/models/event_model.dart';
import 'package:project/models/booked_date_model.dart';
import 'package:project/repositories/event_repository.dart';
import 'package:project/repositories/event_requests_repo.dart';
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

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _organizationType;
  String? _organizationName;
  String? _eventTitle;
  String? _eventDescription;
  String _applicationImageUrl = "";
  bool _acceptedTerms = false;
  bool _isSubmitting = false;
  bool _isImageUploading = false;
  bool _isSubmitted = false;

  final StorageService _profileStorageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _acceptedTerms &&
        _applicationImageUrl.isNotEmpty) {
      _formKey.currentState!.save();
      setState(() => _isSubmitting = true);

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

      await EventRequestsRepository().addEventRequest(newEvent);
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

      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });

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
    setState(() => _isImageUploading = true);
    String? imageUrl = await _profileStorageService.uploadApplicationImage();
    setState(() => _isImageUploading = false);
    if (imageUrl != null) {
      setState(() => _applicationImageUrl = imageUrl);
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
      backgroundColor: Colors.black.withOpacity(0.8),
      appBar: const CustomAppBar(title: "SpotEase SUST", showBackButton: true),
      body: SlideTransition(
        position: _slideAnimation,
        child: AbsorbPointer(
          absorbing: _isSubmitting || _isSubmitted,
          child: SingleChildScrollView(
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
                        fontFamily: 'Urbanist',
                        color: Colors.white),
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
                    dropdownColor: Colors.grey[900],
                    decoration: const InputDecoration(
                      labelText: "Organization/Department",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "Organization",
                          child: Text("Organization",
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: "Department",
                          child: Text("Department",
                              style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (value) =>
                        setState(() => _organizationType = value),
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
                  if (_isImageUploading)
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_applicationImageUrl.isNotEmpty && !_isImageUploading)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.network(_applicationImageUrl, height: 100),
                    ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: const Text(
                        "I agree to follow the guidelines for using this spot responsibly.",
                        style: TextStyle(color: Colors.white)),
                    value: _acceptedTerms,
                    onChanged: (value) =>
                        setState(() => _acceptedTerms = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 20),
                  if (_isSubmitting)
                    const Center(child: CircularProgressIndicator()),
                  if (!_isSubmitting && !_isSubmitted)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text("Cancel",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Urbanist')),
                        ),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text("Submit Request",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Urbanist')),
                        ),
                      ],
                    ),
                ],
              ),
            ),
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
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
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
