// // ! Failure --------------------------

// import 'dart:developer';

// import 'failure.dart';

// class ServerFailure<T> extends Failure<T> {
//   const ServerFailure(super.failure);
//   factory ServerFailure.fromDioException(DioException e) {
//     final FailureBody res = FailureBody(dioExceptionType: e.type);

//     switch (e.type) {
//       case DioExceptionType.connectionTimeout:
//         return ServerFailure(
//           res.copyWith(
//             code: 408,
//             type: 'connection-timeout',
//             message: localeLang().serverTookTooLongToRespond,
//           ),
//         );

//       case DioExceptionType.badCertificate:
//         return ServerFailure(
//           res.copyWith(
//             code: 403,
//             type: 'certificate-error',
//             message: localeLang().sslCertificateNotTrusted,
//           ),
//         );

//       case DioExceptionType.badResponse:
//         return ServerFailure.fromBadResponse(e);
//       case DioExceptionType.cancel:
//         return ServerFailure(
//           res.copyWith(
//             code: 499,
//             type: 'request-canceled',
//             message: localeLang().cancel,
//           ),
//         );

//       case DioExceptionType.connectionError:
//         return ServerFailure(
//           res.copyWith(
//             code: 503,
//             type: 'connection-error',
//             message: localeLang().noInternetConnection,
//           ),
//         );

//       case DioExceptionType.receiveTimeout:
//         return ServerFailure(
//           res.copyWith(
//             code: 504,
//             type: 'receive-timeout',
//             message: localeLang().serverTookTooLong,
//           ),
//         );

//       case DioExceptionType.sendTimeout:
//         return ServerFailure(
//           res.copyWith(
//             code: 504,
//             type: 'send-timeout',
//             message: localeLang().clientTookTooLong,
//           ),
//         );
//       default:
//         log(e.message ?? '');
//         return ServerFailure(
//           res.copyWith(
//             type: 'unknown-error',
//             message: localeLang().unknownErrorOccurred,
//           ),
//         );
//     }
//   }
//   factory ServerFailure.fromBadResponse(DioException e) {
//     final int? statusCode = e.response!.statusCode;
//     print(Get.currentRoute);

//     final FailureBody res = FailureBody(
//       type: e.type.name,
//       code: statusCode ?? -1,
//       message: e.response!.data is Map
//           ? e.response!.data['message']
//           : "unKnownMessage",
//       dioExceptionType: e.type,
//     );

//     if (statusCode == 500) {
//       return ServerFailure(
//         res.copyWith(
//             message: localeLang().thereIsProblemWithServerTryAgainLater),
//       );
//     } else if (res.unauthorizedError && Get.currentRoute != AppRoute.login) {
//       Get.find<AuthLocalDataSource>().logOut().then(
//             (_) => Get.offAllNamed(AppRoute.login),
//           );
//       return ServerFailure(
//         res.copyWith(message: localeLang().unauthorizedError),
//       );
//     } else if (statusCode == 404) {
//       return ServerFailure(
//         res.copyWith(message: localeLang().notExist),
//       );
//     }
//     return ServerFailure(res);
//   }
// }
