import 'dart:io'; // For File handling
import 'dart:typed_data'; // For handling bytes
import 'package:flutter/services.dart'; // For accessing assets

String capitalizeFirst(String text) {
  if (text.isEmpty) {
    return text;
  }
  return text.substring(0, 1).toUpperCase() + text.substring(1);
}

DateTime getFirstDayOfWeek(DateTime date) {
  // Get the weekday (0 for Sunday, 1 for Monday, ..., 6 for Saturday)
  int weekday = date.weekday;

  // Calculate the difference between the current weekday and Monday
  int difference = (weekday + 7 - DateTime.monday) % 7;

  // Subtract the difference from the current date to get the first day of the week
  return date.subtract(Duration(days: difference));
}

// Method to check if the next day has started
bool checkIfNextDayStarted(
    DateTime existingDateTime, DateTime currentDateTime) {
  // Check if the current date is after the existing date
  if (currentDateTime.isAfter(existingDateTime)) {
    // Check if the day part of the date has changed
    if (currentDateTime.day > existingDateTime.day) {
      return true; // The next day has started
    }
  }
  return false; // The next day has not started yet
}

Future<Uint8List> loadFileAudio(String filePath) async {
  File file = File(filePath);
  Uint8List bytes = await file.readAsBytes();
  return bytes;
}
