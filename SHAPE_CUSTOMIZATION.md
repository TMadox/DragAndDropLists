# Shape and Background Color Customization

## Overview

The DragAndDropListExpansion now supports comprehensive customization of both background colors and shapes for expanded and collapsed states.

## New Features

### Background Color Customization

You can now set different background colors for expanded and collapsed states:

```dart
DragAndDropListExpansion(
  title: Text('My List'),
  expandedBackgroundColor: Colors.blue.shade100,  // Color when expanded
  collapsedBackgroundColor: Colors.blue.shade300, // Color when collapsed
  children: [...],
  listKey: UniqueKey(),
)
```

### Shape Customization

You can define different shapes for expanded and collapsed states:

```dart
DragAndDropListExpansion(
  title: Text('My List'),
  expandedShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20.0),
    side: BorderSide(color: Colors.blue, width: 2.0),
  ),
  collapsedShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
    side: BorderSide(color: Colors.blue, width: 1.0),
  ),
  children: [...],
  listKey: UniqueKey(),
)
```

## Available Shape Types

### 1. RoundedRectangleBorder

Creates rectangles with rounded corners:

```dart
RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(15.0),
  side: BorderSide(color: Colors.blue, width: 2.0),
)
```

### 2. StadiumBorder (Pill Shape)

Creates a pill-shaped border:

```dart
StadiumBorder(
  side: BorderSide(color: Colors.green, width: 2.0),
)
```

### 3. BeveledRectangleBorder

Creates rectangles with beveled corners:

```dart
BeveledRectangleBorder(
  borderRadius: BorderRadius.circular(15.0),
  side: BorderSide(color: Colors.orange, width: 2.0),
)
```

### 4. CircleBorder

Creates a circular border:

```dart
CircleBorder(
  side: BorderSide(color: Colors.purple, width: 2.0),
)
```

### 5. ContinuousRectangleBorder

Creates rectangles with continuously curved corners:

```dart
ContinuousRectangleBorder(
  borderRadius: BorderRadius.circular(30.0),
  side: BorderSide(color: Colors.red, width: 2.0),
)
```

### 6. Custom Border Radius

You can create custom shapes with different corner radii:

```dart
RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(25.0),
    topRight: Radius.circular(5.0),
    bottomLeft: Radius.circular(5.0),
    bottomRight: Radius.circular(25.0),
  ),
  side: BorderSide(color: Colors.teal, width: 2.0),
)
```

## Backward Compatibility

The existing `backgroundColor` and `shape` properties are still supported for backward compatibility:

```dart
DragAndDropListExpansion(
  title: Text('My List'),
  backgroundColor: Colors.blue.shade100,  // Legacy property
  shape: RoundedRectangleBorder(          // Legacy property
    borderRadius: BorderRadius.circular(10.0),
  ),
  children: [...],
  listKey: UniqueKey(),
)
```

## Animation

The background colors and shapes smoothly animate between expanded and collapsed states using Flutter's built-in animation system.

## Complete Example

```dart
DragAndDropListExpansion(
  title: Text('Animated List'),
  subtitle: Text('With custom shapes and colors'),
  leading: Icon(Icons.palette),

  // Background colors
  expandedBackgroundColor: Colors.green.shade100,
  collapsedBackgroundColor: Colors.green.shade300,

  // Shapes
  expandedShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20.0),
    side: BorderSide(color: Colors.green, width: 2.0),
  ),
  collapsedShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
    side: BorderSide(color: Colors.green, width: 1.0),
  ),

  children: [
    DragAndDropItem(child: ListTile(title: Text('Item 1'))),
    DragAndDropItem(child: ListTile(title: Text('Item 2'))),
  ],
  listKey: UniqueKey(),
)
```
