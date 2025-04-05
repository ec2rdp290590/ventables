import 'package:equatable/equatable.dart';

// Entidad de Producto que representa el concepto de negocio
class Producto extends Equatable {
  final int productoId;
  final String nombre;
  final String vendedor;
  final String descripcion;
  final double precio;
  final int cantidadDisponible;
  final bool disponibleIntercambio;
  final DateTime fechaPublicacion;
  final String condicion;
  final String? envio;
  final String? caracteristicas;
  final int usuarioId;
  final List<String> imagenes;
  final List<String> categorias;
  final double calificacionPromedio;
  final int numeroValoraciones;

  const Producto({
    required this.productoId,
    required this.nombre,
    required this.vendedor,
    required this.descripcion,
    required this.precio,
    required this.cantidadDisponible,
    required this.disponibleIntercambio,
    required this.fechaPublicacion,
    required this.condicion,
    this.envio,
    this.caracteristicas,
    required this.usuarioId,
    required this.imagenes,
    required this.categorias,
    required this.calificacionPromedio,
    required this.numeroValoraciones,
  });

  // Método para verificar si el producto está disponible
  bool get estaDisponible => cantidadDisponible > 0;

  // Método para verificar si el producto tiene descuento
  bool get tieneDescuento => false; // Se implementaría la lógica de descuentos

  // Implementación de Equatable para comparaciones de igualdad
  @override
  List<Object?> get props => [
        productoId,
        nombre,
        vendedor,
        descripcion,
        precio,
        cantidadDisponible,
        disponibleIntercambio,
        fechaPublicacion,
        condicion,
        envio,
        caracteristicas,
        usuarioId,
        imagenes,
        categorias,
        calificacionPromedio,
        numeroValoraciones,
      ];
}
