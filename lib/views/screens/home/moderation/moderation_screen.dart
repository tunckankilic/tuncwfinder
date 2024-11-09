import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ModerationPanel extends StatelessWidget {
  const ModerationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Moderasyon Paneli')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('moderation')
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Kullanıcı ID: ${data['userId']}'),
                  subtitle: Text('Rapor Sayısı: ${data['reportCount']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _handleModeration(doc.id, 'approved'),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _handleModeration(doc.id, 'rejected'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleModeration(String moderationId, String decision) async {
    try {
      await FirebaseFirestore.instance
          .collection('moderation')
          .doc(moderationId)
          .update({
        'status': decision,
        'moderatedAt': FieldValue.serverTimestamp(),
      });

      // for approved actions
      if (decision == 'approved') {
        // user block or much more
      }
    } catch (e) {
      print('Moderasyon işlemi başarısız: $e');
    }
  }
}
