import "package:reorderable_list/main.dart";
import "package:test/test.dart";

void main() {
  final r = ReorderableListViewExampleState();
  group('test crossing group border', () {
    test('1 3', () {
      r.reAssembleItems();
      expect(r.crossingGroupBorder(1, 3), false);
    });
    test('1 4', () {
      r.reAssembleItems();
      expect(r.crossingGroupBorder(1, 4), true);
    });
    test('4 3', () {
      r.reAssembleItems();
      expect(r.crossingGroupBorder(4, 3), true);
    });
    test('5 4', () {
      r.reAssembleItems();
      expect(r.crossingGroupBorder(5, 4), false);
    });
    test('5 0', () {
      r.reAssembleItems();
      expect(r.crossingGroupBorder(5, 0), true);
    });
    test('4 8', () {
      r.reAssembleItems();
      expect(r.crossingGroupBorder(4, 8), false);
    });
    test('7 10', () {
      r.reAssembleItems();
      expect(r.crossingGroupBorder(7, 10), true);
    });
    test('10 9', () {
      r.reAssembleItems();
      expect(r.crossingGroupBorder(10, 9), true);
    });
    test('11 10', () {
      r.reAssembleItems();
      expect(r.crossingGroupBorder(11, 10), false);
    });
  });
}
