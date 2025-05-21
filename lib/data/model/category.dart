class Category {
  final String id;
  final String name;
  final String? type;
  final String? icon;
  final String color;

  Category({
    required this.id,
    required this.name,
    this.type,
    this.icon,
    required this.color,
  });

  @override
  String toString() {
    return 'Category{id: $id, name: $name, type: $type, icon: $icon, color: $color}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
    };
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
      color: map['color'],
    );
  }
}