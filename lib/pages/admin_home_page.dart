import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project/widgets/custom_app_bar.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void _navigateToSection(BuildContext context, String sectionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $sectionName...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          width: 150,
          height: 150,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                radius: 28,
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Admin Dashboard',
        showBackButton: false,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          children: [
            _buildCard(
              icon: LucideIcons.badgeCheck,
              title: 'Booking\nApproval',
              gradientColors: [Colors.green.shade400, Colors.green.shade700],
              onTap: () => _navigateToSection(context, 'Booking Approval'),
            ),
            _buildCard(
              icon: LucideIcons.mapPin,
              title: 'Spot\nManagement',
              gradientColors: [
                Colors.deepPurple.shade400,
                Colors.deepPurple.shade700
              ],
              onTap: () => _navigateToSection(context, 'Spot Management'),
            ),
            _buildCard(
              icon: LucideIcons.calendarDays,
              title: 'Event\nManagement',
              gradientColors: [
                Colors.orange.shade400,
                Colors.deepOrange.shade600
              ],
              onTap: () => _navigateToSection(context, 'Event Management'),
            ),
            _buildCard(
              icon: LucideIcons.bell,
              title: 'Notification\nManagement',
              gradientColors: [Colors.blue.shade400, Colors.indigo.shade700],
              onTap: () =>
                  _navigateToSection(context, 'Notification Management'),
            ),
          ],
        ),
      ),
    );
  }
}
