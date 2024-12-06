import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_ordernow/models/menu_model.dart';

class MenuService {
  final CollectionReference _menuCollection =
      FirebaseFirestore.instance.collection('menu');

  // Read
  Stream<List<Menu>> getMenus() {
    return _menuCollection
        .where('status',
            isEqualTo: 'tersedia') // Filter hanya status 'Tersedia'
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Menu.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }
}
