import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prova2andre/telas/customdrawer.dart';
import 'package:prova2andre/telas/vehicleinfoscreen.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  User? _currentUser;
  String _username = "Usuário";

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (_currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _username = userDoc['nome'] ?? 'Usuário';
        });
      } else {
        print("Usuário não encontrado.");
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchVehicles() async {
    if (_currentUser == null) {
      print("Usuário não logado.");
      return [];
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('mycars')
          .get();

      return querySnapshot.docs.map((doc) {
        final carData = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': carData['name'] ?? 'Desconhecido',
          'model': carData['model'] ?? 'Desconhecido',
          'liters': carData['liters'] ?? 0,
          'kilometrage': carData['kilometrage'] ?? 0,
          'average': carData['average'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print("Erro ao carregar veículos: $e");
      return [];
    }
  }

  Future<void> _removeCar(String carId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('mycars')
          .doc(carId)
          .delete();

      await FirebaseFirestore.instance
          .collection('cars')
          .doc(carId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Carro excluído com sucesso'),
      ));
      setState(() {});
    } catch (e) {
      print("Erro ao excluir carro: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Erro ao excluir o carro'),
      ));
    }
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> car) {
    final nameController = TextEditingController(text: car['name']);
    final modelController = TextEditingController(text: car['model']);
    final litersController = TextEditingController(text: car['liters'].toString());
    final kilometrageController = TextEditingController(text: car['kilometrage'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Editar Informações do Carro"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Nome", nameController),
              _buildTextField("Modelo", modelController),
              _buildTextField("Litros", litersController, keyboardType: TextInputType.number),
              _buildTextField("Quilometragem", kilometrageController, keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedName = nameController.text.trim();
                final updatedModel = modelController.text.trim();
                final updatedLiters = double.tryParse(litersController.text.trim());
                final updatedKilometrage = int.tryParse(kilometrageController.text.trim());

                if (updatedLiters == null || updatedKilometrage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Por favor, insira valores válidos.")),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_currentUser!.uid)
                      .collection('mycars')
                      .doc(car['id'])
                      .update({
                    'name': updatedName,
                    'model': updatedModel,
                    'liters': updatedLiters,
                    'kilometrage': updatedKilometrage,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Informações atualizadas com sucesso."),
                  ));
                  Navigator.pop(context);
                  setState(() {});
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erro ao atualizar o carro: $error")),
                  );
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboardType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Veículos"),
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchVehicles(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar seus veículos.'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Você não tem veículos cadastrados.'));
            } else {
              final vehicles = snapshot.data!;
              return ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final car = vehicles[index];
                  return _buildCarTile(context, car);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCarTile(BuildContext context, Map<String, dynamic> car) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(car['name']),
        subtitle: Text('Modelo: ${car['model']}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleInfoScreen(carData: car),
            ),
          );
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditDialog(context, car);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _removeCar(car['id']);
              },
            ),
          ],
        ),
      ),
    );
  }
}
