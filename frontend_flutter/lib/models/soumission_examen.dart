class SoumissionExamen {
  final int id;
  final int eleveId;
  final int examenId;
  final double? note;
  final String? feedback;
  final Map<String, String>? reponses;

  SoumissionExamen({required this.id, required this.eleveId, required this.examenId, this.note, this.feedback, this.reponses});

  factory SoumissionExamen.fromJson(Map<String, dynamic> json) {
    return SoumissionExamen(
      id: json['id'],
      eleveId: json['eleve'],
      examenId: json['examen'],
      note: json['note'],
      feedback: json['feedback'],
      reponses: json['reponses'] != null ? Map<String, String>.from(json['reponses']) : null,
    );
  }
}