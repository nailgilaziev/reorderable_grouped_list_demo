import 'dart:ui';

import 'package:flutter/material.dart';

/// Flutter code sample for [ReorderableListView].

class ItemData {
  String name;
  int? groupId;

  ItemData(this.name, {required this.groupId});
}

class GroupData {
  int id;
  String groupName;

  GroupData(this.id, this.groupName);
}

final groups = List.generate(
    4,
    (i) => GroupData(
        i,
        i % 2 == 0
            ? "group $i"
            : "group with very very long name that has many words $i"));

final allItems = [
  ...List.generate(3, (i) => ItemData(groupId: null, "item $i no group")),
  ...List.generate(4, (i) => ItemData(groupId: 0, "item $i in group 0")),
  ...List.generate(4, (i) => ItemData(groupId: 99, "item $i in group 99")),
  ...List.generate(5, (i) => ItemData(groupId: 3, "item $i in group 3")),
  ...List.generate(6, (i) => ItemData(groupId: 2, "item $i in group 2")),
];

void main() => runApp(const ReorderableApp());

class ReorderableApp extends StatelessWidget {
  const ReorderableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ReorderableListView Sample')),
        body: const ReorderableExample(),
      ),
    );
  }
}

class ReorderableExample extends StatefulWidget {
  const ReorderableExample({super.key});

  @override
  State<ReorderableExample> createState() => ReorderableListViewExampleState();
}

class ReorderableListViewExampleState extends State<ReorderableExample> {
  final List<Object> items = [];

  void reAssembleItems() {
    items.clear();
    // добавим те которые без группы
    items.addAll(allItems.where((e) => e.groupId == null));
    // добавим те, у который группа удалена, но в API все еще приходит id (по сути баг API)
    items.addAll(
      allItems.where((e) => e.groupId != null).where((e) {
        // отберем те, которые не представлены в списке групп
        final groupIds = groups.map((e) => e.id);
        return !groupIds.contains(e.groupId);
      }),
    );
    for (final g in groups) {
      items.add(g);
      items.addAll(allItems.where((e) => e.groupId == g.id));
    }
  }

  @override
  void initState() {
    reAssembleItems();
  }

  Widget buildItem(int i) {
    final item = items[i];
    if (item is GroupData) {
      return GestureDetector(
        /// key используется для уникальной идентификации элемента в листе
        key: Key("group_${item.id}"),
        onLongPress: () {
          groupLongPress(item);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 20, bottom: 4),
          child: Text(
            "[$i]${item.groupName}",
            style: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.grey),
          ),
        ),
      );
    }
    if (item is ItemData) {
      return ReorderableDelayedDragStartListener(
        key: Key(item.name),
        index: i,
        child: ListTile(
          // key должен быть уникальным. тут name условно уникальное, нужно использовать id
          title: Text("[$i]${item.name}"),
          onTap: () {},
        ),
      );
    }
    throw 'item in items list has unsupported type';
  }

  GlobalKey<ReorderableListState> listKey = GlobalKey<ReorderableListState>();

  @override
  Widget build(BuildContext context) {
    return ReorderableList(
      key: listKey,
      onReorder: onReorder,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int i) {
        return buildItem(i);
      },
      proxyDecorator: _proxyDecorator,
    );

    // return ReorderableListView(
    //   // padding: const EdgeInsets.symmetric(horizontal: 40),
    //   children: <Widget>[
    //     for (int i = 0; i < allItems.length; i++) buildItem(i)
    //   ],
    //   onReorder: (int oldIndex, int newIndex) {
    //     setState(() {
    //       if (oldIndex < newIndex) {
    //         newIndex -= 1;
    //       }
    //       final item = allItems.removeAt(oldIndex);
    //       allItems.insert(newIndex, item);
    //     });
    //   },
    // );
  }

  /// при перетаскивании item может произойти перетаскивание в соседнюю группу
  bool crossingGroupBorder(int oldIndex, int newIndex) {
    var i = oldIndex;
    while (true) {
      final item = items[i];
      if (item is GroupData) return true;
      if (oldIndex < newIndex) {
        // перетаскиваем вниз, поэтому элемент, на место которого становимся проверять не надо,
        // он просто сместится вниз. то есть мы его не пересечем. Поэтому сразу тут делаем break;
        i++;
        if (i == newIndex) break;
      } else {
        // перетаскиваем вверх, поэтому элемент, на место которого встанем,
        // надо проверить, так как мы его пересекаем. Проверка будет на след итерации
        if (i == newIndex) break;
        i--;
      }
    }
    return false;
  }

  void onReorder(int oldIndex, int newIndex) {
    print("oldIndex->newIndex $oldIndex->$newIndex");
    if (crossingGroupBorder(oldIndex, newIndex)) {
      const snackBar = SnackBar(
        content: Text('Order works only inside group'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
    });
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          child: child,
        );
      },
      child: child,
    );
  }

  void groupLongPress(GroupData g) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(g.groupName,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Переименовать"),
                dense: false,
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.arrow_circle_up),
                title: Text("Поднять выше"),
                dense: false,
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.arrow_circle_down),
                title: Text("Отпустить ниже"),
                dense: false,
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.deepOrange),
                title: Text(
                  "Удалить",
                  style: TextStyle(color: Colors.deepOrange),
                ),
                dense: false,
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
