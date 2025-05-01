import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';

// Màn hình đăng ký tài khoản với thiết kế rực rỡ và sang trọng
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'user'; // Vai trò mặc định là người dùng
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late AnimationController _titleAnimationController;
  late Animation<Color?> _titleColorAnimation;

  @override
  void initState() {
    super.initState();
    // Hiệu ứng scale cho nút đăng ký
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _buttonAnimationController.dispose();
    _titleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        // Nền gradient rực rỡ, đa sắc màu
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeProvider.isDarkMode
                ? [
              Colors.purple[900]!,
              Colors.blue[900]!,
              Colors.teal[900]!,
              Colors.pink[900]!,
            ]
                : [
              Colors.pink[300]!,
              Colors.cyan[300]!,
              Colors.purple[300]!,
              Colors.amber[300]!,
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
                      // Tiêu đề với gradient động và hiệu ứng sáng
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
                            child: Text(
                              'Tạo tài khoản mới',
                              style: TextStyle(
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
                            color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
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
                                // Ô nhập tên người dùng
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    labelText: 'Tên người dùng',
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
                                      Icons.person,
                                      color: Colors.pinkAccent,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập tên người dùng';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
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
                                const SizedBox(height: 16),
                                // Chọn vai trò
                                DropdownButtonFormField<String>(
                                  value: _role,
                                  decoration: InputDecoration(
                                    labelText: 'Vai trò',
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
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _role = value!;
                                    });
                                  },
                                  items: [
                                    DropdownMenuItem(
                                      value: 'user',
                                      child: Text(
                                        'Người dùng',
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'admin',
                                      child: Text(
                                        'Quản trị viên',
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Nút đăng ký với hiệu ứng gradient và scale
                                ScaleTransition(
                                  scale: _buttonScaleAnimation,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      splashColor: Colors.amberAccent.withOpacity(0.6),
                                      highlightColor: Colors.cyanAccent.withOpacity(0.4),
                                      onTap: () async {
                                        _buttonAnimationController
                                            .forward()
                                            .then((value) => _buttonAnimationController.reverse());
                                        if (_formKey.currentState!.validate()) {
                                          try {
                                            await authProvider.register(
                                              _usernameController.text,
                                              _emailController.text,
                                              _passwordController.text,
                                              _role,
                                            );
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => const LoginScreen(),
                                              ),
                                            );
                                          } catch (error) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Đăng ký thất bại: $error',
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
                                            'Tạo tài khoản',
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
                                const SizedBox(height: 16),
                                // Liên kết quay lại đăng nhập
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Đã có tài khoản? Đăng nhập ngay',
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
            // Nút chuyển đổi theme với gradient rực rỡ
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
    );
  }
}