import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotHelpline extends StatefulWidget {
  final List<Map<String, String>> contacts;

  const SpotHelpline({super.key, required this.contacts});

  @override
  State<SpotHelpline> createState() => _SpotHelplineState();
}

class _SpotHelplineState extends State<SpotHelpline> {
  bool _isOpen = false;

  Future<void> _makePhoneCall(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch dialer")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 35, 35, 35).withOpacity(0.6),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: ListTile(
              title: const Text(
                "Helpline",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                    color: Colors.white),
              ),
              trailing: Icon(
                _isOpen ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
              ),
              onTap: () {
                setState(() {
                  _isOpen = !_isOpen;
                });
              },
            ),
          ),
          if (_isOpen)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: widget.contacts.map((contact) {
                  return ListTile(
                    leading: const Icon(Icons.phone, color: Colors.greenAccent),
                    title: Text(
                      contact['name'] ?? '',
                      style: const TextStyle(
                          fontFamily: 'Urbanist', color: Colors.white),
                    ),
                    subtitle: Text(
                      contact['phone'] ?? '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.call, color: Colors.cyanAccent),
                      onPressed: () => _makePhoneCall(contact['phone'] ?? ''),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
