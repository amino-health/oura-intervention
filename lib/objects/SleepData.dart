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
    //because max heart rate is not stored, we have to calculate it
    List<dynamic> hr = json['hr_5min'];
    List<double> hrList = [];
    for (int i = 0; i < hr.length; i++) {
      hrList.add(hr[i] as double);
    }
    hrList.sort();
    double maxHr = hrList.last;
    return SleepData(
      minHr: json['hr_lowest'] as double,
      avgHr: json['hr_average'] as double,
      maxHr: maxHr,
      totalSleep: json['total'] as int,
      lightSleep: json['light'] as int,
      remSleep: json['rem'] as int,
      deepSleep: json['deep'] as int,
      date: json['summary_date'] as String,
    );
  }
}
