import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bubble_label/bubble_label.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';
import 'package:ticker_free_circular_progress_indicator/ticker_free_circular_progress_indicator.dart';
import 'package:s_ink_button/s_ink_button.dart';

part 'bubble_label_mixin.dart';

/// A simple delayed widget
class Delayed extends StatefulWidget {
  final Duration? delay;
  final Widget Function(BuildContext context, bool initialized) builder;

  const Delayed({
    super.key,
    this.delay,
    required this.builder,
  });

  @override
  State<Delayed> createState() => _DelayedState();
}

class _DelayedState extends State<Delayed> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
        }
      });
    } else {
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _initialized);
  }
}

/// A simple Box widget
class Box extends StatelessWidget {
  const Box({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// A customizable button widget that supports various interactions and visual effects.
///
/// Features:
/// - Splash effects
/// - Bounce animation
/// - Bubble labels
/// - Double tap support
/// - Long press support
/// - Custom shapes (circle or rectangle)
/// - Haptic feedback
/// - Loading state
/// - Error handling
/// - Custom hit test behavior
class S_Button extends StatefulWidget {
  const S_Button({
    super.key,
    required this.child,
    this.splashColor,
    this.alignment,
    this.ignoreChildWidgetOnTap = false,
    this.isCircleButton = false,
    this.shouldBounce = true,
    this.bounceScale = 0.98,
    this.bubbleLabelContent,
    this.buttonSelectedColor,
    this.onDoubleTap,
    this.onTap,
    this.splashOpacity,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.delay,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.enableHapticFeedback = true,
    this.hapticFeedbackType = HapticFeedbackType.lightImpact,
    this.isLoading = false,
    this.loadingWidget,
    this.onError,
    this.errorBuilder,
    this.isActive = true,
    this.splashBorderRadius,
    this.tooltipMessage,
  });

  final Widget child;
  final Color? splashColor;
  final Color? buttonSelectedColor;
  final double? splashOpacity;
  final double bounceScale;
  final BorderRadius? splashBorderRadius;
  final AlignmentGeometry? alignment;
  final bool ignoreChildWidgetOnTap;
  final bool isCircleButton;
  final bool shouldBounce;
  final bool isActive;
  final BubbleLabelContent? bubbleLabelContent;
  final Duration? delay;
  final void Function(Offset onTapPosition)? onTap;
  final void Function(Offset onTapPosition)? onDoubleTap;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressEndDetails)? onLongPressEnd;
  final HitTestBehavior hitTestBehavior;
  final bool enableHapticFeedback;
  final HapticFeedbackType hapticFeedbackType;
  final bool isLoading;
  final Widget? loadingWidget;
  final Function(Object error)? onError;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final String? tooltipMessage;

  @override
  State<S_Button> createState() => _S_ButtonState();
}

class _S_ButtonState extends State<S_Button> with BubbleLabelMixin {
  final _widgetKey = GlobalKey();

  @override
  GlobalKey get widgetKey => _widgetKey;

  bool _isMounted = false;

  late final bool _hasLabel = widget.bubbleLabelContent != null;
  late final bool _isWebWithoutLongPress = kIsWeb &&
      _hasLabel &&
      !widget.bubbleLabelContent!.shouldActivateOnLongPressOnAllPlatforms;
  bool ignoreChildWidgetOnTap = false;

  Color? _splashColor;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _cacheComputedValues();
    _initializeWidget();
  }

  void _cacheComputedValues() {
    _splashColor = widget.splashColor;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _initializeWidget() {
    if (!_isMounted) return;

    _isButtonOrNot();
  }

  _isButtonOrNot() {
    if (!widget.isActive || widget.ignoreChildWidgetOnTap) {
      ignoreChildWidgetOnTap = true;
    }
  }

  @override
  void didUpdateWidget(covariant S_Button oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool shouldUpdate = false;

    final shouldUpdateIgnorePointer =
        oldWidget.ignoreChildWidgetOnTap != widget.ignoreChildWidgetOnTap ||
            oldWidget.isActive != widget.isActive;

    final shouldUpdateCache =
        oldWidget.splashBorderRadius != widget.splashBorderRadius ||
            oldWidget.splashColor != widget.splashColor ||
            oldWidget.splashOpacity != widget.splashOpacity ||
            oldWidget.buttonSelectedColor != widget.buttonSelectedColor;

    if (shouldUpdateCache) {
      _cacheComputedValues();
      shouldUpdate = true;
    }

    if (shouldUpdateIgnorePointer) {
      _isButtonOrNot();
      shouldUpdate = true;
    }

    if (shouldUpdate) {
      setState(() {});
    }
  }

  void _handleTap(Offset offset) {
    if (widget.isLoading || !widget.isActive) return;
    widget.onTap?.call(offset);
  }

  @override
  Widget build(BuildContext context) {
    return _hasLabel
        ? _isWebWithoutLongPress
            ? _WebBubbleLabel(
                widgetKey: _widgetKey,
                widget: widget,
                child: _buildSimplifiedButton(),
              )
            : _MobileBubbleLabel(
                widgetKey: _widgetKey,
                widget: widget,
                child: _buildSimplifiedButton(),
              )
        : _buildSimplifiedButton();
  }

  Widget _buildSimplifiedButton() {
    final animationDuration = (widget.delay != null &&
            widget.delay! > const Duration(milliseconds: 100))
        ? const Duration(milliseconds: 200)
        : const Duration(milliseconds: 150);

    return Delayed(
      key: _widgetKey,
      delay: widget.delay,
      builder: (context, initialized) => AnimatedSwitcher(
        duration: animationDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: initialized ? _buildButtonContent() : Box(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return widget.loadingWidget ??
          const TickerFreeCircularProgressIndicator();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(),
      child: Stack(
        alignment: widget.alignment ?? Alignment.center,
        children: [
          IgnorePointer(
            ignoring: !widget.isActive,
            child: SInkButton(
              onTap: _handleTap,
              onDoubleTap: widget.onDoubleTap,
              onLongPressStart: widget.onLongPressStart,
              onLongPressEnd: widget.onLongPressEnd,
              color: _splashColor,
              scaleFactor: widget.shouldBounce &&
                      !ignoreChildWidgetOnTap &&
                      widget.isActive
                  ? widget.bounceScale
                  : 1.0,
              enableHapticFeedback: widget.enableHapticFeedback,
              hapticFeedbackType: widget.hapticFeedbackType,
              hoverAndSplashBorderRadius: widget.splashBorderRadius,
              isActive: widget.isActive,
              isCircleButton: widget.isCircleButton,
              tooltipMessage: widget.tooltipMessage,
              child: widget.child,
            ),
          ),
          if (widget.buttonSelectedColor != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.buttonSelectedColor?.withValues(alpha: 0.8),
                ),
              ).animate(effects: [FadeEffect(duration: 0.3.sec)]),
            ),
        ],
      ),
    );
  }
}
