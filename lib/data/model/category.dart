class Category {
  final String? id;
  final String name;
  final String? icon;
  final String color;
  final String type; // 'income' or 'expense'

  Category({
    this.id,
    required this.name,
    this.icon,
    required this.color,
    required this.type,
  });

  @override
  String toString() {
    return 'Category{id: $id, name: $name, icon: $icon, color: $color}';
  }

  Category copy({
    String? id,
    String? name,
    String? icon,
    String? color,
    String? type,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'icon': icon, 'color': color, 'type': type};
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      type: map['type'] ?? 'expense', // Default to expense if not specified
    );
  }
}
