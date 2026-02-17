import '../custom/toast_component.dart';
import '../main.dart';
import 'status.dart';

Future<Status<T>> executeAndHandleErrors<T>(
  Future<T> Function() function, [
  Future<T?> Function()? functionWhenError,
]) async {
  try {
    return Success<T>(await function());
  } catch (e, st) {
    recordError(e, st);

    T? data;
    if (functionWhenError != null) data = await functionWhenError();

    // if (e is DioException) {
    //   if (AppInfo.isDebugMode) print("DioException: ${e.response}");
    //   return ServerFailure<T>.fromDioException(e).copyWith(data: data);
    // }

    return Failure<T>(FailureBody(message: e.toString()), data);
  }
}

Future<T?> handleErrorsWithMessage<T>(
  Future<T> Function() function, [
  Future<T?> Function()? functionWhenError,
]) async {
  final Status temp = await executeAndHandleErrors<T>(
    function,
    functionWhenError,
  );
  if (temp is Success<T>) return temp.data;

  if (temp is Failure<T>) {
    ToastComponent.showDialog(temp.failure.message ?? temp.failure.type);

    return temp.data;
  }

  return null;
}
