import 'package:flutter/material.dart';
import 'package:project/pages/auditorium.dart';
import 'package:project/pages/basketball_ground.dart';
import 'package:project/pages/handball_ground.dart';
import 'package:project/pages/mini_auditorium.dart';
import 'package:project/pages/central_field.dart';

class SpotList extends StatefulWidget {
  final List<String> spotImages;
  final List<String> spotNames;

  const SpotList(
      {super.key, required this.spotImages, required this.spotNames});

  @override
  State<SpotList> createState() => _SpotListState();
}

class _SpotListState extends State<SpotList> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollArrows);
  }

  void _updateScrollArrows() {
    setState(() {
      _showLeftArrow = _scrollController.offset > 0;
      _showRightArrow =
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 300,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 300,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget? _getSpotPage(String spotName) {
    switch (spotName) {
      case "Auditorium":
        return const AuditoriumPage();
      case "Central Field":
        return const CentralFieldPage();
      case "Basketball Ground":
        return const BasketballGroundPage();
      case "Handball Ground":
        return const HandballGroundPage();
      case "Mini Auditorium":
        return const MiniAuditoriumPage();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 250,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.spotImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Widget? page = _getSpotPage(widget.spotNames[index]);
                  if (page != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => page),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.asset(
                          widget.spotImages[index],
                          height: 242,
                          width: 342,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.spotNames[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_showLeftArrow)
          Positioned(
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: _scrollLeft,
            ),
          ),
        if (_showRightArrow)
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
              onPressed: _scrollRight,
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
