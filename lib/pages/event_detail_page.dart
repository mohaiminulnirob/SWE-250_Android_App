import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/event_model.dart';
import 'package:project/widgets/event_detail.dart';
import 'package:project/widgets/custom_app_bar.dart'; // import your custom app bar

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  String userName = '';
  String userEmail = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.event.uid)
          .get();

      if (doc.exists) {
        userName = doc['username'] ?? '';
        userEmail = doc['email'] ?? '';
      }
      await precacheImage(
        NetworkImage(widget.event.applicationImageUrl),
        context,
      );
    } catch (e) {
      debugPrint('Error fetching user info or image: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Details",
        showBackButton: true,
      ),
      body: isLoading
          ? Center(
              child: Image.asset(
                'assets/images/loading_animation.gif',
                width: 150,
                height: 150,
              ),
            )
          : SingleChildScrollView(
              child: EventDetailWidget(
                title: widget.event.title,
                description: widget.event.description,
                department: widget.event.organizationName,
                email: userEmail,
                userName: userName,
                date: widget.event.date.toLocal().toString().split(' ')[0],
                session: widget.event.session,
                spotName: widget.event.spotName,
                applicationImageUrl: widget.event.applicationImageUrl,
              ),
            ),
    );
  }
}
