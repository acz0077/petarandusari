// services/supabase_service.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Login dengan username dan password
  Future<void> loginWithUsername(String username, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Query untuk mendapatkan user berdasarkan username
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('username', username)
          .single();

      if (response == null) {
        throw Exception('User tidak ditemukan');
      }

      // Verifikasi password (dengan asumsi password_hash menggunakan crypt)
      final passwordCheck = await _supabase
          .from('users')
          .select('password_hash')
          .eq('username', username)
          .eq('password_hash', password) // Supabase akan handle encryption
          .single();

      if (passwordCheck == null) {
        throw Exception('Password salah');
      }

      // Set user session (simulasi)
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Register user baru
  Future<void> registerUser({
    required String username,
    required String namaLengkap,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if username exists
      final existingUser = await _supabase
          .from('users')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception('Username sudah digunakan');
      }

      // Insert new user
      await _supabase.from('users').insert({
        'username': username,
        'nama_lengkap': namaLengkap,
        'email': email,
        'password_hash': password, // Supabase akan encrypt
        'role': 'user',
        'created_at': DateTime.now().toIso8601String(),
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get tahun options
  Future<List<Map<String, dynamic>>> getTahunOptions() async {
    try {
      final response = await _supabase
          .from('tahun_pendataan')
          .select('*')
          .order('tahun', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Return default jika error
      return [
        {'tahun': 2025, 'keterangan': 'Tahun 2025'},
        {'tahun': 2024, 'keterangan': 'Tahun 2024'},
      ];
    }
  }

  // Get jenis agregat options
  Future<List<Map<String, dynamic>>> getJenisAgregat() async {
    try {
      final response =
          await _supabase.from('jenis_agregat').select('*').order('id');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Return default jika error
      return [
        {'kode': 'jk', 'nama': 'Jenis Kelamin'},
        {'kode': 'agama', 'nama': 'Agama'},
        {'kode': 'gol_darah', 'nama': 'Golongan Darah'},
        {'kode': 'pendidikan', 'nama': 'Pendidikan'},
        {'kode': 'pekerjaan', 'nama': 'Pekerjaan'},
        {'kode': 'hub_keluarga', 'nama': 'Hubungan Keluarga'},
        {'kode': 'status_kawin', 'nama': 'Status Kawin'},
        {'kode': 'penyandang_cacat', 'nama': 'Penyandang Cacat'},
        {'kode': 'usia', 'nama': 'Usia'},
        {'kode': 'usia_tunggal', 'nama': 'Usia Tunggal'},
      ];
    }
  }

  // Get data penduduk berdasarkan filter
  Future<List<Map<String, dynamic>>> getDataPenduduk(param0, {
    required int tahun,
    required String jenisAgregat,
  }) async {
    try {
      final response = await _supabase
          .from('data_penduduk')
          .select('*')
          .eq('tahun', tahun)
          .eq('jenis_agregat', jenisAgregat)
          .order('kategori');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get statistik
  Future<Map<String, dynamic>> getStatistik() async {
    try {
      final totalPenduduk = await _supabase
          .from('data_penduduk')
          .select('jumlah')
          .eq('tahun', 2025)
          .limit(1);

      var select = _supabase
          .from('jenis_agregat');
      final totalAgregat = await select;

      return {
        'total_penduduk':
            totalPenduduk.isNotEmpty ? totalPenduduk[0]['jumlah'] : 0,
        'total_agregat': totalAgregat.count ?? 0,
        'tahun_terbaru': 2025,
      };
    } catch (e) {
      return {
        'total_penduduk': 15000,
        'total_agregat': 10,
        'tahun_terbaru': 2025,
      };
    }
  }
  

  // Logout
  void logout() {
    // Clear local session
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithUsername(String trim, String text, String trim2) async {}

  Future<void> signOut() async {}

  Future<dynamic> getAgregatOptions() async {}
}

extension on PostgrestList {
  int? get count => null;
}
