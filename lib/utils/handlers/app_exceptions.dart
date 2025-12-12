class AppException implements Exception {
  final String? _prefix;
  final String? _message;

  AppException([this._prefix, this._message]);

  @override
  String toString() {
    return '$_prefix$_message';
  }
}

class DataFetchException extends AppException {
  DataFetchException([String? message]) : super('Network Error: ', message);
}

class BadRequestException extends AppException {
  BadRequestException([String? message]) : super('', message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String? message]) : super('Unauthorized: ', message);
}

class TooManyRequestsException extends AppException {
  TooManyRequestsException([String? message]) : super('Too many requests: ', message);
}

class InternalErrorException extends AppException {
  InternalErrorException([String? message]) : super('Internal Server Error: ', message);
}

class UnknownErrorException extends AppException {
  UnknownErrorException([String? message]) : super('Unknown Error: ', message);
}
