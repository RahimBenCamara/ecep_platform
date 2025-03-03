import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';

class MessageScreen extends StatelessWidget {
  final TextEditingController _destinataireController = TextEditingController();
  final TextEditingController _contenuController = TextEditingController();

  MessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Messagerie')),
      body: Column(
        children: [
          ElevatedButton(onPressed: () => messageProvider.fetchMessages(), child: Text('Charger les messages')),
          Expanded(
            child: ListView.builder(
              itemCount: messageProvider.messages.length,
              itemBuilder: (context, index) {
                final message = messageProvider.messages[index];
                return ListTile(
                  title: Text(message.contenu),
                  subtitle: Text('De: ${message.expediteurId} - À: ${message.destinataireId} - ${message.lu ? "Lu" : "Non lu"}'),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _destinataireController, decoration: InputDecoration(labelText: 'Destinataire ID'))),
                Expanded(child: TextField(controller: _contenuController, decoration: InputDecoration(labelText: 'Message'))),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    await messageProvider.sendMessage(int.parse(_destinataireController.text), _contenuController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}