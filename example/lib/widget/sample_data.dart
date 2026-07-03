class SampleData {
  static List<String> generate({int count = 20}) {
    return List.generate(count, (i) => 'Item ${i + 1}');
  }

  static Future<void> simulateNetwork({int millis = 1500}) {
    return Future.delayed(Duration(milliseconds: millis));
  }

  static List<String> appendMore(List<String> items, {int count = 5}) {
    final start = items.length;
    return [
      ...items,
      ...List.generate(count, (i) => 'Item ${start + i + 1}'),
    ];
  }

  static bool randomFailure({double rate = 0.3}) {
    return DateTime.now().millisecondsSinceEpoch % 100 < rate * 100;
  }
}
