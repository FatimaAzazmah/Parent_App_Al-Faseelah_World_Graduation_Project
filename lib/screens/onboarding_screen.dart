import 'package:flutter/material.dart';

import '../utils/app_strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingItem> _items(BuildContext context) => [
        OnboardingItem(
          title: AppStrings.onboardingTitle0(context),
          description: AppStrings.onboardingDesc0(context),
          icon: Icons.spa,
          color: const Color(0xFF87CEEB),
          image: 'assets/images/onboarding1.png',
        ),
        OnboardingItem(
          title: AppStrings.onboardingTitle1(context),
          description: AppStrings.onboardingDesc1(context),
          icon: Icons.toys,
          color: const Color(0xFF90EE90),
          image: 'assets/images/onboarding2.png',
        ),
        OnboardingItem(
          title: AppStrings.onboardingTitle2(context),
          description: AppStrings.onboardingDesc2(context),
          icon: Icons.psychology,
          color: const Color(0xFFFFB74D),
          image: 'assets/images/onboarding3.png',
        ),
        OnboardingItem(
          title: AppStrings.onboardingTitle3(context),
          description: AppStrings.onboardingDesc3(context),
          icon: Icons.assessment,
          color: const Color(0xFFBA68C8),
          image: 'assets/images/onboarding4.png',
        ),
        OnboardingItem(
          title: AppStrings.onboardingTitle4(context),
          description: AppStrings.onboardingDesc4(context),
          icon: Icons.shield,
          color: const Color(0xFF4DD0E1),
          image: 'assets/images/onboarding5.png',
        ),
      ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final items = _items(context);
    if (_currentPage < items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final items = _items(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSkipButton(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(items[index]);
                },
              ),
            ),
            _buildPageIndicators(items),
            _buildNavigationButtons(items),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          onPressed: _navigateToLogin,
          child: Text(
            AppStrings.onboardingSkip(context),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                size: 80,
                color: item.color,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators(List<OnboardingItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          items.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? items[_currentPage].color
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(List<OnboardingItem> items) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: items[_currentPage].color),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward, color: items[_currentPage].color),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.onboardingPrev(context),
                      style: TextStyle(color: items[_currentPage].color),
                    ),
                  ],
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: items[_currentPage].color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage == items.length - 1
                        ? AppStrings.onboardingStart(context)
                        : AppStrings.onboardingNext(context),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentPage == items.length - 1
                        ? Icons.login
                        : Icons.arrow_back,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String image;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.image,
  });
}
