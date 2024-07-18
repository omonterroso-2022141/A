class Category {
  final String id;
  final String nombre;

  Category({required this.id, required this.nombre});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      nombre: json['nombre'],
    );
  }
}

