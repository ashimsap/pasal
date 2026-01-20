import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/features/auth/presentation/signup_screen.dart';
import 'package:pasal/src/features/auth/application/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pasal/src/features/auth/presentation/forgot_password_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasal/src/features/auth/presentation/widgets/blur_button.dart';
import 'package:pasal/src/features/auth/presentation/widgets/glass_text_form_field.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearError() {
     if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _clearError();
    });

    try {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
            _emailController.text,
            _passwordController.text,
          );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = 'Invalid email or password.';
      } else {
        errorMessage = 'An unexpected error occurred.';
      }
      setState(() => _errorMessage = errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _isLoading = true;
       _clearError();
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 48),
                  GlassTextFormField(
                    controller: _emailController,
                    labelText: 'Email',
                    onChanged: (_) => _clearError(),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                       if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  GlassTextFormField(
                    controller: _passwordController,
                    labelText: 'Password',
                     onChanged: (_) => _clearError(),
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                   if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                         Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: const Text('Forgot Password?', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlurButton(
                    onPressed: _isLoading ? null : _login,
                    isLoading: _isLoading,
                    child: Text(
                      'LOGIN',
                      style: GoogleFonts.robotoMono(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                   const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider(thickness: 0.5, color: Colors.white70)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('OR', style: textTheme.bodySmall?.copyWith(color: Colors.white70)),
                      ),
                      const Expanded(child: Divider(thickness: 0.5, color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BlurButton(
                    onPressed: _isLoading ? null : _googleSignIn,
                    isLoading: _isLoading,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FaIcon(FontAwesomeIcons.google, size: 18, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          'Sign in with Google',
                          style: GoogleFonts.robotoMono(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                   const SizedBox(height: 24),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?", style: TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
