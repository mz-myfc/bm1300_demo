import 'package:flutter/material.dart';

import 'utils/ble_helper.dart';
import 'utils/helper.dart';
import 'utils/notice.dart';
import 'utils/pop/Pop.dart';
import 'utils/tips.dart';

/*
 * @description HomePage
 * @author zl
 * @date 2023/11/20 16:13
 */
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    Helper.h.startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('BM1300 Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.bluetooth),
              onPressed: () => Ble.helper.startScan(),
            ),
          ],
        ),
        body: ChangeNotifierProvider(
          data: Helper.h,
          child: Consumer<Helper>(
            builder: (context, helper) => Column(
              children: [

                Flex(
                  direction: Axis.horizontal,
                  children: [
                    MyBox(title: 'SYS', value: helper.sys.intVal, unit: 'mmHg'),
                    MyBox(title: 'DIA', value: helper.dia.intVal, unit: 'mmHg'),
                  ],
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    MyBox(title: 'SpO₂', value: helper.spo2.intVal, unit: '%'),
                    MyBox(title: 'PR', value: helper.pr.intVal, unit: 'bpm'),
                  ],
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    MyBox(title: 'PI', value: helper.pi.asFixed, unit: ''),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 15, 15, 0),
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.warning_outlined, color: Colors.amber),
                    onPressed: () => Pop.helper.promptPop(),
                  ),
                ),
                const Spacer(),
                const Text('v1.0', style: TextStyle(fontSize: 15)),
                const Text('Shanghai Berry Electronic Tech Co., Ltd.', style: TextStyle(fontSize: 15)),
                const SizedBox(height: 15), 
              ],
            ),
          ),
        ),
      );

  @override
  void dispose() {
    Helper.h.stopTimer();
    super.dispose();
  }
}

class MyBox extends StatelessWidget {
  const MyBox({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
  });

  final String title;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          height: 100,
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(width: 0.5, color: Colors.grey),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 5,
                left: 5,
                child: Text(title, style: const TextStyle(fontSize: 15)),
              ),
              Text(value, style: const TextStyle(fontSize: 25)),
              Positioned(
                right: 5,
                bottom: 5,
                child: Text(unit ?? '', style: const TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ),
      );
}
