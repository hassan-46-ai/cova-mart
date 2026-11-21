import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/snack.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_controller.dart';
import 'auth_header.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    for (final f in [_nameFocus, _emailFocus, _phoneFocus, _passwordFocus, _confirmFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).signUp(
            name: _name.text,
            email: _email.text,
            phone: _phone.text,
            password: _password.text,
          );
      if (mounted) context.go('/home');
    } on AuthException {
      if (mounted) showCovaSnack(context, context.l10n.errEmailInUse);
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
            AuthHeader(title: l10n.signupTitle, subtitle: l10n.signupSubtitle, showBack: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _name,
                      focusNode: _nameFocus,
                      onSubmitted: (_) => _emailFocus.requestFocus(),
                      label: l10n.fullName,
                      icon: Icons.person_outline_rounded,
                      autofillHints: const [AutofillHints.name],
                      validator: (v) => (v ?? '').trim().length < 2 ? l10n.errRequired : null,
                    ).entrance(index: 3),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _email,
                      focusNode: _emailFocus,
                      onSubmitted: (_) => _phoneFocus.requestFocus(),
                      label: l10n.email,
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      autofillHints: const [AutofillHints.email],
                      validator: (v) => Validators.email(v ?? '') ? null : l10n.errEmail,
                    ).entrance(index: 4),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _phone,
                      focusNode: _phoneFocus,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      label: l10n.phone,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      validator: (v) => Validators.egyptPhone(v ?? '') ? null : l10n.errPhone,
                    ).entrance(index: 5),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _password,
                      focusNode: _passwordFocus,
                      onSubmitted: (_) => _confirmFocus.requestFocus(),
                      label: l10n.password,
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscure,
                      textDirection: TextDirection.ltr,
                      validator: (v) => Validators.minLength(v ?? '', 6) ? null : l10n.errPasswordShort,
                      suffix: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: c.muted),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ).entrance(index: 6),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _confirm,
                      focusNode: _confirmFocus,
                      label: l10n.confirmPassword,
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscure,
                      textDirection: TextDirection.ltr,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      validator: (v) => v == _password.text ? null : l10n.errPasswordMatch,
                    ).entrance(index: 7),
                    const SizedBox(height: 28),
                    AppButton(label: l10n.createAccount, loading: _loading, onPressed: _submit).entrance(index: 8),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.haveAccount, style: TextStyle(color: c.muted)),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(l10n.loginButton, style: const TextStyle(decoration: TextDecoration.underline, decorationColor: AppColors.cyan, decorationThickness: 2)),
                        ),
                      ],
                    ),
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
