import "package:test/test.dart";

void main() {
  final groupIds = [1, 2, 3];
  group('test contains', () {
    test('contains', () {
      expect(groupIds.contains(2), true);
    });
    test('contains null', () {
      expect(groupIds.contains(null), false);
    });
  });
  final items = [null, null, 1, 2, 5, 6];
  test('only deleted', () {
    final r = items.where((e) {
      return !groupIds.contains(e);
    });
    expect(r, [5, 6]);
  });
}
