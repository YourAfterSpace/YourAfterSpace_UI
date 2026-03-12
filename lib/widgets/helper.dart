import 'package:flutter/material.dart';

/// Coerce API value (String or List) to String? to avoid "List is not a subtype of String?".
String? toStr(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  if (v is List && v.isNotEmpty) return v.first?.toString();
  return v.toString();
}

void showError(
  BuildContext context,
  String message, {
  bool isError = true,
}) {
  ScaffoldMessenger.of(context,).clearSnackBars();

  ScaffoldMessenger.of(context,).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14,),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? Colors.black : Colors.green.shade600,
      margin: const EdgeInsets.all(16,),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10,),
      ),
      duration: const Duration(seconds: 2,),
    ),
  );
}
