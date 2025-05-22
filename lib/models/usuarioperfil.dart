class Usuario {
  final int? id;
  final String nombre;
  final String nombreUsuario;
  final String email;
  final String direccion;
  final String ciudad;
  final String pais;
  final String codigoPostal;
  final String descripcion;
  final String fotos;
    
  Usuario({
    this.id,
    required this.nombre,
    required this.nombreUsuario,
    required this.email,
    required this.direccion,
    required this.ciudad,
    required this.pais,
    required this.codigoPostal,
    required this.descripcion,
    required this.fotos,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      nombre: json['nombre']?.toString() ?? '',
      nombreUsuario: json['nombre_usuario']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      ciudad: json['ciudad']?.toString() ?? '',
      pais: json['pais']?.toString() ?? '',
      codigoPostal: json['codigo_postal']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      fotos: json['fotos']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nombre_usuario': nombreUsuario,
      'email': email,
      'direccion': direccion,
      'ciudad': ciudad,
      'pais': pais,
      'codigo_postal': codigoPostal,
      'descripcion': descripcion,
      'fotos': fotos,
    };
  }
}


