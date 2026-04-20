import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (value.trim().length < 3) return 'Username must be at least 3 characters';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    if (value.length < 4) return 'Password must be at least 4 characters';
    return null;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await ApiService.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      _showSuccessSnackBar('Welcome back! Login successful.');
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showErrorSnackBar(result['message'] ?? 'Login failed. Try again.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: Colors.red.shade600,
      duration: const Duration(seconds: 3),
    ));
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: Colors.green.shade600,
      duration: const Duration(seconds: 2),
    ));
  }

  void _fillDemoCredentials() {
    _usernameController.text = 'emilys';
    _passwordController.text = 'emilyspass';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height - MediaQuery.of(context).padding.top,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      _buildLogo(),
                      const SizedBox(height: 32),
                      _buildHeaderText(),
                      const SizedBox(height: 40),
                      _buildLoginForm(),
                      const SizedBox(height: 24),
                      _buildLoginButton(),
                      const SizedBox(height: 16),
                      const Spacer(flex: 3),
                      _buildFooter(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF4A90D9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90D9).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 52),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          'Student Task Manager',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to manage your tasks',
          style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: _validateUsername,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'Enter your username',
              prefixIcon:
              Icon(Icons.person_outline_rounded, color: Color(0xFF4A90D9)),
            ),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            validator: _validatePassword,
            enabled: !_isLoading,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  color: Color(0xFF4A90D9)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A90D9),
          disabledBackgroundColor: const Color(0xFF4A90D9).withOpacity(0.6),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text('Login',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(color: Theme.of(context).dividerColor),
        const SizedBox(height: 10),
        const Text(
          'Created by Muneeb Mustafa',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF4A90D9),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
