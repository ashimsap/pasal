import 'dart:ui';
import 'package:flutter/material.dart';

class GlassTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;

  const GlassTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  State<GlassTextFormField> createState() => _GlassTextFormFieldState();
}

class _GlassTextFormFieldState extends State<GlassTextFormField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _isFocused ? 5 : 0, sigmaY: _isFocused ? 5 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _isFocused ? Colors.white.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: _isFocused ? Colors.white.withOpacity(0.2) : Colors.transparent,
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              validator: widget.validator,
              onChanged: widget.onChanged,
              obscureText: widget.isPassword && _isObscured,
              keyboardType: widget.keyboardType,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: widget.labelText,
                labelStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none, // Remove all borders by default
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent, width: 2),
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
