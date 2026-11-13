# Logbook Peminjaman Alat Lab IoT (Blockchain dApp)

Aplikasi mobile berbasis Flutter yang terintegrasi dengan jaringan Ethereum Sepolia Testnet untuk mencatat riwayat peminjaman dan pengembalian perangkat laboratorium IoT secara transparan, permanen (*immutable*), dan terdesentralisasi menggunakan *Smart Contract* Solidity.

---

## Anggota Kelompok & Pembagian Tugas
* Robin Hermanto (NIM:246661008) — Pengembangan & deployment Smart Contract Solidity ke Sepolia Testnet, integrasi RPC & transaksi Web3 menggunakan `web3dart`.
* Najwa Zulfiana Fitri (NIM: 246661028) — Perancangan UI/UX Flutter, manajemen repositori GitHub, keamanan konfigurasi lingkungan (`.env` & `.gitignore`), serta dokumentasi dan video demo.

---

## Informasi Smart Contract (Sepolia Testnet)
* Jaringan: Ethereum Sepolia Testnet (`Chain ID: 11155111`)
* Contract Address: `0x2A23D5BfD63f6Ed04AFB56407c38177E6A44010e`
* Sepolia Etherscan: (https://sepolia.etherscan.io/address/0x2A23D5BfD63f6Ed04AFB56407c38177E6A44010e)

---

## Fitur Utama Aplikasi
1. Ringkasan Statistik Real-Time: Menampilkan jumlah perangkat IoT yang sedang dipinjam dan yang telah dikembalikan.
2. Riwayat Logbook On-Chain: Membaca daftar peminjaman alat beserta status pengembalian langsung dari smart contract.
3. Catat Peminjaman Baru: Mengirim transaksi pencatatan peminjaman alat baru ke jaringan Sepolia.
4. Tandai Alat Dikembalikan: Memperbarui status peminjaman alat menjadi selesai melalui transaksi smart contract.
5. Indikator Status & Hash Transaksi: Menampilkan status proses transaksi (Memproses, Berhasil, atau Gagal) beserta Transaction Hash.

---

## Teknologi & Paket Utama
* Flutter & Dart
* `web3dart` — Komunikasi RPC, pembacaan fungsi *view*, dan penandatanganan transaksi ke jaringan Ethereum.
* `http` — Klien HTTP untuk koneksi ke penyedia node RPC (Infura Sepolia).
* `flutter_dotenv` — Pengelolaan variabel lingkungan sensitif secara lokal.

---

## Cara Menjalankan Proyek Secara Lokal

1. Clone repositori ini:
   ```bash
   git clone [https://github.com/zulfianaftr/logbook_blockchain.git](https://github.com/zulfianaftr/logbook_blockchain.git)
   cd logbook_blockchain