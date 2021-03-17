import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Switcher<T> extends StatefulWidget {
  static SwitcherState<T> of<T>(BuildContext context) => context.read<SwitcherState<T>>();

  static Widget defaultTransitionBuilder(
    Widget child,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeThroughTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      fillColor: Colors.transparent,
      child: child,
    );
  }

  Switcher({
    Key? key,
    T? initialState,
    required this.duration,
    Duration? sizeDuration,
    this.curve = Curves.linear,
    this.clipBehavior = Clip.none,
    this.transitionBuilder = Switcher.defaultTransitionBuilder,
    Set<T>? reverseFrom,
    required this.children,
  })   : assert(children.length >= 2),
        initialState = initialState ?? children.keys.first,
        sizeDuration = sizeDuration ?? duration,
        reverseFrom = reverseFrom ?? <T>{},
        super(key: key);

  final T initialState;
  final Duration duration;
  final Duration sizeDuration;
  final Curve curve;
  final Clip clipBehavior;
  final PageTransitionSwitcherTransitionBuilder transitionBuilder;
  final Set<T> reverseFrom;
  final Map<T, Widget> children;

  @override
  SwitcherState<T> createState() => SwitcherState<T>();
}

class SwitcherState<T> extends State<Switcher<T>> with SingleTickerProviderStateMixin {
  T? _previousState;

  T get state => _stateNotifier.value;
  late final _stateNotifier = ValueNotifier<T>(widget.initialState);
  set _state(T value) {
    _previousState = state;
    _stateNotifier.value = value;
  }

  void set(T state) => _state = state;

  void reset() => _state = widget.initialState;

  void back() => _state = _previousState ?? state;

  @override
  void dispose() {
    _stateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<SwitcherState<T>>.value(
      value: this,
      child: AnimatedSize(
        vsync: this,
        duration: widget.sizeDuration,
        curve: widget.curve,
        clipBehavior: widget.clipBehavior,
        child: ValueListenableBuilder<T>(
          valueListenable: _stateNotifier,
          builder: (_, state, __) {
            return PageTransitionSwitcher(
              duration: widget.duration,
              transitionBuilder: widget.transitionBuilder,
              reverse: widget.reverseFrom.contains(_previousState),
              child: SizedBox(
                key: ValueKey(state),
                child: widget.children[state],
              ),
            );
          },
        ),
      ),
    );
  }
}
