import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iidlive_app/models/usuarioperfil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({Key? key}) : super(key: key);

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late TextEditingController nombreController;
  late TextEditingController usuarioController;
  late TextEditingController emailController;
  late TextEditingController direccionController;
  late TextEditingController paisController;
  late TextEditingController ciudadController;
  late TextEditingController codigopostalController;
  late TextEditingController descripcionController;

  File? _imagen;
  String? _rutaImagen;
  Usuario? usuario; // Cambié el tipo de Map<String, dynamic> a Usuario

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    usuario = ModalRoute.of(context)!.settings.arguments as Usuario?; // Usamos Usuario

    // Ahora, inicializa los controladores con los valores de usuario
    nombreController = TextEditingController(text: usuario?.nombre ?? '');
    usuarioController = TextEditingController(text: usuario?.nombreUsuario ?? '');
    emailController = TextEditingController(text: usuario?.email ?? '');
    direccionController = TextEditingController(text: usuario?.direccion ?? '');
    paisController = TextEditingController(text: usuario?.pais ?? '');
    ciudadController = TextEditingController(text: usuario?.ciudad ?? '');
    codigopostalController = TextEditingController(text: usuario?.codigoPostal ?? '');
    descripcionController = TextEditingController(text: usuario?.descripcion ?? '');
    _rutaImagen = usuario?.fotos; // Ruta actual de la imagen
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagenSeleccionada = await picker.pickImage(source: ImageSource.gallery);

    if (imagenSeleccionada != null) {
      setState(() {
        _imagen = File(imagenSeleccionada.path);
      });
    }
  }

Future<void> _subirImagen() async {
  if (_imagen == null) return;

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('http://192.168.50.153:8080/plataforma/editar.php'),
  );

  request.files.add(await http.MultipartFile.fromPath('imagen', _imagen!.path));
  request.fields['id'] = usuario!.id.toString();

  try {
    final response = await request.send();
    final responseData = jsonDecode(await response.stream.bytesToString());

    if (response.statusCode == 200 && responseData['status'] == 'success') {
      setState(() {
        _rutaImagen = responseData['url']; // Aquí recibes la URL completa
      });
    } else {
      _mostrarError(responseData['message'] ?? 'Error al subir la imagen');
    }
  } catch (e) {
    _mostrarError('No se pudo conectar al servidor');
  }
}
Widget _buildImage() {
  // Si hay una imagen seleccionada desde la galería
  if (_imagen != null) {
    return Image.file(_imagen!); // Mostrar imagen local
  } 
  // Si la ruta de la imagen es válida y comienza con "http"
  else if (_rutaImagen != null && _rutaImagen!.isNotEmpty && _rutaImagen!.startsWith('http')) {
    return Image.network(_rutaImagen!); // Mostrar imagen desde la URL
  } 
  // Si no hay imagen seleccionada ni URL válida
  else {
    return Image.asset('assets/default_profile.png'); // Imagen por defecto
  }
}


Future<void> _guardarCambios() async {
  if (usuario == null || usuario!.id == null) {
    _mostrarError('No se ha recibido el ID del usuario');
    return;
  }

  await _subirImagen(); // Subimos la imagen antes de guardar los cambios

  final usuarioActualizado = {
    'id': usuario!.id, // Aseguramos que tenemos el ID correcto
    'nombre': nombreController.text,
    'nombreusuario': usuarioController.text,
    'direccion': direccionController.text,
    'pais': paisController.text,
    'ciudad': ciudadController.text,
    'codigopostal': codigopostalController.text,
    'descripcion': descripcionController.text,
    'fotos': _rutaImagen ?? usuario!.fotos, // Aseguramos que la imagen esté incluida
  };

  print("Datos enviados: $usuarioActualizado"); // Agrega esto para verificar los datos enviados

  try {
    final response = await http.post(
      Uri.parse('http://172.20.10.2:8080/plataforma/editar.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(usuarioActualizado),
    );

    final responseData = jsonDecode(response.body);

    print("Respuesta del servidor: $responseData"); // Agrega esto para ver la respuesta

    if (response.statusCode == 200 && responseData['status'] == 'success') {
      // Mostrar mensaje de éxito en un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil actualizado con éxito')),
      );
      Navigator.pop(context, usuario); // Navegamos con el objeto Usuario
    } else {
      _mostrarError(responseData['message'] ?? 'Error al guardar datos');
    }
  } catch (e) {
    _mostrarError('No se pudo conectar al servidor');
  }
}

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _seleccionarImagen,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imagen != null
                    ? FileImage(_imagen!)
                    : (_rutaImagen != null
                        ? NetworkImage(_rutaImagen!)
                        : AssetImage('assets/default_profile.png')) as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('Nombre', nombreController),
            _buildTextField('Nombre de usuario', usuarioController),
            _buildTextField('Correo electrónico', emailController, enabled: false),
            _buildTextField('Dirección', direccionController),
            _buildTextField('País', paisController),
            _buildTextField('Ciudad', ciudadController),
            _buildTextField('Código Postal', codigopostalController),
            _buildTextField('Descripción', descripcionController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarCambios,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        enabled: enabled,
      ),
    );
  }
}
