import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:flutter/material.dart';

abstract class DragAndDropListInterface implements DragAndDropInterface {
  List<DragAndDropItem>? get children;

  /// Optional builder to create a drag feedback widget for the whole list.
  /// The builder is passed the original generated list widget as `child` and
  /// should return the widget to be used as feedback. If null, the generated
  /// widget from `generateWidget` will be used.
  Widget Function(Widget child)? get feedbackBuilder;

  /// Whether or not this item can be dragged.
  /// Set to true if it can be reordered.
  /// Set to false if it must remain fixed.
  bool get canDrag;
  Key? get key;
  Widget generateWidget(DragAndDropBuilderParameters params);
}

abstract class DragAndDropListExpansionInterface
    implements DragAndDropListInterface {
  @override
  final List<DragAndDropItem>? children;

  DragAndDropListExpansionInterface({this.children});

  get isExpanded;

  toggleExpanded();

  expand();

  collapse();
}
