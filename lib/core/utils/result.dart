// core/utils/result.dart
class Result<T> {
  final T? data;
  final Failure? error;

  const Result._({this.data, this.error});

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
  
  static Result<T> success<T>(T data) => Result._(data: data);
  static Result<T> failure<T>(Failure error) => Result._(error: error);
}

class Failure {
  final String message;
  final String? code;
  Failure(this.message, {this.code});
}
