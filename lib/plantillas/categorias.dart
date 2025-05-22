import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iidlive_app/plantillas/Perfil_user.dart';

class CrearCategoriaScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> usuario;

  CrearCategoriaScreen({required this.userId, this.usuario = const {}});

  @override
  _CrearCategoriaScreenState createState() => _CrearCategoriaScreenState();
}

class _CrearCategoriaScreenState extends State<CrearCategoriaScreen> {
  final TextEditingController _nombreCategoriaController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        //Uri.parse("http://10.0.2.2:8080/plataforma/categorias.php") //android
        //Uri.parse("http://127.0.0.1:8080/plataforma/categorias.php"), //apple
         Uri.parse("http://172.20.10.2:8080/plataforma/categorias.php"), 
         //Uri.parse('http://172.20.10.2:8080/plataforma/categorias.php'),
        //Uri.parse('http://192.168.50.54:8080/plataforma/categorias.php'),

      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data['categorias'] != null) {
          setState(() {
            _categories = List<Map<String, dynamic>>.from(data['categorias']);
          });
        } else {
          throw Exception("La respuesta no contiene categorías.");
        }
      } else {
        throw Exception("Error al obtener las categorías.");
      }
    } catch (e) {
      _showError("Error al obtener categorías: $e");
    }
  }

  Future<void> _crearCategoria() async {
    final nombreCategoria = _nombreCategoriaController.text.trim();

    if (nombreCategoria.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor ingrese un nombre válido para la categoría."),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        //Uri.parse("http://10.0.2.2:8080/plataforma/categorias_crear.php"),
        //Uri.parse("http://127.0.0.1:8080/plataforma/categorias_crear.php"), 
        //  Uri.parse("http://172.20.10.2:8080/plataforma/categorias_crear.php"),

        // Uri.parse("http://192.168.1.81:8080/plataforma/categorias_crear.php"),
         Uri.parse("http://172.20.10.2:8080/plataforma/categorias_crear.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nameCategoria": nombreCategoria}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        _nombreCategoriaController.clear();
        _fetchCategories();
      } else {
        _showError(responseData['error'] ?? "Error desconocido");
      }
    } catch (e) {
      _showError("Error al conectar con el servidor: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Categoría")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
  accountName: Text(widget.usuario['nombre'] ?? 'Usuario'),
  accountEmail: Text(widget.usuario['email'] ?? 'user@example.com'),
  currentAccountPicture: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PerfilScreen()),
      );
    },
    child: CircleAvatar(
      backgroundColor: Colors.white,
      child: Text(
        widget.usuario['nombre'] != null && widget.usuario['nombre'].isNotEmpty
            ? widget.usuario['nombre'][0].toUpperCase()
            : 'U',
        style: const TextStyle(fontSize: 40, color: Colors.black),
      ),
    ),
  ),
),

            // UserAccountsDrawerHeader(
            //   accountName: Text(widget.usuario['nombre'] ?? 'Usuario'),
            //   accountEmail: Text(widget.usuario['email'] ?? 'user@example.com'),
            //   currentAccountPicture: CircleAvatar(
            //     backgroundColor: Colors.white,
            //     child: Text(
            //       widget.usuario['nombre']?.substring(0, 1).toUpperCase() ?? 'U',
            //       style: const TextStyle(fontSize: 40, color: Colors.black),
            //     ),
            //   ),
            // ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Página de Inicio'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home', arguments: widget.usuario);
              },
            ),
          //   ListTile(
          //   leading: const Icon(Icons.home),
          //   title: const Text('lives'),
          //   onTap: () {
          //     Navigator.pushReplacementNamed(context, '/lives');
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.home),
          //   title: const Text('Salas'),
          //   onTap: () {
          //     Navigator.pushReplacementNamed(context, '/salas');
          //   },
          // ),
            ListTile(
              leading: const Icon(Icons.mediation),
              title: const Text('Página de Reels'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/reels');
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('Página de Post'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/post');
              },
            ),
            /*ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Crear Categoría'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/crear_categoria');
              },
            ),*/
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuraciones'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              _nombreCategoriaController,
              "Nombre de la Categoría",
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _crearCategoria,
                    child: const Text("Crear Categoría"),
                  ),
            const SizedBox(height: 30),
            const Text(
              "Categorías Creadas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _categories.isEmpty
                ? const Text("No hay categorías disponibles.")
                : Expanded(
                    child: ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final name = category['nameCategoria'];
                        return ListTile(
                          title: Text(name ?? "Categoría sin nombre"),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }
}
