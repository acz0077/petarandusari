import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VillageMapsScreen extends StatefulWidget {
  const VillageMapsScreen({super.key});

  @override
  State<VillageMapsScreen> createState() => _VillageMapsScreenState();
}

class _VillageMapsScreenState extends State<VillageMapsScreen> {
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadImageUrl();
  }

  Future<void> _loadImageUrl() async {
    try {
      final supabase = Supabase.instance.client;
      // Perbaikan: Gunakan path file relatif di dalam bucket, bukan URL lengkap
      // Asumsikan file bernama 'petarandusari.png' (sesuai kode asli Anda; jika berbeda, ganti sesuai nama file yang benar)
      _imageUrl = supabase.storage
          .from('maps')
          .getPublicUrl('petarandusari1.png');
      setState(() {});
    } catch (e) {
      print('Error getting image URL: $e'); // Log untuk debug
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading image URL: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('Peta - Randusari'),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Peta'),
                  content: const Text('Ini adalah peta desa Randusari.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Image(image: AssetImage("assets/images/petarandusari1.png")),
    );
    return scaffold;
  }
}

// Kode DropdownSupabaseExample tetap sama, karena tidak terkait dengan masalah gambar
class DropdownSupabaseExample extends StatefulWidget {
  const DropdownSupabaseExample({super.key});

  @override
  State<DropdownSupabaseExample> createState() =>
      _DropdownSupabaseExampleState();
}

class _DropdownSupabaseExampleState extends State<DropdownSupabaseExample> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _kategoriList = [];
  String? _selectedKategori;

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  Future<void> _fetchKategori() async {
    try {
      final response = await supabase.from('kategori').select();

      setState(() {
        _kategoriList = response;
        // Opsional: set nilai awal dari dropdown
        // _selectedKategori = _kategoriList.isNotEmpty ? _kategoriList.first['nama_kategori'] : null;
      });
    } catch (error) {
      print('Error mengambil kategori: $error');
    }
  }

  // Fungsi untuk memperbarui data di Supabase setelah dropdown diubah
  Future<void> _updateItem(int itemId, String newKategoriId) async {
    try {
      await supabase
          .from('items')
          .update({'kategori_id': newKategoriId})
          .eq('id', itemId);
      print('Item berhasil diubah!');
    } catch (error) {
      print('Error memperbarui item: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dropdown Supabase')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_kategoriList.isEmpty)
                const CircularProgressIndicator()
              else
                DropdownButtonFormField<String>(
                  value: _selectedKategori,
                  hint: const Text('Pilih Kategori'),
                  items: _kategoriList.map((kategori) {
                    return DropdownMenuItem<String>(
                      value: kategori['id']
                          .toString(), // Gunakan ID sebagai value
                      child: Text(kategori['nama_kategori']),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedKategori = newValue;
                    });
                    // Panggil fungsi untuk mengubah data di Supabase di sini
                    // _updateItem(itemId, newValue!);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Kategori',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
