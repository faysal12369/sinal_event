// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sinal_events/components/Main/MScan.dart';
import 'package:sinal_events/pages/main_page.dart';
import 'package:sinal_events/pages/user.dart';

class ChoicePage extends StatelessWidget {
  const ChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(context),
                const SizedBox(height: 40),
                _buildButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final logoSize = isSmallScreen ? 120.0 : 200.0;
    final titleSize = isSmallScreen ? 28.0 : 42.0;
    final subtitleSize = isSmallScreen ? 12.0 : 16.0;

    return Column(
      children: [
        Image.asset(
          'images/sinal.png',
          height: logoSize,
          width: logoSize,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: logoSize,
              width: logoSize,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available,
                size: 80,
                color: Color(0xFF4A90E2),
              ),
            );
          },
        ),
        const SizedBox(height: 30),
        Text(
          'Sinal Acces Event',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Bienvenue',
          style: TextStyle(
            fontSize: subtitleSize,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final buttonWidth = isSmallScreen ? 280.0 : 320.0;
    final buttonHeight = isSmallScreen ? 50.0 : 60.0;
    final fontSize = isSmallScreen ? 16.0 : 18.0;

    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _showModernDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(208, 3, 104, 204),
            foregroundColor: Colors.white,
            minimumSize: Size(buttonWidth, buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow, size: 28),
              const SizedBox(width: 10),
              Text(
                'Lancer Application',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GestionUtilisateursPage(),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4A90E2),
            minimumSize: Size(buttonWidth, buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            side: const BorderSide(color: Color(0xFF4A90E2), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people, size: 28),
              const SizedBox(width: 10),
              Text(
                'Gestion des Utilisateurs',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showModernDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 600;
        final dialogWidth = isSmallScreen ? screenWidth - 40 : 400.0;

        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: dialogWidth,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4A90E2).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.login_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Comment souhaitez-vous procéder ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ajoutez un nouveau client ou scannez un code existant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Material(
                  elevation: 0,
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF4A90E2),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClientsPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add_alt_1,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Nouveau Client',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  elevation: 0,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade50,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF4A90E2).withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            color: Color(0xFF4A90E2),
                            size: 22,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Scanner Client',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A90E2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
