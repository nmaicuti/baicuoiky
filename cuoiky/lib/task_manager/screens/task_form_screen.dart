import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

// Màn hình thêm/sửa nhiệm vụ với thiết kế rực rỡ và sang trọng
class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _status = 'To do';
  int _priority = 1;
  DateTime? _dueDate;
  String? _category;
  String? _assignedTo;
  List<String> _attachments = [];
  bool _completed = false;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonOpacityAnimation;
  late AnimationController _waveAnimationController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
      _category = widget.task!.category;
      _assignedTo = widget.task!.assignedTo;
      _attachments = widget.task!.attachments ?? [];
      _completed = widget.task!.completed;
    }

    // Hiệu ứng cho nút
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeInOut),
    );
    _buttonOpacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeInOut),
    );

    // Hiệu ứng sóng gradient cho nền
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
    _titleController.dispose();
    _descriptionController.dispose();
    _buttonAnimationController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pinkAccent,
              onPrimary: Colors.white,
              surface: Colors.cyanAccent,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.pinkAccent),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _attachments.addAll(result.paths.where((path) => path != null).cast<String>());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isAdmin = authProvider.user?.role == 'admin';

    // Nếu không phải admin, gán mặc định assignedTo là ID của user hiện tại
    if (!isAdmin && widget.task == null) {
      _assignedTo = authProvider.user?.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'Thêm nhiệm vụ' : 'Sửa nhiệm vụ',
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
          // Hiệu ứng sóng gradient làm nền
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
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Ô nhập tiêu đề
                    _buildTextFormField(
                      controller: _titleController,
                      labelText: 'Tiêu đề',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tiêu đề';
                        }
                        return null;
                      },
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(height: 16),
                    // Ô nhập mô tả
                    _buildTextFormField(
                      controller: _descriptionController,
                      labelText: 'Mô tả',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mô tả';
                        }
                        return null;
                      },
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(height: 16),
                    // Dropdown trạng thái
                    _buildDropdownFormField<String>(
                      value: _status,
                      labelText: 'Trạng thái',
                      items: ['Chưa làm', 'Đang làm', 'Hoàn thành', 'Hủy']
                          .map((status) => DropdownMenuItem(
                        value: status == 'Chưa làm'
                            ? 'To do'
                            : status == 'Đang làm'
                            ? 'In progress'
                            : status == 'Hoàn thành'
                            ? 'Done'
                            : 'Cancelled',
                        child: Text(status),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _status = value!;
                        });
                      },
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(height: 16),
                    // Dropdown độ ưu tiên
                    _buildDropdownFormField<int>(
                      value: _priority,
                      labelText: 'Độ ưu tiên',
                      items: [
                        const DropdownMenuItem(value: 1, child: Text('Thấp')),
                        const DropdownMenuItem(value: 2, child: Text('Trung bình')),
                        const DropdownMenuItem(value: 3, child: Text('Cao')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(height: 16),
                    // Chọn ngày hết hạn
                    _buildListTile(
                      title: _dueDate == null
                          ? 'Chọn ngày hết hạn'
                          : 'Ngày hết hạn: ${DateFormat.yMd('vi_VN').format(_dueDate!)}',
                      onTap: () => _pickDate(context),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(height: 16),
                    // Ô nhập danh mục
                    _buildTextFormField(
                      initialValue: _category,
                      labelText: 'Danh mục',
                      onChanged: (value) {
                        _category = value;
                      },
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(height: 16),
                    // Ô nhập người được gán
                    _buildTextFormField(
                      initialValue: _assignedTo,
                      labelText: 'Gán cho (ID người dùng)',
                      onChanged: (value) {
                        _assignedTo = value;
                      },
                      enabled: isAdmin,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập ID người dùng';
                        }
                        return null;
                      },
                      themeProvider: themeProvider,
                    ),
                    if (!isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Lưu ý: Là người dùng thông thường, bạn chỉ có thể gán nhiệm vụ cho chính mình.',
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.cyan[300] : Colors.pink[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Switch hoàn thành
                    _buildSwitchListTile(
                      title: 'Hoàn thành',
                      value: _completed,
                      onChanged: (value) {
                        setState(() {
                          _completed = value;
                        });
                      },
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(height: 16),
                    // Nút tải lên tệp
                    _buildElevatedButton(
                      onPressed: _pickFile,
                      child: const Text('Tải lên tệp đính kèm'),
                      themeProvider: themeProvider,
                    ),
                    // Danh sách tệp đính kèm
                    if (_attachments.isNotEmpty)
                      ..._attachments.map((attachment) => ListTile(
                        title: Text(
                          attachment.split('/').last,
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              _attachments.remove(attachment);
                            });
                          },
                        ),
                      )),
                    const SizedBox(height: 16),
                    // Nút lưu nhiệm vụ
                    _buildElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final task = Task(
                              id: widget.task?.id ?? '',
                              title: _titleController.text,
                              description: _descriptionController.text,
                              status: _status,
                              priority: _priority,
                              dueDate: _dueDate,
                              createdAt: widget.task?.createdAt ?? DateTime.now(),
                              updatedAt: DateTime.now(),
                              assignedTo: _assignedTo,
                              createdBy: authProvider.user!.id,
                              category: _category,
                              attachments: _attachments,
                              completed: _completed,
                            );

                            if (widget.task == null) {
                              final response = await taskProvider.createTask(task, authProvider.token!);
                              final taskId = response['task']['id'];
                              if (_attachments.isNotEmpty) {
                                await taskProvider.uploadAttachments(taskId, _attachments, authProvider.token!);
                              }
                            } else {
                              await taskProvider.updateTask(task, authProvider.token!);
                              if (_attachments.isNotEmpty) {
                                await taskProvider.uploadAttachments(task.id, _attachments, authProvider.token!);
                              }
                            }
                            Navigator.pop(context);
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Lưu nhiệm vụ thất bại: $error',
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
                                  onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(widget.task == null ? 'Thêm nhiệm vụ' : 'Cập nhật nhiệm vụ'),
                      themeProvider: themeProvider,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget tùy chỉnh cho TextFormField
  Widget _buildTextFormField({
    TextEditingController? controller,
    String? initialValue,
    required String labelText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool enabled = true,
    required ThemeProvider themeProvider,
  }) {
    return Container(
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
          color: themeProvider.isDarkMode ? Colors.grey[850]!.withOpacity(0.9) : Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          initialValue: initialValue,
          decoration: InputDecoration(
            labelText: labelText,
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
            prefixIcon: Icon(
              labelText == 'Tiêu đề'
                  ? Icons.title
                  : labelText == 'Mô tả'
                  ? Icons.description
                  : labelText == 'Danh mục'
                  ? Icons.category
                  : Icons.person,
              color: Colors.pinkAccent,
            ),
          ),
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
        ),
      ),
    );
  }

  // Widget tùy chỉnh cho DropdownButtonFormField
  Widget _buildDropdownFormField<T>({
    required T value,
    required String labelText,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required ThemeProvider themeProvider,
  }) {
    return Container(
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
          color: themeProvider.isDarkMode ? Colors.grey[850]!.withOpacity(0.9) : Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            labelText: labelText,
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
            prefixIcon: Icon(
              labelText == 'Trạng thái' ? Icons.task_alt : Icons.priority_high,
              color: Colors.pinkAccent,
            ),
          ),
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
          onChanged: onChanged,
          items: items,
          dropdownColor: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        ),
      ),
    );
  }

  // Widget tùy chỉnh cho ListTile
  Widget _buildListTile({
    required String title,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return Container(
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
          color: themeProvider.isDarkMode ? Colors.grey[850]!.withOpacity(0.9) : Colors.white.withOpacity(0.9),
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
            title,
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          trailing: const Icon(Icons.calendar_today, color: Colors.pinkAccent),
          onTap: onTap,
        ),
      ),
    );
  }

  // Widget tùy chỉnh cho SwitchListTile
  Widget _buildSwitchListTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeProvider themeProvider,
  }) {
    return Container(
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
          color: themeProvider.isDarkMode ? Colors.grey[850]!.withOpacity(0.9) : Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SwitchListTile(
          title: Text(
            title,
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: Colors.cyanAccent,
          inactiveThumbColor: Colors.pinkAccent,
          inactiveTrackColor: Colors.grey[400],
        ),
      ),
    );
  }

  // Widget tùy chỉnh cho ElevatedButton
  Widget _buildElevatedButton({
    required VoidCallback? onPressed,
    required Widget child,
    required ThemeProvider themeProvider,
  }) {
    return AnimatedBuilder(
      animation: _buttonAnimationController,
      builder: (context, _) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: Opacity(
            opacity: _buttonOpacityAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                splashColor: Colors.amberAccent.withOpacity(0.6),
                highlightColor: Colors.cyanAccent.withOpacity(0.4),
                onTapDown: (_) {
                  _buttonAnimationController.forward();
                },
                onTapUp: (_) {
                  _buttonAnimationController.reverse();
                },
                onTapCancel: () {
                  _buttonAnimationController.reverse();
                },
                onTap: onPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pinkAccent, Colors.cyanAccent, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(child: child),
                ),
              ),
            ),
          ),
        );
      },
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