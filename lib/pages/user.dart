// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sinal_events/components/api/api.dart';

class GestionUtilisateursPage extends StatefulWidget {
  const GestionUtilisateursPage({super.key});

  @override
  State<GestionUtilisateursPage> createState() =>
      _GestionUtilisateursPageState();
}

class _GestionUtilisateursPageState extends State<GestionUtilisateursPage> {
  List<AdminUser> users = [];
  List<AdminUser> filteredUsers = [];
  bool loading = true;

  String roleFilter = 'all';
  TextEditingController searchController = TextEditingController();

  int totalUsers = 0;
  int totalAdmins = 0;
  int totalUsersRole = 0;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    searchController.addListener(filterUsers);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    setState(() => loading = true);

    try {
      final result = await ApiService.getAllAdminUsers();
      setState(() {
        users = result;
        filteredUsers = List.from(result);
        updateStats();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void updateStats() {
    totalUsers = users.length;
    totalAdmins = users.where((u) => u.roles == 'admin').length;
    totalUsersRole = users.where((u) => u.roles == 'user').length;
  }

  void filterUsers() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredUsers = users.where((u) {
        bool matchSearch =
            u.nom.toLowerCase().contains(query) ||
            u.fonction.toLowerCase().contains(query);

        bool matchRole = roleFilter == 'all' || u.roles == roleFilter;

        return matchSearch && matchRole;
      }).toList();
    });
  }

  Future<void> createUser() async {
    final nomController = TextEditingController();
    final fonctionController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'user';
    int actif = 1;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Ajouter un utilisateur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fonctionController,
                decoration: const InputDecoration(
                  labelText: 'Fonction',
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('Utilisateur')),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrateur'),
                  ),
                ],
                onChanged: (value) => selectedRole = value!,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Compte actif'),
                value: actif == 1,
                onChanged: (value) => actif = value ? 1 : 0,
                activeThumbColor: Colors.green,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nomController.text.isEmpty ||
                  fonctionController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir tous les champs'),
                  ),
                );
                return;
              }
              Navigator.pop(context, {
                'nom': nomController.text,
                'fonction': fonctionController.text,
                'password': passwordController.text,
                'roles': selectedRole,
                'actif': actif,
              });
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => loading = true);
      try {
        final response = await ApiService.createUser(
          nom: result['nom'],
          fonction: result['fonction'],
          password: result['password'],
          roles: result['roles'],
          actif: result['actif'],
        );

        if (response['success'] == true || response['message'] != null) {
          await fetchUsers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Utilisateur créé avec succès'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          throw Exception(response['error'] ?? 'Erreur inconnue');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
        setState(() => loading = false);
      }
    }
  }

  Future<void> editUser(AdminUser user) async {
    final nomController = TextEditingController(text: user.nom);
    final fonctionController = TextEditingController(text: user.fonction);
    final passwordController = TextEditingController();
    String selectedRole = user.roles;
    int actif = user.actif;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Modifier utilisateur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fonctionController,
                decoration: const InputDecoration(
                  labelText: 'Fonction',
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText:
                      'Nouveau mot de passe (laisser vide pour ne pas changer)',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('Utilisateur')),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrateur'),
                  ),
                ],
                onChanged: (value) => selectedRole = value!,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Compte actif'),
                value: actif == 1,
                onChanged: (value) => actif = value ? 1 : 0,
                activeThumbColor: Colors.green,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'id': user.id,
                'nom': nomController.text,
                'fonction': fonctionController.text,
                'password': passwordController.text,
                'roles': selectedRole,
                'actif': actif,
              });
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => loading = true);
      try {
        final response = await ApiService.updateUser(
          id: result['id'],
          nom: result['nom'],
          fonction: result['fonction'],
          roles: result['roles'],
          actif: result['actif'],
          password: result['password'].isEmpty ? null : result['password'],
        );

        if (response['success'] == true || response['message'] != null) {
          await fetchUsers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Utilisateur modifié avec succès'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          throw Exception(response['error'] ?? 'Erreur inconnue');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
        setState(() => loading = false);
      }
    }
  }

  Future<void> deleteUser(AdminUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer l\'utilisateur "${user.nom}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => loading = true);
      try {
        final response = await ApiService.deleteUser(user.id);

        if (response['success'] == true || response['message'] != null) {
          setState(() {
            users.removeWhere((u) => u.id == user.id);
            filteredUsers.removeWhere((u) => u.id == user.id);
            updateStats();
            filterUsers();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Utilisateur supprimé avec succès'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          throw Exception(response['error'] ?? 'Erreur inconnue');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => loading = false);
      }
    }
  }

  Future<void> toggleUserStatus(AdminUser user) async {
    int newActif = user.actif == 1 ? 0 : 1;

    final updatedUser = user.copyWith(actif: newActif);

    setState(() {
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = updatedUser;
      }
      final filteredIndex = filteredUsers.indexWhere((u) => u.id == user.id);
      if (filteredIndex != -1) {
        filteredUsers[filteredIndex] = updatedUser;
      }
      updateStats();
    });

    try {
      final response = await ApiService.updateUser(
        id: user.id,
        actif: newActif,
      );

      if (response['success'] != true && response['message'] == null) {
        final revertedUser = user.copyWith(actif: user.actif);
        setState(() {
          final index = users.indexWhere((u) => u.id == user.id);
          if (index != -1) {
            users[index] = revertedUser;
          }
          final filteredIndex = filteredUsers.indexWhere(
            (u) => u.id == user.id,
          );
          if (filteredIndex != -1) {
            filteredUsers[filteredIndex] = revertedUser;
          }
          updateStats();
        });
        throw Exception(response['error'] ?? 'Erreur inconnue');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newActif == 1 ? 'Compte activé' : 'Compte désactivé'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget buildStatCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget buildRoleBadge(String role) {
    Color color;
    String label;

    switch (role) {
      case 'admin':
        color = Colors.red;
        label = 'Admin';
        break;
      case 'user':
        color = Colors.green;
        label = 'User';
        break;
      default:
        color = Colors.grey;
        label = role;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: const Color(0xFF1877F2),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchUsers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createUser,
        backgroundColor: const Color(0xFF1877F2),
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      buildStatCard(
                        'Total',
                        totalUsers,
                        Icons.people,
                        Colors.blue,
                      ),
                      buildStatCard(
                        'Admins',
                        totalAdmins,
                        Icons.admin_panel_settings,
                        Colors.red,
                      ),
                      buildStatCard(
                        'Users',
                        totalUsersRole,
                        Icons.person,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Rechercher...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: roleFilter,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Tous')),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('Admins'),
                            ),
                            DropdownMenuItem(
                              value: 'user',
                              child: Text('Users'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => roleFilter = value!);
                            filterUsers();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredUsers.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucun utilisateur trouvé',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: user.roles == 'admin'
                                      ? Colors.red.shade100
                                      : Colors.green.shade100,
                                  child: Icon(
                                    user.roles == 'admin'
                                        ? Icons.admin_panel_settings
                                        : Icons.person,
                                    color: user.roles == 'admin'
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                                title: Text(
                                  user.nom,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fonction,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Créé le: ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    buildRoleBadge(user.roles),
                                    const SizedBox(width: 8),
                                    Switch(
                                      value: user.actif == 1,
                                      onChanged: (_) => toggleUserStatus(user),
                                      activeColor: Colors.green,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => editUser(user),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => deleteUser(user),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
