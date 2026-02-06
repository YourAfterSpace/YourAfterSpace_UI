import 'package:amplify_flutter/amplify_flutter.dart';

String parseAmplifyError(Object error) {
  // Amplify-specific errors
  if (error is AmplifyException) {
    return error.message;
  }

  // Fallback
  return error.toString();
}
