import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

final HttpClient httpClient = HttpClient()
  ..badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Permite certificados no válidos

final ioClient = IOClient(httpClient);
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

Future<void> iniciarSesion() async {
  // Verifica si los campos no están vacíos
  if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor, completa todos los campos'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;  // Activamos el cargador 192.168.1.81
  });

  try {
    final response = await http.post(
      Uri.parse("http://192.168.50.153:8080/plataforma/login.php"),  // URL para compartir internet

      //Uri.parse("http://169.254.191.190:8080/plataforma/login.php"),  // URL para compartir internet
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
      }),
    ).timeout(const Duration(seconds: 10));  // Le ponemos un timeout para evitar que se quede colgado

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Si la respuesta es exitosa, guardamos los datos del usuario
      if (data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('usuario', jsonEncode(data['usuario']));
        FocusScope.of(context).unfocus();
        Navigator.pushReplacementNamed(context, '/home');

      } else {
        // Si no fue exitoso, mostramos el mensaje de error devuelto por el servidor
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Error general del servidor
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error del servidor: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on http.ClientException catch (e) {
    debugPrint("Error HTTPS: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error al conectar con el servidor'),
        backgroundColor: Colors.red,
      ),
    );
  } on TimeoutException {
    // Manejo de timeout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La solicitud tardó demasiado tiempo'),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    // Error inesperado
    debugPrint("Error desconocido: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ocurrió un error inesperado'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isLoading = false;  // Desactivamos el cargador
    });
  }
}


@override
Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;

  return Scaffold(
    resizeToAvoidBottomInset: true, // Esto hace que la vista se ajuste al teclado
    body: SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
         
          _cajaMorado(size),
           Padding(
            padding: const EdgeInsets.only(top: 50.0), // Ajusta el espacio superior
            child: Image.asset(
              'assets/images/logo-Photoroom.png',
              width: 550,  // Ajusta el tamaño según lo necesites
              height: 230,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 200), // Espacio para que no se solape la imagen
                  _cajaLogin(context),
                  const SizedBox(height: 20),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    disabledColor: Colors.grey,
                    color: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      child: const Text('Registrar cuenta',
                          style: TextStyle(color: Colors.black)),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, 'registro');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  Container _cajaLogin(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      width: double.infinity,
      height: 430,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            'Login',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _emailController,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE86CA6)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE86CA6), width: 2),
              ),
              hintText: 'ejemplo@gmail.com',
              labelText: 'Correo electrónico',
              icon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _passwordController,
            autocorrect: false,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE86CA6)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE86CA6), width: 2),
              ),
              hintText: 'Contraseña',
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_clock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFFE86CA6),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 50),
          _isLoading
              ? const CircularProgressIndicator()
              : MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledColor: Colors.grey,
                  color: const Color(0xFFE86CA6),
                  onPressed: iniciarSesion,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Container _cajaMorado(Size size) {
    return Container(
      color: const Color(0xFFE86CA6),
      width: double.infinity,
      height: size.height * 0.4,
    );
  }
}
