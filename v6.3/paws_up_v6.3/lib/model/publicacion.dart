class Publicacion {
  final String id;
  final String autor;
  final String descripcion;
  final String horaPublicado;
  final List<String> imagenes;
  final List<String> likes;
  final List<String> dislikes;

  Publicacion({
    required this.id,
    required this.autor,
    required this.descripcion,
    required this.horaPublicado,
    required this.imagenes,
    required this.likes,
    required this.dislikes,
  });

  factory Publicacion.fromJson(Map<String, dynamic> json) {
    return Publicacion(
      id: json['_id'],
      autor: json['autor'],
      descripcion: json['descripcion'],
      horaPublicado: json['horaPublicado'],
      imagenes: List<String>.from(json['imagenes']),
      likes: List<String>.from(json['like']),
      dislikes: List<String>.from(json['dislike']),
    );
  }

  get comentarios => null;
}
