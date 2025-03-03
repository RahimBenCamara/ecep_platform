class Examen {
  final int id;
  final String titre;
  final String typeExamen;
  final int coursId;
  final int duree;

  Examen({required this.id, required this.titre, required this.typeExamen, required this.coursId, required this.duree});

  factory Examen.fromJson(Map<String, dynamic> json) {
    return Examen(
      id: json['id'],
      titre: json['titre'],
      typeExamen: json['type_examen'],
      coursId: json['cours'],
      duree: json['duree'],
    );
  }
}