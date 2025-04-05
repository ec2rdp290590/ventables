import 'dart:convert';
import 'package:ventables/core/domain/entities/usuario.dart';

// Modelo de Usuario que mapea los datos de la API/Base de datos a objetos Dart
class UsuarioModel extends Usuario {
  const UsuarioModel({
    required int usuarioId,
    required String nombre,
    required String apellidos,
    required String email,
    String? telefono,
    required String contrasenaHash,
    required String tipoUsuario,
    required DateTime fechaRegistro,
    required bool verificado,
    required double calificacionPromedio,
    String? fotoPerfil,
    required bool activo,
  }) : super(
          usuarioId: usuarioId,
          nombre: nombre,
          apellidos: apellidos,
          email: email,
          telefono: telefono,
          contrasenaHash: contrasenaHash,
          tipoUsuario: tipoUsuario,
          fechaRegistro: fechaRegistro,
          verificado: verificado,
          calificacionPromedio: calificacionPromedio,
          fotoPerfil: fotoPerfil,
          activo: activo,
        );

  // Método para crear un modelo a partir de un mapa JSON
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      email: json['email'],
      telefono: json['telefono'],
      contrasenaHash: json['contrasena_hash'],
      tipoUsuario: json['tipo_usuario'],
      fechaRegistro: DateTime.parse(json['fecha_registro']),
      verificado: json['verificado'],
      calificacionPromedio: json['calificacion_promedio'].toDouble(),
      fotoPerfil: json['foto_perfil'],
      activo: json['activo'],
    );
  }

  // Método para convertir el modelo a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'telefono': telefono,
      'contrasena_hash': contrasenaHash,
      'tipo_usuario': tipoUsuario,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'verificado': verificado,
      'calificacion_promedio': calificacionPromedio,
      'foto_perfil': fotoPerfil,
      'activo': activo,
    };
  }

  // Método para crear una copia del modelo con algunos campos modificados
  UsuarioModel copyWith({
    int? usuarioId,
    String? nombre,
    String? apellidos,
    String? email,
    String? telefono,
    String? contrasenaHash,
    String? tipoUsuario,
    DateTime? fechaRegistro,
    bool? verificado,
    double? calificacionPromedio,
    String? fotoPerfil,
    bool? activo,
  }) {
    return UsuarioModel(
      usuarioId: usuarioId ?? this.usuarioId,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      contrasenaHash: contrasenaHash ?? this.contrasenaHash,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      verificado: verificado ?? this.verificado,
      calificacionPromedio: calificacionPromedio ?? this.calificacionPromedio,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      activo: activo ?? this.activo,
    );
  }
}
