import 'package:ventables/core/domain/entities/producto.dart';

// Modelo de Producto que mapea los datos de la API/Base de datos a objetos Dart
class ProductoModel extends Producto {
  const ProductoModel({
    required int productoId,
    required String nombre,
    required String vendedor,
    required String descripcion,
    required double precio,
    required int cantidadDisponible,
    required bool disponibleIntercambio,
    required DateTime fechaPublicacion,
    required String condicion,
    String? envio,
    String? caracteristicas,
    required int usuarioId,
    required List<String> imagenes,
    required List<String> categorias,
    required double calificacionPromedio,
    required int numeroValoraciones,
  }) : super(
          productoId: productoId,
          nombre: nombre,
          vendedor: vendedor,
          descripcion: descripcion,
          precio: precio,
          cantidadDisponible: cantidadDisponible,
          disponibleIntercambio: disponibleIntercambio,
          fechaPublicacion: fechaPublicacion,
          condicion: condicion,
          envio: envio,
          caracteristicas: caracteristicas,
          usuarioId: usuarioId,
          imagenes: imagenes,
          categorias: categorias,
          calificacionPromedio: calificacionPromedio,
          numeroValoraciones: numeroValoraciones,
        );

  // Método para crear un modelo a partir de un mapa JSON
  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      productoId: json['producto_id'],
      nombre: json['nombre'],
      vendedor: json['vendedor'],
      descripcion: json['descripcion'],
      precio: json['precio'].toDouble(),
      cantidadDisponible: json['cantidad_disponible'],
      disponibleIntercambio: json['disponible_intercambio'],
      fechaPublicacion: DateTime.parse(json['fecha_publicacion']),
      condicion: json['condicion'],
      envio: json['envio'],
      caracteristicas: json['caracteristicas'],
      usuarioId: json['usuario_id'],
      imagenes: List<String>.from(json['imagenes']),
      categorias: List<String>.from(json['categorias']),
      calificacionPromedio: json['calificacion_promedio'].toDouble(),
      numeroValoraciones: json['numero_valoraciones'],
    );
  }

  // Método para convertir el modelo a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'nombre': nombre,
      'vendedor': vendedor,
      'descripcion': descripcion,
      'precio': precio,
      'cantidad_disponible': cantidadDisponible,
      'disponible_intercambio': disponibleIntercambio,
      'fecha_publicacion': fechaPublicacion.toIso8601String(),
      'condicion': condicion,
      'envio': envio,
      'caracteristicas': caracteristicas,
      'usuario_id': usuarioId,
      'imagenes': imagenes,
      'categorias': categorias,
      'calificacion_promedio': calificacionPromedio,
      'numero_valoraciones': numeroValoraciones,
    };
  }

  // Método para crear una copia del modelo con algunos campos modificados
  ProductoModel copyWith({
    int? productoId,
    String? nombre,
    String? vendedor,
    String? descripcion,
    double? precio,
    int? cantidadDisponible,
    bool? disponibleIntercambio,
    DateTime? fechaPublicacion,
    String? condicion,
    String? envio,
    String? caracteristicas,
    int? usuarioId,
    List<String>? imagenes,
    List<String>? categorias,
    double? calificacionPromedio,
    int? numeroValoraciones,
  }) {
    return ProductoModel(
      productoId: productoId ?? this.productoId,
      nombre: nombre ?? this.nombre,
      vendedor: vendedor ?? this.vendedor,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
      disponibleIntercambio: disponibleIntercambio ?? this.disponibleIntercambio,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
      condicion: condicion ?? this.condicion,
      envio: envio ?? this.envio,
      caracteristicas: caracteristicas ?? this.caracteristicas,
      usuarioId: usuarioId ?? this.usuarioId,
      imagenes: imagenes ?? this.imagenes,
      categorias: categorias ?? this.categorias,
      calificacionPromedio: calificacionPromedio ?? this.calificacionPromedio,
      numeroValoraciones: numeroValoraciones ?? this.numeroValoraciones,
    );
  }
}
