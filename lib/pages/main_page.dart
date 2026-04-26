// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sinal_events/components/Main/DropDown.dart';
import 'package:flutter/services.dart';
import 'package:sinal_events/pages/Fclient.dart';
import 'package:sinal_events/components/api/api.dart';
import 'package:sinal_events/pages/choice.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  int _totalClients = 0;
  int _totalWithAccompaniment = 0;
  bool _isLoadingStats = true;
  bool _isLoadingUsers = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _fetchData();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _fetchData() async {
    await _fetchUsers();
    await _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final stats = await ApiService.getStats();

      if (mounted) {
        int totalWithAcc = 0;
        for (var user in _users) {
          totalWithAcc += 1;
          totalWithAcc += user.acc;
        }

        setState(() {
          _totalClients = stats['total'] ?? 0;
          _totalWithAccompaniment = totalWithAcc;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final loadedUsers = await ApiService.getUsers();
      if (mounted) {
        setState(() {
          _users = loadedUsers;
          _filteredUsers = loadedUsers;
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  }

  void _filterUsersByDate(DateTime? date) {
    setState(() {
      _selectedDate = date;
      if (date == null) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          try {
            final userDate = DateTime.parse(user.eventDate);
            return userDate.year == date.year &&
                userDate.month == date.month &&
                userDate.day == date.day;
          } catch (e) {
            return false;
          }
        }).toList();
      }
    });
  }

  Future<void> _refreshData() async {
    await _fetchData();
  }

  String getAccompagnementText(int acc) {
    if (acc == 0) return '0 Accompagnateur';
    if (acc == 1) return '1 Accompagnateur';
    return '$acc Accompagnateurs';
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  Widget getStatusWidget(User user) {
    if (user.present == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text(
              'Présent',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (user.checked == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.blue, size: 16),
            SizedBox(width: 4),
            Text(
              'Check-in',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pending, color: Colors.orange, size: 16),
            SizedBox(width: 4),
            Text(
              'En attente',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _editUser(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClientForm(user: user)),
    ).then((_) => _refreshData());
  }

  void _goBackToChoicePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ChoicePage()),
    );
  }

  Widget _buildUserCard(User user) {
    return GestureDetector(
      onTap: () => _editUser(user),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      user.nom,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  getStatusWidget(user),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Raison Sociale:', user.rs),
              _buildInfoRow('Accompagnement:', getAccompagnementText(user.acc)),
              _buildInfoRow('Date événement:', formatDate(user.eventDate)),
              _buildInfoRow('Téléphone:', user.tel),
              _buildInfoRow('Adresse:', user.adresse, isAddress: true),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 14, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'Modifier',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAddress = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isAddress ? FontWeight.normal : FontWeight.w500,
              ),
              overflow: isAddress
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              softWrap: isAddress,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 800;
    final isVerySmallScreen = screenSize.width < 500;

    return WillPopScope(
      onWillPop: () async {
        _goBackToChoicePage();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 169, 194, 231),
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          toolbarHeight: isVerySmallScreen ? 80 : 70,
          title: isVerySmallScreen
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF4A90E2),
                          ),
                          onPressed: _goBackToChoicePage,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Text(
                            'Gestion des Clients',
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Color(0xFF4A90E2),
                          ),
                          onPressed: _refreshData,
                          tooltip: 'Actualiser',
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints.tight(const Size(40, 40)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('images/sinal.png'),
                          height: 30,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Sinal Acces Event',
                          style: TextStyle(
                            color: Color(0xFF2C3E50),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    GestureDetector(
                      onTap: _goBackToChoicePage,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Color(0xFF4A90E2)),
                          SizedBox(width: 8),
                          Text(
                            'Gestion des Clients/Prospects',
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image(
                          image: AssetImage('images/sinal.png'),
                          height: 40,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Sinal Acces Event',
                          style: TextStyle(
                            color: Color(0xFF2C3E50),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF4A90E2)),
                      onPressed: _refreshData,
                      tooltip: 'Actualiser',
                    ),
                  ],
                ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 600;
                    if (isSmall) {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: _buildStatsCard(
                              title: "Nombre Des Clients:",
                              value: _isLoadingStats ? "..." : "$_totalClients",
                              icon: Icons.people,
                              color: Colors.blue,
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: _buildStatsCard(
                              title: "Avec Accompagnateur:",
                              value: _isLoadingStats
                                  ? "..."
                                  : "$_totalWithAccompaniment",
                              icon: Icons.group,
                              color: Colors.green,
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DateEvent(
                            onDateSelected: _filterUsersByDate,
                            selectedDate: _selectedDate,
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: _buildStatsCard(
                              title: "Nombre Des Clients:",
                              value: _isLoadingStats ? "..." : "$_totalClients",
                              icon: Icons.people,
                              color: Colors.blue,
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            flex: 2,
                            child: _buildStatsCard(
                              title: "Clients + Accompagnateur:",
                              value: _isLoadingStats
                                  ? "..."
                                  : "$_totalWithAccompaniment",
                              icon: Icons.group,
                              color: Colors.green,
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          DateEvent(
                            onDateSelected: _filterUsersByDate,
                            selectedDate: _selectedDate,
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_selectedDate != null)
                      Chip(
                        label: Text(
                          'Filtré: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () {
                          _filterUsersByDate(null);
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                        backgroundColor: Colors.blue.shade50,
                      ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClientForm(),
                          ),
                        ).then((_) => _refreshData());
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(
                        'Ajouter un client',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _isLoadingUsers
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Chargement des clients...'),
                            ],
                          ),
                        ),
                      )
                    : _filteredUsers.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.event_busy,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedDate != null
                                    ? 'Aucun client pour cette date'
                                    : 'Aucun client trouvé',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          return _buildUserCard(_filteredUsers[index]);
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 10 : 15,
        horizontal: isSmallScreen ? 12 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: isSmallScreen ? 24 : 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 24,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
