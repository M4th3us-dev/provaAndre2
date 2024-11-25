import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prova2andre/telas/customdrawer.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _kilometrageController = TextEditingController();
  final TextEditingController _averageController = TextEditingController();

  Future<void> _addVehicle() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          String uid = user.uid;

          String name = _nameController.text;
          String model = _modelController.text;
          String year = _yearController.text;
          String placa = _placaController.text;
          double liters = double.tryParse(_litersController.text) ?? 0.0;
          int kilometrage = int.tryParse(_kilometrageController.text) ?? 0;
          double average = double.tryParse(_averageController.text) ?? 0.0;

          DocumentReference carRef = await FirebaseFirestore.instance.collection('cars').add({
            'name': name,
            'model': model,
            'year': year,
            'placa': placa,
            'liters': liters,
            'kilometrage': kilometrage,
            'average': average,
            'createdAt': FieldValue.serverTimestamp(),
          });

          String carId = carRef.id;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('mycars')
              .doc(carId)
              .set({
            'name': name,
            'model': model,
            'year': year,
            'placa': placa,
            'liters': liters,
            'kilometrage': kilometrage,
            'average': average,
            'createdAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Veículo cadastrado com sucesso!')),
          );

          _clearFormFields();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuário não autenticado!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar o veículo: $e')),
        );
      }
    }
  }

  // Método para limpar os campos do formulário
  void _clearFormFields() {
    _nameController.clear();
    _modelController.clear();
    _yearController.clear();
    _placaController.clear();
    _litersController.clear();
    _kilometrageController.clear();
    _averageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar veículo"),
      ),
      drawer: CustomDrawer(),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildTextField(_nameController, 'Nome'),
                const SizedBox(height: 10),
                _buildTextField(_modelController, 'Modelo'),
                const SizedBox(height: 10),
                _buildTextField(_yearController, 'Ano'),
                const SizedBox(height: 10),
                _buildTextField(_placaController, 'Placa'),
                const SizedBox(height: 10),
                _buildTextField(_litersController, 'Litros iniciais', isNumeric: true),
                const SizedBox(height: 10),
                _buildTextField(_kilometrageController, 'Quilometragem inicial', isNumeric: true),
                const SizedBox(height: 10),
                _buildTextField(_averageController, 'Média inicial', isNumeric: true),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Cadastrar"),
        icon: const Icon(Icons.add),
        onPressed: _addVehicle,
      ),
    );
  }

  // Método auxiliar para criar os campos de texto
  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) => value == null || value.isEmpty ? 'Informe $label' : null,
    );
  }
}
