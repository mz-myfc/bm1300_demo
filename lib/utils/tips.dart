import 'package:flutter/material.dart';

import 'pop/pop.dart';

/*
 * @description Tips
 * @author zl
 * @date 2023/11/20 16:09
 */
class Tips extends StatelessWidget {
  const Tips({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 410,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0.5),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const Text(
              'Description of permissions. \n\n'
              'Android:\n'
              '1. Please turn on the Bluetooth permission of your phone;\n'
              '2. Please allow the APP to use Bluetooth;\n'
              '3. Please allow the APP to use location information;\n'
              '4. Please enable nearby device permissions. \n\n'
              'iOS:\n'
              'Allow APP to use Bluetooth.',
              style: TextStyle(fontSize: 15),
            ),
            const Spacer(),
            ElevatedButton(
              child: Container(
                alignment: Alignment.center,
                width: 100,
                child: const Text('OK', style: TextStyle(fontSize: 15)),
              ),
              onPressed: () => Pop.helper.dismiss(),
            ),
          ],
        ),
      );
}
