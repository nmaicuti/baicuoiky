import 'dart:math' as math; // Added to fix 'math' undefined error
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'register_screen.dart';
import 'task_list_screen.dart';

// Màn hình đăng nhập với thiết kế rực rỡ và sang trọng
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonOpacityAnimation;
  late AnimationController _titleAnimationController;
  late Animation<Color?> _titleColorAnimation;
  late AnimationController _waveAnimationController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    // Hiệu ứng cho nút đăng nhập
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

    // Hiệu ứng gradient động cho tiêu đề
    _titleAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _titleColorAnimation = ColorTween(
      begin: Colors.pinkAccent,
      end: Colors.cyanAccent,
    ).animate(
      CurvedAnimation(parent: _titleAnimationController, curve: Curves.easeInOut),
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
    _emailController.dispose();
    _passwordController.dispose();
    _buttonAnimationController.dispose();
    _titleAnimationController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
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
            child: Stack(
              children: [
                // Nội dung chính
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tiêu đề với hiệu ứng văn bản động và gradient
                          AnimatedBuilder(
                            animation: _titleColorAnimation,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _titleColorAnimation.value!,
                                      Colors.amberAccent,
                                      Colors.cyanAccent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _titleColorAnimation.value!.withOpacity(0.7),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: AnimatedTextKit(
                                  animatedTexts: [
                                    TyperAnimatedText(
                                      'Đăng nhập',
                                      textStyle: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.amberAccent.withOpacity(0.8),
                                            offset: const Offset(0, 0),
                                            blurRadius: 15,
                                          ),
                                        ],
                                      ),
                                      speed: const Duration(milliseconds: 100),
                                    ),
                                  ],
                                  repeatForever: true,
                                  pause: const Duration(milliseconds: 1000),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          // Khung nhập liệu với viền gradient
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [Colors.pinkAccent, Colors.cyanAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[850]!.withOpacity(0.9)
                                    : Colors.white.withOpacity(0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pinkAccent.withOpacity(0.5),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Ô nhập email
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        labelStyle: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.cyan[300]
                                              : Colors.pink[700],
                                        ),
                                        filled: true,
                                        fillColor: themeProvider.isDarkMode
                                            ? Colors.grey[900]
                                            : Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Colors.pinkAccent,
                                            width: 2,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Colors.cyanAccent,
                                            width: 2,
                                          ),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.email,
                                          color: Colors.pinkAccent,
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Vui lòng nhập email';
                                        }
                                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                          return 'Email không hợp lệ';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    // Ô nhập mật khẩu
                                    TextFormField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        labelText: 'Mật khẩu',
                                        labelStyle: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.cyan[300]
                                              : Colors.pink[700],
                                        ),
                                        filled: true,
                                        fillColor: themeProvider.isDarkMode
                                            ? Colors.grey[900]
                                            : Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Colors.pinkAccent,
                                            width: 2,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Colors.cyanAccent,
                                            width: 2,
                                          ),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.lock,
                                          color: Colors.pinkAccent,
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Vui lòng nhập mật khẩu';
                                        }
                                        if (value.length < 6) {
                                          return 'Mật khẩu cần ít nhất 6 ký tự';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    // Nút đăng nhập với hiệu ứng scale và opacity
                                    AnimatedBuilder(
                                      animation: _buttonAnimationController,
                                      builder: (context, child) {
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
                                                onTap: () async {
                                                  if (_formKey.currentState!.validate()) {
                                                    try {
                                                      await authProvider.login(
                                                        _emailController.text,
                                                        _passwordController.text,
                                                      );
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) => const TaskListScreen(),
                                                        ),
                                                      );
                                                    } catch (error) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Đăng nhập thất bại: $error',
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
                                                            onPressed: () => ScaffoldMessenger.of(context)
                                                                .hideCurrentSnackBar(),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 32,
                                                    vertical: 16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.pinkAccent,
                                                        Colors.cyanAccent,
                                                        Colors.purpleAccent,
                                                      ],
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
                                                  child: const Center(
                                                    child: Text(
                                                      'Đăng nhập',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    // Nút chuyển đến màn hình đăng ký
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const RegisterScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Chưa có tài khoản? Tạo tài khoản ngay',
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.cyan[300]
                                              : Colors.pink[700],
                                          fontWeight: FontWeight.w600,
                                          shadows: [
                                            Shadow(
                                              color: Colors.amberAccent.withOpacity(0.5),
                                              offset: const Offset(0, 0),
                                              blurRadius: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Nút chuyển đổi giao diện
                Positioned(
                  top: 40,
                  right: 16,
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
                        size: 28,
                      ),
                      onPressed: () {
                        themeProvider.toggleTheme();
                      },
                      tooltip: themeProvider.isDarkMode ? 'Chế độ sáng' : 'Chế độ tối',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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