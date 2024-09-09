import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../tips.dart';
import 'loading.dart';
import 'toast.dart';

/*
 * @description Dialog
 * @author zl
 * @date 2023/11/20 14:56
 */
class Pop {
  static final Pop helper = Pop._();

  Pop._();

  void dismiss() async => await SmartDialog.dismiss();

  ///Toast
  void toast({String msg = ''}) async {
    dismiss();
    await SmartDialog.showToast('',
        builder: (_) => ToastPop(msg: msg), displayType: SmartToastType.last);
  }

  ///Custom loading animations
  void loadAnimation({String? msg}) async {
    dismiss();
    await SmartDialog.show(
      builder: (_) => LoadAnimation(msg: msg),
    ).timeout(const Duration(minutes: 30), onTimeout: dismiss);
  }

  void promptPop() async {
    dismiss();
    await SmartDialog.show(builder: (_) => const Tips());
  }
}
