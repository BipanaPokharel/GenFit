import 'package:flutter/material.dart';
import 'package:fyp/features/communityfeed/firstpage.dart';
import 'package:fyp/features/communityfeed/presentation/bmi.dart';
import 'package:fyp/features/communityfeed/presentation/community.dart';
import 'package:fyp/features/communityfeed/presentation/friendmanagement.dart';
import 'package:fyp/features/communityfeed/presentation/notification.dart';
import 'package:fyp/features/communityfeed/secondpage.dart';
import 'package:fyp/features/presentation/login/login.dart';
import 'package:fyp/features/presentation/onboarding/onboarding.dart';
import 'package:fyp/features/presentation/password/password.dart';
import 'package:fyp/features/presentation/signup/signup.dart';
// import 'package:fyp/features/user/presentation/userdashboard.dart';
import 'package:fyp/features/workout/journaling.dart';
import 'package:fyp/features/workout/presentation/equipment_listing.dart';
import 'package:fyp/features/workout/presentation/mealplanner.dart';
// import 'package:fyp/features/workout/presentation/pinterest.dart';
// import 'package:fyp/features/workout/presentation/setting.dart';
import 'package:fyp/features/workout/presentation/workout.dart';
import 'package:fyp/features/user/presentation/chat.dart';

class Operator extends StatelessWidget {
  const Operator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operator Page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // **Social**
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text('Social',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ListTile(
                      title: const Text('Chat'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const ChatScreen(userId: 1, receiverId: 2),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Community Feed'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CommunityFeed(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Journal Page'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const JournalPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // **Health & Fitness**
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text('Health & Fitness',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ListTile(
                      title: const Text('Workout'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Workout(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Meal Planner'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MealPlanner(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('BMI Calculator'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const BMICalculator(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // **Workout Tools**
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text('Workout Tools',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ListTile(
                      title: const Text('Equipment Listing'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DailyWorkoutsPage(
                              username: 'bipana',
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Friend Requests'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FriendRequestsScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Notifications'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Notifications(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // **Authentication**
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text('Authentication',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ListTile(
                      title: const Text('Login'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Sign Up'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignUp(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Reset Password'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // **Onboarding**
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text('Onboarding',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ListTile(
                      title: const Text('Fitness OnBoard'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FitnessOnBoard(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Initial'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Initial(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Second Page'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Second(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
