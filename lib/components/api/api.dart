import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UserSession {
  static String? userId;
  static String? userName;
  static String? userRole;

  static void setUser(String id, String name, String role) {
    userId = id;
    userName = name;
    userRole = role;
  }

  static void clear() {
    userId = null;
    userName = null;
    userRole = null;
  }
}

class ApiService {
  static const String baseUrl = 'https://event.optiquesinaldz.com';
  static const String apiUrl = '$baseUrl/api/api.php';

  static Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    if (response.body.trim().isEmpty) {
      throw Exception('Empty response from server');
    }

    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Invalid JSON response from server');
    }
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final uri = Uri.parse('$apiUrl?action=login');

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Connection timeout - Server not responding');
            },
          );

      final result = await _handleResponse(response) as Map<String, dynamic>;

      if (result.containsKey('error')) {
        if (result['error'] is String &&
            (result['error'].toString().contains('désactivé') ||
                result['error'].toString().contains('desactivated'))) {
          return {
            'success': false,
            'errorType': 'account_disabled',
            'error': result['error'],
          };
        }

        return {
          'success': false,
          'errorType': 'credentials',
          'error': result['error'] is String
              ? result['error']
              : (result['message'] ??
                    'Nom d\'utilisateur ou mot de passe incorrect'),
        };
      }

      if (result["id"] == null || result["id"].toString().isEmpty) {
        return {
          'success': false,
          'errorType': 'credentials',
          'error': 'Nom d\'utilisateur ou mot de passe incorrect',
        };
      }

      if (result.containsKey('actif')) {
        final int actif = result["actif"] is int
            ? result["actif"]
            : int.tryParse(result["actif"].toString()) ?? 0;

        if (actif != 1) {
          return {
            'success': false,
            'errorType': 'account_disabled',
            'error':
                'Votre compte est désactivé. Veuillez contacter l\'administrateur.',
          };
        }
      }

      UserSession.setUser(
        result["id"].toString(),
        result["nom"].toString(),
        result["roles"].toString(),
      );

      return {
        'success': true,
        'errorType': 'none',
        'id': result["id"],
        'nom': result["nom"],
        'roles': result["roles"],
      };
    } on SocketException {
      return {
        'success': false,
        'errorType': 'network',
        'error':
            'Impossible de se connecter au serveur. Vérifiez que:\n'
            '1. Le serveur est allumé\n'
            '2. L\'adresse IP est correcte: $baseUrl\n'
            '3. Vous êtes sur le même réseau WiFi',
      };
    } on HttpException catch (e) {
      return {
        'success': false,
        'errorType': 'http',
        'error': 'Erreur HTTP: $e',
      };
    } catch (e) {
      return {
        'success': false,
        'errorType': 'unknown',
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> registerUser({
    required String nom,
    required String rs,
    required String eventDate,
    required String adresse,
    required String wilaya,
    required String tel,
    required int acc,
    int? userId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'nom': nom,
        'rs': rs,
        'event_date': eventDate,
        'adresse': adresse,
        'wilaya': wilaya,
        'tel': tel,
        'acc': acc,
      };

      if (userId != null) {
        body['user_id'] = userId;
      }

      final response = await http
          .post(
            Uri.parse('$apiUrl?action=register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      return await _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      return {'error': true, 'message': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyQR(String token) async {
    try {
      final response = await http
          .get(Uri.parse('$apiUrl?action=verify&token=$token'))
          .timeout(const Duration(seconds: 10));
      final data = await _handleResponse(response) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return {'error': true, 'message': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkinUser(String token) async {
    try {
      final response = await http
          .put(
            Uri.parse('$apiUrl?action=checkin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}),
          )
          .timeout(const Duration(seconds: 10));
      return await _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': true, 'message': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkinUserWithId(
    String token,
    String? userId,
  ) async {
    try {
      final Map<String, dynamic> body = {'token': token};
      if (userId != null && userId.isNotEmpty) {
        body['user_id'] = int.parse(userId);
      }

      final response = await http
          .put(
            Uri.parse('$apiUrl?action=checkin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      return await _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      return {'error': true, 'message': 'Erreur: $e'};
    }
  }

  static Future<List<User>> getUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$apiUrl?action=getUsers'))
          .timeout(const Duration(seconds: 10));

      final data = await _handleResponse(response);

      if (data is List) {
        return data.map((e) => User.fromJson(e)).toList();
      }

      if (data is Map && data['data'] is List) {
        return (data['data'] as List).map((e) => User.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http
          .get(Uri.parse('$apiUrl?action=get_stats'))
          .timeout(const Duration(seconds: 10));

      final data = await _handleResponse(response) as Map<String, dynamic>;

      if (data['success'] == true && data['stats'] != null) {
        return data['stats'];
      } else if (data['stats'] != null) {
        return data['stats'];
      } else {
        return data;
      }
    } catch (e) {
      return {'total': 0, 'present': 0, 'total_accompagnateurs': 0};
    }
  }

  static Future<Map<String, dynamic>> createAdmin({
    required String username,
    required String password,
    required String fonction,
    required String roles,
    required int actif,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$apiUrl?action=create_admin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'fonction': fonction,
              'roles': roles,
              'actif': actif,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return await _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> togglePresence(
    int id,
    int checked,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$apiUrl?action=toggle_presence'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id': id, 'checked': checked}),
          )
          .timeout(const Duration(seconds: 10));
      return await _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> updatePresent(int id, int present) async {
    try {
      final response = await http
          .put(
            Uri.parse('$apiUrl?action=updatePresent'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id': id, 'present': present}),
          )
          .timeout(const Duration(seconds: 10));

      final result = await _handleResponse(response) as Map<String, dynamic>;

      return {
        'success': result['success'] == true || result['success'] == 'true',
        'data': result['data'] ?? {},
      };
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  static Future<List<AdminUser>> getAllAdminUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$apiUrl?action=getAllUsers'))
          .timeout(const Duration(seconds: 10));

      final data = await _handleResponse(response);

      if (data is List) {
        return data.map((e) => AdminUser.fromJson(e)).toList();
      }

      if (data is Map) {
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((e) => AdminUser.fromJson(e))
              .toList();
        }

        if (data['users'] is List) {
          return (data['users'] as List)
              .map((e) => AdminUser.fromJson(e))
              .toList();
        }

        if (data['id_user'] != null) {
          return [AdminUser.fromJson(data as Map<String, dynamic>)];
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createUser({
    required String nom,
    required String password,
    required String fonction,
    required String roles,
    required int actif,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$apiUrl?action=create_user'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nom': nom,
              'password': password,
              'fonction': fonction,
              'roles': roles,
              'actif': actif,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return await _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUser({
    required int id,
    String? nom,
    String? fonction,
    String? roles,
    int? actif,
    String? password,
  }) async {
    try {
      Map<String, dynamic> data = {'id': id};
      if (nom != null) data['nom'] = nom;
      if (fonction != null) data['fonction'] = fonction;
      if (roles != null) data['roles'] = roles;
      if (actif != null) data['actif'] = actif;
      if (password != null && password.isNotEmpty) data['password'] = password;

      final response = await http
          .put(
            Uri.parse('$apiUrl?action=update_user'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));
      return await _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$apiUrl?action=delete_user'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id': id}),
          )
          .timeout(const Duration(seconds: 10));
      return await _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }
}

class User {
  final int id;
  final String nom;
  final String rs;
  final String eventDate;
  final String adresse;
  final String wilaya;
  final String tel;
  final int acc;
  final int present;
  final int checked;
  final String qrToken;
  final String qrCode;
  final DateTime creation;
  final DateTime? time;
  final String? civilite;
  final String? activite;
  final String? clientProspect;
  final String? statut;
  final String? email;
  final String? signaturePath;

  User({
    required this.id,
    required this.nom,
    required this.rs,
    required this.eventDate,
    required this.adresse,
    required this.wilaya,
    required this.tel,
    required this.acc,
    required this.present,
    required this.checked,
    required this.qrToken,
    required this.qrCode,
    required this.creation,
    this.time,
    this.civilite,
    this.activite,
    this.clientProspect,
    this.statut,
    this.email,
    this.signaturePath,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      nom: json['nom'] ?? '',
      rs: json['rs'] ?? '',
      eventDate: json['event_date'] ?? '',
      adresse: json['adresse'] ?? '',
      wilaya: json['wilaya'] ?? '',
      tel: json['tel'] ?? '',
      acc: int.parse(json['acc'].toString()),
      present: int.parse(json['present']?.toString() ?? '0'),
      checked: int.parse(json['checked']?.toString() ?? '0'),
      qrToken: json['qr_token'] ?? '',
      qrCode: json['qr_code'] ?? '',
      creation: json['creation'] != null
          ? DateTime.parse(json['creation'])
          : DateTime.now(),
      time: json['time'] != null && json['time'] != '0000-00-00 00:00:00'
          ? DateTime.parse(json['time'])
          : null,
      civilite: json['civilite'],
      activite: json['activite'],
      clientProspect: json['client_prospect'],
      statut: json['statut'],
      email: json['email'],
      signaturePath: null,
    );
  }
}

class AdminUser {
  final int id;
  final String nom;
  final String fonction;
  final String roles;
  final int actif;
  final DateTime createdAt;

  AdminUser({
    required this.id,
    required this.nom,
    required this.fonction,
    required this.roles,
    required this.actif,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id_user'] is int
          ? json['id_user']
          : int.parse(json['id_user'].toString()),
      nom: json['nom'] ?? '',
      fonction: json['fonction'] ?? '',
      roles: json['roles'] ?? 'user',
      actif: json['actif'] is int
          ? json['actif']
          : int.parse(json['actif'].toString()),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  AdminUser copyWith({
    int? id,
    String? nom,
    String? fonction,
    String? roles,
    int? actif,
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      fonction: fonction ?? this.fonction,
      roles: roles ?? this.roles,
      actif: actif ?? this.actif,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': id,
      'nom': nom,
      'fonction': fonction,
      'roles': roles,
      'actif': actif,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Statistics {
  final int total;
  final int present;
  final int totalAccompagnateurs;

  Statistics({
    required this.total,
    required this.present,
    required this.totalAccompagnateurs,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      total: json['total'] ?? 0,
      present: json['present'] ?? 0,
      totalAccompagnateurs: json['total_accompagnateurs'] ?? 0,
    );
  }

  int get pending => total - present;
  double get rate => total > 0 ? (present / total) * 100 : 0;
}
