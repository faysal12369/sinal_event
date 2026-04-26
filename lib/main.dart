// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sinal_events/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sinal Events',
      home: const SplashScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
      locale: const Locale('fr', 'FR'),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
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
                _buildLoadingCard(isSmallScreen),
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
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: Container(
              height: logoSize,
              width: logoSize,
              color: Colors.white,
              child: Image.asset(
                "images/sinal.png",
                height: logoSize,
                width: logoSize,
                fit: BoxFit.contain, // Changed from cover to contain
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: logoSize,
                    width: logoSize,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.event_available,
                      size: 60,
                      color: Color(0xFF1565C0),
                    ),
                  );
                },
              ),
            ),
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
            "Bienvenue",
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

  Widget _buildLoadingCard(bool isSmallScreen) {
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
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Préparation de votre espace",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Veuillez patienter...",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
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
