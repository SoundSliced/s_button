part of 's_button.dart';
mixin BubbleLabelMixin {
  GlobalKey get widgetKey;

  (Offset, Size) getWidgetPositionAndSize() {
    final renderBox =
        widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return (Offset.zero, Size.zero);

    return (
      renderBox.localToGlobal(Offset.zero),
      renderBox.size,
    );
  }

  BubbleLabelContent getBubbleContentWithUpdatedPosition(dynamic widget) {
    final (offset, size) = getWidgetPositionAndSize();
    return widget.bubbleLabelContent!.copyWith(
      childWidgetPosition: offset,
      childWidgetSize: size,
    );
  }
}

class _WebBubbleLabel extends StatefulWidget {
  final GlobalKey widgetKey;
  final dynamic widget;
  final Widget child;

  const _WebBubbleLabel({
    required this.widgetKey,
    required this.widget,
    required this.child,
  });

  @override
  State<_WebBubbleLabel> createState() => _WebBubbleLabelState();
}

class _WebBubbleLabelState extends State<_WebBubbleLabel>
    with BubbleLabelMixin {
  Offset? _tapPosition;

  @override
  GlobalKey get widgetKey => widget.widgetKey;

  BubbleLabelContent _getBubbleContentWithUpdatedPosition() {
    return getBubbleContentWithUpdatedPosition(widget.widget);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) async => await BubbleLabel.show(
        bubbleContent: _getBubbleContentWithUpdatedPosition(),
      ),
      onExit: (_) async => await BubbleLabel.dismiss(),
      opaque: false,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent, // Don't consume tap events
        onDoubleTapDown: (details) => _tapPosition = details.globalPosition,
        onDoubleTap: () =>
            widget.widget.onDoubleTap?.call(_tapPosition ?? Offset.zero),
        onLongPressStart: widget.widget.onLongPressStart,
        onLongPressEnd: widget.widget.onLongPressEnd,
        child: widget.child,
      ),
    );
  }
}

class _MobileBubbleLabel extends StatelessWidget {
  final GlobalKey widgetKey;
  final dynamic widget;
  final Widget child;

  const _MobileBubbleLabel({
    required this.widgetKey,
    required this.widget,
    required this.child,
  });

  (Offset, Size) _getWidgetPositionAndSize() {
    final renderBox =
        widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return (Offset.zero, Size.zero);

    return (
      renderBox.localToGlobal(Offset.zero),
      renderBox.size,
    );
  }

  BubbleLabelContent _getBubbleContentWithUpdatedPosition() {
    final (offset, size) = _getWidgetPositionAndSize();
    return widget.bubbleLabelContent!.copyWith(
      childWidgetPosition: offset,
      childWidgetSize: size,
    );
  }

  Future<void> _handleLongPressStart(LongPressStartDetails details) async {
    if (!widget.isActive) return;

    widget.onLongPressStart?.call(details);

    if (widget.bubbleLabelContent != null) {
      await BubbleLabel.show(
        bubbleContent: _getBubbleContentWithUpdatedPosition(),
      );
    }
  }

  Future<void> _handleLongPressEnd(LongPressEndDetails details) async {
    if (!widget.isActive) return;

    widget.onLongPressEnd?.call(details);
    if (widget.bubbleLabelContent != null) {
      await BubbleLabel.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // Don't consume tap events
      onLongPressStart: _handleLongPressStart,
      onLongPressEnd: _handleLongPressEnd,
      child: child,
    );
  }
}
