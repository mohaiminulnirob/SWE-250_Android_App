import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project/pages/auditorium.dart';
import 'package:project/pages/basketball_ground.dart';
import 'package:project/pages/handball_ground.dart';
import 'package:project/pages/mini_auditorium.dart';
import 'package:project/pages/central_field.dart';

class SpotList extends StatefulWidget {
  final String uid;
  final List<String> spotImages;
  final List<String> spotNames;

  const SpotList({
    super.key,
    required this.spotImages,
    required this.spotNames,
    required this.uid,
  });

  @override
  State<SpotList> createState() => _SpotListState();
}

class _SpotListState extends State<SpotList> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  int get realLength => widget.spotImages.length;

  List<String> get _loopedImages => [
        widget.spotImages.last,
        ...widget.spotImages,
        widget.spotImages.first,
      ];

  List<String> get _loopedNames => [
        widget.spotNames.last,
        ...widget.spotNames,
        widget.spotNames.first,
      ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    if (index == 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _pageController.jumpToPage(realLength);
      });
      _currentPage = realLength - 1;
    } else if (index == realLength + 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _pageController.jumpToPage(1);
      });
      _currentPage = 0;
    } else {
      _currentPage = index - 1;
    }
    setState(() {});
  }

  Widget? _getSpotPage(String spotName) {
    switch (spotName) {
      case "Auditorium":
        return AuditoriumPage(uid: widget.uid);
      case "Central Field":
        return CentralFieldPage(uid: widget.uid);
      case "Basketball Ground":
        return BasketballGroundPage(uid: widget.uid);
      case "Handball Ground":
        return HandballGroundPage(uid: widget.uid);
      case "Mini Auditorium":
        return MiniAuditoriumPage(uid: widget.uid);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _loopedImages.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Widget? page = _getSpotPage(_loopedNames[index]);
                  if (page != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => page),
                    );
                  }
                },
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        _loopedImages[index],
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withOpacity(0.3),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        _loopedNames[index],
                        style: const TextStyle(
                          color: Color.fromARGB(255, 248, 249, 249),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(realLength, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 6 : 3,
              height: _currentPage == index ? 6 : 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.white : Colors.black,
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
}
