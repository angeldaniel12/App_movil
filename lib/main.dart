import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iidlive_app/plantillas/home.dart';
import 'package:iidlive_app/plantillas/login.dart';
import 'package:iidlive_app/plantillas/registro.dart';
import 'package:iidlive_app/plantillas/reels.dart'; // Asegúrate de importar la página de SubirReel
import 'package:iidlive_app/plantillas/post.dart';
import 'package:iidlive_app/plantillas/categorias.dart';
import 'package:iidlive_app/plantillas/lives.dart';
import 'package:iidlive_app/plantillas/todo_lives.dart';
import 'package:iidlive_app/plantillas/reelss.dart';
import 'package:iidlive_app/plantillas/Perfil_user.dart';
import 'package:iidlive_app/plantillas/editar_perfil.dart';

void main() {
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
      ],
      locale: const Locale('es', 'ES'),
       
      routes: {
        'login': (context) => Login(),
        '/home': (context) => FutureBuilder<Map<String, dynamic>>(
  future: _getUserData(),  // Cargar datos del usuario desde SharedPreferences
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError || !snapshot.hasData) {
      return const Center(child: Text('Error al cargar los datos'));
    } else {
      try {
        final usuario = snapshot.data!;  // Asegúrate de que los datos sean válidos
        return Home(usuario: usuario);  // Pasa los datos a Home
      } catch (e) {
        return const Center(child: Text('Error al parsear los datos del usuario'));
      }
    }
  },
),



        'registro': (context) => Registro(),
        '/lives' : (context) => LiveStreamingPage(),
        '/salas' : (context)=> LiveStreamingPages(),
       '/perfil': (context) => PerfilScreen(), // Asegúrate de pasar el userId aquí
        '/editar' : (context) => EditarPerfilScreen(),
        '/vistaReels': (context) => ReelsScreen(), // Agrega la pantalla de reels
        '/login': (context) => Login(), // Ruta para el login
        '/reels': (context) => FutureBuilder<Map<String, dynamic>>(
          
  future: _getUserData(),  // Cargar los datos del usuario desde SharedPreferences
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator()); // Mientras se cargan los datos
    } else if (snapshot.hasError || !snapshot.hasData) {
      return const Center(child: Text('Error al cargar los datos del usuario'));
    } else {
      final usuario = snapshot.data!; // Datos del usuario cargados
      return SubirReelPage(userId: usuario['id'], usuario: usuario);
    }
  },
),
 // Cambié de SubirReelPag a SubirReelPage
    '/post': (context) => FutureBuilder<Map<String, dynamic>>(
  future: _getUserData(),  // Cargar los datos del usuario desde SharedPreferences
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());  // Mientras se cargan los datos
    } else if (snapshot.hasError || !snapshot.hasData) {
      return const Center(child: Text('Error al cargar los datos del usuario'));
    } else {
      final usuario = snapshot.data!;  // Datos del usuario cargados
      return CreatePostPage(userId: usuario['id'], usuario: usuario);
    }
  },
),


        '/crear_categoria': (context) => FutureBuilder<Map<String, dynamic>>(
  future: _getUserData(),  // Cargar los datos del usuario desde SharedPreferences
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());  // Mientras se cargan los datos
    } else if (snapshot.hasError || !snapshot.hasData) {
      return const Center(child: Text('Error al cargar los datos del usuario'));
    } else {
      final usuario = snapshot.data!;  // Datos del usuario cargados
      return CrearCategoriaScreen(userId: usuario['id'], usuario: usuario);
    }
  },
), 
      },
      
      initialRoute: 'login',
    );
  }
Future<Map<String, dynamic>> _getUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('usuario'); // Cargar los datos del usuario guardados
    
    if (userData != null) {
      return jsonDecode(userData); // Decodificar los datos guardados en formato JSON
    } else {
      throw Exception("No se encontraron datos del usuario");
    }
  } catch (e) {
    throw Exception("Error al obtener los datos del usuario: $e");
  }
}

  
}
