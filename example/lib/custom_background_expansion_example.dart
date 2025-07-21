import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:example/custom_navigation_drawer.dart';
import 'package:flutter/material.dart';

class CustomBackgroundExpansionExample extends StatefulWidget {
  const CustomBackgroundExpansionExample({Key? key}) : super(key: key);

  @override
  State createState() => _CustomBackgroundExpansionExample();
}

class InnerList {
  final String name;
  List<String> children;
  InnerList({required this.name, required this.children});
}

class _CustomBackgroundExpansionExample
    extends State<CustomBackgroundExpansionExample> {
  late List<InnerList> _lists;

  @override
  void initState() {
    super.initState();

    _lists = List.generate(5, (outerIndex) {
      return InnerList(
        name: outerIndex.toString(),
        children: List.generate(4, (innerIndex) => '$outerIndex.$innerIndex'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Shapes & Background Colors'),
      ),
      drawer: const CustomNavigationDrawer(),
      body: DragAndDropLists(
        children: List.generate(_lists.length, (index) => _buildList(index)),
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        // listGhost is mandatory when using expansion tiles to prevent multiple widgets using the same globalkey
        listGhost: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 100.0),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: const Icon(Icons.add_box),
            ),
          ),
        ),
      ),
    );
  }

  _buildList(int outerIndex) {
    var innerList = _lists[outerIndex];

    // Define different color schemes and shapes for demonstration
    Color? expandedColor;
    Color? collapsedColor;
    ShapeBorder? expandedShape;
    ShapeBorder? collapsedShape;

    switch (outerIndex % 4) {
      case 0:
        expandedColor = Colors.green.shade100;
        collapsedColor = Colors.green.shade300;
        expandedShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: Colors.green.shade400, width: 2.0),
        );
        collapsedShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.green.shade600, width: 1.0),
        );
        break;
      case 1:
        expandedColor = Colors.blue.shade100;
        collapsedColor = Colors.blue.shade300;
        expandedShape = const CircleBorder(
          side: BorderSide(color: Colors.blue, width: 2.0),
        );
        collapsedShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
          side: BorderSide(color: Colors.blue.shade600, width: 1.0),
        );
        break;
      case 2:
        expandedColor = Colors.orange.shade100;
        collapsedColor = Colors.orange.shade300;
        expandedShape = BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.orange.shade400, width: 2.0),
        );
        collapsedShape = BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
          side: BorderSide(color: Colors.orange.shade600, width: 1.0),
        );
        break;
      case 3:
        expandedColor = Colors.purple.shade100;
        collapsedColor = Colors.purple.shade300;
        expandedShape = const StadiumBorder(
          side: BorderSide(color: Colors.purple, width: 2.0),
        );
        collapsedShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Colors.purple.shade600, width: 1.0),
        );
        break;
    }

    return DragAndDropListExpansion(
      title: Text('List ${innerList.name}'),
      subtitle: Text('Custom Shapes & Colors'),
      leading: const Icon(Icons.palette),
      expandedBackgroundColor: expandedColor,
      collapsedBackgroundColor: collapsedColor,
      expandedShape: expandedShape,
      collapsedShape: collapsedShape,
      children: List.generate(innerList.children.length,
          (index) => _buildItem(innerList.children[index])),
      listKey: ObjectKey(innerList),
    );
  }

  _buildItem(String item) {
    return DragAndDropItem(
      child: ListTile(
        title: Text(item),
        trailing: const Icon(Icons.drag_handle),
      ),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _lists[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _lists.removeAt(oldListIndex);
      _lists.insert(newListIndex, movedList);
    });
  }
}
