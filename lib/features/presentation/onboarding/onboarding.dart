import 'package:flutter/material.dart';
import 'package:fyp/features/presentation/login/login.dart';

class FitnessOnBoard extends StatefulWidget {
  const FitnessOnBoard({super.key});

  @override
  State<FitnessOnBoard> createState() => _FitnessOnBoardState();
}

class _FitnessOnBoardState extends State<FitnessOnBoard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<FitnessOnBoardingContent> _contents = [
    FitnessOnBoardingContent(
      title: "Welcome to Fitness App",
      image: const AssetImage('assets/workout.png'),
      description: "Your personal fitness and diet companion!",
      fact: "Did you know? The average person walks 5,000 steps per day.",
    ),
    FitnessOnBoardingContent(
      title: "Track Your Progress",
      image: const AssetImage('assets/progress.png'),
      description: "Monitor your fitness goals and nutritional intake.",
      fact: "Strength training can increase your metabolism for up to 2 days!",
    ),
    FitnessOnBoardingContent(
      title: "Personalized Plans",
      image: const AssetImage('assets/plan.png'),
      description: "Get customized workout routines and meal plans.",
      fact: "Drinking water can boost your metabolism by 24-30%.",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[100]!, Colors.blue[50]!],
              ),
            ),
          ),
          Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child:
                      Text('Skip', style: TextStyle(color: Colors.blue[800])),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _contents.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return FitnessOnBoardingPage(content: _contents[index]);
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _contents.length,
                        (index) => buildDumbbell(index),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage != 0)
                          TextButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text('Back',
                                style: TextStyle(color: Colors.blue[800])),
                          )
                        else
                          const SizedBox.shrink(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            if (_currentPage == _contents.length - 1) {
                              _finishOnboarding();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Text(
                            _currentPage == _contents.length - 1
                                ? "Let's Go!"
                                : "Next",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDumbbell(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.fitness_center,
        color: Colors.white,
        size: 12,
      ),
    );
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }
}

class FitnessOnBoardingContent {
  final String title;
  final ImageProvider image;
  final String description;
  final String fact;

  FitnessOnBoardingContent({
    required this.title,
    required this.image,
    required this.description,
    required this.fact,
  });
}

class FitnessOnBoardingPage extends StatelessWidget {
  final FitnessOnBoardingContent content;

  const FitnessOnBoardingPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Opacity(
              opacity: 0.8,
              child: Image(
                image: content.image,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            content.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              "Fun Fact: ${content.fact}",
              style: TextStyle(
                color: Colors.blue[800],
                fontStyle: FontStyle.italic,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
