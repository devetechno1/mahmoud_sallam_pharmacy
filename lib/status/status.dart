export 'errors/failure.dart';
export 'success/success.dart';

abstract class Status<T> {
  final T? data;
  const Status([this.data]);
}

// class Loading extends Status {
//   const Loading([this.loadingMore = false]);
//   final bool loadingMore;
// }
