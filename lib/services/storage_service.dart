import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  //telefonun hafızasında kaydedilecek veriler için bir anahtar tanımlıyorum
  static const String _keyCities = 'saved_cities';

  // 1)kayotlı şehirleri gösterme kısmı
  Future<List<String>> getCities() async {
    final prefs = await SharedPreferences.getInstance();
    // Eğer hiç kayıt yoksa boş liste döndür varsa kayıtlı şehirleri döndür
    return prefs.getStringList(_keyCities) ?? [];
  }

  // 2)Yeni şehir ekleme kısmı
  Future<void> addCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();

    // önce mevcut listeyi al
    List<String> cities = prefs.getStringList(_keyCities) ?? [];

    // şehir zaten listede yoksa ekle
    if (!cities.contains(cityName)) {
      cities.add(cityName);
      //gncel listeyi hafızaya yaz
      await prefs.setStringList(_keyCities, cities);
    }
  }

  // 3) şehir silme kısmı
  Future<void> removeCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> cities = prefs.getStringList(_keyCities) ?? [];

    // şehir silme
    cities.remove(cityName);

    //yeni listeyi hafızaya yaz
    await prefs.setStringList(_keyCities, cities);
  }
}
