import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.agreeTermsRequiredSnack(context)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final result = await _authService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      );

      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF90EE90).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: Color(0xFF90EE90),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.registerSuccessTitle(dialogContext),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.registerWelcomeBody(
                  dialogContext, _nameController.text),
              textAlign: TextAlign.center,
              style: TextStyle(color: ThemeColors.subtle(context)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text(AppStrings.getStarted(dialogContext)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.registerAppBarTitle(context),
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressIndicator(),
                const SizedBox(height: 32),
                _buildStepContent(),
                const SizedBox(height: 32),
                _buildNavigationButtons(),
                const SizedBox(height: 24),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        final isCompleted = index < _currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : ThemeColors.border(context),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive ? Colors.white : ThemeColors.subtle(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      index == 0
                          ? AppStrings.regStepData(context)
                          : index == 1
                              ? AppStrings.regStepSecurity(context)
                              : AppStrings.regStepConfirm(context),
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : ThemeColors.faint(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < _currentStep
                        ? Theme.of(context).colorScheme.primary
                        : ThemeColors.border(context),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildSecurityStep();
      case 2:
        return _buildConfirmationStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.regPersonalTitle(context),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.regPersonalSubtitle(context),
          style: TextStyle(color: ThemeColors.subtle(context)),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: AppStrings.fullNameLabel(context),
            hintText: AppStrings.fullNameHint(context),
            prefixIcon: const Icon(Icons.person_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.validationNameRequired(context);
            }
            if (value.length < 3) {
              return AppStrings.validationNameMinLength(context);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: AppStrings.emailLabel(context),
            hintText: AppStrings.emailHintSample(context),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.validationEmailRequired(context);
            }
            if (!value.contains('@') || !value.contains('.')) {
              return AppStrings.validationEmailInvalid(context);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: AppStrings.phoneOptionalLabel(context),
            hintText: AppStrings.phoneHint(context),
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.regSecurityTitle(context),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.regSecuritySubtitle(context),
          style: TextStyle(color: ThemeColors.subtle(context)),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: AppStrings.passwordLabel(context),
            hintText: AppStrings.passwordHintDots(context),
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.validationPasswordRequired(context);
            }
            if (value.length < 6) {
              return AppStrings.validationPasswordMinLength(context);
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildPasswordStrengthIndicator(context),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: AppStrings.confirmPasswordLabel(context),
            hintText: AppStrings.passwordHintDots(context),
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.validationConfirmPasswordRequired(context);
            }
            if (value != _passwordController.text) {
              return AppStrings.validationPasswordMismatch(context);
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator(BuildContext context) {
    String password = _passwordController.text;
    double strength = 0;
    String strengthText = AppStrings.passwordWeak(context);
    Color strengthColor = Colors.red;

    if (password.length >= 6) strength += 0.25;
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;

    if (strength <= 0.25) {
      strengthText = AppStrings.passwordWeak(context);
      strengthColor = Colors.red;
    } else if (strength <= 0.5) {
      strengthText = AppStrings.passwordMedium(context);
      strengthColor = Colors.orange;
    } else if (strength <= 0.75) {
      strengthText = AppStrings.passwordGood(context);
      strengthColor = Colors.lightGreen;
    } else {
      strengthText = AppStrings.passwordStrong(context);
      strengthColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.passwordStrengthLabel(context),
              style: TextStyle(fontSize: 12, color: ThemeColors.subtle(context)),
            ),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 12,
                color: strengthColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strength,
            backgroundColor: ThemeColors.fill(context),
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildPasswordHint(
                context, AppStrings.pwdHint6Chars(context), password.length >= 6),
            _buildPasswordHint(
                context,
                AppStrings.pwdHintUpper(context),
                password.contains(RegExp(r'[A-Z]'))),
            _buildPasswordHint(
                context,
                AppStrings.pwdHintDigit(context),
                password.contains(RegExp(r'[0-9]'))),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordHint(BuildContext context, String text, bool isValid) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          size: 14,
          color: isValid ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: isValid ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.regConfirmTitle(context),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.regConfirmSubtitle(context),
          style: TextStyle(color: ThemeColors.subtle(context)),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryItem(
                    context, AppStrings.summaryName(context), _nameController.text, Icons.person),
                const Divider(),
                _buildSummaryItem(
                    context, AppStrings.summaryEmail(context), _emailController.text, Icons.email),
                if (_phoneController.text.isNotEmpty) ...[
                  const Divider(),
                  _buildSummaryItem(context, AppStrings.summaryPhone(context),
                      _phoneController.text, Icons.phone),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value!;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                children: [
                  Text(AppStrings.iAgreePrefix(context)),
                  GestureDetector(
                    onTap: () => _showTermsDialog(),
                    child: Text(
                      AppStrings.termsLink(context),
                      style: const TextStyle(
                        color: Color(0xFF87CEEB),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(AppStrings.andWord(context)),
                  GestureDetector(
                    onTap: () => _showPrivacyDialog(),
                    child: Text(
                      AppStrings.privacyLink(context),
                      style: const TextStyle(
                        color: Color(0xFF87CEEB),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: ThemeColors.subtle(context))),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(AppStrings.previous(context)),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (_currentStep < 2) {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _currentStep++;
                        });
                      }
                    } else {
                      _register();
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(_currentStep < 2
                    ? AppStrings.next(context)
                    : AppStrings.createAccountButton(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.haveAccountPrompt(context),
          style: TextStyle(color: ThemeColors.subtle(context)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppStrings.loginButton(context),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.termsDialogTitle(dialogContext)),
        content: SingleChildScrollView(
          child: Text(AppStrings.termsDialogBody(dialogContext)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.close(dialogContext)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.privacyDialogTitleReg(dialogContext)),
        content: SingleChildScrollView(
          child: Text(AppStrings.privacyDialogBodyReg(dialogContext)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.close(dialogContext)),
          ),
        ],
      ),
    );
  }
}
