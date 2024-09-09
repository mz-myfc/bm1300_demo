import '../helper.dart';

/*
 * @description cNIBP Protocol 20 bytes
 * @author zl
 * @date 2024/9/9 13:45
 */
class CNIBPProtocol {
  static final CNIBPProtocol instance = CNIBPProtocol();

  List<int> _buffArray = [];

  void init() {
    _buffArray = [];
  }

  //Bluetooth data analysis
  void parse(List<int> array) {
    _buffArray += array;
    var i = 0; //Current index
    var validIndex = 0; //Valid indexes
    var maxIndex = _buffArray.length -
        20; //Leave at least enough room for a minimum set of data
    while (i <= maxIndex) {
      //Failed to match the headers
      if (_buffArray[i] != 0xFF || _buffArray[i + 1] != 0xAA) {
        i += 1;
        validIndex = i;
        continue;
      }
      //The header is successfully matched
      var total = 0;
      var checkSum = _buffArray[i + 19];
      for (var index = 0; index <= 18; index++) {
        total += _buffArray[i + index];
      }
      //If the verification fails, discard the two data
      if (checkSum != total % 256) {
        i += 2;
        validIndex = i;
        continue;
      }

      // Read Data
      Helper.h.read(_buffArray.sublist(i, i + 19));

      i += 20; //Move back one group
      validIndex = i;
      continue;
    }
    _buffArray = _buffArray.sublist(validIndex); //Reorganize the cache array, delete all the data before the valid index
  }
}
