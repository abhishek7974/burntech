import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controller/auth_controller.dart';
import '../../view/auth/signup.dart';
import '../../widget/custom_elevated_button.dart';
import '../../widget/custom_text_form_field.dart';
import '../../widget/custom_image.dart';

class LoginPage extends ConsumerWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginController = ref.watch(loginProvider);
    final isLoading = loginController.isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Form(
              key: _formKey, // Assign the GlobalKey to the Form
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomImageView(
                    radius: BorderRadius.circular(24),
                    height: 200,
                    imagePath: "assets/images/burning_man_icon.jpg",
                  ),
                  const SizedBox(height: 20),
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildTextField(
                    context: context,
                    controller: emailController,
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Email cannot be empty";
                      } else if (!loginController.emailValidator(val)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    context: context,
                    controller: passwordController,
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    obscureText: true,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Password cannot be empty";
                      } else if (val.length < 6) {
                        return "Password must be at least 6 characters long";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildForgotPasswordLink(context),
                  const SizedBox(height: 30),
                  _buildLoginButton(context, ref, isLoading),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome Back!",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "No account?",
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
              child: Text(
                "Create account",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    required Icon prefixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 50,
      child: CustomTextFormField(
        controller: controller,
        obscureText: obscureText,
        hintText: labelText,
        prefix: prefixIcon,
        fillColor: Colors.grey.shade200,
        validator: validator,
      ),
    );
  }

  Widget _buildForgotPasswordLink(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: () {
          // Navigate to forgot password page or handle reset logic
        },
        child: Text(
          "Forgot password?",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
      BuildContext context, WidgetRef ref, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: isLoading
          ? Center(child: const CircularProgressIndicator())
          : CustomElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // If all fields are valid, perform login
            await ref.read(loginProvider).validateAndLogin(
              context,
              emailController.text,
              passwordController.text,
            );
          }
        },
        text: "Log In",
      ),
    );
  }
}
