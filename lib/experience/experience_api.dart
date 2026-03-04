import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../profile/profile_api.dart';

/// GET /v1/experiences/all?city={cityName}. Pass null for all experiences.
Future<List<Map<String, dynamic>>> getExperiences({String? city}) async {
  try {
    final headers = await getApiHeaders();
    if (headers.isEmpty) return [];
    final uri = city != null && city.isNotEmpty
        ? Uri.parse(experiencesAllUrl).replace(queryParameters: {'city': city})
        : Uri.parse(experiencesAllUrl);
    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) return [];
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final success = body['success'] as bool? ?? false;
    final data = body['data'];
    if (!success || data == null) return [];
    final list = data as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  } catch (e) {
    debugPrint('ExperienceApi getExperiences: $e');
    return [];
  }
}

/// PUT /v1/experiences/{id}/interest with {"interested": true|false}
Future<bool> putExperienceInterest(String experienceId, bool interested) async {
  try {
    final headers = await getApiHeaders();
    if (headers.isEmpty) return false;
    final uri = Uri.parse(experienceInterestUrl(experienceId));
    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode({'interested': interested}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) return true;
    return false;
  } catch (e) {
    debugPrint('ExperienceApi putInterest: $e');
    return false;
  }
}

/// GET /v1/experiences?upcoming=true - user's upcoming experiences.
Future<List<Map<String, dynamic>>> getUpcomingExperiences() async {
  try {
    final headers = await getApiHeaders();
    if (headers.isEmpty) return [];
    final uri = Uri.parse(experiencesUrl).replace(queryParameters: {'upcoming': 'true'});
    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) return [];
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final success = body['success'] as bool? ?? false;
    final data = body['data'];
    if (!success || data == null) return [];
    final list = data as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  } catch (e) {
    debugPrint('ExperienceApi getUpcomingExperiences: $e');
    return [];
  }
}

/// GET /v1/experiences?past=true - user's past experiences.
Future<List<Map<String, dynamic>>> getPastExperiences() async {
  try {
    final headers = await getApiHeaders();
    if (headers.isEmpty) return [];
    final uri = Uri.parse(experiencesUrl).replace(queryParameters: {'past': 'true'});
    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) return [];
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final success = body['success'] as bool? ?? false;
    final data = body['data'];
    if (!success || data == null) return [];
    final list = data as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  } catch (e) {
    debugPrint('ExperienceApi getPastExperiences: $e');
    return [];
  }
}

/// PUT /v1/experiences/{id}/status with {"status": "BOOKED"} to add experience to upcoming.
Future<bool> putExperienceStatus(String experienceId, String status) async {
  try {
    final headers = await getApiHeaders();
    if (headers.isEmpty) return false;
    final uri = Uri.parse(experienceStatusUrl(experienceId));
    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) return true;
    return false;
  } catch (e) {
    debugPrint('ExperienceApi putStatus: $e');
    return false;
  }
}

/// GET /v1/user/interested-experiences. Returns list of experience IDs the user marked interested.
Future<List<String>> getInterestedExperienceIds() async {
  try {
    final headers = await getApiHeaders();
    if (headers.isEmpty) return [];
    final uri = Uri.parse(userInterestedExperiencesUrl);
    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) return [];
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final success = body['success'] as bool? ?? false;
    final data = body['data'];
    if (!success || data == null) return [];
    final list = data is List ? data : <dynamic>[];
    return list.map((e) {
      if (e is Map && e['experienceId'] != null) return e['experienceId'] as String;
      if (e is String) return e;
      return e?.toString() ?? '';
    }).where((s) => s.isNotEmpty).toList();
  } catch (e) {
    debugPrint('ExperienceApi getInterestedIds: $e');
    return [];
  }
}
