import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import '../config/contract_abi.dart'; 

class Web3Service extends ChangeNotifier {
  late Web3Client _client;
  late EthPrivateKey _credentials;
  late DeployedContract _contract;
  
  // Variabel untuk menyimpan fungsi-fungsi kontrak
  late ContractFunction _jumlahPinjaman;
  late ContractFunction _ambilPinjaman;
  late ContractFunction _pinjamAlat;
  late ContractFunction _kembalikanAlat;

  List> logbookList = [];
  bool isLoading = true;

  Web3Service() {
    initWeb3();
  }

  Future<void> initWeb3() async {
    // 1. Ambil variabel dari .env
    final rpcUrl = dotenv.env['RPC_URL']!;
    final privateKey = dotenv.env['PRIVATE_KEY']!;
    final contractAddress = dotenv.env['CONTRACT_ADDRESS']!;
    final chainId = int.parse(dotenv.env['CHAIN_ID']!);

    // 2. Hubungkan ke jaringan Sepolia lewat Infura
    _client = Web3Client(rpcUrl, http.Client());
    _credentials = EthPrivateKey.fromHex(privateKey);

    // 3. Daftarkan Smart Contract menggunakan ABI dan Address
    _contract = DeployedContract(
      ContractAbi.fromJson(logbookAbi, 'LogbookLab'),
      EthereumAddress.fromHex(contractAddress),
    );

    // 4. Daftarkan fungsi-fungsi kontrak
    _jumlahPinjaman = _contract.function('jumlahPinjaman');
    _ambilPinjaman = _contract.function('ambilPinjaman');
    _pinjamAlat = _contract.function('pinjamAlat');
    _kembalikanAlat = _contract.function('kembalikanAlat');

    // 5. Muat daftar peminjaman saat aplikasi pertama kali dibuka
    await fetchLogbook();
  }

  // /// FUNGSI 1: MEMBACA DATA DARI KONTRAK (VIEW) ///
  Future<void> fetchLogbook() async {
    isLoading = true;
    notifyListeners();
    logbookList.clear();

    try {
      // Panggil fungsi 'jumlahPinjaman'
      final countResult = await _client.call(
        contract: _contract,
        function: _jumlahPinjaman,
        params: [],
      );
      int totalData = countResult[0].toInt();

      // Looping untuk memanggil 'ambilPinjaman' berdasarkan ID
      for (int i = 0; i < totalData; i++) {
        final itemResult = await _client.call(
          contract: _contract,
          function: _ambilPinjaman,
          params: [BigInt.from(i)],
        );
        
        logbookList.add({
          'id': i,
          'namaAlat': itemResult[0].toString(),
          'sudahDikembalikan': itemResult[1] as bool,
          'waktuPinjam': itemResult[2].toInt(),
          'peminjam': itemResult[3].toString(),
        });
      }
    } catch (e) {
      print("Gagal mengambil data: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // /// FUNGSI 2: MENULIS DATA BARU (TRANSACTION) ///
  Future<void> pinjamAlat(String namaAlat) async {
    isLoading = true;
    notifyListeners();

    try {
      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _pinjamAlat,
          parameters: [namaAlat],
        ),
        chainId: int.parse(dotenv.env['CHAIN_ID']!),
      );
      
      // Tunggu sebentar agar blok ditambang, lalu muat ulang data
      await Future.delayed(const Duration(seconds: 3));
      await fetchLogbook();
    } catch (e) {
      print("Gagal meminjam alat: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  // /// FUNGSI 3: MENGUBAH STATUS (TRANSACTION) ///
  Future<void> kembalikanAlat(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _kembalikanAlat,
          parameters: [BigInt.from(id)],
        ),
        chainId: int.parse(dotenv.env['CHAIN_ID']!),
      );

      // Tunggu sebentar agar blok ditambang, lalu muat ulang data
      await Future.delayed(const Duration(seconds: 3));
      await fetchLogbook();
    } catch (e) {
      print("Gagal mengembalikan alat: $e");
      isLoading = false;
      notifyListeners();
    }
  }
}