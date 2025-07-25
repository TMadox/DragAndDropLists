import 'dart:async';

import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item_target.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item_wrapper.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/programmatic_expansion_tile.dart';
import 'package:flutter/material.dart';

typedef OnExpansionChanged = void Function(bool expanded);

/// This class mirrors flutter's [ExpansionTile], with similar options.
class DragAndDropListExpansion implements DragAndDropListExpansionInterface {
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final bool initiallyExpanded;

  /// Set this to a unique key that will remain unchanged over the lifetime of the list.
  /// Used to maintain the expanded/collapsed states
  final Key listKey;

  /// This function will be called when the expansion of a tile is changed.
  final OnExpansionChanged? onExpansionChanged;

  /// The color to display behind the sublist when expanded.
  /// This is kept for backward compatibility, but consider using [expandedBackgroundColor] instead.
  final Color? backgroundColor;

  /// The color to display behind the list when expanded.
  final Color? expandedBackgroundColor;

  /// The color to display behind the list when collapsed.
  final Color? collapsedBackgroundColor;

  /// The shape of the expansion tile when expanded.
  final ShapeBorder? expandedShape;

  /// The shape of the expansion tile when collapsed.
  final ShapeBorder? collapsedShape;

  /// The shape of the expansion tile. This is kept for backward compatibility.
  /// Consider using [expandedShape] and [collapsedShape] for more control.
  final ShapeBorder? shape;

  @override
  final List<DragAndDropItem>? children;
  final Widget? contentsWhenEmpty;
  final Widget? lastTarget;

  /// Whether or not this item can be dragged.
  /// Set to true if it can be reordered.
  /// Set to false if it must remain fixed.
  @override
  final bool canDrag;

  @override
  final Key? key;

  /// Disable to borders displayed at the top and bottom when expanded
  final bool disableTopAndBottomBorders;

  /// The bottom padding to add to the expansion tile content when expanded
  final double? bottomPadding;

  final ValueNotifier<bool> _expanded = ValueNotifier<bool>(true);
  final GlobalKey<ProgrammaticExpansionTileState> _expansionKey =
      GlobalKey<ProgrammaticExpansionTileState>();

  DragAndDropListExpansion({
    this.children,
    this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.initiallyExpanded = false,
    this.backgroundColor,
    this.expandedBackgroundColor,
    this.collapsedBackgroundColor,
    this.expandedShape,
    this.collapsedShape,
    this.shape,
    this.onExpansionChanged,
    this.contentsWhenEmpty,
    this.lastTarget,
    required this.listKey,
    this.canDrag = true,
    this.key,
    this.disableTopAndBottomBorders = false,
    this.bottomPadding,
  }) {
    _expanded.value = initiallyExpanded;
  }

  @override
  Widget generateWidget(DragAndDropBuilderParameters params) {
    var contents = _generateDragAndDropListInnerContents(params);

    Widget expandable = ProgrammaticExpansionTile(
      title: title,
      listKey: listKey,
      subtitle: subtitle,
      trailing: trailing,
      leading: leading,
      disableTopAndBottomBorders: disableTopAndBottomBorders,
      backgroundColor: backgroundColor,
      expandedBackgroundColor: expandedBackgroundColor,
      collapsedBackgroundColor: collapsedBackgroundColor,
      expandedShape: expandedShape,
      collapsedShape: collapsedShape,
      shape: shape,
      initiallyExpanded: initiallyExpanded,
      onExpansionChanged: _onSetExpansion,
      key: _expansionKey,
      children: contents,
      bottomPadding: bottomPadding,
    );

    if (params.listDecoration != null) {
      expandable = Container(
        decoration: params.listDecoration,
        child: expandable,
      );
    }

    if (params.listPadding != null) {
      expandable = Padding(
        padding: params.listPadding!,
        child: expandable,
      );
    }

    Widget toReturn = ValueListenableBuilder(
      valueListenable: _expanded,
      child: expandable,
      builder: (context, dynamic error, child) {
        if (!_expanded.value) {
          return Stack(children: <Widget>[
            child!,
            Positioned.fill(
              child: DragTarget<DragAndDropItem>(
                builder: (context, candidateData, rejectedData) {
                  if (candidateData.isNotEmpty) {}
                  return Container();
                },
                onWillAcceptWithDetails: (details) {
                  _startExpansionTimer();
                  return false;
                },
                onLeave: (data) {
                  _stopExpansionTimer();
                },
                onAcceptWithDetails: (details) {},
              ),
            )
          ]);
        } else {
          return child!;
        }
      },
    );

    return toReturn;
  }

  List<Widget> _generateDragAndDropListInnerContents(
      DragAndDropBuilderParameters parameters) {
    var contents = <Widget>[];
    if (children != null && children!.isNotEmpty) {
      for (int i = 0; i < children!.length; i++) {
        contents.add(DragAndDropItemWrapper(
          child: children![i],
          parameters: parameters,
        ));
        if (i < children!.length - 1) {
          if (parameters.itemDivider != null) {
            contents.add(parameters.itemDivider!);
          } else if (parameters.itemSpacing != null &&
              parameters.itemSpacing! > 0) {
            contents.add(SizedBox(height: parameters.itemSpacing));
          }
        }
      }
      contents.add(DragAndDropItemTarget(
        parent: this,
        parameters: parameters,
        onReorderOrAdd: parameters.onItemDropOnLastTarget!,
        child: lastTarget ??
            Container(
              height: parameters.lastItemTargetHeight,
            ),
      ));
    } else {
      contents.add(
        contentsWhenEmpty ??
            const Text(
              'Empty list',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
      );
      contents.add(
        DragAndDropItemTarget(
          parent: this,
          parameters: parameters,
          onReorderOrAdd: parameters.onItemDropOnLastTarget!,
          child: lastTarget ??
              Container(
                height: parameters.lastItemTargetHeight,
              ),
        ),
      );
    }
    return contents;
  }

  @override
  toggleExpanded() {
    if (isExpanded) {
      collapse();
    } else {
      expand();
    }
  }

  @override
  collapse() {
    if (!isExpanded) {
      _expanded.value = false;
      _expansionKey.currentState!.collapse();
    }
  }

  @override
  expand() {
    if (!isExpanded) {
      _expanded.value = true;
      _expansionKey.currentState!.expand();
    }
  }

  _onSetExpansion(bool expanded) {
    _expanded.value = expanded;

    if (onExpansionChanged != null) onExpansionChanged!(expanded);
  }

  @override
  get isExpanded => _expanded.value;

  late Timer _expansionTimer;

  _startExpansionTimer() async {
    _expansionTimer =
        Timer(const Duration(milliseconds: 400), _expansionCallback);
  }

  _stopExpansionTimer() async {
    if (_expansionTimer.isActive) {
      _expansionTimer.cancel();
    }
  }

  _expansionCallback() {
    expand();
  }
}
