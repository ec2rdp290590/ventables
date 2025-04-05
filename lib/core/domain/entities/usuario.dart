import 'package:equatable/equatable.dart';

// Entidad de Usuario que representa el concepto de negocio
class Usuario extends Equatable {
  final int usuarioId;
  final String nombre;
  final String apellidos;
  final String email;
  final String? telefono;
  final String contrasenaHash;
  final String tipoUsuario;
  final DateTime fechaRegistro;
  final bool verificado;
  final double calificacionPromedio;
  final String? fotoPerfil;
  final bool activo;

  const Usuario({
    required this.usuarioId,
    required this.nombre,
    required this.apellidos,
    required this.email,
    this.telefono,
    required this.contrasenaHash,
    required this.tipoUsuario,
    required this.fechaRegistro,
    required this.verificado,
    required this.calificacionPromedio,
    this.fotoPerfil,
    required this.activo,
  });

  // Método para obtener el nombre completo del usuario
  String get nombreCompleto => '$nombre $apellidos';

  // Implementación de Equatable para comparaciones de igualdad
  @override
  List<Object?> get props => [
        usuarioId,
        nombre,
        apellidos,
        email,
        telefono,
        contrasenaHash,
        tipoUsuario,
        fechaRegistro,
        verificado,
        calificacionPromedio,
        fotoPerfil,
        activo,
      ];
}
