class Message {
  final int id;
  final int expediteurId;
  final int destinataireId;
  final String contenu;
  final String dateEnvoi;
  final bool lu;

  Message({required this.id, required this.expediteurId, required this.destinataireId, required this.contenu, required this.dateEnvoi, required this.lu});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      expediteurId: json['expediteur'],
      destinataireId: json['destinataire'],
      contenu: json['contenu'],
      dateEnvoi: json['date_envoi'],
      lu: json['lu'],
    );
  }
}