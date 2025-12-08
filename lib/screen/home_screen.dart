import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'maps_randusari_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedYear;
  String? _selectedAgregat;
  List<int> _years = [];
  List<Map<String, dynamic>> _agregatList = [];
  List<Map<String, dynamic>> _populationData = [];
  bool _isLoading = true;
  int _currentTab = 0; // 0 = Data Penduduk, 1 = Peta Kelurahan

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadYears(), _loadAgregat()]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadYears() async {
    final response = await Supabase.instance.client
        .from('tahun_pendataan')
        .select('tahun')
        .order('tahun', ascending: false);

    setState(() {
      _years = response.map<int>((item) => item['tahun'] as int).toList();
      if (_years.isNotEmpty && _selectedYear == null) {
        _selectedYear = _years.first;
      }
    });
  }

  Future<void> _loadAgregat() async {
    final response = await Supabase.instance.client
        .from('jenis_agregat')
        .select('kode, nama, icon, warna')
        .order('urutan');

    setState(() {
      _agregatList = List<Map<String, dynamic>>.from(response);
      if (_agregatList.isNotEmpty && _selectedAgregat == null) {
        _selectedAgregat = _agregatList.first['kode'];
      }
    });
  }

  Future<void> _loadPopulationData() async {
    if (_selectedYear == null || _selectedAgregat == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('data_penduduk')
          .select()
          .eq('tahun', _selectedYear as Object)
          .eq('jenis_agregat', _selectedAgregat as Object)
          .order('kategori');

      setState(() {
        _populationData = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelurahan Randusari'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.blue[800],
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _currentTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _currentTab == 0
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.data_usage,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Data Penduduk',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: _currentTab == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _currentTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _currentTab == 1
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Peta Kelurahan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: _currentTab == 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.userData['nama_lengkap'] ?? 'User'),
              accountEmail: Text(widget.userData['email'] ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.userData['nama_lengkap']?.substring(0, 1) ?? 'U',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Beranda'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading && _currentTab == 0
          ? const Center(child: CircularProgressIndicator())
          : _currentTab == 0
          ? _buildDataPendudukTab()
          : _buildPetaKelurahanTab(),
    );
  }

  Widget _buildDataPendudukTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.filter_list, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Filter Data',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 65,
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedYear,
                            decoration: InputDecoration(
                              labelText: 'Tahun',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.calendar_today),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            isExpanded: true,
                            items: _years.map((year) {
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text(
                                  'Tahun $year',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedYear = value);
                              _loadPopulationData();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedAgregat,
                            decoration: InputDecoration(
                              labelText: 'Jenis Agregat',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.category),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            isExpanded: true,
                            items: _agregatList.map((agregat) {
                              return DropdownMenuItem<String>(
                                value: agregat['kode'],
                                child: Row(
                                  children: [
                                    Icon(
                                      _getIcon(agregat['icon']),
                                      size: 18,
                                      color: Color(
                                        int.parse(
                                              agregat['warna'].substring(1, 7),
                                              radix: 16,
                                            ) +
                                            0xFF000000,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        agregat['nama'],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedAgregat = value);
                              _loadPopulationData();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPopulationData,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh),
                        SizedBox(width: 8),
                        Text('Tampilkan Data'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: _populationData.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.data_usage, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Pilih filter dan tampilkan data',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _populationData.length,
                  itemBuilder: (context, index) {
                    final item = _populationData[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[50],
                          child: Text(
                            item['jumlah'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        title: Text(item['kategori']),
                        subtitle: Text('Persentase: ${item['persentase']}%'),
                        trailing: Chip(
                          label: Text('${item['persentase']}%'),
                          backgroundColor: _getPercentageColor(
                            item['persentase'],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPetaKelurahanTab() {
    return MapsRandusariScreen();
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'people':
        return Icons.people;
      case 'temple_buddhist':
        return Icons.temple_buddhist;
      case 'bloodtype':
        return Icons.bloodtype;
      case 'school':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'favorite':
        return Icons.favorite;
      case 'accessible':
        return Icons.accessible;
      case 'calendar_today':
        return Icons.calendar_today;
      default:
        return Icons.person;
    }
  }

  Color _getPercentageColor(double percentage) {
    if (percentage > 50) return Colors.green[100]!;
    if (percentage > 25) return Colors.blue[100]!;
    return Colors.orange[100]!;
  }
}
