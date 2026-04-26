// ignore_for_file: file_names, empty_catches, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sinal_events/components/api/api.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  MobileScannerController? scannerController;
  bool isScanning = true;
  bool isProcessing = false;
  bool hasPermission = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInitialize();
  }

  Future<void> _checkPermissionsAndInitialize() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      setState(() {
        hasPermission = true;
      });
      _initializeScanner();
    } else if (status.isDenied) {
      setState(() {
        errorMessage =
            'La permission caméra est nécessaire pour scanner les QR codes';
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        errorMessage =
            'La permission caméra a été refusée définitivement. Veuillez l\'activer dans les paramètres.';
      });
    }
  }

  void _initializeScanner() {
    try {
      scannerController = MobileScannerController(
        facing: CameraFacing.back,
        torchEnabled: false,
        autoStart: true,
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors de l\'initialisation de la caméra: $e';
      });
    }
  }

  @override
  void dispose() {
    _disposeScanner();
    super.dispose();
  }

  Future<void> _disposeScanner() async {
    if (scannerController != null) {
      try {
        await scannerController?.dispose();
      } catch (e) {}
      scannerController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scanner QR Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (hasPermission && scannerController != null) ...[
            IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white),
              onPressed: () => scannerController?.toggleTorch(),
            ),
            IconButton(
              icon: const Icon(Icons.switch_camera, color: Colors.white),
              onPressed: () => scannerController?.switchCamera(),
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  errorMessage = null;
                });
                _checkPermissionsAndInitialize();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (!hasPermission) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Demande de permission caméra...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (scannerController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initialisation du scanner...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: scannerController!,
          onDetect: (capture) {
            if (!isScanning || isProcessing) return;

            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                _processQRCode(barcode.rawValue!);
                break;
              }
            }
          },
        ),
        Container(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
          child: Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.blue.shade300,
                            width: 4,
                          ),
                          left: BorderSide(
                            color: Colors.blue.shade300,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.blue.shade300,
                            width: 4,
                          ),
                          right: BorderSide(
                            color: Colors.blue.shade300,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.blue.shade300,
                            width: 4,
                          ),
                          left: BorderSide(
                            color: Colors.blue.shade300,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.blue.shade300,
                            width: 4,
                          ),
                          right: BorderSide(
                            color: Colors.blue.shade300,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const Text(
                'Scannez le QR code du client',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Placez le code dans le cadre',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () => _showManualEntryDialog(),
                icon: const Icon(Icons.keyboard, color: Colors.white),
                label: const Text(
                  'Entrer le code manuellement',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        if (isProcessing)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Vérification en cours...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _processQRCode(String qrData) async {
    if (isProcessing) return;

    setState(() {
      isScanning = false;
      isProcessing = true;
    });

    try {
      String token = qrData;

      if (qrData.contains('token=')) {
        token = qrData.split('token=')[1].split('&')[0];
      }

      if (qrData.contains('id=')) {
        token = qrData.split('id=')[1].split('&')[0];
      }

      final response = await ApiService.verifyQR(token);

      if (!mounted) return;

      if (response['id'] != null) {
        await _showUserCheckinDialog(response);
      } else if (response.containsKey('data') && response['data'] != null) {
        await _showUserCheckinDialog(response['data']);
      } else if (response['success'] == true && response['user'] != null) {
        await _showUserCheckinDialog(response['user']);
      } else {
        await _showErrorDialog(
          'QR code invalide',
          response['message'] ?? 'Code QR non reconnu par le système',
        );
      }
    } catch (e) {
      await _showErrorDialog('Erreur', 'Une erreur est survenue: $e');
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Future<void> _showUserCheckinDialog(Map<String, dynamic> user) async {
    final isChecked = user['checked'] == 1 || user['checked'] == true;
    final nom = user['nom'] ?? 'N/A';
    final rs = user['rs'] ?? 'N/A';
    final tel = user['tel'] ?? 'N/A';
    final wilaya = user['wilaya'] ?? 'N/A';
    final adresse = user['adresse'] ?? 'Pas Saisie';
    final time = user['time'];

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isChecked ? Icons.check_circle : Icons.person,
                color: isChecked ? Colors.green : Colors.blue,
              ),
              const SizedBox(width: 10),
              Text(isChecked ? 'Déjà Check-in' : 'Nouveau Check-in'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Nom', nom),
              const Divider(),
              _buildInfoRow('Raison Sociale', rs),
              const Divider(),
              _buildInfoRow('Téléphone', tel),
              const Divider(),
              _buildInfoRow('Wilaya', wilaya),
              const Divider(),
              _buildInfoRow('Adresse', adresse),
              const Divider(),
              _buildInfoRow(
                'Statut',
                isChecked ? '✅ Déjà check-in' : '⏳ En attente',
              ),
              if (time != null && time != '0000-00-00 00:00:00') ...[
                const Divider(),
                _buildInfoRow('Heure de check-in', time.toString()),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (!isChecked) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Fermer'),
            ),
            if (!isChecked)
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _confirmCheckin(user);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Valider Check-in'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmCheckin(Map<String, dynamic> user) async {
    setState(() {
      isProcessing = true;
    });

    try {
      final token =
          user['qr_token']?.toString() ??
          user['token']?.toString() ??
          user['id']?.toString() ??
          '';

      if (token.isEmpty) {
        await _showErrorDialog('Erreur', 'Token invalide');
        setState(() {
          isProcessing = false;
          isScanning = true;
        });
        return;
      }

      final loggedInUserId = UserSession.userId;
      final result = await ApiService.checkinUserWithId(token, loggedInUserId);

      if (!mounted) return;

      if (result['message'] != null && result['error'] != true) {
        await _showSuccessDialog(
          'Check-in validé',
          'Le client a été marqué comme présent',
        );
        setState(() {
          isScanning = true;
        });
      } else {
        await _showErrorDialog(
          'Erreur',
          result['message'] ?? 'Erreur lors du check-in',
        );
        setState(() {
          isScanning = true;
        });
      }
    } catch (e) {
      await _showErrorDialog('Erreur', 'Une erreur est survenue: $e');
      setState(() {
        isScanning = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Future<void> _showManualEntryDialog() async {
    final TextEditingController tokenController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Entrer le code manuellement'),
          content: TextField(
            controller: tokenController,
            decoration: const InputDecoration(
              hintText: 'Entrez le token ou l\'URL du QR code',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                if (tokenController.text.isNotEmpty) {
                  await _processQRCode(tokenController.text);
                }
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(String title, String message) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String title, String message) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isScanning = true;
                });
              },
              child: const Text('Réessayer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
