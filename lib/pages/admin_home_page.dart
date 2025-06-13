import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project/pages/booking_approval.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/pages/event_management.dart';
import 'package:project/pages/spot_management.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Admin Dashboard',
        showBackButton: false,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            HoverCard(
              icon: LucideIcons.badgeCheck,
              title: 'Booking\nApproval',
              gradientColors: [
                Colors.green.shade400,
                Colors.green.shade700,
              ],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BookingApprovalPage()),
              ),
            ),
            const SizedBox(height: 20),
            HoverCard(
              icon: LucideIcons.mapPin,
              title: 'Spot\nManagement',
              gradientColors: [
                Colors.deepPurple.shade400,
                Colors.deepPurple.shade700,
              ],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SpotManagementPage()),
              ),
            ),
            const SizedBox(height: 20),
            HoverCard(
              icon: LucideIcons.calendarDays,
              title: 'Event\nManagement',
              gradientColors: [
                Colors.orange.shade400,
                Colors.deepOrange.shade600,
              ],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EventManagementPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HoverCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const HoverCard({
    super.key,
    required this.icon,
    required this.title,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors.last.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            width: double.infinity,
            height: 160,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  radius: 32,
                  child: Icon(widget.icon, size: 34, color: Colors.white),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
