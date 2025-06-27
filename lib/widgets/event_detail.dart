import 'package:flutter/material.dart';
import 'package:project/pages/full_image_view.dart';

class EventDetailWidget extends StatelessWidget {
  final String title;
  final String description;
  final String department;
  final String userName;
  final String email;
  final String date;
  final String session;
  final String spotName;
  final String applicationImageUrl;

  const EventDetailWidget({
    super.key,
    required this.title,
    required this.description,
    required this.department,
    required this.userName,
    required this.email,
    required this.date,
    required this.session,
    required this.spotName,
    required this.applicationImageUrl,
  });

  Widget _buildInfoBox(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border.all(color: Colors.white70),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Urbanist',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: Colors.black.withOpacity(0.6),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Event Details",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Urbanist',
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullImageView(imageUrl: applicationImageUrl),
                ),
              );
            },
            child: Hero(
              tag: applicationImageUrl,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(applicationImageUrl),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoBox("Title", title),
          _buildInfoBox("Department", department),
          _buildInfoBox("User Name", userName),
          _buildInfoBox("User Email", email),
          _buildInfoBox("Date", date),
          _buildInfoBox("Session", session),
          _buildInfoBox("Spot", spotName),
          const SizedBox(height: 14),
          Text(
            "Description",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Urbanist',
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white70,
                fontFamily: 'Urbanist',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
