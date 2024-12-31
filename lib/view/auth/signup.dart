import 'package:burntech/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widget/custom_image.dart';
import '../../widget/custom_text_form_field.dart';
import '../auth/login.dart';
import '../user_view/bottom_nav_bar/bottom_nav_bar.dart';

class SignupPage extends ConsumerStatefulWidget {
  SignupPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController interestController = TextEditingController();

  final TextEditingController religionController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    interestController.dispose();
    religionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signupController = ref.watch(loginProvider);
    final isLoading = signupController.isLoading;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
        child: Center(
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomImageView(
                    radius: BorderRadius.circular(24),
                    height: 200,
                    imagePath: "assets/images/burning_man_icon.jpg",
                  ),
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: nameController,
                    labelText: "Name",
                    prefixIcon: const Icon(Icons.person),
                  ),
                  _buildTextField(
                    controller: emailController,
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                  ),
                  _buildTextField(
                    controller: passwordController,
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  _buildSignUpButton(context, ref, isLoading),
                  const SizedBox(height: 20),
                  _buildForgotPasswordLink(context),
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
          "Welcome!",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Already have an account?",
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text(
                "Login",
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
    required TextEditingController controller,
    required String labelText,
    required Icon prefixIcon,
    bool obscureText = false,
  }) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: CustomTextFormField(
        controller: controller,
        obscureText: obscureText,
        hintText: labelText,
        prefix: prefixIcon,
        fillColor: Colors.grey.shade200,
      ),
    );
  }

  Widget _buildSignUpButton(
      BuildContext context, WidgetRef ref, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                    await ref.read(loginProvider).signupUser(
                      context,
                      emailController.text,
                      nameController.text,
                      passwordController.text,
                    );
              },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Sign Up",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildForgotPasswordLink(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => LoginPage()));
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
}
