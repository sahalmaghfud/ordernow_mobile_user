import 'package:flutter/material.dart';
import 'package:user_ordernow/models/menu_model.dart';
import 'package:user_ordernow/services/menu_service.dart';
import 'package:user_ordernow/models/pesanan_model.dart';
import 'konfirmasi_pesanan_screen.dart';

class PilihMenuScreen extends StatefulWidget {
  final String namaPel;
  final int noMeja;

  const PilihMenuScreen(
      {super.key, required this.namaPel, required this.noMeja});

  @override
  _PilihMenuScreenState createState() => _PilihMenuScreenState();
}

class _PilihMenuScreenState extends State<PilihMenuScreen> {
  final MenuService _menuService = MenuService();
  final Map<String, int> _orderQuantities = {};
  final TextEditingController _catatanController = TextEditingController();

  Widget _buildMenuCard(Menu menu) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Gambar Menu dengan Zoom
            GestureDetector(
              onTap: () {
                _showFullImageDialog(menu.gambar);
              },
              child: Hero(
                tag: menu.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    menu.gambar,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.green[700],
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Detail Menu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.nama,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    menu.deskripsi,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${_formatCurrency(menu.harga)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),

            // Kuantitas Kontrol
            Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _orderQuantities[menu.id] =
                            (_orderQuantities[menu.id] ?? 0) - 1;
                        if (_orderQuantities[menu.id]! < 0) {
                          _orderQuantities[menu.id] = 0;
                        }
                      });
                    },
                    icon:
                        Icon(Icons.remove, color: Colors.green[700], size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    '${_orderQuantities[menu.id] ?? 0}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _orderQuantities[menu.id] =
                            (_orderQuantities[menu.id] ?? 0) + 1;
                      });
                    },
                    icon: Icon(Icons.add, color: Colors.green[700], size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.green[700],
                      size: 100,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Format mata uang
  String _formatCurrency(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pilih Menu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<Menu>>(
        stream: _menuService.getMenus(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.green[700],
              ),
            );
          }

          final menuItems = snapshot.data!;
          final makanan =
              menuItems.where((menu) => menu.tipe == 'makanan').toList();
          final minuman =
              menuItems.where((menu) => menu.tipe == 'minuman').toList();

          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 100.0, top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selamat Datang Yang Terhormat , ${widget.namaPel}!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          Text(
                            'Meja ${widget.noMeja}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Makanan Section
                      _buildSectionTitle('Makanan'),
                      ...makanan.map((menu) => _buildMenuCard(menu)),

                      const SizedBox(height: 20),

                      // Minuman Section
                      _buildSectionTitle('Minuman'),
                      ...minuman.map((menu) => _buildMenuCard(menu)),

                      const SizedBox(height: 20),

                      // Catatan TextField
                      TextField(
                        controller: _catatanController,
                        decoration: InputDecoration(
                          labelText: 'Catatan Tambahan (Opsional)',
                          labelStyle: TextStyle(color: Colors.green[700]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.green[700]!,
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(
                          height: 100), // Extra space for bottom button
                    ],
                  ),
                ),
              ),

              // Floating Lanjut Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _processOrder(context, menuItems);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Lanjutkan ke Konfirmasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
        ),
      ),
    );
  }

  void _processOrder(BuildContext context, List<Menu> menuItems) {
    if (_orderQuantities.values.every((quantity) => quantity == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan pilih minimal satu menu'),
          backgroundColor: Colors.red[400],
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    List<Detail> selectedDetails =
        _orderQuantities.entries.where((entry) => entry.value > 0).map((entry) {
      final menu = menuItems.firstWhere((menu) => menu.id == entry.key);
      return Detail(
        namaMenu: menu.nama,
        quantity: entry.value,
        harga: menu.harga,
        jumlah: menu.harga * entry.value,
      );
    }).toList();

    int total = selectedDetails.fold(0, (sum, detail) => sum + detail.jumlah);

    Pesanan pesanan = Pesanan(
      namaPel: widget.namaPel,
      noMeja: widget.noMeja,
      total: total,
      statusPembayaran: 'Belum Dibayar',
      statusPesanan: 'Menunggu',
      detail: selectedDetails,
      catatan: _catatanController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KonfirmasiPesananScreen(pesanan: pesanan),
      ),
    );
  }
}
