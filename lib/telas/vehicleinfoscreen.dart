import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VehicleInfoScreen extends StatefulWidget {
  final Map<String, dynamic> carData;

  const VehicleInfoScreen({Key? key, required this.carData}) : super(key: key);

  @override
  _VehicleInfoScreenState createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  late Map<String, dynamic> carDetails;

  @override
  void initState() {
    super.initState();
    carDetails = widget.carData;
  }

  void _openFuelDialog(BuildContext context) {
    final TextEditingController litersController = TextEditingController();
    final TextEditingController kilometrageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Registrar Abastecimento"),
              const SizedBox(height: 16),
              TextField(
                controller: litersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Litros abastecidos",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: kilometrageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Kilometragem Atual",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final liters = double.tryParse(litersController.text);
                  final kilometrage = int.tryParse(kilometrageController.text);

                  if (liters == null || kilometrage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Valores inválidos. Tente novamente.")),
                    );
                    return;
                  }

                  _updateVehicleData(context, liters, kilometrage);
                },
                child: const Text("Salvar Alterações"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateVehicleData(BuildContext context, double liters, int kilometrage) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuário não autenticado. Tente novamente.")),
        );
        return;
      }

      final carDocument = await FirebaseFirestore.instance
          .collection('cars')
          .doc(carDetails['id'])
          .get();

      if (carDocument.exists) {
        final carData = carDocument.data() as Map<String, dynamic>;
        final previousKilometrage = carData['kilometrage'] ?? 0;

        await FirebaseFirestore.instance
            .collection('cars')
            .doc(carDetails['id'])
            .set({
          'liters': FieldValue.increment(liters),
          'kilometrage': kilometrage,
          'average': FieldValue.increment(0),
        }, SetOptions(merge: true));

        if (previousKilometrage > 0) {
          final fuelEfficiency = (kilometrage - previousKilometrage) / liters;

          await FirebaseFirestore.instance
              .collection('cars')
              .doc(carDetails['id'])
              .update({'average': fuelEfficiency});

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('mycars')
              .doc(carDetails['id'])
              .set({
            'average': fuelEfficiency,
            'kilometrage': kilometrage,
            'liters': FieldValue.increment(liters),
          }, SetOptions(merge: true));

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('historico')
              .doc(carDetails['id'])
              .set({
            'carModel': carData['model'],
            'carName': carData['name'],
            'carPlaca': carData['placa'],
            'carYear': carData['year'],
            'kilometrage': kilometrage,
            'liters': FieldValue.increment(liters),
            'timestamp': Timestamp.now(),
          }, SetOptions(merge: true));
        }

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Informações atualizadas com sucesso!")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar dados: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(carDetails['name'] ?? 'Detalhes do Veículo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nome: ${carDetails['name'] ?? 'Desconhecido'}"),
            Text("Modelo: ${carDetails['model'] ?? 'Desconhecido'}"),
            Text("Ano: ${carDetails['year'] ?? 'Desconhecido'}"),
            Text("Placa: ${carDetails['placa'] ?? 'Desconhecida'}"),
            Text("Kilometragem: ${carDetails['kilometrage'] ?? 'Não disponível'}"),
            Text("Litros abastecidos: ${carDetails['liters'] ?? 'Não informado'}"),
            Text("Média de Consumo: ${carDetails['average']?.toStringAsFixed(2) ?? 'Não calculado'}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _openFuelDialog(context),
              child: const Text("Registrar Abastecimento"),
            ),
          ],
        ),
      ),
    );
  }
}
