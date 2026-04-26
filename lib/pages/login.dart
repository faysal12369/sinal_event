// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sinal_events/components/api/api.dart';
import 'package:sinal_events/pages/choice.dart';
import 'package:sinal_events/pages/fuser.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Remplir tous les champs"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final data = await ApiService.login(
        emailController.text,
        passwordController.text,
      );

      if (!mounted) return;

      if (data["success"] == false || data["error"] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["error"] ?? "Email ou mot de passe incorrect"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
          ),
        );
        setState(() => loading = false);
        return;
      }

      if (data["id"] != null && data["roles"] != null) {
        if (data["roles"] == "user") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ChoicePage0()),
          );
        } else if (data["roles"] == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ChoicePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Rôle utilisateur non reconnu"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email ou mot de passe incorrect"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur de connexion: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
        ),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20 : 40,
              vertical: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(isSmallScreen),
                const SizedBox(height: 50),
                _buildLoginCard(isSmallScreen),
                const SizedBox(height: 30),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    final logoSize = isSmallScreen ? 100.0 : 120.0;
    final titleSize = isSmallScreen ? 28.0 : 36.0;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 20 : 25),
          decoration: BoxDecoration(
            color: Colors.white, // White background for the container
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            "images/sinal.png",
            height: logoSize,
            width: logoSize,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.event_available,
                size: 60,
                color: Color(0xFF1565C0),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "SINAL EVENT",
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "ACCÈS",
          style: TextStyle(
            fontSize: titleSize * 0.6,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF90CAF9),
            letterSpacing: 5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            "Page de connexion",
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? double.infinity : 450,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bienvenue",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Connectez-vous à votre compte",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: emailController,
            hint: "Nom d'utilisateur",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: passwordController,
            hint: "Mot de passe",
            icon: Icons.lock_outline,
            obscure: obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade400,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: 32),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hint,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF1565C0), size: 20),
            suffixIcon: suffixIcon,
            hintText: "Entrez votre $hint",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF1565C0),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: loading ? null : login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "Se connecter",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 1,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.fingerprint,
              size: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 12),
            Container(
              width: 50,
              height: 1,
              color: Colors.white.withOpacity(0.3),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 12,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              "Connexion sécurisée",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "SINAL EVENT ACCESS",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
