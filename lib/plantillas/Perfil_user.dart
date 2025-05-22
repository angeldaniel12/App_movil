import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/usuarioperfil.dart';
import 'package:iidlive_app/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error al cargar los datos'));
        } else {
          final usuario = Usuario.fromJson(jsonDecode(snapshot.data!));

          return Scaffold(
            appBar: AppBar(
              title: const Text('Perfil de Usuario'),
              backgroundColor: const Color(0xFFC17C9C),
            ),
            drawer: CustomDrawer(
              usuario: usuario,
              parentContext: context,
              onLogout: () => _logout(context),
            ),
            body: Column(
              children: [
                // Cabecera con el fondo y la foto del usuario
                Container(
                  color: const Color(0xFFC17C9C),
                  height: MediaQuery.of(context).size.height *
                      0.3, // Ajuste de altura
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: const Color.fromARGB(255, 158, 50, 50),
                      backgroundImage:
                          (usuario.fotos.isNotEmpty)
                              ? NetworkImage(
                                  usuario.fotos.startsWith('http')
                                      ? usuario.fotos
                                      : 'http://192.168.50.153:8080/${usuario.fotos}',
                                )
                              : null,
                      child: (usuario.fotos.isEmpty)
                          ? Text(
                              (usuario.nombre.isNotEmpty)
                                  ? usuario.nombre[0].toUpperCase()
                                  : 'N',
                              style: const TextStyle(
                                fontSize: 100,
                                color: Color.fromARGB(255, 119, 29, 29),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Información del usuario
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text('Nombre: ${usuario.nombre }',
                          style: const TextStyle(fontSize: 18)),
                      Text(
                          'Nombre de usuario: ${usuario.nombreUsuario}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 5),
                      Text('Correo: ${usuario.email }',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.grey)),
                      Text('Dirección: ${usuario.direccion }',
                          style: const TextStyle(fontSize: 18)),
                      Text('País: ${usuario.pais }',
                          style: const TextStyle(fontSize: 18)),
                      Text('Ciudad: ${usuario.ciudad }',
                          style: const TextStyle(fontSize: 18)),
                      Text(
                          'Código Postal: ${usuario.codigoPostal }',
                          style: const TextStyle(fontSize: 18)),
                      Text(
                          'Descripción: ${usuario.descripcion }',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/editar',
                            arguments: usuario,
                          );

                          if (result != null && result is Usuario) {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString(
                                'usuario', jsonEncode(result.toJson()));
                          } else {
                            debugPrint(
                                'Tipo inesperado: ${result.runtimeType}');
                          }
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text('Editar Perfil',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFC17C9C), // Color personalizado (puedes cambiarlo)
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<String?> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario');
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
