import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyCities = 'saved_cities';

  // 1. kayıtlı şehirleri getir vetemizle
  Future<List<String>> getCities() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_keyCities) ?? [];

    // listeyi al, .toSet() ile kopyaları yok et, tekrar listeye çevir
    final List<String> cleanList = rawList.toSet().toList();

    // temizlenmiş listeyi tekrar hafızaya yaz ki bidaha aynı şehirler çıkmasın
    if (rawList.length != cleanList.length) {
      await prefs.setStringList(_keyCities, cleanList);
    }

    return cleanList;
  }

  // 2. yeni Şehir Ekle
  Future<void> addCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cities = prefs.getStringList(_keyCities) ?? [];

    // eğer listede zaten varsa EKLEME!!!
    if (!cities.contains(cityName)) {
      cities.add(cityName);
      await prefs.setStringList(_keyCities, cities);
    }
  }

  // 3. şehir sil
  Future<void> removeCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cities = prefs.getStringList(_keyCities) ?? [];
    cities.remove(cityName);
    await prefs.setStringList(_keyCities, cities);
  }
}
