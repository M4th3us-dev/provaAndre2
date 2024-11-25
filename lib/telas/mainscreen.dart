import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prova2andre/telas/customdrawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  User? currentUser;
  String userName = "Convidado";

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc['nome'] ?? 'Usuário';
          });
        }
      } catch (e) {
        debugPrint("Erro ao carregar informações do usuário: $e");
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCarData() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('cars').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint("Erro ao buscar dados de carros: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela Principal'),
        centerTitle: true,
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo, $userName!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchCarData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Erro ao carregar a lista de carros.',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum carro disponível no momento.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    );
                  } else {
                    final cars = snapshot.data!;
                    return ListView.separated(
                      itemCount: cars.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final car = cars[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.directions_car),
                            title: Text(
                              car['name'] ?? 'Sem nome',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Modelo: ${car['model'] ?? 'Desconhecido'}',
                            ),
                            trailing: Text(
                              car['year']?.toString() ?? 'Ano ND',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
