import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClient {
  static final supabase = Supabase.instance.client;
  
  static Future<Map<String, dynamic>?> getUser(String username, String password) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('username', username)
          .eq('password_hash', password)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }
  
  static Future<List<Map<String, dynamic>>> getPopulationData(int tahun, String jenisAgregat) async {
    final response = await supabase
        .from('data_penduduk')
        .select()
        .eq('tahun', tahun)
        .eq('jenis_agregat', jenisAgregat)
        .order('kategori');
    
    return List<Map<String, dynamic>>.from(response);
  }
}