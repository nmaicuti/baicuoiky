import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/task_item.dart';
import 'task_form_screen.dart';
import 'login_screen.dart';

// Màn hình danh sách nhiệm vụ với thiết kế rực rỡ và sang trọng
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with TickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonOpacityAnimation;
  late AnimationController _waveAnimationController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<TaskProvider>(context, listen: false)
        .fetchTasks(authProvider.token!);

    // Hiệu ứng cho FloatingActionButton
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
    _buttonAnimationController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final tasks = taskProvider.tasks
        .where((task) =>
    task.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
        (_selectedCategory == 'Tất cả' || task.category == _selectedCategory))
        .toList();

    final categories = ['Tất cả', ...tasks.map((task) => task.category ?? '').toSet()];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh sách nhiệm vụ',
          style: TextStyle(
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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            tooltip: 'Đăng xuất',
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
            child: Column(
              children: [
                // Ô tìm kiếm
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
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
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Tìm kiếm',
                          labelStyle: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.cyan[300] : Colors.pink[700],
                          ),
                          prefixIcon: const Icon(Icons.search, color: Colors.pinkAccent),
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
                        ),
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                // Dropdown danh mục
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
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
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Danh mục',
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
                        ),
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        items: categories
                            .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                            .toList(),
                        dropdownColor: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
                      ),
                    ),
                  ),
                ),
                // Danh sách nhiệm vụ
                Expanded(
                  child: DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        TabBar(
                          indicator: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.pinkAccent, Colors.cyanAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor:
                          themeProvider.isDarkMode ? Colors.cyan[300] : Colors.pink[700],
                          tabs: const [
                            Tab(text: 'Chưa làm'),
                            Tab(text: 'Đang làm'),
                            Tab(text: 'Hoàn thành'),
                            Tab(text: 'Hủy'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildTaskList(tasks, 'To do'),
                              _buildTaskList(tasks, 'In progress'),
                              _buildTaskList(tasks, 'Done'),
                              _buildTaskList(tasks, 'Cancelled'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _buttonAnimationController,
        builder: (context, _) {
          return Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: Opacity(
              opacity: _buttonOpacityAnimation.value,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TaskFormScreen()),
                  );
                },
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.pinkAccent, Colors.cyanAccent, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                tooltip: 'Thêm nhiệm vụ',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, String status) {
    final filteredTasks = tasks.where((task) => task.status == status).toList();
    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        return TaskItem(task: filteredTasks[index]);
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