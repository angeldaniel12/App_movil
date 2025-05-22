import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Registro extends StatefulWidget {
  const Registro({Key? key}) : super(key: key);

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nombreUsuarioController =
      TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_nombreController, "Nombre", Icons.person),
              _buildTextField(_nombreUsuarioController, "Nombre de Usuario",
                  Icons.person_outline),
              _buildTextField(
                  _correoController, "Correo Electrónico", Icons.email),
              _buildPasswordField(
                  _passwordController, "Contraseña", Icons.lock, true),
              _buildPasswordField(_confirmPasswordController,
                  "Confirmar Contraseña", Icons.lock_outline, false),
              _buildDatePickerField(),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _registerUser,
                      child: const Text("Registrarse"),
                    ),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text("Volver al login"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText:
          isPassword ? !_isPasswordVisible : !_isConfirmPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(
            isPassword
                ? (_isPasswordVisible ? Icons.visibility : Icons.visibility_off)
                : (_isConfirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
          ),
          onPressed: () {
            setState(() {
              if (isPassword) {
                _isPasswordVisible = !_isPasswordVisible;
              } else {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return TextField(
      controller: _birthDateController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: "Fecha de Nacimiento",
        prefixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _birthDateController.text =
                DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
    );
  }

  Future<void> _registerUser() async {
    if (!_validateFields()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        
        Uri.parse("http://192.168.50.54:8080//plataforma/registro.php"),
        //Uri.parse("http://10.0.2.2:8080/plataforma/registro.php"),
        // Uri.parse("http://172.20.10.2:8080/plataforma/registro.php"),
        //Uri.parse('http://127.0.0.1:8080/plataforma/registro.php'), // Cambia según tu configuración
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": _nombreController.text,
          "nombreUsuario": _nombreUsuarioController.text,
          "password": _passwordController.text,
          "email": _correoController.text,
          "fechanac": _birthDateController.text,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          responseData['message'] == 'Registro exitoso') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro exitoso")),
        );

        // Crear un mapa con los datos del usuario

        // Redirigir a la pantalla Home pasando los datos del usuario
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'nombre': _nombreController.text,
            'nombreUsuario': _nombreUsuarioController.text,
            'email': _correoController.text,
            'fechanac': _birthDateController.text,
          },
        );
      } else {
        _showError(responseData['message']);
      }
    } catch (e) {
      _showError("Error al conectar con el servidor");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateFields() {
    if (_nombreController.text.isEmpty ||
        _nombreUsuarioController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _birthDateController.text.isEmpty) {
      _showError("Por favor complete todos los campos");
      return false;
    }

    if (!_isValidEmail(_correoController.text)) {
      _showError("Correo electrónico inválido");
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Las contraseñas no coinciden");
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
