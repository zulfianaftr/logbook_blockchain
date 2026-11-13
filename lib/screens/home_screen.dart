import 'package:flutter/material.dart';
import '../services/web3_service.dart';
import 'add_logbook_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Inisialisasi penghubung ke Blockchain (Web3Service)
  final Web3Service _web3Service = Web3Service();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logbook Lab IoT (Sepolia)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // Tombol refresh manual untuk mengambil data terbaru dari blockchain
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _web3Service.fetchLogbook(),
          ),
        ],
      ),
      // AnimatedBuilder digunakan agar UI otomatis ter-update saat blockchain memproses data
      body: AnimatedBuilder(
        animation: _web3Service,
        builder: (context, child) {
          // 1. Tampilkan loading jika sedang memuat/mengirim transaksi ke blockchain
          if (_web3Service.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Memproses data di Blockchain Sepolia..."),
                ],
              ),
            );
          }

          // 2. Tampilkan pesan jika data di smart contract kosong
          if (_web3Service.logbookList.isEmpty) {
            return const Center(child: Text("Belum ada riwayat peminjaman."));
          }

          // 3. Tampilkan daftar alat dari blockchain
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _web3Service.logbookList.length,
            itemBuilder: (context, index) {
              // Ambil data map dari web3_service.dart
              final item = _web3Service.logbookList[index];
              final int id = item['id'];
              final String namaAlat = item['namaAlat'];
              final bool sudahDikembalikan = item['sudahDikembalikan'];
              
              // Konversi UNIX timestamp ke format waktu biasa
              final waktu = DateTime.fromMillisecondsSinceEpoch(item['waktuPinjam'] * 1000);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    sudahDikembalikan ? Icons.check_circle : Icons.precision_manufacturing,
                    color: sudahDikembalikan ? Colors.green : Colors.orange,
                    size: 32,
                  ),
                  title: Text(
                    namaAlat,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Waktu: ${waktu.toLocal().toString().split('.')[0]}"),
                  trailing: sudahDikembalikan
                      ? const Text(
                          "Selesai",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        )
                      : ElevatedButton.icon(
                          onPressed: () async {
                            // Eksekusi fungsi kembalikan alat ke blockchain
                            await _web3Service.kembalikanAlat(id);
                          },
                          icon: const Icon(Icons.assignment_return, size: 18),
                          label: const Text('Kembalikan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade100,
                            foregroundColor: Colors.teal.shade900,
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
      // Tombol untuk pindah ke halaman tambah peminjaman
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLogbookScreen(
                // Ini akan dipanggil saat tombol di AddLogbookScreen ditekan
                onTambahData: (namaAlat, peminjam) async {
                  // Gabungkan nama alat dan kelompok peminjam 
                  String dataKeBlockchain = '$namaAlat ($peminjam)';
                  
                  // Kirim transaksi ke blockchain
                  await _web3Service.pinjamAlat(dataKeBlockchain);
                },
              ),
            ),
          );
        },
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Pinjam Alat"),
      ),
    );
  }
}