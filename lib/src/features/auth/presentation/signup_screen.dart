import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/features/auth/application/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasal/src/features/auth/presentation/widgets/blur_button.dart';
import 'package:pasal/src/features/auth/presentation/widgets/glass_text_form_field.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
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

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).createUserWithEmailAndPassword(
            _emailController.text,
            _passwordController.text,
          );
      if(mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        default:
          errorMessage = 'An unexpected error occurred. Please try again.';
          break;
      }
      setState(() {
        _errorMessage = errorMessage;
      });
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
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if(mounted) Navigator.of(context).pop();
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
      backgroundColor: Colors.transparent,
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
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s get you started',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 48),
                  GlassTextFormField(
                    controller: _nameController,
                    labelText: 'Name',
                    onChanged: (_) => _clearError(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
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
                  const SizedBox(height: 32),
                   BlurButton(
                    onPressed: _isLoading ? null : _signUp,
                    isLoading: _isLoading,
                    child: Text(
                      'SIGN UP',
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
                          'Sign up with Google',
                          style: GoogleFonts.robotoMono(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?", style: TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Sign In'),
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
