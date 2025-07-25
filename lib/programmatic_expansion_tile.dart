// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const Duration _kExpand = Duration(milliseconds: 200);

/// A single-line [ListTile] with a trailing button that expands or collapses
/// the tile to reveal or hide the [children].
///
/// This widget is typically used with [ListView] to create an
/// "expand / collapse" list entry. When used with scrolling widgets like
/// [ListView], a unique [PageStorageKey] must be specified to enable the
/// [ProgrammaticExpansionTile] to save and restore its expanded state when it is scrolled
/// in and out of view.
///
/// See also:
///
///  * [ListTile], useful for creating expansion tile [children] when the
///    expansion tile represents a sublist.
///  * The "Expand/collapse" section of
///    <https://material.io/guidelines/components/lists-controls.html>.
class ProgrammaticExpansionTile extends StatefulWidget {
  /// Creates a single-line [ListTile] with a trailing button that expands or collapses
  /// the tile to reveal or hide the [children]. The [initiallyExpanded] property must
  /// be non-null.
  const ProgrammaticExpansionTile({
    required Key key,
    required this.listKey,
    this.leading,
    required this.title,
    this.subtitle,
    this.isThreeLine = false,
    this.backgroundColor,
    this.expandedBackgroundColor,
    this.collapsedBackgroundColor,
    this.expandedShape,
    this.collapsedShape,
    this.shape,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.initiallyExpanded = false,
    this.disableTopAndBottomBorders = false,
    this.bottomPadding,
  }) : super(key: key);

  final Key listKey;

  /// A widget to display before the title.
  ///
  /// Typically a [CircleAvatar] widget.
  final Widget? leading;

  /// The primary content of the list item.
  ///
  /// Typically a [Text] widget.
  final Widget? title;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  final Widget? subtitle;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  final bool isThreeLine;

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool>? onExpansionChanged;

  /// The widgets that are displayed when the tile expands.
  ///
  /// Typically [ListTile] widgets.
  final List<Widget?> children;

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

  /// A widget to display instead of a rotating arrow icon.
  final Widget? trailing;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  /// Disable to borders displayed at the top and bottom when expanded
  final bool disableTopAndBottomBorders;

  /// The bottom padding to add to the expansion tile content when expanded
  final double? bottomPadding;

  @override
  ProgrammaticExpansionTileState createState() =>
      ProgrammaticExpansionTileState();
}

class ProgrammaticExpansionTileState extends State<ProgrammaticExpansionTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeOutTween =
      CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();
  final ColorTween _customBackgroundColorTween = ColorTween();

  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;
  late Animation<Color?> _borderColor;
  late Animation<Color?> _headerColor;
  late Animation<Color?> _iconColor;
  late Animation<Color?> _backgroundColor;
  late Animation<Color?> _customBackgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    _borderColor = _controller.drive(_borderColorTween.chain(_easeOutTween));
    _headerColor = _controller.drive(_headerColorTween.chain(_easeInTween));
    _iconColor = _controller.drive(_iconColorTween.chain(_easeInTween));
    _backgroundColor =
        _controller.drive(_backgroundColorTween.chain(_easeOutTween));
    _customBackgroundColor =
        _controller.drive(_customBackgroundColorTween.chain(_easeOutTween));

    _isExpanded = PageStorage.of(context)
            .readState(context, identifier: widget.listKey) as bool? ??
        widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;

    // Schedule the notification that widget has changed for after init
    // to ensure that the parent widget maintains the correct state
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      if (widget.onExpansionChanged != null &&
          _isExpanded != widget.initiallyExpanded) {
        widget.onExpansionChanged!(_isExpanded);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void expand() {
    _setExpanded(true);
  }

  void collapse() {
    _setExpanded(false);
  }

  void toggle() {
    _setExpanded(!_isExpanded);
  }

  void _setExpanded(bool expanded) {
    if (_isExpanded != expanded) {
      setState(() {
        _isExpanded = expanded;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse().then<void>((void value) {
            if (!mounted) return;
            setState(() {
              // Rebuild without widget.children.
            });
          });
        }
        PageStorage.of(context)
            .writeState(context, _isExpanded, identifier: widget.listKey);
      });
      if (widget.onExpansionChanged != null) {
        widget.onExpansionChanged!(_isExpanded);
      }
    }
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    final Color borderSideColor = _borderColor.value ?? Colors.transparent;
    bool setBorder = !widget.disableTopAndBottomBorders;

    // Determine the background color based on expansion state and available properties
    Color? finalBackgroundColor;

    if (widget.expandedBackgroundColor != null ||
        widget.collapsedBackgroundColor != null) {
      // Use the custom background color animation if new properties are available
      finalBackgroundColor = _customBackgroundColor.value ?? Colors.transparent;
    } else if (widget.backgroundColor != null) {
      // Fall back to legacy backgroundColor property (for backward compatibility)
      finalBackgroundColor = _backgroundColor.value ?? Colors.transparent;
    } else {
      finalBackgroundColor = Colors.transparent;
    }

    // Determine the shape based on expansion state and available properties
    ShapeBorder? finalShape;

    if (widget.expandedShape != null || widget.collapsedShape != null) {
      // Use state-specific shapes if available
      if (_isExpanded) {
        finalShape = widget.expandedShape;
      } else {
        finalShape = widget.collapsedShape;
      }
    } else if (widget.shape != null) {
      // Fall back to general shape property
      finalShape = widget.shape;
    }

    // Create the base decoration
    Decoration decoration;

    if (finalShape != null) {
      // Use ShapeDecoration when a shape is specified
      decoration = ShapeDecoration(
        color: finalBackgroundColor,
        shape: finalShape,
      );
    } else {
      // Use BoxDecoration for backward compatibility
      decoration = BoxDecoration(
        color: finalBackgroundColor,
        border: setBorder
            ? Border(
                top: BorderSide(color: borderSideColor),
                bottom: BorderSide(color: borderSideColor),
              )
            : null,
      );
    }

    return Container(
      decoration: decoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTileTheme.merge(
            iconColor: _iconColor.value,
            textColor: _headerColor.value,
            child: ListTile(
              onTap: toggle,
              leading: widget.leading,
              title: widget.title,
              subtitle: widget.subtitle,
              isThreeLine: widget.isThreeLine,
              trailing: widget.trailing ??
                  RotationTransition(
                    turns: _iconTurns,
                    child: const Icon(Icons.expand_more),
                  ),
            ),
          ),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _borderColorTween.end = theme.dividerColor;
    _headerColorTween
      ..begin = theme.textTheme.titleMedium!.color
      ..end = theme.colorScheme.secondary;
    _iconColorTween
      ..begin = theme.unselectedWidgetColor
      ..end = theme.colorScheme.secondary;

    // Set up color tweens for the new background color properties
    if (widget.expandedBackgroundColor != null ||
        widget.collapsedBackgroundColor != null) {
      _customBackgroundColorTween
        ..begin = widget.collapsedBackgroundColor ?? Colors.transparent
        ..end = widget.expandedBackgroundColor ?? Colors.transparent;
    } else {
      // Fall back to legacy backgroundColor behavior for backward compatibility
      _backgroundColorTween.end = widget.backgroundColor;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;

    Widget expansionTile = AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children as List<Widget>),
    );

    // Apply bottom padding to the entire expansion tile if specified
    if (widget.bottomPadding != null && widget.bottomPadding! > 0) {
      expansionTile = Padding(
        padding: EdgeInsets.only(bottom: widget.bottomPadding!),
        child: expansionTile,
      );
    }

    return expansionTile;
  }
}
