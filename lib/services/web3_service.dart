import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart' as web3;
import 'package:wallet/wallet.dart' as wallet;
import '../config/contract_abi.dart'; 

class Web3Service extends ChangeNotifier {
  late web3.Web3Client _client;
  late web3.EthPrivateKey _credentials;
  late web3.DeployedContract _contract;
  
  late web3.ContractFunction _jumlahPinjaman;
  late web3.ContractFunction _ambilPinjaman;
  late web3.ContractFunction _pinjamAlat;
  late web3.ContractFunction _kembalikanAlat;

  List<dynamic> logbookList = [];
  bool isLoading = true;

  Web3Service() {
    initWeb3();
  }

  Future<void> initWeb3() async {
    try {
      final rpcUrl = 'https://sepolia.infura.io/v3/5e4f22a26977484fbe0de3916423b32f';
      final privateKey = '1a9e86d782fd6f08ed53b8e74659b9695eff7b93d7c7ff44b274af23a5e37f09';
      final contractAddress = '0x2A23D5BfD63f6Ed04AFB56407c38177E6A44010e';

      _client = web3.Web3Client(rpcUrl, http.Client());
      _credentials = web3.EthPrivateKey.fromHex(privateKey);

      _contract = web3.DeployedContract(
        web3.ContractAbi.fromJson(logbookAbi, 'LogbookLab'),
        wallet.EthereumAddress.fromHex(contractAddress),
      );

      _jumlahPinjaman = _contract.function('jumlahPinjaman');
      _ambilPinjaman = _contract.function('ambilPinjaman');
      _pinjamAlat = _contract.function('pinjamAlat');
      _kembalikanAlat = _contract.function('kembalikanAlat');

      await fetchLogbook();
    } catch (e) {
      print("Gagal inisialisasi Web3: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLogbook() async {
    isLoading = true;
    notifyListeners();
    logbookList.clear();

    try {
      final countResult = await _client.call(
        contract: _contract,
        function: _jumlahPinjaman,
        params: [],
      );
      int totalData = (countResult[0] as BigInt).toInt();

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
          'waktuPinjam': (itemResult[2] as BigInt).toInt(),
          'peminjam': itemResult[3].toString(),
        });
      }
    } catch (e) {
      print("Gagal mengambil data kontrak: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> pinjamAlat(String namaAlat) async {
    isLoading = true;
    notifyListeners();

    try {
      await _client.sendTransaction(
        _credentials,
        web3.Transaction.callContract(
          contract: _contract,
          function: _pinjamAlat,
          parameters: [namaAlat],
        ),
        chainId: 11155111,
      );
      
      await Future.delayed(const Duration(seconds: 5));
      await fetchLogbook();
    } catch (e) {
      print("Gagal meminjam alat: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> kembalikanAlat(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      await _client.sendTransaction(
        _credentials,
        web3.Transaction.callContract(
          contract: _contract,
          function: _kembalikanAlat,
          parameters: [BigInt.from(id)],
        ),
        chainId: 11155111,
      );

      await Future.delayed(const Duration(seconds: 5));
      await fetchLogbook();
    } catch (e) {
      print("Gagal mengembalikan alat: $e");
      isLoading = false;
      notifyListeners();
    }
  }
}