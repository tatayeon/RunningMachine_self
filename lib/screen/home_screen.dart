import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final Function(bool isVisible) onToggleBottomNav; // Callback to toggle Bottom Navigation Bar

  const HomeScreen({Key? key, required this.onToggleBottomNav}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController pageController = PageController();
  List<bool> isTextVisible = [false, false, false, false];
  late Timer autoSlideTimer;
  bool isHintVisible = true;
  late Timer blinkTimer;

  @override
  void initState() {
    super.initState();
    startAutoSlide();
    startBlinkingHint();
  }

  @override
  void dispose() {
    autoSlideTimer.cancel();
    blinkTimer.cancel();
    pageController.dispose();
    super.dispose();
  }

  void startAutoSlide() {
    autoSlideTimer = Timer.periodic(
      Duration(seconds: 3),
          (timer) {
        if (isTextVisible.contains(true)) return;

        int? currentPage = pageController.page?.toInt();
        if (currentPage == null) return;

        int nextPage = (currentPage + 1) % 4;
        pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      },
    );
  }

  void startBlinkingHint() {
    blinkTimer = Timer.periodic(
      Duration(milliseconds: 500),
          (timer) {
        setState(() {
          isHintVisible = !isHintVisible;
        });
      },
    );
  }

  void updateBottomNavVisibility(int index) {
    widget.onToggleBottomNav(isTextVisible[index]); // Update Bottom Navigation Bar visibility
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return PageView.builder(
      controller: pageController,
      itemCount: 4,
      onPageChanged: updateBottomNavVisibility, // Update visibility on page change
      itemBuilder: (context, index) {
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.delta.dy < -10 && !isTextVisible[index]) {
              setState(() {
                isTextVisible[index] = true;
                widget.onToggleBottomNav(true); // Show Bottom Navigation Bar
              });
            } else if (details.delta.dy > 10 && isTextVisible[index]) {
              setState(() {
                isTextVisible[index] = false;
                widget.onToggleBottomNav(false); // Hide Bottom Navigation Bar
              });
            }
          },
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: isTextVisible[index]
                ? _buildTextView(index)
                : _buildImageView(index),
          ),
        );
      },
    );
  }

  Widget _buildImageView(int index) {
    return Stack(
      key: ValueKey('image_$index'),
      children: [
        Image.asset(
          'assets/img/${index + 1}.jpg',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),
        Positioned(
          bottom: 20.0,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedOpacity(
              opacity: isHintVisible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Text(
                "<< Swipe Up for Info >>",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextView(int index) {
    final texts = [
      'Page 1: Welcome to the app!',
      'Page 2: Swipe left or right to explore images.',
      'Page 3: Enjoy your experience!',
      'Page 4: Thank you for visiting our app!',
    ];

    return Container(
      key: ValueKey('text_$index'),
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              texts[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Scroll down to return to the image.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
