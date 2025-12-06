import 'package:flutter/material.dart';
import 'package:peta_randusari/screen/maps_randusari_screen.dart';
import 'package:peta_randusari/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'services/supabase_service.dart';
import 'screens/maps_randusari_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedTahun;
  String? _selectedAgregat;
  List<Map<String, dynamic>> _tahunList = [];
  List<Map<String, dynamic>> _agregatList = [];
  List<Map<String, dynamic>> _dataPenduduk = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final service = Provider.of<SupabaseService>(context, listen: false);
      
      // Load tahun options
      final tahunData = await service.getTahunOptions();
      
      // Load agregat options
      final agregatData = await service.getAgregatOptions();
      
      if (mounted) {
        setState(() {
          _tahunList = tahunData;
          _agregatList = agregatData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadDataPenduduk() async {
    if (_selectedTahun == null || _selectedAgregat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih tahun dan jenis agregat terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final service = Provider.of<SupabaseService>(context, listen: false);
      final data = await service.getDataPenduduk(
        tahun: _selectedTahun,
        jenisAgregat: _selectedAgregat,
      );

      if (mounted) {
        setState(() {
          _dataPenduduk = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data penduduk: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDataCard() {
    if (_dataPenduduk.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 60,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'Data tidak tersedia',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Pilih tahun dan jenis agregat untuk menampilkan data',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hasil Data Penduduk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 12),
            ..._dataPenduduk.map((data) {
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color.fromARGB(255, 55, 51, 51)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data['kategori']?.toString() ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${data['jumlah']?.toString() ?? '0'} orang',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.map, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapsRandusariScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'logout') {
                try {
                  await Provider.of<SupabaseService>(context, listen: false).signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout gagal: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading && _tahunList.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue[900],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_circle,
                                size: 40,
                                color: Colors.blue[900],
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selamat Datang',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      'User Kelurahan Randusari',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Gunakan filter di bawah untuk melihat data penduduk berdasarkan tahun dan jenis agregat',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Filter Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Filter Data Penduduk',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // Tahun Dropdown
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color.fromARGB(255, 55, 51, 51)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<int>(
                                value: _selectedTahun,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTahun = value;
                                  });
                                },
                                hint: Text(
                                  'Pilih Tahun',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                items: _tahunList.map((tahun) {
                                  return DropdownMenuItem<int>(
                                    value: tahun['tahun'],
                                    child: Text(
                                      'Tahun ${tahun['tahun']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 16, right: 8),
                                ),
                                menuItemStyleData: MenuItemStyleData(
                                  height: 40,
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  iconSize: 24,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Agregat Dropdown
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color.fromARGB(255, 55, 51, 51)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                value: _selectedAgregat,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAgregat = value;
                                  });
                                },
                                hint: Text(
                                  'Pilih Jenis Agregat',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                items: _agregatList.map((agregat) {
                                  return DropdownMenuItem<String>(
                                    value: agregat['kode'],
                                    child: Text(
                                      agregat['nama'],
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 16, right: 8),
                                ),
                                menuItemStyleData: MenuItemStyleData(
                                  height: 40,
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  iconSize: 24,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Search Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _loadDataPenduduk,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'TAMPILKAN DATA',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Data Card
                  _buildDataCard(),
                  
                  SizedBox(height: 20),
                  
                  // Info Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Sistem',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: 12),
                          
                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                icon: Icons.data_usage,
                                label: 'Data Tersedia',
                                value: '${_agregatList.length} jenis',
                                color: Colors.blue,
                              ),
                              _buildStatItem(
                                icon: Icons.calendar_today,
                                label: 'Tahun Data',
                                value: '${_tahunList.length} tahun',
                                color: Colors.green,
                              ),
                              _buildStatItem(
                                icon: Icons.people,
                                label: 'Total Penduduk',
                                value: '15,234 jiwa',
                                color: Colors.orange,
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Map Button
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapsRandusariScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                foregroundColor: Colors.blue[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.blue[200]!),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.map),
                                  SizedBox(width: 8),
                                  Text('Lihat Peta Wilayah'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}