// import 'package:petroject/features/user/domain/user_model.dart';
// import 'package:petroject/utiils/api.dart';

// class AuthRepository {
//   final endpoint = "auth";

// //login
//   Future<UserModel?> login({
//     required String email,
//     required String password,
//     required Device device,
//   }) async {
//     try {
//       final response = await Api.post(endpoint: "$endpoint/login", body: {
//         "email": email,
//         "password": password,
//         "device": device.deviceId
//       });

//       final user = UserModel.fromRawJson(response.body);
//       return user;
//     } catch (e) {
//       rethrow;
//     }
//   }

// //signup
//   Future<UserModel?> register({
//     required String email,
//     required String password,
//     required Device device,
//     required String name,
//     required int phoneNumber,
//     required DateTime dob,
//     required String gender,
//   }) async {
//     try {
//       final response = await Api.post(
//           code: [201],
//           endpoint: "$endpoint/signup",
//           body: {
//             "name": name,
//             "email": email,
//             "phoneNumber": phoneNumber,
//             "dob": dob.toIso8601String(),
//             "gender": gender,
//             "password": password,
//             "device": device.toJson()
//           });

//       final user = UserModel.fromRawJson(response.body);
//       return user;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   //forgot password
//   Future<void> forgotPassword({
//     required String email,
//   }) async {
//     try {
//       final response = await Api.post(
//           code: [200, 409],
//           endpoint: "$endpoint/forgot-password",
//           body: {
//             "email": email,
//           });

//       return;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   //to reset

//   Future<void> resetPassword({
//     required String resetToken,
//     required String newPassword,
//   }) async {
//     try {
//       final response =
//           await Api.post(endpoint: "$endpoint/reset-password", body: {
//         "resetToken": resetToken,
//         "newPassword": newPassword,
//       });

//       return;
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
