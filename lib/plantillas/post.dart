import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iidlive_app/models/usuarioperfil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:iidlive_app/widgets/custom_drawer.dart';

class CreatePostPage extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> usuario;

  CreatePostPage({required this.userId, this.usuario = const {}});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();

  static CreatePostPage fromArguments(Map<String, dynamic> args) {
    return CreatePostPage(
      userId: args['userId'] ?? 0,
      usuario: args['usuario'] ?? {},
    );
  }
}

class _CreatePostScreenState extends State<CreatePostPage> {
  final TextEditingController _descripcionController = TextEditingController();
  File? _image;
  int? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  
 

  @override
  void initState() {
    super.initState();
    print(widget.usuario);
     // Verificar los datos del usuario
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.50.153:8080/plataforma/get_categorias.php"));

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
        throw Exception("Error al obtener las categorías. Código: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al obtener categorías: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> createPost({
    required String descripcion,
    required int categoriaId,
    required int userId,
    File? image,
  }) async {
    final uri = Uri.parse("http://192.168.50.153:8080/plataforma/post.php");
    var request = http.MultipartRequest('POST', uri)
      ..fields['content'] = descripcion
      ..fields['category_id'] = categoriaId.toString()
      ..fields['user_id'] = userId.toString();

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final result = jsonDecode(responseData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['mensaje'])),
      );
    } else {
      throw Exception("Error al crear el post.");
    }
  }

  Future<void> _handleCreatePost() async {
    String descripcion = _descripcionController.text.trim();

    if (descripcion.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios.")),
      );
      return;
    }

    try {
      await createPost(
        descripcion: descripcion,
        categoriaId: _selectedCategory!,
        userId: widget.userId,
        image: _image,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post creado con éxito.")),
      );

      setState(() {
        _descripcionController.clear();
        _selectedCategory = null;
        _image = null;
      });
    } catch (e) {
      print("Error al crear el post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear el post: $e")),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Post"),
        backgroundColor: const Color(0xFFC17C9C),
      ),
      drawer: CustomDrawer(
         usuario: Usuario.fromJson(widget.usuario),
        parentContext: context,
        onLogout: () => _logout(context),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.teal.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  hintText: 'Escribe algo interesante...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              const Text("Selecciona una categoría", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _categories.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFFC17C9C)),
                      ),
                      child: DropdownButtonFormField<int>(
                        value: _selectedCategory,
                        decoration: InputDecoration.collapsed(hintText: ""),
                        hint: Text("Selecciona una categoría"),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                        items: _categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: int.parse(cat["id"].toString()),
                            child: Text(cat["nameCategoria"]),
                          );
                        }).toList(),
                      ),
                    ),
              const SizedBox(height: 20),
              Center(
                child: _image == null
                    ? Text("No se ha seleccionado ninguna imagen.")
                    : Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Seleccionar Imagen"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC17C9C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _handleCreatePost,
                        icon: const Icon(Icons.send),
                        label: const Text("Crear Post"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC17C9C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
