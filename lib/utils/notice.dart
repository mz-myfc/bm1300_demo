import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InheritedProvider<T> extends InheritedWidget {
  const InheritedProvider({super.key, required this.data, required super.child});
  final T data;

  @override
  bool updateShouldNotify(InheritedProvider<T> oldWidget) => true;
}

class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  const ChangeNotifierProvider({super.key, required this.data, required this.child});
  final T data;
  final Widget child;

  static T of<T>(BuildContext context, {bool listen = true}) {
    final provider = listen
        ? context.dependOnInheritedWidgetOfExactType<InheritedProvider<T>>()
        : context
            .getElementForInheritedWidgetOfExactType<InheritedProvider<T>>()
            ?.widget as InheritedProvider<T>;
    return provider!.data;
  }

  @override
  State<StatefulWidget> createState() => _ChangeNotifierProviderState<T>();
}

class _ChangeNotifierProviderState<T extends ChangeNotifier>
    extends State<ChangeNotifierProvider<T>> {
  void update() => setState(() {});

  @override
  void didUpdateWidget(ChangeNotifierProvider<T> oldWidget) {
    if (widget.data != oldWidget.data) {
      oldWidget.data.removeListener(update);
      widget.data.addListener(update);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _portrait();
    widget.data.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    _portrait();
    widget.data.removeListener(update);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _portrait();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) =>
      InheritedProvider<T>(data: widget.data, child: widget.child);
}

class Consumer<T> extends StatelessWidget {
  const Consumer({super.key, required this.builder});
  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(BuildContext context) =>
      builder(context, ChangeNotifierProvider.of<T>(context));
}


//Force portrait orientation
void _portrait() => SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
