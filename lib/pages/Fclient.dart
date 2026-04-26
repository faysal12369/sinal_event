// ignore_for_file: file_names, deprecated_member_use, use_build_context_synchronously
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:signature/signature.dart';
import 'package:sinal_events/components/api/api.dart';
import 'package:flutter/services.dart';
import 'package:sinal_events/pages/main_page.dart';

class ClientForm extends StatefulWidget {
  final User? user;
  const ClientForm({super.key, this.user});

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _isSubmitting = false;
  DateTime _selectedDateTime = DateTime.now();
  bool _isEditing = false;
  bool _hasExistingSignature = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _isEditing = widget.user != null;

    if (_isEditing) {
      _populateFormWithUserData();
      _checkExistingSignature();
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingSignature() async {
    if (widget.user != null) {
      final directory = await getApplicationDocumentsDirectory();
      final signaturePath =
          '${directory.path}/signature_${widget.user!.id}.png';
      final signatureFile = File(signaturePath);
      setState(() async {
        _hasExistingSignature = await signatureFile.exists();
      });
    }
  }

  void _populateFormWithUserData() {
    final user = widget.user!;

    final nameParts = user.nom.split(' ');
    final prenom = nameParts.length > 1 ? nameParts[0] : '';
    final nom = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : user.nom;

    if (user.time != null) {
      _selectedDateTime = user.time!;
    } else {
      try {
        _selectedDateTime = DateTime.parse(user.eventDate);
      } catch (e) {
        _selectedDateTime = DateTime.now();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.patchValue({
        'nom': nom,
        'prenom': prenom,
        'magasin': user.rs,
        'telephone': user.tel,
        'email': user.email ?? '',
        'adresse': user.adresse,
        'wilaya': _getWilayaString(user.wilaya),
        'accompagnateur': user.acc.toString(),
        'civilite': user.civilite ?? 'Mme',
        'activite': user.activite ?? '01 Opticien',
        'clientProspect': user.clientProspect ?? 'Client',
        'statut': user.statut ?? 'Présent',
      });
    });
  }

  String _getWilayaString(String code) {
    final wilayas = {
      '1': '01 Adrar',
      '2': '02 Chlef',
      '3': '03 Laghouat',
      '4': '04 Oum El Bouaghi',
      '5': '05 Batna',
      '6': '06 Béjaïa',
      '7': '07 Biskra',
      '8': '08 Béchar',
      '9': '09 Blida',
      '10': '10 Bouira',
      '11': '11 Tamanrasset',
      '12': '12 Tébessa',
      '13': '13 Tlemcen',
      '14': '14 Tiaret',
      '15': '15 Tizi Ouzou',
      '16': '16 Alger',
      '17': '17 Djelfa',
      '18': '18 Jijel',
      '19': '19 Sétif',
      '20': '20 Saïda',
      '21': '21 Skikda',
      '22': '22 Sidi Bel Abbès',
      '23': '23 Annaba',
      '24': '24 Guelma',
      '25': '25 Constantine',
      '26': '26 Médéa',
      '27': '27 Mostaganem',
      '28': "28 M'Sila",
      '29': '29 Mascara',
      '30': '30 Ouargla',
      '31': '31 Oran',
      '32': '32 El Bayadh',
      '33': '33 Illizi',
      '34': '34 Bordj Bou Arreridj',
      '35': '35 Boumerdès',
      '36': '36 El Tarf',
      '37': '37 Tindouf',
      '38': '38 Tissemsilt',
      '39': '39 El Oued',
      '40': '40 Khenchela',
      '41': '41 Souk Ahras',
      '42': '42 Tipaza',
      '43': '43 Mila',
      '44': '44 Aïn Defla',
      '45': '45 Naâma',
      '46': '46 Aïn Témouchent',
      '47': '47 Ghardaïa',
      '48': '48 Relizane',
      '49': '49 Timimoun',
      '50': '50 Bordj Badji Mokhtar',
      '51': '51 Ouled Djellal',
      '52': '52 Béni Abbès',
      '53': '53 In Salah',
      '54': '54 In Guezzam',
      '55': '55 Touggourt',
      '56': '56 Djanet',
      '57': "57 El M'Ghair",
      '58': '58 El Meniaa',
      '59': '59 Aflou',
      '60': '60 El Abiodh Sidi Cheikh',
      '61': '61 El Aricha',
      '62': '62 El Kantara',
      '63': '63 Barika',
      '64': '64 Bou Saâda',
      '65': '65 Bir El Ater',
      '66': '66 Ksar El Boukhari',
      '67': '67 Ksar Chellala',
      '68': '68 Aïn Oussera',
      '69': '69 Messaâd',
    };
    return wilayas[code] ?? '16 Alger';
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    final weekdays = [
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche',
    ];

    final weekday = weekdays[dateTime.weekday - 1];
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$weekday $day $month $year à $hour:$minute';
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              timePickerTheme: const TimePickerThemeData(
                hourMinuteColor: Colors.blue,
                hourMinuteTextColor: Colors.white,
                dialHandColor: Colors.blue,
                dialBackgroundColor: Colors.blue,
                dayPeriodColor: Colors.blue,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      } else {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _selectedDateTime.hour,
            _selectedDateTime.minute,
          );
        });
      }
    }
  }

  Future<void> _showConfirmationDialog() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    final formData = Map<String, dynamic>.from(_formKey.currentState!.value);

    // If editing and user has existing signature, skip signature dialog
    if (_isEditing && _hasExistingSignature) {
      await _submitForm(formData, null);
      return;
    }

    // For new users or users without signature, show signature dialog
    SignatureController dialogSignatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    bool signatureEmpty = true;

    dialogSignatureController.addListener(() {
      signatureEmpty = dialogSignatureController.isEmpty;
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.gavel, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Confirmation légale',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 550),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Notice d\'information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Conformément à la loi 18-07 relative à la Protection des Personnes "
                            "Physiques dans le Traitement de leurs Données à Caractère Personnel, "
                            "et dans le cadre de nos échanges, la SARL SINAL s'engage à protéger "
                            "vos données personnelles qui lui seront confiées.",
                            style: TextStyle(fontSize: 12, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("✓ ", style: TextStyle(color: Colors.green)),
                              Expanded(
                                child: Text(
                                  "En validant ma participation, je reconnais que la SARL SINAL "
                                  "est responsable du traitement de mes données dans le cadre de l'événement.",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("✓ ", style: TextStyle(color: Colors.green)),
                              Expanded(
                                child: Text(
                                  "J'autorise la SARL SINAL à me contacter pour des propositions ou invitations "
                                  "à d'autres événements liés à mon activité.",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("✓ ", style: TextStyle(color: Colors.green)),
                              Expanded(
                                child: Text(
                                  "J'accepte que la SARL SINAL enregistre et diffuse des images et vidéos "
                                  "de l'événement à des fins promotionnelles.",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.blue.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Signature',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  dialogSignatureController.clear();
                                  setDialogState(() {});
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                ),
                                child: const Text(
                                  'Effacer',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Signature(
                                controller: dialogSignatureController,
                                width: double.infinity,
                                height: 220,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                          if (signatureEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Signature requise",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  dialogSignatureController.dispose();
                  Navigator.pop(dialogContext);
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (signatureEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Veuillez signer avant de confirmer"),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);
                  await _submitForm(formData, dialogSignatureController);
                  dialogSignatureController.dispose();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Confirmer'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitForm(
    Map<String, dynamic> data,
    SignatureController? signatureController,
  ) async {
    setState(() {
      _isSubmitting = true;
    });

    final String eventDateTime =
        "${_selectedDateTime.year}-${_selectedDateTime.month.toString().padLeft(2, '0')}-${_selectedDateTime.day.toString().padLeft(2, '0')} ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}:00";

    final Map<String, dynamic> apiData = {
      'nom': data['nom'] ?? '',
      'prenom': data['prenom'] ?? '',
      'rs': data['magasin'] ?? '',
      'tel': data['telephone'] ?? '',
      'email': data['email'] ?? '',
      'adresse': data['adresse'] ?? '',
      'wilaya': _extractWilayaCode(data['wilaya'] ?? ''),
      'acc': int.tryParse(data['accompagnateur']?.toString() ?? '0') ?? 0,
      'civilite': data['civilite'] ?? '',
      'activite': data['activite'] ?? '',
      'client_prospect': data['clientProspect'] ?? '',
      'statut': 'Présent',
      'event_date': eventDateTime,
      'user_id': UserSession.userId != null
          ? int.parse(UserSession.userId!)
          : null,
    };

    try {
      final result = await ApiService.registerUser(
        nom: '${apiData['prenom']} ${apiData['nom']}'.trim(),
        rs: apiData['rs'],
        eventDate: apiData['event_date'],
        adresse: apiData['adresse'],
        wilaya: apiData['wilaya'],
        tel: apiData['tel'],
        acc: apiData['acc'],
        userId: apiData['user_id'],
      );

      if (result.containsKey('id') ||
          (result.containsKey('data') && result['data'] != null)) {
        final userId = result['id'] ?? result['data']['id'];
        final int userIdInt = userId is String
            ? int.parse(userId)
            : userId as int;

        // Only save signature if it's a new user or signature controller is provided
        if (signatureController != null) {
          final signatureBytes = await signatureController.toPngBytes();
          if (signatureBytes != null) {
            final directory = await getApplicationDocumentsDirectory();
            final signaturePath = '${directory.path}/signature_$userIdInt.png';
            final File signatureFile = File(signaturePath);

            if (await signatureFile.exists()) {
              await signatureFile.delete();
            }

            await signatureFile.writeAsBytes(signatureBytes);
          }
        }

        await ApiService.updatePresent(userIdInt, 1);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? "Client modifié avec succès!"
                    : "Inscription réussie! Bienvenue à l'événement.",
              ),
              backgroundColor: Colors.green,
            ),
          );
          _showSuccessDialog();
        }
      } else if (result.containsKey('error')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error']),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
        }
      } else {
        throw Exception('Unknown response format');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _extractWilayaCode(String wilayaString) {
    final parts = wilayaString.split(' ');
    if (parts.isNotEmpty) {
      String code = parts[0];
      if (code.length == 2 && code.startsWith('0')) {
        code = code.substring(1);
      }
      return code;
    }
    return '';
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Succès!"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing
                  ? "Le client a été modifié avec succès."
                  : "Votre inscription a été enregistrée avec succès.\n\nVous êtes maintenant enregistré(e) comme présent(e) à l'événement.",
            ),
            const SizedBox(height: 16),
            const Icon(Icons.celebration, size: 48, color: Colors.green),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetFormAndGoBack();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _resetFormAndGoBack() {
    _formKey.currentState?.reset();
    _signatureController.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ClientsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? "Modifier Client" : "Fiche Client",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ClientsPage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSalonHeader(),
              const SizedBox(height: 24),
              _buildDesktopGrid(),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalonHeader() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 500;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isSmallScreen
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Date et heure de l'événement",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDateTime(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatDateTime(_selectedDateTime),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Date et heure de l'événement",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                InkWell(
                  onTap: () => _selectDateTime(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatDateTime(_selectedDateTime),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDesktopGrid() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 1000;

    if (isSmallScreen) {
      return Column(
        children: [
          _buildFieldCard([
            _buildRadioField("Client/Prospect", "clientProspect", [
              "Client",
              "Prospect",
            ]),
            _buildTextField("Nom", "nom", hintText: "Fayçal"),
            _buildTextField(
              "Téléphone",
              "telephone",
              hintText: "0000000000",
              keyboardType: TextInputType.phone,
            ),
            _buildTextField("Magasin", "magasin", hintText: "SINAL OPTICS"),
            const SizedBox(height: 16),
            _buildTextField("Prénom", "prenom", hintText: "TOUHAMI"),
            _buildTextField(
              "E-Mail",
              "email",
              hintText: "",
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              "Nbr Accompagnateur",
              "accompagnateur",
              hintText: "0",
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              "Adresse",
              "adresse",
              hintText: "Adresse complète",
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildDropdownField("Civilité", "civilite", ["Mme", "M."], "Mme"),
            _buildDropdownField("Activité", "activite", [
              "01 Opticien",
              "02 Optométriste",
            ], "01 Opticien"),
            _buildDropdownField(
              "Wilaya",
              "wilaya",
              _getWilayaList(),
              "16 Alger",
            ),
            _buildRadioField(
              "Statut",
              "statut",
              ["Absent", "Présent"],
              horizontal: true,
              initialValue: "Présent",
            ),
          ]),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildFieldCard([
            _buildRadioField("Client/Prospect", "clientProspect", [
              "Client",
              "Prospect",
            ]),
            _buildTextField("Nom", "nom", hintText: "Fayçal"),
            _buildTextField(
              "Téléphone",
              "telephone",
              hintText: "0000000000",
              keyboardType: TextInputType.phone,
            ),
            _buildTextField("Magasin", "magasin", hintText: "SINAL OPTICSIQUE"),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFieldCard([
            _buildTextField("Prénom", "prenom", hintText: "TOUHAMI"),
            _buildTextField(
              "E-Mail",
              "email",
              hintText: "",
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              "Nbr Accompagnateur",
              "accompagnateur",
              hintText: "0",
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              "Adresse",
              "adresse",
              hintText: "Adresse complète",
              maxLines: 2,
            ),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFieldCard([
            _buildDropdownField("Civilité", "civilite", ["Mme", "M."], "Mme"),
            _buildDropdownField("Activité", "activite", [
              "01 Opticien",
              "02 Optométriste",
            ], "01 Opticien"),
            _buildDropdownField(
              "Wilaya",
              "wilaya",
              _getWilayaList(),
              "16 Alger",
            ),
            _buildRadioField(
              "Statut",
              "statut",
              ["Absent", "Présent"],
              horizontal: true,
              initialValue: "Présent",
            ),
          ]),
        ),
      ],
    );
  }

  List<String> _getWilayaList() {
    return [
      "01 Adrar",
      "02 Chlef",
      "03 Laghouat",
      "04 Oum El Bouaghi",
      "05 Batna",
      "06 Béjaïa",
      "07 Biskra",
      "08 Béchar",
      "09 Blida",
      "10 Bouira",
      "11 Tamanrasset",
      "12 Tébessa",
      "13 Tlemcen",
      "14 Tiaret",
      "15 Tizi Ouzou",
      "16 Alger",
      "17 Djelfa",
      "18 Jijel",
      "19 Sétif",
      "20 Saïda",
      "21 Skikda",
      "22 Sidi Bel Abbès",
      "23 Annaba",
      "24 Guelma",
      "25 Constantine",
      "26 Médéa",
      "27 Mostaganem",
      "28 M'Sila",
      "29 Mascara",
      "30 Ouargla",
      "31 Oran",
      "32 El Bayadh",
      "33 Illizi",
      "34 Bordj Bou Arreridj",
      "35 Boumerdès",
      "36 El Tarf",
      "37 Tindouf",
      "38 Tissemsilt",
      "39 El Oued",
      "40 Khenchela",
      "41 Souk Ahras",
      "42 Tipaza",
      "43 Mila",
      "44 Aïn Defla",
      "45 Naâma",
      "46 Aïn Témouchent",
      "47 Ghardaïa",
      "48 Relizane",
      "49 Timimoun",
      "50 Bordj Badji Mokhtar",
      "51 Ouled Djellal",
      "52 Béni Abbès",
      "53 In Salah",
      "54 In Guezzam",
      "55 Touggourt",
      "56 Djanet",
      "57 El M'Ghair",
      "58 El Meniaa",
      "59 Aflou",
      "60 El Abiodh Sidi Cheikh",
      "61 El Aricha",
      "62 El Kantara",
      "63 Barika",
      "64 Bou Saâda",
      "65 Bir El Ater",
      "66 Ksar El Boukhari",
      "67 Ksar Chellala",
      "68 Aïn Oussera",
      "69 Messaâd",
    ];
  }

  Widget _buildFieldCard(List<Widget> fields) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String name, {
    String? hintText,
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          FormBuilderTextField(
            name: name,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            keyboardType: keyboardType,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String name,
    List<String> options,
    String initialValue,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          FormBuilderDropdown<String>(
            name: name,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: options
                .map(
                  (option) =>
                      DropdownMenuItem(value: option, child: Text(option)),
                )
                .toList(),
            initialValue: initialValue,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioField(
    String label,
    String name,
    List<String> options, {
    bool horizontal = true,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              radioTheme: RadioThemeData(
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blue;
                  }
                  return Colors.grey;
                }),
                overlayColor: WidgetStateProperty.all(
                  Colors.blue.withOpacity(0.1),
                ),
              ),
            ),
            child: FormBuilderRadioGroup<String>(
              name: name,
              orientation: horizontal
                  ? OptionsOrientation.horizontal
                  : OptionsOrientation.vertical,
              options: options
                  .map(
                    (option) => FormBuilderFieldOption(
                      value: option,
                      child: Text(option),
                    ),
                  )
                  .toList(),
              initialValue: initialValue ?? options.first,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _showConfirmationDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isEditing ? "Mettre à jour" : "Valider",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
