// // ignore_for_file: use_build_context_synchronously

// import 'package:petroject/features/auth/controllers/auth_device_controller.dart';
// import 'package:petroject/features/auth/data/auth_repository.dart';
// import 'package:petroject/features/auth/presentation/login/login.dart';

// import 'package:petroject/features/pet/presentation/pet.dart';
// import 'package:petroject/features/user/domain/user_model.dart';
// import 'package:petroject/utiils/exporter.dart';

// class AuthController extends Notifier<UserModel?> {
//   final key = "user";

//   @override
//   UserModel? build() {
//     return null;
//   }

//   // Initialize our app by checking user
//   void init(BuildContext context) async {
//     await load();
//     Future.delayed(const Duration(milliseconds: 800), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => state == null ? const Login() : const First(),
//         ),
//       );
//     });
//   }

//   // Logic to load persisted user
//   Future<void> load() async {
//     final userFromStorage = await storage.read(key: key);
//     print(userFromStorage);
//     if (userFromStorage != null) {
//       state = UserModel.fromRawJson(userFromStorage);
//     }
//   }

//   // Logic to persist (store to local storage) current logged in user
//   Future<void> store() async {
//     await storage.write(key: key, value: state?.toRawJson());
//   }

//   // Logic to login user & store in device
//   Future<void> login(BuildContext context,
//       {required String email, required String password}) async {
//     try {
//       final device = await AuthDeviceController().fetchDeviceInfo();
//       if (device == null) {
//         throw Exception("Couldn't retrieve device info");
//       }

//       final loggedInUser = await AuthRepository()
//           .login(email: email, password: password, device: device);
//       if (loggedInUser == null) throw Exception("Could not login");

//       state = loggedInUser;
//       await store();

//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const First()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     }
//   }

//   // Logic to logout user & clear from local storage
//   Future<void> logout(BuildContext context) async {
//     await storage.delete(key: key);
//     state = null;
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => const Login()),
//     );
//   }

//   // Logic to signup user & store in device
//   Future<void> signup(BuildContext context,
//       {required String email,
//       required String password,
//       required String name,
//       required DateTime dob,
//       required String gender,
//       required int phoneNumber}) async {
//     try {
//       final device = await AuthDeviceController().fetchDeviceInfo();
//       if (device == null) {
//         throw Exception("Couldn't retrieve device info");
//       }

//       final signedUpUser = await AuthRepository().register(
//         email: email,
//         password: password,
//         name: name,
//         dob: dob,
//         gender: gender,
//         phoneNumber: phoneNumber,
//         device: device,
//       );

//       if (signedUpUser == null) throw Exception("Could not sign up");

//       // state = signedUpUser;
//       // await store();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text(
//                 "Registration successful! Check your email to verify account!")),
//       );
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//             builder: (context) => Login(
//                   email: email,
//                 )),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     }
//   }

//   //logic to reset password
//   Future<bool> forgotPassword(BuildContext context,
//       {required String email}) async {
//     try {
//       // Send a password reset request to the server
//       final status = await AuthRepository().forgotPassword(email: email);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Password reset request sent to your email.'),
//         ),
//       );

//       return true;
//     } catch (e) {
//       // Handle any errors during the request
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//       return false;
//     }
//   }

//   Future<bool> resetPassword(BuildContext context,
//       {required String resetToken,
//       required String newPassword,
//       required String email}) async {
//     try {
//       //password reset on the server with token and new password
//       final user = (await AuthRepository().resetPassword(
//         resetToken: resetToken,
//         newPassword: newPassword,
//       ));

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Password successfully reset!'),
//         ),
//       );

//       // Navigate to login after password reset
//       await Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//             builder: (context) => Login(
//                   email: email,
//                 )),
//       );
//       return true;
//     } catch (e) {
//       // Handle any errors
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//       return false;
//     }
//   }
// }
