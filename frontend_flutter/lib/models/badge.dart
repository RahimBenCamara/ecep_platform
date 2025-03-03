class Badge {
  final int id;
  final String nom;
  final String description;
  final String critere;

  Badge({required this.id, required this.nom, required this.description, required this.critere});

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      critere: json['critere'],
    );
  }
}

class AttributionBadge {
  final int id;
  final int userId;
  final Badge badge;
  final String dateObtention;

  AttributionBadge({required this.id, required this.userId, required this.badge, required this.dateObtention});

  factory AttributionBadge.fromJson(Map<String, dynamic> json) {
    return AttributionBadge(
      id: json['id'],
      userId: json['user'],
      badge: Badge.fromJson(json['badge']),
      dateObtention: json['date_obtention'],
    );
  }
}