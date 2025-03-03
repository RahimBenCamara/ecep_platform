class Cours {
  final int id;
  final String titre;
  final String description;
  final int enseignantId;
  final String? fichierUrl;

  Cours({required this.id, required this.titre, required this.description, required this.enseignantId, this.fichierUrl});

  factory Cours.fromJson(Map<String, dynamic> json) {
    return Cours(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      enseignantId: json['enseignant'],
      fichierUrl: json['fichier'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
    'description': description,
    'enseignant': enseignantId,
    'fichier': fichierUrl,
  };
}