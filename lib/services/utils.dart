import 'dart:math';

int getDatestamp() {
  final DateTime now = DateTime.now();
  final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration difference = now.difference(epoch);
  final int days = difference.inDays;
  return days;
}

int? parseDuration(String duration) {
  if (duration == null) {
    return null;
  }
  List<int> mappedIncrements = List.generate(3, (i) => max(0, 3600 - 60 * i));
  List<String> times = duration.split(":").reversed.toList();
  int seconds = 0;
  for (var i = 0; i < times.length; i++) {
    seconds += mappedIncrements[i] * int.parse(times[i]);
  }
  return seconds;
}
