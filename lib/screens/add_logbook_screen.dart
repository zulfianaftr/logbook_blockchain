import 'package:flutter/material.dart';

class AddLogbookScreen extends StatefulWidget {
  final Function(String namaAlat, String peminjam) onTambahData;

  const AddLogbookScreen({super.key, required this.onTambahData});

  @override
  State<AddLogbookScreen> createState() => _AddLogbookScreenState();
}

class _AddLogbookScreenState extends State<AddLogbookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaAlatController = TextEditingController();
  final _peminjamController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _namaAlatController.dispose();
    _peminjamController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.onTambahData(
        _namaAlatController.text.trim(),
        _peminjamController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinjam Alat Lab IoT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaAlatController,
                decoration: const InputDecoration(
                  labelText: 'Nama Alat IoT',
                  hintText: 'Contoh: ESP32 DevKit V1 / Sensor DHT22',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Nama alat wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _peminjamController,
                decoration: const InputDecoration(
                  labelText: 'Nama / Kode Peminjam',
                  hintText: 'Contoh: Kelompok 3 / Mahasiswa A',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Peminjam wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitForm,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSubmitting ? 'Mengirim Transaksi...' : 'Catat Peminjaman ke Blockchain'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}