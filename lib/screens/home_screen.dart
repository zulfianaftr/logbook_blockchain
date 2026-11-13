import 'package:flutter/material.dart';
import '../models/logbook_item.dart';
import 'add_logbook_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Data simulasi sementara sebelum disambungkan ke web3dart
  final List<LogbookItem> _items = [
    LogbookItem(
      id: 0,
      namaAlat: 'ESP32 DevKit V1',
      peminjam: '0x71C...89A (Kelompok 1)',
      waktuPinjam: DateTime.now().subtract(const Duration(hours: 3)),
      sudahKembali: false,
    ),
    LogbookItem(
      id: 1,
      namaAlat: 'Sensor Ultrasonik HC-SR04',
      peminjam: '0x42B...11F (Kelompok 2)',
      waktuPinjam: DateTime.now().subtract(const Duration(days: 1)),
      waktuKembali: DateTime.now().subtract(const Duration(hours: 5)),
      sudahKembali: true,
    ),
  ];

  bool _isLoading = false;
  String _txStatus = 'Siap'; // Status: Siap | Memproses | Berhasil | Gagal
  String _txDetail = '';

  // Fungsi Refresh / Baca Data dari Kontrak
  Future<void> _muatUlangData() async {
    setState(() => _isLoading = true);
    try {
      // TODO (Rekan Web3): Panggil fungsi ambilData dari smart contract di sini
      await Future.delayed(const Duration(milliseconds: 600));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi Tambah Peminjaman Baru
  Future<void> _prosesTambahPeminjaman(String namaAlat, String peminjam) async {
    setState(() {
      _txStatus = 'Memproses';
      _txDetail = 'Mengirim transaksi peminjaman ke jaringan Sepolia...';
    });

    try {
      // TODO (Rekan Web3): Panggil fungsi tulis tambahPeminjaman di smart contract
      await Future.delayed(const Duration(seconds: 1));
      const dummyTxHash = '0x9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b';

      setState(() {
        _items.insert(
          0,
          LogbookItem(
            id: _items.length,
            namaAlat: namaAlat,
            peminjam: peminjam,
            waktuPinjam: DateTime.now(),
            sudahKembali: false,
          ),
        );
        _txStatus = 'Berhasil';
        _txDetail = 'Tx Hash: $dummyTxHash';
      });
    } catch (e) {
      setState(() {
        _txStatus = 'Gagal';
        _txDetail = 'Error: $e';
      });
    }
  }

  // Fungsi Tandai Alat Sudah Dikembalikan
  Future<void> _prosesKembalikanAlat(int index) async {
    setState(() {
      _txStatus = 'Memproses';
      _txDetail = 'Memproses pengembalian alat di blockchain...';
    });

    try {
      // TODO (Rekan Web3): Panggil fungsi tandaiKembali(id) di smart contract
      await Future.delayed(const Duration(seconds: 1));
      const dummyTxHash = '0x1f2e3d4c5b6a79887766554433221100aabbccdd';

      setState(() {
        final lama = _items[index];
        _items[index] = LogbookItem(
          id: lama.id,
          namaAlat: lama.namaAlat,
          peminjam: lama.peminjam,
          waktuPinjam: lama.waktuPinjam,
          waktuKembali: DateTime.now(),
          sudahKembali: true,
        );
        _txStatus = 'Berhasil';
        _txDetail = 'Alat dikembalikan! Tx Hash: $dummyTxHash';
      });
    } catch (e) {
      setState(() {
        _txStatus = 'Gagal';
        _txDetail = 'Error: $e';
      });
    }
  }

  String _formatWaktu(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logbook Alat Lab IoT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang Data',
            onPressed: _isLoading ? null : _muatUlangData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Indikator Status Transaksi (Wajib di Modul)
          if (_txStatus != 'Siap')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: _txStatus == 'Memproses'
                  ? Colors.amber.shade100
                  : _txStatus == 'Berhasil'
                      ? Colors.green.shade100
                      : Colors.red.shade100,
              child: Row(
                children: [
                  Icon(
                    _txStatus == 'Memproses'
                        ? Icons.hourglass_top
                        : _txStatus == 'Berhasil'
                            ? Icons.check_circle
                            : Icons.error,
                    color: _txStatus == 'Memproses'
                        ? Colors.orange.shade800
                        : _txStatus == 'Berhasil'
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '[$_txStatus] $_txDetail',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _txStatus = 'Siap'),
                  )
                ],
              ),
            ),

          // Daftar Logbook Peminjaman
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _muatUlangData,
                    child: _items.isEmpty
                        ? const Center(child: Text('Belum ada data peminjaman alat.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: Icon(
                                    item.sudahKembali
                                        ? Icons.check_box
                                        : Icons.inventory_2_outlined,
                                    color: item.sudahKembali ? Colors.green : Colors.blue,
                                  ),
                                  title: Text(
                                    item.namaAlat,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: item.sudahKembali
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Peminjam: ${item.peminjam}'),
                                      Text('Pinjam: ${_formatWaktu(item.waktuPinjam)}'),
                                      if (item.waktuKembali != null)
                                        Text(
                                          'Kembali: ${_formatWaktu(item.waktuKembali!)}',
                                          style: const TextStyle(color: Colors.green),
                                        ),
                                    ],
                                  ),
                                  trailing: item.sudahKembali
                                      ? const Chip(
                                          label: Text('Selesai', style: TextStyle(fontSize: 11)),
                                        )
                                      : ElevatedButton(
                                          onPressed: () => _prosesKembalikanAlat(index),
                                          child: const Text('Kembalikan'),
                                        ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddLogbookScreen(
                onTambahData: _prosesTambahPeminjaman,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Pinjam Alat'),
      ),
    );
  }
}