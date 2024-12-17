import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_ordernow/models/pesanan_model.dart';

class PesananService {
  final CollectionReference _pesananCollection =
      FirebaseFirestore.instance.collection('pesanan');

  Stream<DocumentSnapshot> getPesananById(String pesananId) {
    return _pesananCollection.doc(pesananId).snapshots();
  }

  // Create Pesanan
  Future<String> createPesanan(Pesanan pesanan) async {
    try {
      // Konversi objek Pesanan menjadi Map untuk disimpan di Firestore
      final pesananData = pesanan.toJson();

      // Tambahkan data ke koleksi 'pesanan' dan simpan referensi dokumen
      DocumentReference docRef = await _pesananCollection.add(pesananData);

      // Kembalikan document ID
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create pesanan: $e');
    }
  }

  Stream<int> countPendingOrders(String pesananId) async* {
    try {
      // Ambil dokumen pesanan berdasarkan ID
      DocumentSnapshot pesananDoc =
          await _pesananCollection.doc(pesananId).get();

      if (!pesananDoc.exists) {
        throw Exception('Pesanan dengan ID $pesananId tidak ditemukan.');
      }

      // Ambil nilai createdAt dari dokumen pesanan
      final pesananData = pesananDoc.data() as Map<String, dynamic>;
      final Timestamp createdAt = pesananData['createdAt'];

      // Stream query untuk menghitung dokumen dengan kondisi
      yield* _pesananCollection
          .where('statusPesanan', isNotEqualTo: 'Selesai')
          .where('createdAt', isLessThan: createdAt)
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs.length + 1);
    } catch (e) {
      throw Exception('Gagal menghitung jumlah pesanan: $e');
    }
  }
}
