class TagModel {
  final String id;
  final String name;
  final String color; // Stored as a string name or hex

  TagModel({
    required this.id,
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
    };
  }

  factory TagModel.fromMap(Map<String, dynamic> map, String docId) {
    return TagModel(
      id: docId,
      name: map['name'] ?? '',
      color: map['color'] ?? 'blue',
    );
  }
}
