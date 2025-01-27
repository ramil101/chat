import 'package:chat/services/auth/auth_service.dart';
import 'package:chat/components/button.dart';
import 'package:flutter/material.dart';
import '../components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

//register
  Future<void> register(BuildContext context) async {
    final auth = AuthService();

    // Check if name is empty
    if (_nameController.text.trim().isEmpty) {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("Error"),
                content: Text("Please enter your name"),
              ));
      return;
    }

    if (_pwController.text == _confirmPwController.text) {
      try {
        await auth.signUpWithEmailPassword(
          _emailController.text,
          _pwController.text,
          _nameController.text.trim(),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Error"),
                  content: Text(e.toString()),
                ));
      }
    } else {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("Error"),
                content: Text("Passwords do not match"),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.message,
                size: 60,
                color: Colors.black,
              ),
              const SizedBox(height: 50),
              Text(
                "Let's create an account for you",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 16),
              ),
              const SizedBox(height: 25),
              MyTextfield(
                hintText: "Name",
                obscureText: false,
                controller: _nameController,
              ),
              const SizedBox(height: 10),
              MyTextfield(
                hintText: "Email",
                obscureText: false,
                controller: _emailController,
              ),
              const SizedBox(height: 10),
              MyTextfield(
                hintText: "Password",
                obscureText: true,
                controller: _pwController,
              ),
              const SizedBox(height: 10),
              MyTextfield(
                hintText: "Confirm Password",
                obscureText: true,
                controller: _confirmPwController,
              ),
              const SizedBox(height: 25),
              MyButton(
                text: "Register",
                onTap: () => register(context),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: const Text(
                      "Login here",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
