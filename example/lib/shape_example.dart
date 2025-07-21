import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:example/custom_navigation_drawer.dart';
import 'package:flutter/material.dart';

class ShapeExample extends StatefulWidget {
  const ShapeExample({Key? key}) : super(key: key);

  @override
  State createState() => _ShapeExample();
}

class InnerList {
  final String name;
  List<String> children;
  InnerList({required this.name, required this.children});
}

class _ShapeExample extends State<ShapeExample> {
  late List<InnerList> _lists;

  @override
  void initState() {
    super.initState();

    _lists = List.generate(6, (outerIndex) {
      return InnerList(
        name: outerIndex.toString(),
        children:
            List.generate(3, (innerIndex) => 'Item $outerIndex.$innerIndex'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shape Examples'),
      ),
      drawer: const CustomNavigationDrawer(),
      body: DragAndDropLists(
        children: List.generate(_lists.length, (index) => _buildList(index)),
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
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
        listPadding: const EdgeInsets.all(8.0),
      ),
    );
  }

  _buildList(int outerIndex) {
    var innerList = _lists[outerIndex];

    // Define different shapes for demonstration
    String shapeType;
    ShapeBorder? expandedShape;
    ShapeBorder? collapsedShape;
    Color expandedColor = Colors.blue.shade50;
    Color collapsedColor = Colors.blue.shade200;

    switch (outerIndex % 6) {
      case 0:
        shapeType = 'Rounded Rectangle';
        expandedShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Colors.blue, width: 2.0),
        );
        collapsedShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(color: Colors.blue, width: 1.0),
        );
        break;
      case 1:
        shapeType = 'Stadium (Pill)';
        expandedShape = const StadiumBorder(
          side: BorderSide(color: Colors.green, width: 2.0),
        );
        collapsedShape = const StadiumBorder(
          side: BorderSide(color: Colors.green, width: 1.0),
        );
        expandedColor = Colors.green.shade50;
        collapsedColor = Colors.green.shade200;
        break;
      case 2:
        shapeType = 'Beveled Rectangle';
        expandedShape = BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(color: Colors.orange, width: 2.0),
        );
        collapsedShape = BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: Colors.orange, width: 1.0),
        );
        expandedColor = Colors.orange.shade50;
        collapsedColor = Colors.orange.shade200;
        break;
      case 3:
        shapeType = 'Circle';
        expandedShape = const CircleBorder(
          side: BorderSide(color: Colors.purple, width: 2.0),
        );
        collapsedShape = const CircleBorder(
          side: BorderSide(color: Colors.purple, width: 1.0),
        );
        expandedColor = Colors.purple.shade50;
        collapsedColor = Colors.purple.shade200;
        break;
      case 4:
        shapeType = 'Continuous Rectangle';
        expandedShape = ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: const BorderSide(color: Colors.red, width: 2.0),
        );
        collapsedShape = ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(color: Colors.red, width: 1.0),
        );
        expandedColor = Colors.red.shade50;
        collapsedColor = Colors.red.shade200;
        break;
      case 5:
        shapeType = 'Custom Border';
        expandedShape = RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(25.0),
          ),
          side: const BorderSide(color: Colors.teal, width: 2.0),
        );
        collapsedShape = RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(3.0),
            bottomLeft: Radius.circular(3.0),
            bottomRight: Radius.circular(15.0),
          ),
          side: const BorderSide(color: Colors.teal, width: 1.0),
        );
        expandedColor = Colors.teal.shade50;
        collapsedColor = Colors.teal.shade200;
        break;
      default:
        shapeType = 'Default';
    }

    return DragAndDropListExpansion(
      title: Text(shapeType),
      subtitle: Text('List ${innerList.name}'),
      leading: const Icon(Icons.shape_line),
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
