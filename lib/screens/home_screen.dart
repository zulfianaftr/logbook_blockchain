import 'package:flutter/material.dart';
import '../models/logbook_item.dart';
import 'add_logbook_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  String _txStatus = 'Siap';
  String _txDetail = '';

  Future<void> _muatUlangData() async {
    setState(() => _isLoading = true);
    try {
      // TODO (Rekan Web3): Panggil fungsi ambilData dari smart contract di sini
      await Future.delayed(const Duration(milliseconds: 600));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalDipinjam = _items.where((e) => !e.sudahKembali).length;
    final totalKembali = _items.where((e) => e.sudahKembali).length;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logbook Lab IoT',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
            Text(
              'Sepolia Testnet • On-Chain Record',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang Data',
            onPressed: _isLoading ? null : _muatUlangData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Ringkasan Statistik
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF0F766E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'Sedang Dipinjam',
                    count: totalDipinjam,
                    icon: Icons.memory_rounded,
                    accentColor: Colors.amber.shade300,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    label: 'Dikembalikan',
                    count: totalKembali,
                    icon: Icons.check_circle_outline_rounded,
                    accentColor: Colors.tealAccent.shade200,
                  ),
                ),
              ],
            ),
          ),

          // Banner Indikator Status Transaksi
          if (_txStatus != 'Siap')
            Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _txStatus == 'Memproses'
                    ? Colors.amber.shade50
                    : _txStatus == 'Berhasil'
                      ? Colors.teal.shade50
                      : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _txStatus == 'Memproses'
                      ? Colors.amber.shade300
                      : _txStatus == 'Berhasil'
                          ? Colors.teal.shade300
                          : Colors.red.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _txStatus == 'Memproses'
                        ? Icons.hourglass_top_rounded
                        : _txStatus == 'Berhasil'
                            ? Icons.verified_rounded
                            : Icons.error_outline_rounded,
                    size: 20,
                    color: _txStatus == 'Memproses'
                        ? Colors.amber.shade800
                        : _txStatus == 'Berhasil'
                            ? Colors.teal.shade800
                            : Colors.red.shade800,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$_txStatus • $_txDetail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _txStatus = 'Siap'),
                    child: const Icon(Icons.close, size: 18, color: Colors.black54),
                  )
                ],
              ),
            ),

          // Judul Bagian Daftar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Riwayat Peminjaman Alat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '${_items.length} catatan',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
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
                        ? const Center(
                            child: Text(
                              'Belum ada data peminjaman alat.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: item.sudahKembali
                                        ? Colors.grey.shade200
                                        : const Color(0xFFCCFBF1),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(9),
                                          decoration: BoxDecoration(
                                            color: item.sudahKembali
                                                ? const Color(0xFFF1F5F9)
                                                : const Color(0xFFCCFBF1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            item.sudahKembali
                                                ? Icons.check_circle_rounded
                                                : Icons.developer_board_rounded,
                                            color: item.sudahKembali
                                                ? const Color(0xFF64748B)
                                                : const Color(0xFF0F766E),
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.namaAlat,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: item.sudahKembali
                                                      ? const Color(0xFF64748B)
                                                      : const Color(0xFF0F172A),
                                                  decoration: item.sudahKembali
                                                      ? TextDecoration.lineThrough
                                                      : TextDecoration.none,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item.peminjam,
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  color: Color(0xFF475569),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: item.sudahKembali
                                                ? const Color(0xFFDCFCE7)
                                                : const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            item.sudahKembali ? 'Selesai' : 'Dipinjam',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: item.sudahKembali
                                                  ? const Color(0xFF166534)
                                                  : const Color(0xFF92400E),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.access_time_rounded,
                                                    size: 13, color: Color(0xFF64748B)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Pinjam: ${_formatWaktu(item.waktuPinjam)}',
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (item.waktuKembali != null) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.event_available_rounded,
                                                      size: 13, color: Color(0xFF0F766E)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Kembali: ${_formatWaktu(item.waktuKembali!)}',
                                                    style: const TextStyle(
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color(0xFF0F766E),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (!item.sudahKembali)
                                          FilledButton.tonalIcon(
                                            onPressed: () => _prosesKembalikanAlat(index),
                                            icon: const Icon(Icons.assignment_return_rounded,
                                                size: 16),
                                            label: const Text(
                                              'Kembalikan',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: const Color(0xFFCCFBF1),
                                              foregroundColor: const Color(0xFF0F766E),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
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
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Pinjam Alat',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required int count,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count Alat',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}