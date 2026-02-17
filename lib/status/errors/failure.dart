import '../status.dart';
export 'failure_body.dart';

class Failure<T> extends Status<T> {
  final FailureBody failure;
  const Failure(this.failure, [super.data]);

  Failure<T> copyWith({FailureBody? failure, String? error, T? data}) {
    return Failure(failure ?? this.failure, data ?? this.data);
  }
}
