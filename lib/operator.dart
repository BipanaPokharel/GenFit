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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: const Text('workout'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const Workout(),
                    ),
                  );
                },
              ),
              // ListTile(
              //   title: const Text('PinterestFeed'),
              //   onTap: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(builder: (context) => PinterestFeed()),
              //     );
              //   },
              // ),
              ListTile(
                title: const Text('JournalPage'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const JournalPage(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('chat'),
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
                title: const Text('FitnessOnBoard'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FitnessOnBoard(),
                    ),
                  );
                },
              ),
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
                title: const Text('signup'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SignUp(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('reset'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage(),
                    ),
                  );
                },
              ),

              ListTile(
                title: const Text('EquipmentTypeSelector'),
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
                title: const Text('communityfeed'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CommunityFeed(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('FriendRequest'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FriendRequestsScreen(),
                    ),
                  );
                },
              ),
              // ListTile(
              //   title: const Text('UserProfile'),
              //   onTap: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (context) => DashboardScreen(
              //           onLogout: () {},
              //         ),
              //       ),
              //     );
              //   },
              // ),
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

              ListTile(
                title: const Text('mealplanner'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MealPlanner(),
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
                title: const Text('secondpage'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const Second(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('BMICalculatorApp'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BMICalculator(),
                    ),
                  );
                },
              ),
              // ListTile(
              //   title: const Text('userdashboard'),
              //   onTap: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (context) => ProfileScreen(),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ));
  }
}
