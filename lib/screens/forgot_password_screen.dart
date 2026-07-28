import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;
  int _resendCountdown = 0;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final result = await _authService.forgotPassword(_emailController.text);

      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        setState(() {
          _emailSent = true;
          _resendCountdown = 60;
        });
        _startResendCountdown();
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

  void _startResendCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        return true;
      }
      return false;
    });
  }

  Future<void> _resendEmail() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _authService.forgotPassword(_emailController.text);

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      setState(() {
        _resendCountdown = 60;
      });
      _startResendCountdown();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.emailResentSnack(context)),
            backgroundColor: const Color(0xFF90EE90),
          ),
        );
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF87CEEB).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 60,
              color: Color(0xFF87CEEB),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          AppStrings.forgotPasswordTitle(context),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.forgotPasswordDescription(context),
          style: TextStyle(
            fontSize: 14,
            color: ThemeColors.subtle(context),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Form(
          key: _formKey,
          child: Column(
            children: [
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          AppStrings.sendResetLink(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_forward),
          label: Text(AppStrings.backToLogin(context)),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF90EE90).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read,
              size: 80,
              color: Color(0xFF90EE90),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          AppStrings.emailSentTitle(context),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.emailSentSubtitle(context),
          style: TextStyle(
            fontSize: 14,
            color: ThemeColors.subtle(context),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF87CEEB),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInstructionItem(
                  '1',
                  AppStrings.forgotStepCheckInbox(context),
                  Icons.inbox,
                ),
                const SizedBox(height: 16),
                _buildInstructionItem(
                  '2',
                  AppStrings.forgotStepClickLink(context),
                  Icons.link,
                ),
                const SizedBox(height: 16),
                _buildInstructionItem(
                  '3',
                  AppStrings.forgotStepNewPassword(context),
                  Icons.lock_open,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB74D).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFFB74D).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFFFB74D)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.forgotSpamHint(context),
                  style: TextStyle(
                    fontSize: 13,
                    color: ThemeColors.subtle(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.emailNotReceived(context),
              style: TextStyle(color: ThemeColors.subtle(context)),
            ),
            TextButton(
              onPressed:
                  _resendCountdown > 0 || _isLoading ? null : _resendEmail,
              child: Text(
                _resendCountdown > 0
                    ? AppStrings.resendWithSeconds(context, _resendCountdown)
                    : AppStrings.resend(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
          icon: const Icon(Icons.arrow_forward),
          label: Text(AppStrings.backToLogin(context)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF87CEEB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.subtle(context),
            ),
          ),
        ),
      ],
    );
  }
}
