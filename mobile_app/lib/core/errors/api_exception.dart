import 'app_exception.dart';

class ApiException extends AppException {
  const ApiException({
    required this.statusCode,
    required String message,
  }) : super(message);

  final int statusCode;
}
