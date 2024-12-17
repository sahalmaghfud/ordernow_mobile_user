import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_ordernow/services/pesanan_service.dart'; // Services
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // YT player
import 'daftar_screen.dart'; // Halaman Awal Untuk Pesanan Selesai

class TrackPesananScreen extends StatelessWidget {
  final String pesananId;

  const TrackPesananScreen({super.key, required this.pesananId});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.deepOrange.shade400;
      case 'diproses':
        return Colors.lightBlue.shade600;
      case 'selesai':
        return Colors.green.shade600;
      case 'dibatalkan':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getPembayaranColor(String status) {
    switch (status.toLowerCase()) {
      case 'sudah bayar':
        return Colors.green.shade600;
      case 'belum dibayar':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pesananService = PesananService();
    final YoutubePlayerController youtubeController = YoutubePlayerController(
      initialVideoId: '7q7wAABkdaQ',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final pesananSnapshot =
            await pesananService.getPesananById(pesananId).first;

        if (pesananSnapshot.exists) {
          final pesananData = pesananSnapshot.data() as Map<String, dynamic>;
          final statusPesanan = pesananData['statusPesanan'];

          if (statusPesanan == 'Selesai' || statusPesanan == 'Dibatalkan') {
            Navigator.of(context).pop();
            return true;
          }
        }

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Peringatan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
                'Tidak bisa membuat pesanan baru jika pesanan saat ini belum siap. Jika ingin membuat pesanan baru silahkan gunakan device lain.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text(
            'Status Pesanan',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          backgroundColor: Colors.green.shade600,
          elevation: 0,
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: pesananService.getPesananById(pesananId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'Pesanan tidak ditemukan.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            final pesananData = snapshot.data!.data() as Map<String, dynamic>;
            final statusPembayaran =
                pesananData['statusPembayaran'] ?? 'Tidak diketahui';
            final statusPesanan =
                pesananData['statusPesanan'] ?? 'Tidak diketahui';
            final nama = pesananData['namaPel'] ?? 'Tidak diketahui';

            final detailPesanan =
                (pesananData['detail'] as List<dynamic>?)?.map((item) {
                      return {
                        'namaMenu': item['namaMenu'] ?? 'Tidak diketahui',
                        'quantity': item['quantity'] ?? 0,
                        'harga': item['harga'] ?? 0,
                        'jumlah': item['jumlah'] ?? 0,
                      };
                    }).toList() ??
                    [];

            // Check for completed order and show dialog
            if (statusPesanan == 'Selesai') {
              Future.delayed(const Duration(seconds: 1), () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Pesanan Selesai'),
                      content: const Text(
                          'Terima Kasih Telah Berkenan Hati Untuk Makan Di Tempat Kami, Sini Lagi Ya Besok :)'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DaftarScreen(),
                              ),
                            );
                          },
                          child: const Text('Ya'),
                        ),
                      ],
                    );
                  },
                );
              });
            }

            return SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            'Detail Pesanan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Name Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade50,
                                Colors.green.shade100
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person,
                                  color: Colors.green.shade600, size: 30),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  'Atas Nama: $nama',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade800,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Order Details
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ExpansionTile(
                            title: const Text(
                              'Rincian Pesanan',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87),
                            ),
                            children: detailPesanan.map((detail) {
                              return ListTile(
                                title: Text(detail['namaMenu'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                    'Qty: ${detail['quantity']} | Harga: Rp${detail['harga']}',
                                    style:
                                        TextStyle(color: Colors.grey.shade700)),
                                trailing: Text('Total: Rp${detail['jumlah']}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700)),
                              );
                            }).toList(),
                          ),
                        ),

                        // Catatan Pesanan
                        if (pesananData['catatan'] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.note, color: Colors.grey.shade600),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Catatan: ${pesananData['catatan']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Status and Queue
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatusCard(
                                title: 'Status Pembayaran',
                                status: statusPembayaran,
                                color: _getPembayaranColor(statusPembayaran),
                                icon: Icons.payment,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatusCard(
                                title: 'Status Pesanan',
                                status: statusPesanan,
                                color: _getStatusColor(statusPesanan),
                                icon: Icons.food_bank_rounded,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Queue Number
                        StreamBuilder<int>(
                          stream: pesananService.countPendingOrders(pesananId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildQueueCard('Loading...', Colors.grey);
                            } else if (snapshot.hasError) {
                              return _buildQueueCard(
                                  'Error: ${snapshot.error}', Colors.red);
                            } else if (snapshot.hasData) {
                              final nomor = snapshot.data.toString();
                              return _buildQueueCard(
                                  'Antrian Ke: $nomor', Colors.green.shade600);
                            } else {
                              return _buildQueueCard('No Data', Colors.grey);
                            }
                          },
                        ),

                        const SizedBox(height: 20),

                        // QRIS Payment
                        _buildSectionTitle('Qris Pembayaran'),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/ordernow-b2449.firebasestorage.app/o/quris.jpg?alt=media&token=c3b326da-0b75-4d6f-944c-1788545282de',
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Entertainment Video
                        _buildSectionTitle('Video Hiburan'),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: YoutubePlayer(
                              controller: youtubeController,
                              showVideoProgressIndicator: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Continuing the previous code...

  Widget _buildQueueCard(String text, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.queue, color: color),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.green.shade700,
      ),
    );
  }
}
