import 'package:flutter_dotenv/flutter_dotenv.dart';

class BlockchainConfig {
  // Mengambil data sensitif dari file .env lokal agar aman[cite: 5, 6]
  static String get rpcUrl => dotenv.env['RPC_URL'] ?? '';
  static String get privateKey => dotenv.env['PRIVATE_KEY'] ?? '';
  static String get contractAddress => dotenv.env['CONTRACT_ADDRESS'] ?? '';
  static int get chainId => int.tryParse(dotenv.env['CHAIN_ID'] ?? '11155111') ?? 11155111;
}