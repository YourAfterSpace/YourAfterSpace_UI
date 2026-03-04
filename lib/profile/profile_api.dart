import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'user_profile.dart' as profile_models;


class ProfileApiException implements Exception {
  final String message;
  final int? statusCode;

  ProfileApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ProfileApiException: $message (status: $statusCode)';
}

/// Returns the Cognito user sub (identity id) for API headers.
/// Your Spring Boot backend expects this in x-amzn-oidc-identity.
Future<String?> _getCognitoUserSub() async {
  try {
    final cognitoPlugin =
        Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    final session = await cognitoPlugin.fetchAuthSession();
    final sub = session.userSubResult.value;
    return sub.isNotEmpty ? sub : null;
  } catch (e) {
    debugPrint('ProfileApi: failed to get user sub: $e');
    return null;
  }
}

/// Headers for profile API: Spring Boot expects x-amzn-oidc-identity with Cognito user id.
Future<Map<String, String>> _profileHeaders() async {
  final userSub = await _getCognitoUserSub();
  if (userSub == null) return {};
  return {
    'Content-Type': 'application/json',
    'x-amzn-oidc-identity': userSub,
  };
}

/// Shared API headers for other modules (e.g. experiences).
Future<Map<String, String>> getApiHeaders() async => _profileHeaders();

/// GET user profile. Returns true if profile exists (200 + success), false otherwise.
/// On network/CORS errors returns false (treat as profile incomplete → show onboarding).
Future<bool> getProfileExists() async {
  try {
    final headers = await _profileHeaders();
    if (headers.isEmpty) return false;

    final uri = Uri.parse(userProfileUrl);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) return false;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final success = body['success'] as bool? ?? false;
    final data = body['data'];
    return success && data != null;
  } catch (e) {
    debugPrint('ProfileApi getProfileExists: $e');
    return false;
  }
}

/// GET full profile data (for profile page). Returns data object or null.
Future<Map<String, dynamic>?> getProfileData() async {
  try {
    final headers = await _profileHeaders();
    if (headers.isEmpty) return null;
    final uri = Uri.parse(userProfileUrl);
    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final success = body['success'] as bool? ?? false;
    final data = body['data'];
    if (!success || data == null) return null;
    return data as Map<String, dynamic>;
  } catch (e) {
    debugPrint('ProfileApi getProfileData: $e');
    return null;
  }
}

/// POST questionnaire answers. Body: { "answers": { "questionId": value or [values] } }.
Future<void> postQuestionnaire(Map<String, dynamic> answers) async {
  final headers = await _profileHeaders();
  if (headers.isEmpty) throw ProfileApiException('Not authenticated');
  final uri = Uri.parse(userQuestionnaireUrl);
  final response = await http.post(
    uri,
    headers: headers,
    body: jsonEncode({'answers': answers}),
  );
  if (response.statusCode >= 200 && response.statusCode < 300) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final success = body['success'] as bool? ?? false;
    if (!success) {
      final msg = body['message'] as String? ?? 'Save failed';
      throw ProfileApiException(msg, response.statusCode);
    }
    return;
  }
  String message = 'Server error: ${response.statusCode}';
  try {
    final b = jsonDecode(response.body) as Map<String, dynamic>?;
    if (b != null && b['message'] != null) message = b['message'] as String;
  } catch (_) {}
  throw ProfileApiException(message, response.statusCode);
}

/// POST user profile to backend. Throws [ProfileApiException] on failure.
Future<void> postUserProfile(profile_models.UserProfile profile) async {
  final headers = await _profileHeaders();
  if (headers.isEmpty) {
    throw ProfileApiException('Not authenticated');
  }

  final uri = Uri.parse(userProfileUrl);
  final response = await http.post(
    uri,
    headers: headers,
    body: jsonEncode(profile.toJson()),
  );

  if (response.statusCode >= 200 && response.statusCode < 300) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final success = body['success'] as bool? ?? false;
    if (!success) {
      final msg = body['message'] as String? ?? 'Profile save failed';
      throw ProfileApiException(msg, response.statusCode);
    }
    return;
  }

  String message = 'Server error: ${response.statusCode}';
  try {
    final body = jsonDecode(response.body) as Map<String, dynamic>?;
    if (body != null && body['message'] != null) {
      message = body['message'] as String;
    }
  } catch (_) {}
  throw ProfileApiException(message, response.statusCode);
}
