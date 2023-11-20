import 'package:flutter/material.dart';

/*
 * @description Loading
 * @author zl
 * @date 2023/11/20 14:56
 */
class LoadAnimation extends StatefulWidget {
  const LoadAnimation({Key? key, this.msg}) : super(key: key);
  final String? msg;

  @override
  State<StatefulWidget> createState() => _LoadAnimationState();
}

class _LoadAnimationState extends State<LoadAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 200,
        height: 150,
        padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              alignment: Alignment.center,
              turns: _controller,
              child: Image.asset(
                'assets/images/loading.png',
                height: 50,
                width: 50,
                color: Colors.black12,
              ),
            ),
            const SizedBox(height: 15),
            Text(widget.msg ?? '')
          ],
        ),
      );

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }
}
