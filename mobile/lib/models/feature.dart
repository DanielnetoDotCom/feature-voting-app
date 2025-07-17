class Feature {
  final int id;
  final String title;
  final String? description;
  final int votes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Feature({
    required this.id,
    required this.title,
    this.description,
    required this.votes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      votes: json['votes'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'votes': votes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Feature copyWith({
    int? id,
    String? title,
    String? description,
    int? votes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Feature(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      votes: votes ?? this.votes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Feature(id: $id, title: $title, votes: $votes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Feature && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
