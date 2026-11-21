import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/snack.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_controller.dart';
import 'auth_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _passwordFocus.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).login(email: _email.text, password: _password.text);
      if (mounted) context.go('/home');
    } on AuthException {
      if (mounted) showCovaSnack(context, context.l10n.errInvalidCredentials);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            AuthHeader(title: l10n.loginTitle, subtitle: l10n.loginSubtitle),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _email,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      label: l10n.email,
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      autofillHints: const [AutofillHints.email],
                      validator: (v) => Validators.email(v ?? '') ? null : l10n.errEmail,
                    ).entrance(index: 3),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _password,
                      focusNode: _passwordFocus,
                      label: l10n.password,
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscure,
                      textDirection: TextDirection.ltr,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      validator: (v) => (v ?? '').isEmpty ? l10n.errRequired : null,
                      suffix: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: c.muted),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ).entrance(index: 4),
                    const SizedBox(height: 28),
                    AppButton(label: l10n.loginButton, loading: _loading, onPressed: _submit).entrance(index: 5),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.noAccount, style: TextStyle(color: c.muted)),
                        TextButton(
                          onPressed: () => context.push('/signup'),
                          child: Text(l10n.signUp, style: const TextStyle(decoration: TextDecoration.underline, decorationColor: AppColors.cyan, decorationThickness: 2)),
                        ),
                      ],
                    ).entrance(index: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
