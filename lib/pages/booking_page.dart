import 'package:flutter/material.dart';
import 'package:project/widgets/custom_app_bar.dart';

class BookingPage extends StatefulWidget {
  final String spotName;
  final DateTime selectedDate;
  final String session;

  const BookingPage({
    super.key,
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
  bool _acceptedTerms = false;

  void _submitForm() {
    if (_formKey.currentState!.validate() && _acceptedTerms) {
      _formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request Submitted Successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form.')),
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
                ),
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
              _buildTextField(
                  "Official Email",
                  "Enter official email",
                  (value) => _officialEmail = value,
                  TextInputType.emailAddress),
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
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Submit Request"),
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
