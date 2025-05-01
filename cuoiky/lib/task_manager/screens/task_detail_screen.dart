import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

// Màn hình chi tiết nhiệm vụ với thiết kế rực rỡ và sang trọng
class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> with TickerProviderStateMixin {
  late AnimationController _waveAnimationController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    // Hiệu ứng sóng gradient
    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.cyanAccent,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.cyanAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.cyanAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
              tooltip: themeProvider.isDarkMode ? 'Chế độ sáng' : 'Chế độ tối',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Hiệu ứng sóng gradient
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(
                  animationValue: _waveAnimation.value,
                  isDarkMode: themeProvider.isDarkMode,
                ),
                child: Container(),
              );
            },
          ),
          // Nền gradient chính
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeProvider.isDarkMode
                    ? [
                  Colors.purple[900]!.withOpacity(0.8),
                  Colors.blue[900]!.withOpacity(0.8),
                  Colors.teal[900]!.withOpacity(0.8),
                  Colors.pink[900]!.withOpacity(0.8),
                ]
                    : [
                  Colors.pink[300]!.withOpacity(0.8),
                  Colors.cyan[300]!.withOpacity(0.8),
                  Colors.purple[300]!.withOpacity(0.8),
                  Colors.amber[300]!.withOpacity(0.8),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Mô tả
                  _buildDetailItem(
                    label: 'Mô tả',
                    value: widget.task.description,
                    themeProvider: themeProvider,
                  ),
                  // Trạng thái
                  _buildDetailItem(
                    label: 'Trạng thái',
                    value: widget.task.status == 'To do'
                        ? 'Chưa làm'
                        : widget.task.status == 'In progress'
                        ? 'Đang làm'
                        : widget.task.status == 'Done'
                        ? 'Hoàn thành'
                        : 'Hủy',
                    themeProvider: themeProvider,
                  ),
                  // Độ ưu tiên
                  _buildDetailItem(
                    label: 'Độ ưu tiên',
                    value: widget.task.priority == 3
                        ? 'Cao'
                        : widget.task.priority == 2
                        ? 'Trung bình'
                        : 'Thấp',
                    themeProvider: themeProvider,
                  ),
                  // Ngày hết hạn
                  _buildDetailItem(
                    label: 'Ngày hết hạn',
                    value: widget.task.dueDate != null
                        ? _formatDueDate(widget.task.dueDate!)
                        : 'Không đặt',
                    themeProvider: themeProvider,
                  ),
                  // Danh mục
                  _buildDetailItem(
                    label: 'Danh mục',
                    value: widget.task.category ?? 'Không đặt',
                    themeProvider: themeProvider,
                  ),
                  // Hoàn thành
                  _buildDetailItem(
                    label: 'Hoàn thành',
                    value: widget.task.completed ? 'Có' : 'Không',
                    themeProvider: themeProvider,
                  ),
                  const SizedBox(height: 16),
                  // Tệp đính kèm
                  _buildDetailItem(
                    label: 'Tệp đính kèm',
                    value: '',
                    themeProvider: themeProvider,
                    isHeader: true,
                  ),
                  if (widget.task.attachments != null && widget.task.attachments!.isNotEmpty)
                    ...widget.task.attachments!.map((attachment) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [Colors.pinkAccent, Colors.cyanAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: themeProvider.isDarkMode
                              ? Colors.grey[850]!.withOpacity(0.9)
                              : Colors.white.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            attachment.split('/').last,
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          onTap: () {
                            // Mở tệp đính kèm (nếu cần)
                          },
                        ),
                      ),
                    ))
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Không có tệp đính kèm',
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.cyan[300] : Colors.pink[700],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Dropdown cập nhật trạng thái
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.pinkAccent, Colors.cyanAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: themeProvider.isDarkMode
                            ? Colors.grey[850]!.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: widget.task.status,
                        decoration: InputDecoration(
                          labelText: 'Cập nhật trạng thái',
                          labelStyle: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.cyan[300] : Colors.pink[700],
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
                          ),
                          prefixIcon: const Icon(Icons.task_alt, color: Colors.pinkAccent),
                        ),
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onChanged: (value) async {
                          try {
                            await taskProvider.updateTask(
                              Task(
                                id: widget.task.id,
                                title: widget.task.title,
                                description: widget.task.description,
                                status: value!,
                                priority: widget.task.priority,
                                dueDate: widget.task.dueDate,
                                createdAt: widget.task.createdAt,
                                updatedAt: DateTime.now(),
                                assignedTo: widget.task.assignedTo,
                                createdBy: widget.task.createdBy,
                                category: widget.task.category,
                                attachments: widget.task.attachments,
                                completed: widget.task.completed,
                              ),
                              authProvider.token!,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Cập nhật trạng thái thành công',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                                action: SnackBarAction(
                                  label: 'Đóng',
                                  textColor: Colors.white,
                                  onPressed: () =>
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                                ),
                              ),
                            );
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Cập nhật trạng thái thất bại: $error',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                                action: SnackBarAction(
                                  label: 'Đóng',
                                  textColor: Colors.white,
                                  onPressed: () =>
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                                ),
                              ),
                            );
                          }
                        },
                        items: [
                          'To do',
                          'In progress',
                          'Done',
                          'Cancelled',
                        ]
                            .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                            status == 'To do'
                                ? 'Chưa làm'
                                : status == 'In progress'
                                ? 'Đang làm'
                                : status == 'Done'
                                ? 'Hoàn thành'
                                : 'Hủy',
                          ),
                        ))
                            .toList(),
                        dropdownColor: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm định dạng ngày với xử lý lỗi
  String _formatDueDate(DateTime dueDate) {
    try {
      return DateFormat.yMd().format(dueDate);
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return 'Không thể định dạng';
    }
  }

  // Widget tùy chỉnh cho item chi tiết
  Widget _buildDetailItem({
    required String label,
    required String value,
    required ThemeProvider themeProvider,
    bool isHeader = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.pinkAccent, Colors.cyanAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: themeProvider.isDarkMode
              ? Colors.grey[850]!.withOpacity(0.9)
              : Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            isHeader ? label : '$label: $value',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// CustomPainter để vẽ hiệu ứng sóng gradient
class WavePainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;

  WavePainter({required this.animationValue, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: isDarkMode
            ? [
          Colors.purple[900]!.withOpacity(0.5),
          Colors.blue[900]!.withOpacity(0.5),
          Colors.teal[900]!.withOpacity(0.5),
          Colors.pink[900]!.withOpacity(0.5),
        ]
            : [
          Colors.pink[300]!.withOpacity(0.5),
          Colors.cyan[300]!.withOpacity(0.5),
          Colors.purple[300]!.withOpacity(0.5),
          Colors.amber[300]!.withOpacity(0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    for (double x = 0; x < size.width; x++) {
      final y = size.height * 0.5 +
          50 * math.sin((x / size.width * 2 * math.pi) + animationValue * 2 * math.pi);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}