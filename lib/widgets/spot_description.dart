import 'package:flutter/material.dart';

class SpotDescription extends StatefulWidget {
  final String title;
  final Widget content;

  const SpotDescription({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<SpotDescription> createState() => _SpotDescriptionState();
}

class _SpotDescriptionState extends State<SpotDescription> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            title: Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
                color: Colors.white,
              ),
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
              color: Colors.black.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Urbanist',
              ),
              child: widget.content,
            ),
          ),
      ],
    );
  }
}
