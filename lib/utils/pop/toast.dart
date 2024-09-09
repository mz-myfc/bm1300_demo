import 'package:flutter/material.dart';

/*
 * @description Toast
 * @author zl
 * @date 2023/11/20 14:56
 */
class ToastPop extends StatelessWidget {
  const ToastPop({super.key, required this.msg});
  final String msg;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 50),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            msg,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
}
