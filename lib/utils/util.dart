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
