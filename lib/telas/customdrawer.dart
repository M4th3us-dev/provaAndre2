import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prova2andre/telas/addvehiclescreen.dart';
import 'package:prova2andre/telas/auth/loginscreen.dart';
import 'package:prova2andre/telas/historyscreen.dart';
import 'package:prova2andre/telas/mainscreen.dart';
import 'package:prova2andre/telas/profilescreen.dart';
import 'package:prova2andre/telas/vehiclescreen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String _userName = "Carregando...";
  String _userEmail = "";

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(_user!.uid).get();
      setState(() {
        _userName = userDoc['name'] ?? 'Usuário';
        _userEmail = _user?.email ?? 'user@email.com';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              _userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              _userEmail,
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 40, color: Colors.blue),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerTile(
                  icon: Icons.home,
                  title: "Home",
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                    );
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.directions_car,
                  title: "Meus veículos",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VehiclesScreen()),
                    );
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.add_circle_outline,
                  title: "Adicionar veículos",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddVehicleScreen()),
                    );
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.history,
                  title: "Histórico de abastecimentos",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen()),
                    );
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.person,
                  title: "Perfil",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()),);
                  },
                ),
                const Divider(),
                _buildDrawerTile(
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: () async {
                    await _auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(
      {required IconData icon, required String title, required Function() onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}
