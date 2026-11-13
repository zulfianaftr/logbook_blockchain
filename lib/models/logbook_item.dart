class LogbookItem {
  final int id;
  final String namaAlat;
  final String peminjam;
  final DateTime waktuPinjam;
  final DateTime? waktuKembali;
  final bool sudahKembali;

  LogbookItem({
    required this.id,
    required this.namaAlat,
    required this.peminjam,
    required this.waktuPinjam,
    this.waktuKembali,
    required this.sudahKembali,
  });
}