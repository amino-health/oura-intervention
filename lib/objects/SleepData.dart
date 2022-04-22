// Object that stores data that will be stored
// in Firestore Database about sleep for one day
class SleepData {
  //hr in beats per minute
  final double minHr;
  final double avgHr;
  final double maxHr;

  //sleep in seconds
  final int totalSleep;
  final int lightSleep;
  final int remSleep;
  final int deepSleep;

  //date as string "YYYY-MM-DD"
  final String date;

  const SleepData({
    required this.minHr,
    required this.avgHr,
    required this.maxHr,
    required this.totalSleep,
    required this.lightSleep,
    required this.remSleep,
    required this.deepSleep,
    required this.date,
  });

  factory SleepData.fromJson(Map<String, dynamic> json) {
    //remove all zero-values from sleep heart-rate
    List<double> hr = json['hr_5min'].where((f) => (f > 0)).toList();
    //because max heart-rate is not included as an attribute, we can
    //calculate it from this list.
    hr.sort();
    double maxHr = hr.last;

    return SleepData(
      minHr: json['hr_lowest'],
      avgHr: json['hr_average'],
      maxHr: maxHr,
      totalSleep: json['total'],
      lightSleep: json['light'],
      remSleep: json['rem'],
      deepSleep: json['deep'],
      date: json['summary_date'],
    );
  }
}
