import 'package:flutter/material.dart';

/*
 * @description Tips
 * @author zl
 * @date 2023/11/20 16:09
 */
class Tips extends StatefulWidget{
  const Tips({super.key });

  @override
  State<StatefulWidget> createState() => _TipsState();

}

class _TipsState extends State<Tips>{
  bool showTip = true;
  IconData icon = Icons.keyboard_arrow_down;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 50),
    padding: const EdgeInsets.all(15),
    alignment: Alignment.centerLeft,
    child: Column(
      children: [
        Row(
          children: [
            const Text('Tips', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              icon: Icon(icon, size: 30),
              onPressed: () {
                setState(() {
                  showTip = !showTip;
                  icon = showTip ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up;
                });
              },
            ),
          ],
        ),
        showTip ? const Text(
          'This Demo does not add permission prompts, please open it manually before use. \n\n'
              'Android:\n'
              '1. Please turn on the Bluetooth permission of your phone;\n'
              '2. Please allow the APP to use Bluetooth;\n'
              '3. Please allow the APP to use location information;\n'
              '4. Please enable nearby device permissions. \n\n'
              'iOS:\n'
              'Allow APP to use Bluetooth.',
          style: TextStyle(fontSize: 15),
        ): const SizedBox.shrink(),
        Container(
          margin: const EdgeInsets.only(top: 30),
          child: const Column(
            children: [
              Text('v1.0', style: TextStyle(fontSize: 15)),
              Text('Shanghai Berry Electronic Tech Co., Ltd.', style: TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ],
    ),
  );
}