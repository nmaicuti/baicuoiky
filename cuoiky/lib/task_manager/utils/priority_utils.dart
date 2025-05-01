import 'package:flutter/material.dart';

class PriorityUtils {
  static Color getPriorityColor(int priority, [BuildContext? context]) {
    // Nếu context được cung cấp, lấy brightness để điều chỉnh màu
    final bool isDarkMode = context != null && Theme.of(context).brightness == Brightness.dark;

    switch (priority) {
      case 1:
        return isDarkMode ? Colors.green[300]! : Colors.green;
      case 2:
        return isDarkMode ? Colors.yellow[300]! : Colors.yellow;
      case 3:
        return isDarkMode ? Colors.red[300]! : Colors.red;
      default:
        return isDarkMode ? Colors.grey[300]! : Colors.grey;
    }
  }

  static String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không xác định';
    }
  }

}